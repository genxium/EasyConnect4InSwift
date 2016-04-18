//
//  ChipDrop.swift
//  ConnectFour
//
//  Created by Wing Lo on 4/19/16.
//  Copyright © 2016 Wing Lo. All rights reserved.
//

import GameplayKit

class ChipDrop: NSObject, GKGameModelUpdate {
    var targetCol: Int?
    
    convenience init(aCol: Int) {
        self.init()
        targetCol = aCol
    }
    
    // MARK: GKGameModelUpdate
    var value: Int = 0
}
