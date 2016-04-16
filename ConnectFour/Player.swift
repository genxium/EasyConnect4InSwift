import UIKit

enum Chip : Int {
    case None = 0
    case Red
    case Black
}

class Player {
    
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
    var opponent: Player! {
        get {
            switch self.chip {
            case .Red:
                return Player.blackPlayer()
            case .Black:
                return Player.redPlayer()
            default:
                return nil
            }
            
        }
    }
    
    // MARK: methods
    required init(chip: Chip) {
        self.chip = chip
    }
    
    class func redPlayer() -> Player {
        return self.playerForChip(.Red)!
    }

    class func blackPlayer() -> Player {
        return self.playerForChip(.Black)!
    }

    class func allPlayers() -> [Player] {
        var allPlayers: [Player]? = nil
        if allPlayers == nil {
            allPlayers = [Player(chip: .Red), Player(chip: .Black)]
        }
        return allPlayers!
    }

    class func playerForChip(chip: Chip) -> Player? {
        if chip == .None {
            return nil
        }
        // Chip enum is 0/1/2, array is 0/1.
        return self.allPlayers()[chip.rawValue - 1]
    }

    func debugDescription() -> String {
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