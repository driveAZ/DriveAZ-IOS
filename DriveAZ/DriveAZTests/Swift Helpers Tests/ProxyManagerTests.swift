//
//  ProxyManagerTests.swift
//  DriveAZTests
//
//  Created by Ben on 7/29/22.
//

import Foundation
import XCTest
@testable import DriveAZ
import CoreMotion
import CoreMedia
import SmartDeviceLink

class ProxyManagerTests: XCTestCase {
    func testDidConnect() throws {
        ProxyManager.sharedManager.connect()
    }
    func testHandleConnectSuccess() throws {
        ProxyManager.sharedManager.handleConnectSuccess()
    }

    func testCheckConnectResultsSuccess() {
        ProxyManager.sharedManager.checkConnectResults(success: true, error: nil)
    }

    func testCheckConnectResultsError() {
        ProxyManager.sharedManager.checkConnectResults(success: false, error: NSError(domain: "", code: 500))
    }

    func testPrintErrorError() {
        ProxyManager.sharedManager.printErrorWithLocation(
            NSError(domain: "", code: 500),
            calledFrom: "testPrintErrorError"
        )
    }

    func testPrintErrorNoError() {
        ProxyManager.sharedManager.printErrorWithLocation(nil, calledFrom: "testPrintErrorNoError")
    }
    func testManagerDidDisconnect() throws {
        ProxyManager.sharedManager.managerDidDisconnect()
        XCTAssertFalse(ProxyManager.sharedManager.isConnected)
    }
    func testHMILevel() throws {
        XCTAssertNoThrow(ProxyManager.sharedManager.hmiLevel(SDLHMILevel.limited, didChangeToLevel: SDLHMILevel.full))
    }
    func testDidReceiveSystemInfo() throws {
        let info :SDLSystemInfo = SDLSystemInfo()
        XCTAssertTrue(ProxyManager.sharedManager.didReceiveSystemInfo(info))
    }
}
