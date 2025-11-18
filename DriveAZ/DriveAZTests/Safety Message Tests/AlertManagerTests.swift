//
//  AlertManagerTests.swift
//  DriveAZ
//
//  Created by Ben on 1/16/25.
//

import XCTest
@testable import DriveAZ
import CoreLocation

class AlertManagerTests: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }
    
    func testSimpleAlertCheckNorthTrue() throws {
        XCTAssertEqual(true, AlertManager.sharedInstance.simpleAlertCheck(phoneHeading: 0, phoneLat: 0, phoneLng: 0, checkLat: 1, checkLng: 2))
    }
    
    func testSimpleAlertCheckNorthFalse() throws {
        XCTAssertEqual(false, AlertManager.sharedInstance.simpleAlertCheck(phoneHeading: 0, phoneLat: 0, phoneLng: 0, checkLat: -1, checkLng: 2))
    }
    
    func testSimpleAlertCheckNorthEastTrue() throws {
        XCTAssertEqual(true, AlertManager.sharedInstance.simpleAlertCheck(phoneHeading: 45, phoneLat: 0, phoneLng: 0, checkLat: 1, checkLng: 2))
    }
    
    func testSimpleAlertCheckNorthEastFalse() throws {
        XCTAssertEqual(false, AlertManager.sharedInstance.simpleAlertCheck(phoneHeading: 45, phoneLat: 0, phoneLng: 0, checkLat: -1, checkLng: 2))
    }
    
    func testSimpleAlertCheckEastTrue() throws {
        XCTAssertEqual(true, AlertManager.sharedInstance.simpleAlertCheck(phoneHeading: 90, phoneLat: 0, phoneLng: 0, checkLat: 1, checkLng: 2))
    }
    
    func testSimpleAlertCheckEastFalse() throws {
        XCTAssertEqual(false, AlertManager.sharedInstance.simpleAlertCheck(phoneHeading: 90, phoneLat: 0, phoneLng: 0, checkLat: -1, checkLng: -2))
    }
    
    func testSimpleAlertCheckSouthEastTrue() throws {
        XCTAssertEqual(true, AlertManager.sharedInstance.simpleAlertCheck(phoneHeading: 135, phoneLat: 0, phoneLng: 0, checkLat: -1, checkLng: 2))
    }
    
    func testSimpleAlertCheckSouthEastFalse() throws {
        XCTAssertEqual(false, AlertManager.sharedInstance.simpleAlertCheck(phoneHeading: 135, phoneLat: 0, phoneLng: 0, checkLat: -1, checkLng: -2))
    }
    
    func testSimpleAlertCheckSouthTrue() throws {
        XCTAssertEqual(true, AlertManager.sharedInstance.simpleAlertCheck(phoneHeading: 180, phoneLat: 0, phoneLng: 0, checkLat: -1, checkLng: -2))
    }
    
    func testSimpleAlertCheckSouthFalse() throws {
        XCTAssertEqual(false, AlertManager.sharedInstance.simpleAlertCheck(phoneHeading: 180, phoneLat: 0, phoneLng: 0, checkLat: 1, checkLng: -2))
    }
    
    func testSimpleAlertCheckSouthWestTrue() throws {
        XCTAssertEqual(true, AlertManager.sharedInstance.simpleAlertCheck(phoneHeading: 225, phoneLat: 0, phoneLng: 0, checkLat: -1, checkLng: -2))
    }
    
    func testSimpleAlertCheckSouthWestFalse() throws {
        XCTAssertEqual(false, AlertManager.sharedInstance.simpleAlertCheck(phoneHeading: 225, phoneLat: 0, phoneLng: 0, checkLat: -1, checkLng: 2))
    }
    
    func testSimpleAlertCheckWestTrue() throws {
        XCTAssertEqual(true, AlertManager.sharedInstance.simpleAlertCheck(phoneHeading: 270, phoneLat: 0, phoneLng: 0, checkLat: -1, checkLng: -2))
    }
    
    func testSimpleAlertCheckWestFalse() throws {
        XCTAssertEqual(false, AlertManager.sharedInstance.simpleAlertCheck(phoneHeading: 270, phoneLat: 0, phoneLng: 0, checkLat: -1, checkLng: 2))
    }
    
    func testSimpleAlertCheckNorthWestTrue() throws {
        XCTAssertEqual(true, AlertManager.sharedInstance.simpleAlertCheck(phoneHeading: 315, phoneLat: 0, phoneLng: 0, checkLat: 1, checkLng: -2))
    }
    
    func testSimpleAlertCheckNorthWestFalse() throws {
        XCTAssertEqual(false, AlertManager.sharedInstance.simpleAlertCheck(phoneHeading: 315, phoneLat: 0, phoneLng: 0, checkLat: 1, checkLng: 2))
    }
    
    func testSimpleAlertCheckNorth359True() throws {
        XCTAssertEqual(true, AlertManager.sharedInstance.simpleAlertCheck(phoneHeading: 359, phoneLat: 0, phoneLng: 0, checkLat: 1, checkLng: 2))
    }
    
    func testSimpleAlertCheckNorth359False() throws {
        XCTAssertEqual(false, AlertManager.sharedInstance.simpleAlertCheck(phoneHeading: 359, phoneLat: 0, phoneLng: 0, checkLat: -1, checkLng: 2))
    }
    
    func testGetSafeHeadingNegative() throws {
        XCTAssertEqual(345.6, AlertManager.sharedInstance.getSafeHeading(-14.4))
    }
    
    func testGetSafeHeadingSuperNegative() throws {
        XCTAssertEqual(345.6, AlertManager.sharedInstance.getSafeHeading(-374.4))
    }
    
    func testGetSafeHeadingOver() throws {
        XCTAssertEqual(345.6, AlertManager.sharedInstance.getSafeHeading(705.6))
    }
    
    func testGetSafeHeadingSuperOver() throws {
        XCTAssertEqual(345.6, AlertManager.sharedInstance.getSafeHeading(1065.6), accuracy: 0.01)
    }
    
    func testPointInTriangle() throws {
        let pt = CLLocationCoordinate2D(latitude: 2, longitude: 2)
        let v1 = CLLocationCoordinate2D(latitude: 1, longitude: 1)
        let v2 = CLLocationCoordinate2D(latitude: 3, longitude: 2)
        let v3 = CLLocationCoordinate2D(latitude: 1, longitude: 3)
        XCTAssert(AlertManager.sharedInstance.pointInTriangle(pt: pt, v1: v1, v2: v2, v3: v3))
    }
    
    func testPointInTriangleFails() throws {
        let pt = CLLocationCoordinate2D(latitude: 2, longitude: 3)
        let v1 = CLLocationCoordinate2D(latitude: 1, longitude: 1)
        let v2 = CLLocationCoordinate2D(latitude: 3, longitude: 2)
        let v3 = CLLocationCoordinate2D(latitude: 1, longitude: 3)
        XCTAssertFalse(AlertManager.sharedInstance.pointInTriangle(pt: pt, v1: v1, v2: v2, v3: v3))
    }
    
    func testPointInTriangleWithNegatives() throws {
        let pt = CLLocationCoordinate2D(latitude: 2, longitude: 0)
        let v1 = CLLocationCoordinate2D(latitude: 1, longitude: -1)
        let v2 = CLLocationCoordinate2D(latitude: 3, longitude: 0)
        let v3 = CLLocationCoordinate2D(latitude: 1, longitude: 1)
        XCTAssert(AlertManager.sharedInstance.pointInTriangle(pt: pt, v1: v1, v2: v2, v3: v3))
    }
    
    func testLocationWithBearing() throws {
        let origin = CLLocationCoordinate2D(latitude: 0, longitude: 0)
        XCTAssertEqual(-0.00045, AlertManager.sharedInstance.locationWithBearing(bearing: 180, distanceMeters: 50, origin: origin).latitude, accuracy: 0.00001)
    }
    
    func testLocationWithBearingOtherLocation() throws {
        let origin = CLLocationCoordinate2D(latitude: 43.250096, longitude: -83.794319)
        XCTAssertEqual(-83.79279656995114, AlertManager.sharedInstance.locationWithBearing(bearing: 90, distanceMeters: 123, origin: origin).longitude, accuracy: 0.00001)
    }

    func testConeAlertCheck_NWOutside100m() throws {
        // Arrange: Phone location and target coordinates as provided.
        let phoneLat = 42.481681
        let phoneLng = -83.151245
        let phoneHeading = 315.0   // NW (315°)
        let distance = 100.0       // Cone distance of 100 meters
        let coneAngle = 30.0       // Cone angle of 60 degrees
        
        // Target location:
        let targetLat = 42.482777
        let targetLng = -83.152237
        
        // Act: Check if the target is within the cone
        let isInCone = AlertManager.sharedInstance.coneAlertCheck(phoneHeading: phoneHeading,
          phoneLat: phoneLat,
          phoneLng: phoneLng,
          checkLat: targetLat,
          checkLng: targetLng,
          distance: distance,
          angle: coneAngle)
        // Assert: The target is more than 100 meters away, so it should be outside the cone.
        XCTAssertFalse(isInCone, "The target at (42.482777, -83.152237) should be outside the 100m cone from the phone at (42.481681, -83.151245) with heading NW (315°).")
    }

    func testConeAlertCheck_NWInside150m() throws {
        // Arrange: Phone location and target coordinates as provided.
        let phoneLat = 42.481681
        let phoneLng = -83.151245
        let phoneHeading = 315.0   // NW (315°)
        let distance = 150.0       // Cone distance of 100 meters
        let coneAngle = 30.0       // Cone angle of 60 degrees
        
        // Target location:
        let targetLat = 42.482777
        let targetLng = -83.152237
        
        // Act: Check if the target is within the cone
        let isInCone = AlertManager.sharedInstance.coneAlertCheck(phoneHeading: phoneHeading,
          phoneLat: phoneLat,
          phoneLng: phoneLng,
          checkLat: targetLat,
          checkLng: targetLng,
          distance: distance,
          angle: coneAngle)
        // Assert: The target is more than 100 meters away, so it should be outside the cone.
        XCTAssertTrue(isInCone, "The target at (42.482777, -83.152237) should be outside the 100m cone from the phone at (42.481681, -83.151245) with heading NW (315°).")
    }
}
