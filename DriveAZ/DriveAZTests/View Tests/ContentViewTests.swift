////
////  ContentViewTests.swift
////  DriveAZTests
////
////  Created by Ben on 5/18/22.
////

import XCTest
@testable import DriveAZ

class ContentViewTests: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

//    func testViews() throws {
//        let contentView = ContentView()
//        let firstView = FirstView()
//        let secondView = SecondView()
//        let thirdView = ThirdView(id: "test")
//        let lastView = LastView()
//        let logInView = LogInView()
//
//        XCTAssert(contentView.body != nil)
//        XCTAssert(firstView.body != nil)
//        XCTAssert(secondView.body != nil)
//        XCTAssert(thirdView.body != nil)
//        XCTAssert(lastView.body != nil)
//        XCTAssert(logInView.body != nil)
//
//        let mainView = MainView()
//        let mapView = MapView()
//        let vruView = VRUView(id: "test")
//        let listView = ListView()
//        let settingsView = SettingsView()
//
//        XCTAssert(mainView.body != nil)
//        XCTAssert(mapView.body != nil)
//        XCTAssert(vruView.body != nil)
//        XCTAssert(listView.body != nil)
//        XCTAssert(settingsView.body != nil)
//
//        let contentViewPreviews = ContentView_Previews()
//        let firstViewPreviews = FirstView_Previews()
//        let secondViewPreviews = SecondView_Previews()
//        let thirdViewPreviews = ThirdView_Previews()
//        let lastViewPreviews = LastView_Previews()
//
//        XCTAssert(contentViewPreviews.self != nil)
//        XCTAssert(firstViewPreviews != nil)
//        XCTAssert(secondViewPreviews != nil)
//        XCTAssert(thirdViewPreviews != nil)
//        XCTAssert(lastViewPreviews != nil)
//    }
//
//    func testMapPin() throws {
//
//        VRUManager.sharedInstance.seenVRUs["123"] = Examples.sharedInstance.examplePSMWithoutInfo
//        VRUManager.sharedInstance.seenVRUs["456"] = Examples.sharedInstance.examplePSM
//
//        let mapView = MapView().body
//    }
//
//    func testListView() throws {
//
//        VRUManager.sharedInstance.seenVRUs["123"] = Examples.sharedInstance.examplePSMWithoutInfo
//        VRUManager.sharedInstance.seenVRUs["456"] = Examples.sharedInstance.examplePSM
//
//        let listView = ListView().body
//    }
//
//    func testListViewAgain() throws {
//
//        VRUManager.sharedInstance.seenVRUs["123"] = Examples.sharedInstance.examplePSMWithoutInfo
//        VRUManager.sharedInstance.seenVRUs["456"] = Examples.sharedInstance.examplePSM
//        wait(for: [], timeout: 1)
//        let listView = ListView().body
//        wait(for: [], timeout: 1)
//        VRUManager.sharedInstance.seenVRUs["789"] = Examples.sharedInstance.examplePSM
//        wait(for: [], timeout: 1)
//
//    }
//
//    func testVRUView() throws {
//
//        VRUManager.sharedInstance.seenVRUs["123"] = Examples.sharedInstance.examplePSMWithoutInfo
//        VRUManager.sharedInstance.seenVRUs["456"] = Examples.sharedInstance.examplePSM
//
//        let vruView = VRUView(id: "456")
//        XCTAssert(vruView.getPSM() != nil)
//        let vruViewBody = vruView.body
//    }
//
//    func testVRUViewWithoutInfo() throws {
//
//        VRUManager.sharedInstance.seenVRUs["123"] = Examples.sharedInstance.examplePSMWithoutInfo
//        VRUManager.sharedInstance.seenVRUs["456"] = Examples.sharedInstance.examplePSM
//
//        let vruView = VRUView(id: "123")
//        XCTAssert(vruView.getPSM() != nil)
//        let vruViewBody = vruView.body
//    }
//
//    func testVRUViewNilPSM() throws {
//
//        VRUManager.sharedInstance.seenVRUs["123"] = Examples.sharedInstance.examplePSMWithoutInfo
//        VRUManager.sharedInstance.seenVRUs["456"] = Examples.sharedInstance.examplePSM
//
//        let vruView = VRUView(id: "NIL")
//        XCTAssert(vruView.getPSM() == nil)
//        let vruViewBody = vruView.body
//    }
//
//    func testListDetailView() throws {
//
//        let listDetailView = ListDetail(type: "type", id: "id").body
//        let listDetailViewnil = ListDetail(type: nil, id: nil).body
//    }
//
//    func testShowUnsupportedAlert() throws {
//        PhoneManager.sharedInstance.phoneDoesntSupport2M = true
//
//        let contentView = ContentView()
//        let contentViewBody = contentView.body
//    }
//
//    func testShowLogIn() throws {
//        let logInView = LogInView()
//        logInView.signIn()
//    }
//
//    func testNilListDetail() {
//        let thing = ListDetail(type: nil, id: nil)
//
//        XCTAssertEqual(thing.type, "Unknown")
//        XCTAssertEqual(thing.id, "----")
//    }
}
