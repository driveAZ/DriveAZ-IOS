////
////  SafetyMessageCreatorTests.swift
////  DriveAZTests
////
////  Created by Ben on 3/31/22.
////

import XCTest
@testable import DriveAZ
import CoreLocation

class SafetyMessageCreatorTests: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

//    func testPSMMessageCount() throws {
//        let smc = SafetyMessageCreator()
//        let psm1 = smc.createPSM()
//        XCTAssertEqual(psm1.msgCnt, 0)
//        let psm2 = smc.createPSM()
//        XCTAssertEqual(psm2.msgCnt, 1)
//    }
//
//    func testPSMMessageCountPart2() throws {
//        let smc = SafetyMessageCreator()
//        smc.lastPSMMessageCount = 12
//        let psm1 = smc.createPSM()
//        XCTAssertEqual(psm1.msgCnt, 13)
//        let psm2 = smc.createPSM()
//        XCTAssertEqual(psm2.msgCnt, 14)
//    }
//
//    func testNilUUID() throws {
//        let smc = SafetyMessageCreator()
//        smc.possibleUUID = nil
//        let psm = smc.createPSM()
//        XCTAssertEqual(psm.id.buf.pointee, 189)
//    }
//
//    func testNilSecondsAndNanoSeconds() throws {
//        let smc = SafetyMessageCreator()
//        let result = smc.calculateSecMark(seconds: nil, nanoSeconds: nil)
//        XCTAssertEqual(result, 0.0)
//    }
//
//    func testTrueHeading() throws {
//        let smc = SafetyMessageCreator()
//        LocationManager.sharedInstance.lastSeenTrueHeading = 123.45
//        let psm = smc.createPSM()
//        XCTAssertEqual(psm.heading, headingRangeMap.mapForward(123.45))
//    }
//
//    //////////////////////////////////////// BSM
//    func testBSMMessageCount() throws {
//        let smc = SafetyMessageCreator()
//        let bsm1 = smc.createBSM()
//        XCTAssertEqual(bsm1.coreData.msgCnt, 0)
//        let bsm2 = smc.createBSM()
//        XCTAssertEqual(bsm2.coreData.msgCnt, 1)
//    }
//
//    func testBSMMessageCountPart2() throws {
//        let smc = SafetyMessageCreator()
//        smc.lastBSMMessageCount = 12
//        let bsm1 = smc.createBSM()
//        XCTAssertEqual(bsm1.coreData.msgCnt, 13)
//        let bsm2 = smc.createBSM()
//        XCTAssertEqual(bsm2.coreData.msgCnt, 14)
//    }
}
