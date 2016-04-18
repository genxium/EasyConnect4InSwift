//
//  GameStrategist.swift
//  ConnectFour
//
//  Created by Wing Lo on 4/18/16.
//  Copyright © 2016 Wing Lo. All rights reserved.
//

import Foundation
import GameplayKit

@objc(GameStrategist)
class GameStrategist: GKMinmaxStrategist {
    required init(aGameModel: Board, aMaxLookAheadDepth: Int) {
        super.init()
        self.gameModel = aGameModel
        maxLookAheadDepth = aMaxLookAheadDepth
        randomSource = GKARC4RandomSource()
    }
    
    func bestColumnToDrop(player: Player) -> Int {
        let chipDrop = bestMoveForPlayer(player)
        return (chipDrop as! ChipDrop).targetCol!
    }
}