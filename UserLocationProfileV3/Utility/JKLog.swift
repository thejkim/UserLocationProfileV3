//
//  JKLog.swift
//  WSMInventory
//
//  Created by Jinho Kang on 5/24/22.
//

import Foundation

class JKLog {
    static func log(message: String, for function: String = #function, at line: Int = #line) {
        print("[\(function):\(line)] \(message)")
    }
}
