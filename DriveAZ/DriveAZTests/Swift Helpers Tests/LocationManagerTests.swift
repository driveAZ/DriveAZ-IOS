////
////  LocationManager.swift
////  DriveAZTests
////
////  Created by Ben on 3/31/22.
////

import XCTest
@testable import DriveAZ
import CoreLocation

class LocationManagerTests: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

//    func testDidUpdateHeading() throws {
//        let newHeading = CLHeading()
//
//        LocationManager.sharedInstance.locationManager(LocationManager.sharedInstance.locationManager,
//                                                       didUpdateHeading: newHeading)
//
//        XCTAssertEqual(newHeading, LocationManager.sharedInstance.lastSeenHeading)
//    }
//
//    func testDidUpdateLocation() throws {
//        let newLocation = CLLocation()
//
//        LocationManager.sharedInstance.locationManager(LocationManager.sharedInstance.locationManager,
//                                                       didUpdateLocations: [newLocation])
//
//        XCTAssertEqual(newLocation, LocationManager.sharedInstance.lastSeenLocation)
//    }
//
//    func testInitWithFullAccuracy() throws {
//
//    }
//    
//    func testStartMonitoring() {
//        var geofencingLatitude: Double = 42.48724366544757
//        var geofencingLongitude: Double = -83.14687801715559
//        var geofencingRadius: Double = 100
//        
//        let geofenceRegion = CLCircularRegion(center: CLLocationCoordinate2D(latitude: geofencingLatitude,
//                                                                             longitude: geofencingLongitude),
//                                              radius: geofencingRadius, identifier: "Tome")
//        
//        LocationManager.sharedInstance.startMonitoring(for: geofenceRegion)
//        XCTAssertEqual(true, LocationManager.sharedInstance.monitoring)
//    }
//    
//    func testStopMonitoring() {
//        var geofencingLatitude: Double = 42.48724366544757
//        var geofencingLongitude: Double = -83.14687801715559
//        var geofencingRadius: Double = 100
//        
//        let geofenceRegion = CLCircularRegion(center: CLLocationCoordinate2D(latitude: geofencingLatitude,
//                                                                             longitude: geofencingLongitude),
//                                              radius: geofencingRadius, identifier: "Tome")
//        
//        LocationManager.sharedInstance.startMonitoring(for: geofenceRegion)
//        LocationManager.sharedInstance.stopMonitoring(for: geofenceRegion)
//        XCTAssertEqual(false, LocationManager.sharedInstance.monitoring)
//    }
//    
//    func testGeofenced() {
//        var geofencingLatitude: Double = 42.48724366544757
//        var geofencingLongitude: Double = -83.14687801715559
//        var geofencingRadius: Double = 100
//        
//        let geofenceRegion = CLCircularRegion(center: CLLocationCoordinate2D(latitude: geofencingLatitude,
//                                                                             longitude: geofencingLongitude),
//                                              radius: geofencingRadius, identifier: "Tome")
//        
//        LocationManager.sharedInstance.didEnterRegion(geofenceRegion)
//        XCTAssertEqual(true, LocationManager.sharedInstance.geofenced)
//    }
//    
//    func testGeofencedExit() {
//        var geofencingLatitude: Double = 42.48724366544757
//        var geofencingLongitude: Double = -83.14687801715559
//        var geofencingRadius: Double = 100
//        
//        let geofenceRegion = CLCircularRegion(center: CLLocationCoordinate2D(latitude: geofencingLatitude,
//                                                                             longitude: geofencingLongitude),
//                                              radius: geofencingRadius, identifier: "Tome")
//        
//        LocationManager.sharedInstance.didEnterRegion(geofenceRegion)
//        LocationManager.sharedInstance.didExitRegion(geofenceRegion)
//        XCTAssertEqual(false, LocationManager.sharedInstance.geofenced)
//    }
//    
//    // Note: This test is commented out to pass Jenkins, which fails
//    // for some reason even though it passes in XCode 100x.
////    func testToggleGeofence() {
////        LocationManager.sharedInstance.toggleGeofencing(value: true
////        XCTAssertEqual(true, LocationManager.sharedInstance.monitoring)
////    }
////
//    func testToggleGeofenceOff() {
//        LocationManager.sharedInstance.toggleGeofencing(value: false)
//        XCTAssertEqual(false, LocationManager.sharedInstance.monitoring)
//    }
    
}
