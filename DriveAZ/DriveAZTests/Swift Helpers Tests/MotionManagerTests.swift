////
////  MotionManagerTests.swift
////  DriveAZTests
////
////  Created by Ben on 4/4/22.
////

import XCTest
@testable import DriveAZ
import CoreMotion

class MotionManagerTests: XCTestCase {
//    func testDidUpdateHeading() throws {
////        XCTAssertEqual(MotionManager.sharedInstance.lastSeenAcceleration?.x, nil)
//        MotionManager.sharedInstance.startAccelerometers()
//        MotionManager.sharedInstance.timer.fire()
////        XCTAssertEqual(MotionManager.sharedInstance.lastSeenAcceleration?.x, nil)
//    }
//
//    func testBasicTypeWalking() throws {
//        MotionManager.sharedInstance.selectedMode = "walking"
//        XCTAssertEqual(MotionManager.sharedInstance.getBasicType(), 1)
//    }
//
//    func testBasicTypeBiking() throws {
//        MotionManager.sharedInstance.selectedMode = "biking"
//        XCTAssertEqual(MotionManager.sharedInstance.getBasicType(), 2)
//    }
//
//    func testBasicTypeScootering() throws {
//        MotionManager.sharedInstance.selectedMode = "scootering"
//        XCTAssertEqual(MotionManager.sharedInstance.getBasicType(), 2)
//    }
//
//    func testBasicTypeOther() throws {
//        MotionManager.sharedInstance.selectedMode = "other"
//        XCTAssertEqual(MotionManager.sharedInstance.getBasicType(), 0)
//    }
//
//    func testCheckActivityUpdateWalking() throws {
//        MotionManager.sharedInstance.lastSeenActivity = "none"
//        MotionManager.sharedInstance.autoTravelModeDetection = false
////        let activity = CMMotionActivity()
////        activity.walking = true
//        MotionManager.sharedInstance.checkActivityUpdate(nil)
//        XCTAssertEqual(MotionManager.sharedInstance.selectedMode, "walking")
//    }
//
//    func testCheckActivityUpdateWalkingAutoMode() throws {
//        MotionManager.sharedInstance.lastSeenActivity = "none"
//        MotionManager.sharedInstance.autoTravelModeDetection = true
////        let activity = CMMotionActivity()
////        activity.walking = true
//        MotionManager.sharedInstance.checkActivityUpdate(nil)
//        XCTAssertEqual(MotionManager.sharedInstance.selectedMode, "none")
//    }
//
//    func testWalkingToBikingDoesntChangeFromNotScanning() throws {
//        BLEManager.sharedInstance.stopScanning()
//        XCTAssertEqual(BLEManager.sharedInstance.isScanning, false)
//        MotionManager.sharedInstance.checkIfChangeOfScanningIsNeeded(oldValue: "walking", newValue: "biking")
//        XCTAssertEqual(BLEManager.sharedInstance.isScanning, false)
//    }
//
//    func testWalkingToBikingDoesntChangeFromScanning() throws {
//        BLEManager.sharedInstance.startScanning()
//        XCTAssertEqual(BLEManager.sharedInstance.isScanning, true)
//        MotionManager.sharedInstance.checkIfChangeOfScanningIsNeeded(oldValue: "walking", newValue: "biking")
//        XCTAssertEqual(BLEManager.sharedInstance.isScanning, true)
//    }
//
//    func testWalkingToDrivingStartsScanning() throws {
//        BLEManager.sharedInstance.stopScanning()
//        XCTAssertEqual(BLEManager.sharedInstance.isScanning, false)
//        MotionManager.sharedInstance.checkIfChangeOfScanningIsNeeded(oldValue: "walking", newValue: "driving")
//        XCTAssertEqual(BLEManager.sharedInstance.isScanning, true)
//    }
//
//    func testDrivingToWalkingStopsScanning() throws {
//        BLEManager.sharedInstance.startScanning()
//        XCTAssertEqual(BLEManager.sharedInstance.isScanning, true)
//        MotionManager.sharedInstance.checkIfChangeOfScanningIsNeeded(oldValue: "driving", newValue: "walking")
//        XCTAssertEqual(BLEManager.sharedInstance.isScanning, false)
//    }
}
