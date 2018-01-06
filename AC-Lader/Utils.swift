//
//  Utils.swift
//  AC-Lader
//
//  Created by Bart van Kuik on 06/01/2018.
//  Copyright © 2018 DutchVirtual. All rights reserved.
//

import Foundation

func dlog(_ format: String = "", _ args: [CVarArg] = [], file: String = #file, function: String = #function, line: Int = #line) {
    let filename: String
    if let fn = URL(string:file)?.lastPathComponent.components(separatedBy: ".").first {
        filename = fn
    } else {
        filename = "nil"
    }

    let formattedString = String(format: "\(filename).\(function) line \(line) $ \(format)", arguments: args)
    NSLog(formattedString)
}
