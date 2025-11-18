//
//  RuntimeError.swift
//  DriveAZ
//
//  Created by Ben on 2/6/23.
//

import Foundation

struct RuntimeError: Error {
    let message: String

    init(_ message: String) {
        self.message = message
    }

    public var localizedDescription: String {
        return message
    }
}
