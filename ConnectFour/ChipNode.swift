//
//  ChipNode.swift
//  ConnectFour
//
//  Created by Wing Lo on 4/15/16.
//  Copyright © 2016 Wing Lo. All rights reserved.
//

import UIKit

class ChipNode: CAShapeLayer {
    
    var row: Int!
    var col: Int!
    
    required override init() {
        super.init()
    }
    
    convenience init(aColor: CGColor, aShape: CGPath, aTargetPosition: CGPoint) {
        self.init()
        self.fillColor = aColor
        self.path = aShape // note that there's a difficulty in distingushing names when using UIBezierPath to draw the boundary of a CAShapeLayer
       self.position = aTargetPosition
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
