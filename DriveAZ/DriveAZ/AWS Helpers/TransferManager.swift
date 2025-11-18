//
//  TransferManager.swift
//  DriveAZ
//
//  Created by Ben on 1/31/23.
//

import Foundation

class TransferManager: ObservableObject {
    static let sharedInstance = TransferManager()

    private init() {
        print("TransferManager init")
    }
}
