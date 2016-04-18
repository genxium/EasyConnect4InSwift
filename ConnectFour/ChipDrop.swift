//
//  ChipDrop.swift
//  ConnectFour
//
//  Created by Wing Lo on 4/18/16.
//  Copyright © 2016 Wing Lo. All rights reserved.
//

import GameplayKit

@objc(ChipDrop)
class ChipDrop: NSObject, GKGameModelUpdate {
    var targetCol: Int?
    
    required override init() {
        super.init()
    }
    
    convenience init(aCol: Int) {
        self.init()
        targetCol = aCol
    }
    
    // MARK: GKGameModelUpdate
    var value: Int = 0
}