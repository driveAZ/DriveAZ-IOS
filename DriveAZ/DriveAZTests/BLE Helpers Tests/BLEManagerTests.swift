////
////  BLEManagerTests.swift
////  DriveAZTests
////
////  Created by Ben on 5/3/22.
////

import XCTest
@testable import DriveAZ
import CoreLocation
import CoreBluetooth
import B2VExtras

class BLEManagerTests: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

//    func testUInt8ToUUIDsWithEmptyArray() throws {
//        let inputData: [UInt8] = []
//
//        let results = BLEManager.sharedInstance.uint8ToUUIDs(inputData)
//
//        XCTAssertEqual(results, [CBUUID(string: "FFFFFFFF-FFFF-FFFF-FFFF-FFFFFFFFFFFF")])
//    }
//
//    func testRecievePSM() throws {
//        PSMManager.sharedInstance.updatePSM()
//        let manfCode: [UInt8] = [0x77, 0x08, 0x42]
//        let advData = manfCode + PSMManager.sharedInstance.latestBytes
//
//        BLEManager.sharedInstance.handleDidDiscoverAdvertisment(
//            BLEManager.sharedInstance.centralManager,
//            didDiscover: nil,
//            advertisementData: ["kCBAdvDataManufacturerData": Data(advData)],
//            rssi: 1)
//
//        XCTAssert(BLEManager.sharedInstance.testingHaveWeSeenAMessage)
//    }
//
//    func testStartScanning() throws {
//        BLEManager.sharedInstance.startScanning()
//
//        XCTAssertEqual(BLEManager.sharedInstance.isScanning, true)
//    }
//
//    func testStopScanning() throws {
//        BLEManager.sharedInstance.startScanning()
//
//        XCTAssertEqual(BLEManager.sharedInstance.isScanning, true)
//        BLEManager.sharedInstance.stopScanning()
//
//        XCTAssertEqual(BLEManager.sharedInstance.isScanning, false)
//    }
//
//    func testNotScanningAtFirst() throws {
//        XCTAssertEqual(BLEManager.sharedInstance.isScanning, false)
//    }
//
//    func testNilBuffer() {
//        let id = OCTET_STRING()
//
//        XCTAssertEqual(BLEManager.sharedInstance.handleBuffer(id), nil)
//    }
}
