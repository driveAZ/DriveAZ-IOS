//
//  DriveAZUITestsLaunchTests.swift
//  DriveAZUITests
//
//  Created by Ben on 1/21/22.
//

import XCTest
// import B2ViOSExtras
// @testable import DriveAZ

class DriveAZUITestsLaunchTests: XCTestCase {

    override class var runsForEachTargetApplicationUIConfiguration: Bool {
        false
    }

    override func setUpWithError() throws {
        continueAfterFailure = false
    }

    func testModeButtons() throws {
        let app = XCUIApplication()
        app.launchArguments = ["testMode"]
        app.launch()

        app.images.element(matching: .image, identifier: "scootering-button").tap()
        app.images.element(matching: .image, identifier: "biking-button").tap()
        app.images.element(matching: .image, identifier: "driving-button").tap()
        app.images.element(matching: .image, identifier: "walking-button").tap()

    }

    func testMapAndListView() throws {
        let app = XCUIApplication()
        app.launchArguments = ["testMode"]
        app.launch()

        app.images.element(matching: .image, identifier: "map-button").tap()
        app.images.element(matching: .image, identifier: "list-button").tap()
    }

    func testVRUView() throws {
        let app = XCUIApplication()
        app.launchArguments = ["testMode"]
        app.launch()

        app.images.element(matching: .image, identifier: "map-button").tap()
        app.images.element(matching: .image, identifier: "list-button").tap()
        // Commented out as there's no record of a "Forward" element
        //app.images.matching(identifier: "Forward").element(boundBy: 3).tap()
    }

    func testSettingsView() throws {
        let app = XCUIApplication()
        app.launchArguments = ["testMode"]
        app.launch()

        app.images.element(matching: .image, identifier: "settings-button").tap()
    }

//    func testSettingsViewLogIn() throws {
//        let app = XCUIApplication()
//        app.launch()
//        
//        app.buttons.element(matching: .button, identifier: "sign-in-button").tap()
//        app.images.element(matching: .image, identifier: "settings-button").tap()
//    }

    func testSettingsViewLogOut() throws {
        let app = XCUIApplication()
        app.launchArguments = ["testMode"]
        app.launch()

        app.images.element(matching: .image, identifier: "settings-button").tap()
        app.buttons.element(matching: .button, identifier: "sign-out-button").tap()
    }

//    func testSettingsViewLogOutThenIn() throws {
//        let app = XCUIApplication()
//        app.launchArguments = ["testMode"]
//        app.launch()
//
//        app.images.element(matching: .image, identifier: "settings-button").tap()
//        app.buttons.element(matching: .button, identifier: "sign-out-button").tap()
//        app.buttons.element(matching: .button, identifier: "sign-in-button").tap()
//    }

    func testLogInPage() {
        let app = XCUIApplication()
        app.launchArguments = ["testLoggedOut"]
        app.launch()

        app.buttons.element(matching: .button, identifier: "sign-in-button").tap()
    }

    func testBackButton() throws {
        let app = XCUIApplication()
        app.launchArguments = ["testMode"]
        app.launch()

        app.images.element(matching: .image, identifier: "settings-button").tap()
        app.images.element(matching: .image, identifier: "Left").tap()
        app.images.element(matching: .image, identifier: "map-button").tap()
        app.images.element(matching: .image, identifier: "Left").tap()
    }

    func testMapViewPin() throws {
        let app = XCUIApplication()
        app.launchArguments = ["testMode"]
        app.launch()

        app.images.element(matching: .image, identifier: "map-button").tap()
    }

    func testRedAlert() throws {
        let app = XCUIApplication()
        app.launchArguments = ["testMode"]
        app.launch()

        app.images.element(matching: .image, identifier: "settings-button").tap()
        app.buttons.element(matching: .button, identifier: "show-red-alert").tap()
    }

    func testYellowAlert() throws {
        let app = XCUIApplication()
        app.launchArguments = ["testMode"]
        app.launch()

        app.images.element(matching: .image, identifier: "settings-button").tap()
        app.buttons.element(matching: .button, identifier: "show-yellow-alert").tap()
    }

    func testOldPhone() throws {
        let app = XCUIApplication()
        app.launchArguments = ["testMode", "testOldPhone"]
        app.launch()
        app.buttons.element(boundBy: 0).tap()
    }

    func testListView() throws {
        let app = XCUIApplication()
        app.launchArguments = ["testMode", "testAddPSMToList"]
        app.launch()

        app.images.element(matching: .image, identifier: "map-button").tap()
        app.images.element(matching: .image, identifier: "list-button").tap()
    }
}
