//
//  GameViewController.swift
//  ConnectFour
//
//  Created by Wing Lo on 4/15/16.
//  Copyright (c) 2016 Wing Lo. All rights reserved.
//

import UIKit
import QuartzCore
import SceneKit
import GameplayKit

class GameViewController: UIViewController {
    
    // MARK: properties
    var blackByAI = true
    
    var countsToWin = 4
    var boardNCols = 7
    var boardNRows = 6
    
    var columnButtonList: [UIButton]!
    var board: Board!
    var nodeList: [ChipNode]!
    var nodeShape: UIBezierPath!
    
    // MARK: methods
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    func takeTurnOrEndGame() {
        // try to end game
        var gameOverTitle: String? = nil
        
        if (self.board.isFull()) {
            gameOverTitle = "Draw!"
        }
        
        if board.isWinForPlayer(board.currentPlayer) {
            gameOverTitle = String(format: "%@ Wins!", self.board.currentPlayer.name)
        }
        
        if let t = gameOverTitle {
            let alert = UIAlertController(title: t, message: nil, preferredStyle: .Alert)
            
            let alertAction = UIAlertAction(title: "Play Again", style: .Default) {
                (act) -> () in
                self.resetBoard()
            }
            
            alert.addAction(alertAction)
            self.presentViewController(alert, animated: true, completion: nil)
            return
        }
        
        // take turn
        self.board.currentPlayer = self.board.currentPlayer.opponent;
        updateNavItems()
    }
    
    func enableColumnButtonListWithCapacityCheck(val: Bool) {
        for singleButton in columnButtonList {
            let col = singleButton.tag;
            singleButton.enabled = (val &&
                board.canDropAtColumn(col))
        }
    }
    
    func updateNavItems() {
        navigationItem.title = String(format:"%@ Turn", board.currentPlayer.name!)
        navigationController!.navigationBar.backgroundColor = board.currentPlayer.color
        
        // TODO: do NOT hardcode the AI side to be always black
        if blackByAI && board.currentPlayer.chip == Chip.Black {
            
            enableColumnButtonListWithCapacityCheck(false) // GUI guarding begins, will be automatically ended by drop(_:, _:)
            
            // spinning begins
            let spinner = UIActivityIndicatorView(activityIndicatorStyle: .Gray)
            spinner.startAnimating()
            
            let barButtonItem = UIBarButtonItem(customView: spinner)
            self.navigationItem.leftBarButtonItem = barButtonItem
            
            // asynchronous AI "thinking" process with time limit
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), {
                // TODO: let AI "think" for 2 seconds
                let secondsToThink = Int64(2) // seconds
                
                let stTime = currentGmtMillis()
                
                // TODO: don't use such dumb traversal, apply GameplayKit strategist
                var colToTakeMove = 0 // just get any valid move at this stage, not yet a strategy
                for col in 0 ..< self.boardNCols {
                    let row = self.board.nextEmptySlotAtColumn(col)
                    guard row != self.board.INVALID_ROW else {
                        continue
                    }
                    colToTakeMove = col
                    break
                }
                
                let edTime = currentGmtMillis()
                let secondsElapsedInThinking = ((edTime - stTime) / Int64(1000))
                
                let delay = UInt64(secondsToThink - secondsElapsedInThinking)
                // apply the move when back to main/UI thread
                let dispatchTimeDelay = dispatch_time(DISPATCH_TIME_NOW, Int64(delay * NSEC_PER_SEC))
                dispatch_after(dispatchTimeDelay, dispatch_get_main_queue(), {
                    self.navigationItem.leftBarButtonItem = nil // spinning ends
                    self.drop(self.board.currentPlayer, atColumn: colToTakeMove)
                })
            })
        }
    }
    
    func updateButton(button: UIButton) {
        let col = button.tag;
        button.enabled = board.canDropAtColumn(col)
        if !button.enabled {
            button.backgroundColor = UIColor.grayColor()
        } else {
            button.backgroundColor = UIColor.whiteColor()
        }
    }
    
    func resetBoard() {
        self.board = Board(aCountsToWin: countsToWin, aNCols: boardNCols, aNRows: boardNRows)
        for button in columnButtonList {
            updateButton(button)
        }
        updateNavItems()
        
        for node in nodeList {
            node.removeFromSuperlayer()
        }
        nodeList.removeAll()
    }
    
    func onColumnButtonClicked(sender: UIButton) {
        let col = sender.tag
        guard drop(board.currentPlayer, atColumn: col) else {
            print("Invalid Column")
            return
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        columnButtonList = [UIButton]()
        board = Board(aCountsToWin: countsToWin, aNCols: boardNCols, aNRows: boardNRows)
        nodeList = [ChipNode]()
        
        // calculate button size with respect to #cols
        // TODO: respect margins
        let buttonW = self.view.bounds.width/CGFloat(boardNCols)
        let buttonH = self.view.bounds.height
        
        let horizontalStart = CGFloat(0)
        let verticalStart = CGFloat(0)

        var horizontalOffset = CGFloat(0)
        // there's no vertical offset for buttons
        
        // determine node shape
        let nodeLength = min(buttonW, buttonH/CGFloat(boardNRows));
        let nodeSquare = CGRectMake(0, 0, nodeLength, nodeLength);
        nodeShape = UIBezierPath(ovalInRect: nodeSquare)
        
        // init buttons as columns
        for col in 0 ..< boardNCols {
            let singleButton = UIButton()
            singleButton.frame = CGRectMake(horizontalStart + horizontalOffset, verticalStart, buttonW, buttonH)// will trigger GUI update at the next renderer cycle
            
            // tag the column index
            singleButton.tag = col
                
            // on click listener
            singleButton.addTarget(self, action: #selector(GameViewController.onColumnButtonClicked(_:)), forControlEvents: .TouchUpInside)
                
            // border for visual effect
            singleButton.layer.borderWidth = 1.0
            singleButton.layer.borderColor = UIColor.grayColor().CGColor
            
            // add to self.view
            self.view.addSubview(singleButton)
            // add to columnButtonLists
            columnButtonList.append(singleButton)
            
            horizontalOffset += buttonW
        }
        
        resetBoard()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
    }
    
    // MARK: drop(_:, _:) may be called either by player-button interaction or AI
    func drop(byPlayer: Player, atColumn: Int) -> Bool {
        let nextRow = board.nextEmptySlotAtColumn(atColumn)
        guard nextRow != board.INVALID_ROW else {
            return false
        }
        
        // create a node
        let node = ChipNode(aColor: byPlayer.color.CGColor, aShape: nodeShape.CGPath, aTargetPosition: positionForNode(atColumn, row: nextRow))
        
        // add the node to the current layer
        self.view.layer.addSublayer(node)
        
        // add it to nodeList
        nodeList.append(node)
        
        // add chip information to board
        board.addChip(board.currentPlayer.chip, atColumn: atColumn)
        for button in columnButtonList {
            updateButton(button)
        }
        
        takeTurnOrEndGame()
        
        // create a translation animator
        let translationAnimator = CABasicAnimation(keyPath: "position.y")
        translationAnimator.fromValue = 0.0 // top of self.view.layer
        translationAnimator.toValue = node.position.y
        translationAnimator.duration = 0.5 // seconds
        translationAnimator.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseIn)
        
        // TODO: GUI guarding for animation
        node.addAnimation(translationAnimator, forKey: nil)
        
        return true
    }
    
    func positionForNode(col: Int, row: Int) -> CGPoint {
        let columnButton = columnButtonList[col]
        let horizontalOffset = CGRectGetMinX(columnButton.frame)
        
        // note that vertical coordinate grows downwards, i.e. y == 0.0 marks the top of the view
        let verticalHeight = CGFloat(row + 1) * nodeShape.bounds.height
        let verticalOffset = columnButton.frame.maxY - verticalHeight
        let pos = CGPointMake(horizontalOffset, verticalOffset)
        return pos
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Release any cached data, images, etc that aren't in use.
    }
}
