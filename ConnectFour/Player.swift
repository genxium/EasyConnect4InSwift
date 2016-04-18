import UIKit
import GameplayKit

enum Chip : Int {
    case None = 0
    case Red
    case Black
}

@objc(Player)
class Player: NSObject {
    
    // MARK: properties
    var chip: Chip
    var color: UIColor! {
        get {
            switch self.chip {
            case .Red:
                return UIColor.redColor()
            case .Black:
                return UIColor.blackColor()
            default:
                return nil
            }
        }
    }
    
    var name: String! {
        get {
            switch self.chip {
            case .Red:
                return "Red"
            case .Black:
                return "Black"
            default:
                return nil
            }
            
        }
    }
    
    // MARK: methods
    required init(chip: Chip) {
        
        self.chip = chip
    }
    
    // MARK: debug description
    override var debugDescription: String {
        switch self.chip {
            case .Red:
                return "X"
            case .Black:
                return "O"
            default:
                return " "
        }
    }
}

// MARK: GKGameModelPlayer
extension Player: GKGameModelPlayer {
    var playerId: Int {
        return chip.rawValue
    }
}