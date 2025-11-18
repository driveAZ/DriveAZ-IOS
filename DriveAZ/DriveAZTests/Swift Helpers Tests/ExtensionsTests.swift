////
////  ExtensionsTests.swift
////  DriveAZTests
////
////  Created by Jeffrey Yeung on 4/24/23.
////

import XCTest
@testable import DriveAZ
import SwiftUI
import B2VExtras

final class ExtensionsTests: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testExample() throws {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
        // Any test you write for XCTest can be annotated as throws and async.
        // Mark your test throws to produce an unexpected failure when your test encounters an uncaught error.
        // Mark your test async to allow awaiting for asynchronous code to complete.
        // Check the results with assertions afterwards.
    }

    func testPerformanceExample() throws {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }
    
//    func testModelIdentifier() throws {
//        let model :String = modelIdentifier()
//        XCTAssertNotNil(model)
//    }
//    
//    func testSerialization_e() throws {
//        let desc: String = serialization_e(0x0000).description
//        XCTAssertEqual(desc, "SERIALIZATION_OK")
//        
//        let desc2: String = serialization_e(0x10006).description
//        XCTAssertEqual(desc2, "SERIALIZATION_DATA_INVALID_SIZE")
//        
//    }
}
