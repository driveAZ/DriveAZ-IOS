//
//  LogInManagerTests.swift
//  DriveAZTests
//
//  Created by Ben on 7/26/22.
//

import Foundation
import XCTest
@testable import DriveAZ

class LogInManagerTests: XCTestCase {

    override func setUpWithError() throws {
        UserDefaults.standard.removeObject(forKey: "UserIsLoggedIn")
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testLogInSetsLoggedIn() throws {
        LogInManager.sharedInstance.loggedIn()
        XCTAssertEqual(LogInManager.sharedInstance.isLoggedIn, true)
    }

    func testLogOutSetsLoggedOut() throws {
        LogInManager.sharedInstance.loggedIn()
        XCTAssertEqual(LogInManager.sharedInstance.isLoggedIn, true)
        LogInManager.sharedInstance.loggedOut()
        XCTAssertEqual(LogInManager.sharedInstance.isLoggedIn, false)
    }
}
