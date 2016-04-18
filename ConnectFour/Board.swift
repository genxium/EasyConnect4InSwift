import GameplayKit

@objc(Board)
class Board: NSObject {
    /*
    // TODO: not used yet
    enum State: Int {
        case IDLE = 0
        case PENDING_RESET
    }
     */
    
    // MARK: properties
    var INVALID_ROW = (-1)
    
    var countsToWin: Int!
    var nCols: Int!
    var nRows: Int!
    var chipList: [Chip]!
    var currentPlayer: Player!
//    var state: State
    
    // MARK: methods
    convenience init(aCountsToWin: Int, aNCols: Int, aNRows: Int) {
        self.init()
        countsToWin = aCountsToWin
        nCols = aNCols
        nRows = aNRows
        
        // The properties below should be overwritten in `copyWithZone` and `setGameModel`
        currentPlayer = GamePlayerSource.playerForChip(.Red)
        chipList = [Chip](count: nCols*nRows, repeatedValue: .None)
        //        state = State.IDLE
    }

    func chipAt(column: Int, row: Int) -> Chip {
        return chipList[row + column * nRows]
    }

    func canDropAtColumn(column: Int) -> Bool {
        return nextEmptySlotAtColumn(column) != INVALID_ROW
    }
    
    func setChip(chip: Chip, atColumn column: Int, row: Int) {
        self.chipList[row + column * nRows] = chip
    }

    func addChip(chip: Chip, atColumn column: Int) -> Bool {
        let row = nextEmptySlotAtColumn(column)
        guard row != INVALID_ROW else {
            return false
        }
        setChip(chip, atColumn: column, row: row)
        return true
    }

    func runCountsForPlayer(player: Player) -> [Int] {
        let chip = player.chip
        var counts = [Int]()
        
        // Detect horizontal runs.
        for row in 0..<nRows {
            var runCount = 0
            for column in 0..<nCols {
                if chipAt(column, row: row) == chip {
                    runCount += 1
                } else {
                    // Run isn't continuing, note it and reset counter.
                    if runCount > 0 {
                        counts.append(runCount)
                    }
                    runCount = 0
                }
            }
            if runCount > 0 {
                // Note the run if still on one at the end of the row.
                counts.append(runCount)
            }
        }
        
        // Detect vertical runs.
        for column in 0 ..< nCols {
            var runCount = 0
            for row in 0 ..< nRows {
                if self.chipAt(column, row: row) == chip {
                    runCount += 1
                }
                else {
                    // Run isn't continuing, note it and reset counter.
                    if runCount > 0 {
                        counts.append(runCount)
                    }
                    runCount = 0
                }
            }
            if runCount > 0 {
                // Note the run if still on one at the end of the column.
                counts.append(runCount)
            }
        }
        
        // Detect diagonal (northeast) runs
        for startColumn in -nRows ..< nCols {
                // Start from off the edge of the board to catch all the diagonal lines through it.
            var runCount = 0
            for offset in 0 ..< nRows {
                let column = startColumn + offset
                if column < 0 || column >= nCols {
                    // Ignore area off the board.
                    continue
                }
                if self.chipAt(column, row: offset) == chip {
                    runCount += 1
                }
                else {
                    // Run isn't continuing, note it and reset counter.
                    if runCount > 0 {
                        counts.append(runCount)
                    }
                    runCount = 0
                }
            }
            if runCount > 0 {
                counts.append(runCount)
            }
        }
        
        // Detect diagonal (northwest) runs
        for startColumn in 0 ..< (nCols + nRows) {
                // Iterate through areas off the edge of the board to catch all the diagonal lines through it.
            var runCount = 0
            for offset in 0 ..< nRows {
                let column = startColumn - offset
                if column < 0 || column >= nCols {
                    // Ignore area off the board.
                    continue
                }
                if chipAt(column, row: offset) == chip {
                    runCount += 1
                }
                else {
                    // Run isn't continuing, note it and reset counter.
                    if runCount > 0 {
                        counts.append(runCount)
                    }
                    runCount = 0
                }
            }
            if runCount > 0 {
                // Note the run if still on one at the end of the line.
                counts.append(runCount)
            }
        }
        return counts
    }
    
    func isFull() -> Bool {
        for column in 0 ..< nCols {
            if canDropAtColumn(column) {
                return false
            }
        }
        return true
    }
    
    func nextEmptySlotAtColumn(column: Int) -> Int {
        for row in 0 ..< nRows {
            if chipAt(column, row: row) == .None {
                return row
            }
        }
        return INVALID_ROW
    }

    // MARK: debug description
    override var debugDescription: String {
        var output = ""
        for row in (nRows - 1).stride(through: 0, by: -1) {
            for column in 0..<nCols {
                let chip: Chip = self.chipAt(column, row: row)
                let playerDescription: String = GamePlayerSource.playerForChip(chip).debugDescription ?? " "
                output += (playerDescription)
                let nodeDescription = (column + 1 < nCols) ? "." : ""
                output += nodeDescription
            }
            let toAppend = (row > 0) ? "\n" : ""
            output += toAppend
        }
        return output
    }
}

// MARK: GKGameModel
extension Board: GKGameModel {
    // MARK: NSCopying
    func copyWithZone(zone: NSZone) -> AnyObject {
        let copy = Board()
        copy.setGameModel(self)
        return copy
    }
    
    var activePlayer: GKGameModelPlayer? {
        return currentPlayer
    }
    
    var players: [GKGameModelPlayer]? {
        return GamePlayerSource.allPlayers
    }
    
    func setGameModel(gameModel: GKGameModel) {
        // blind copy implementation
        let aBoard = gameModel as! Board
        INVALID_ROW = aBoard.INVALID_ROW
        countsToWin = aBoard.countsToWin
        nCols = aBoard.nCols
        nRows = aBoard.nRows
        chipList = aBoard.chipList
        currentPlayer = aBoard.currentPlayer // This assignment is intentional because the pointers/RAM-addr to `currentPlayer` and `opponent` are supposed to be the same across all `GKGameModel` copies
        //        state = aBoard.state
    }
    
    func gameModelUpdatesForPlayer(player: GKGameModelPlayer) -> [GKGameModelUpdate]? {
        
        var updates: [ChipDrop] = []
        updates.reserveCapacity(nCols)
        for col in 0 ..< nCols {
            if canDropAtColumn(col) {
                // TODO: apply lazy-init of ChipDrop for same column values
                updates.append(ChipDrop(aCol: col))
            }
        }
        
        return updates
    }
    
    func applyGameModelUpdate(gameModelUpdate: GKGameModelUpdate) {
        let drop = gameModelUpdate as! ChipDrop
        addChip(currentPlayer.chip, atColumn: drop.targetCol!)
        currentPlayer = GamePlayerSource.opponent(currentPlayer)
    }
    
    func isWinForPlayer(player: GKGameModelPlayer) -> Bool {
        let runCounts = runCountsForPlayer(player as! Player)
        guard let longestRun = runCounts.maxElement() else {
            return false
        }
        return longestRun >= countsToWin
    }
    
    func isLossForPlayer(player: GKGameModelPlayer) -> Bool {
        return !isWinForPlayer(player)
    }
    
    func scoreForPlayer(player: GKGameModelPlayer) -> Int {
        let playerInstance = player as! Player
        
        let playerRunCounts = runCountsForPlayer(playerInstance)
        let playerTotal = playerRunCounts.reduce(0, combine: +)
        
        let opponentRunCounts = runCountsForPlayer(GamePlayerSource.opponent(playerInstance))
        let opponentTotal = opponentRunCounts.reduce(0, combine: +)
        
        // Return the sum of player runs minus the sum of opponent runs.
        return playerTotal - opponentTotal
    }
}