class Board {
    /*
    // TODO: not used yet
    enum State: Int {
        case IDLE = 0
        case PENDING_RESET
    }
     */
    
    // MARK: properties
    let INVALID_ROW = (-1)
    
    var countsToWin: Int
    var nCols: Int
    var nRows: Int
    var chipList: [Chip]
    var currentPlayer: Player
//    var state: State 
    
    required init(aCountsToWin: Int, aNCols: Int, aNRows: Int) {
//        state = State.IDLE
        countsToWin = aCountsToWin
        nCols = aNCols
        nRows = aNRows
        currentPlayer = Player.redPlayer()
        chipList = [Chip](count: nCols*nRows, repeatedValue: .None)
    }

    // MARK: methods
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

    func updateChipsFromBoard(otherBoard: Board) {
        chipList = otherBoard.chipList
    }
    
    func isFull() -> Bool {
        for column in 0 ..< nCols {
            if canDropAtColumn(column) {
                return false
            }
        }
        return true
    }
    
    func isWinForPlayer(player: Player) -> Bool {
        let runCounts = runCountsForPlayer(player)
        guard let longestRun = runCounts.maxElement() else {
            return false
        }
        return longestRun >= countsToWin
    }
    
    func isLostForPlayer(player: Player) -> Bool {
        return !isWinForPlayer(player)
    }
    
    /*
    - (BOOL)isWinForPlayer:(AAPLPlayer *)player {
    // Use AAPLBoard's utility method to find all N-in-a-row runs of the player's chip.
    NSArray<NSNumber *> *runCounts = [self runCountsForPlayer:player];
    
    // The player wins if there are any runs of 4 (or more, but that shouldn't happen in a regular game).
    NSNumber *longestRun = [runCounts valueForKeyPath:@"@max.self"];
    return longestRun.integerValue >= AAPLCountToWin;
    }
    
    - (BOOL)isLossForPlayer:(AAPLPlayer *)player {
    // This is a two-player game, so a win for the opponent is a loss for the player.
    return [self isWinForPlayer:player.opponent];
    }
    */

    // MARK: debug information
    func debugDescription() -> String {
        var output = ""
        for row in (nRows - 1).stride(through: 0, by: -1) {
            for column in 0..<nCols {
                let chip: Chip = self.chipAt(column, row: row)
                let playerDescription: String = Player.playerForChip(chip).debugDescription ?? " "
                output += (playerDescription)
                let nodeDescription = (column + 1 < nCols) ? "." : ""
                output += nodeDescription
            }
            let toAppend = (row > 0) ? "\n" : ""
            output += toAppend
        }
        return output
    }

    func nextEmptySlotAtColumn(column: Int) -> Int {
        for row in 0 ..< nRows {
            if chipAt(column, row: row) == .None {
                return row
            }
        }
        return INVALID_ROW
    }
}