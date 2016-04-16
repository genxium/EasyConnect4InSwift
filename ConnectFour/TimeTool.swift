//
//  TimeTool.swift
//  ConnectFour
//
//  Created by Wing Lo on 4/16/16.
//  Copyright © 2016 Wing Lo. All rights reserved.
//

import Foundation

func dateToGmtMillis(date: NSDate) -> Int64 {
    return Int64(date.timeIntervalSince1970) * 1000
}

func currentGmtMillis() -> Int64 {
    return dateToGmtMillis(NSDate())
}