////
////  PSMManagerTests.swift
////  DriveAZTests
////
////  Created by Ben on 3/31/22.
////

import XCTest
@testable import DriveAZ
import CoreLocation

class PSMManagerTests: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

//    func testTimer() throws {
//        XCTAssertEqual(0.1, PSMManager.sharedInstance.timer.timeInterval)
//    }
//
//    func testTimer2() throws {
//        _ = PSMManager.sharedInstance.psm
//        PSMManager.sharedInstance.timer.fire()
//        PSMManager.sharedInstance.updatePSM()
//        _ = PSMManager.sharedInstance.psm
//        XCTAssertEqual(true, PSMManager.sharedInstance.timerIsWorking)
//    }
//
//    func testUpdatePSM() throws {
//        PSMManager.sharedInstance.timer.invalidate()
//        let firstPSM = PSMManager.sharedInstance.psm
//        PSMManager.sharedInstance.updatePSM()
//        let secondPSM = PSMManager.sharedInstance.psm
//        XCTAssertEqual(firstPSM.msgCnt + 1, secondPSM.msgCnt)
//    }
}
