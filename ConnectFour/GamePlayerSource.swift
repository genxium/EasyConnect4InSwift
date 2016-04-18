//
//  PlayerSource.swift
//  ConnectFour
//
//  Created by Wing Lo on 4/18/16.
//  Copyright © 2016 Wing Lo. All rights reserved.
//

import Foundation
import GameplayKit

class GamePlayerSource {
    // In the original objective-C sample codes, the `allPlayers` variable is confusingly kept by the `Player` class. 
    // Note that the instances in `allPlayers` are intentionally reused for the strategist
    static let allPlayers: [GKGameModelPlayer] = [Player(chip: .Red), Player(chip: .Black)]
    
    class func opponent(currentPlayer: Player) -> Player! {
        switch currentPlayer.chip {
            case .Red:
                return playerForChip(.Black)
            case .Black:
                return playerForChip(.Red)
            default:
                return nil
        }
    }
    
    class func playerForChip(chip: Chip) -> Player! {
        switch chip {
        case .Red:
            return (allPlayers[chip.rawValue - 1] as! Player)
        case .Black:
            return (allPlayers[chip.rawValue - 1] as! Player)
        default:
            return nil
        }
    }
}