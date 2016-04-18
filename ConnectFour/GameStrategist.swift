//
//  GameStrategist.swift
//  ConnectFour
//
//  Created by Wing Lo on 4/18/16.
//  Copyright © 2016 Wing Lo. All rights reserved.
//

import Foundation
import GameplayKit

class GameStrategist: GKMinmaxStrategist {
    func bestColForPlayer(player: Player) -> Int {
        let chipDrop = bestMoveForPlayer(player) as! ChipDrop
        return chipDrop.targetCol!
    }
    
    convenience init(aGameModel: Board, aDepth: Int) {
        self.init()
        self.gameModel = aGameModel
        self.maxLookAheadDepth = aDepth
        self.randomSource = GKARC4RandomSource()
    }
}