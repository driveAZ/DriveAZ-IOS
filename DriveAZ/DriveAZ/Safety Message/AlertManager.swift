//
//  AlertManager.swift
//  DriveAZ
//
//  Created by Ben on 6/22/22.
//

import Foundation
import CoreLocation
import B2VExtrasSwift
import UIKit
import CocoaLumberjack
import SwiftUI

class AlertManager: ObservableObject {
    static let sharedInstance = AlertManager()
    let alertAngle = 45.0
    let timeToShowAlert = 5.0
    let timeBetweenSameAlerts = 30.0
    let timeToShowOnMapAfterLastMessage = 60.0
    
    let simulatorSpeed = 14
    let simulatorHeading = 90.0
    
    @Published var shouldShowErrorAlert = false
    var errorAlertTitle = "alertTitle"
    var errorAlertText = "alertText"
    var errorAlertButton = "Ok"
    var errorAlertNumber: Int32 = -1

    // Lookup table of stopping distances in meters where the index is the speed in m/s
    // Generated with https://github.com/US-Detroit/internal-safetyteam-stopping-distances
    let total_stopping_distances : [Double] = [0.0, 7.550968399592253, 15.203873598369011, 22.958715596330276, 30.815494393476044, 38.77420998980632, 46.8348623853211, 54.99745158002039, 63.261977573904176, 71.62844036697248, 80.09683995922528, 88.66717635066259, 97.33944954128441, 106.11365953109072, 114.98980632008156, 123.96788990825688, 133.0479102956167, 142.22986748216107, 151.5137614678899, 160.89959225280325, 170.3873598369011, 179.97706422018348, 189.66870540265035, 199.46228338430174, 209.3577981651376, 219.355249745158, 229.4546381243629, 239.6559633027523, 249.9592252803262, 260.3644240570846, 270.8715596330275, 281.48063200815494, 292.19164118246687, 303.0045871559633, 313.9194699286442, 324.9362895005097, 336.0550458715596, 347.27573904179405, 358.59836901121304, 370.0229357798165, 381.54943934760445, 393.177879714577, 404.9082568807339, 416.74057084607546, 428.67482161060144, 440.7110091743119, 452.8491335372069, 465.08919469928645, 477.43119266055044, 489.875127420999, 502.420998980632, 515.0688073394496, 527.8185524974516, 540.6702344546381, 553.6238532110092, 566.6794087665647, 579.8369011213048, 593.0963302752293, 606.4576962283384, 619.920998980632];

    init() {
        print("DEBUG accuracyAuthorization \(LocationManager.sharedInstance.locationManager.accuracyAuthorization.rawValue)")
        print("DEBUG accuracyAuthorization \(LocationManager.sharedInstance.locationManager.accuracyAuthorization.hashValue)")
        print("DEBUG headingFilter \(LocationManager.sharedInstance.locationManager.headingFilter)")
        print("DEBUG authorizationStatus \(LocationManager.sharedInstance.locationManager.authorizationStatus.rawValue)")
        print("DEBUG desiredAccuracy \(LocationManager.sharedInstance.locationManager.desiredAccuracy)")

        if UIDevice.current.isSimulator {
            print("IS SIMULATOR")
            LocationManager.sharedInstance.lastSeenTrueHeading = simulatorHeading
//            Timer.scheduledTimer(withTimeInterval: 45, repeats: false) { _ in
//                print("Turn")
//                LocationManager.sharedInstance.lastSeenTrueHeading = 90
//            }
        }
        
        Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { _ in
            MQTTManager.sharedInstance.checkAllAlerts()
        }
    }
    
    func shouldShowAlert(grm: GRMAnnotationItem) -> Bool {
        guard
            let location = LocationManager.sharedInstance.lastSeenLocation,
            (location.speed >= 1 || UIDevice.current.isSimulator)
        else {
            print("alert not moving")
            return false
        }
        
        if !["TIM", "PSM"].contains(grm.messageType) {
            print("alert wrong type \(grm.messageType)")
            return false
        }
        
        guard
            let checkLocation = getLocationFromAGRM(grm: grm)
        else {
            print("alert no check location")
            return false
        }
        print("")
        
        print("Distance Between is \(location.distance(from: checkLocation))")
        if location.distance(from: checkLocation) < 123 {
            print("Should be alerting!!")
        }
        
        var heading = 0.0
        
//        var heading = LocationManager.sharedInstance.lastSeenCourse ?? 0
        if UIDevice.current.isSimulator {
            heading = simulatorHeading
        } else {
            guard
                var safeCourse = LocationManager.sharedInstance.lastSeenCourse
            else {
                print("alert no heading")
                return false
            }
            heading = safeCourse
        }
        
        print("Doing Simple Alert Check. PhoneHeading: \(heading), Location: \(location.coordinate), CheckLocation: \(checkLocation.coordinate)")
        if !simpleAlertCheck(phoneHeading: heading, phoneLat: location.coordinate.latitude, phoneLng: location.coordinate.longitude, checkLat: checkLocation.coordinate.latitude, checkLng: checkLocation.coordinate.longitude) {
            print("alert failed simple alert")
            return false
        }
        
        var alertDistance = getAlertDistance(location)
        
        if
            let c = MQTTManager.sharedInstance.getTIMContenArray(grm),
            c.keys.contains("workZone")
        {
            alertDistance = 500
        }
        
        if alertDistance == 0 {
            print("alertDistance is somehow zero")
            return false
        }
        
        print("Doing coneAlertCheck. Heading: \(heading), PhoneLat: \(location.coordinate.latitude), PhoneLng: \(location.coordinate.longitude), CheckLat: \(checkLocation.coordinate.latitude), CheckLng: \(checkLocation.coordinate.longitude), Distance: \(alertDistance), Angle: \(alertAngle), Speed \(location.speed)")
        let coneAlertCheckResult = coneAlertCheck(phoneHeading: heading, phoneLat: location.coordinate.latitude, phoneLng: location.coordinate.longitude, checkLat: checkLocation.coordinate.latitude, checkLng: checkLocation.coordinate.longitude, distance: alertDistance, angle: alertAngle)
        
        print("coneAlertCheckResult: \(coneAlertCheckResult)")
        
        return coneAlertCheckResult
    }
    
    
    func getLocationFromAGRM(grm: GRMAnnotationItem) -> CLLocation? {
        if grm.messageType == "PSM" {
            let pos = grm.messageFrame.value.choice.PersonalSafetyMessage.position
            return CLLocation(latitude: Double(pos.lat)/1e7, longitude: Double(pos.Long)/1e7)
        }
        
        if
            let (lat, long) = MQTTManager.sharedInstance.getTIMLLatLng(grm)
        {
            return CLLocation(latitude: Double(lat)/1e7, longitude: Double(long)/1e7)
        }
        
        return nil
    }
    
    func getAlertDistance(_ location: CLLocation) -> Double {
        var intSpeed = Int(location.speed.rounded(.up))
        if intSpeed >= total_stopping_distances.count {
            intSpeed = total_stopping_distances.count - 1
        }
        
        
        if UIDevice.current.isSimulator {
            intSpeed = simulatorSpeed
        }
        
        if intSpeed < 0 {
            intSpeed = 0
        }
        
        return total_stopping_distances[intSpeed]
    }
    
    
    func getSafeHeading(_ heading: Double) -> Double {
        
        var safePhoneHeading = heading
        while safePhoneHeading < 0 {
            safePhoneHeading += 360
        }
        return safePhoneHeading.truncatingRemainder(dividingBy: 360)
    }
    
    func simpleAlertCheck(phoneHeading: Double, phoneLat: Double, phoneLng: Double, checkLat: Double, checkLng: Double) -> Bool {
        let div = 360.0/16.0
        let safePhoneHeading = getSafeHeading(phoneHeading)
        
        if 1 * div < safePhoneHeading && safePhoneHeading <= 3 * div { // NE
            return checkLat >= phoneLat && checkLng >= phoneLng
        } else if 3 * div < safePhoneHeading && safePhoneHeading <= 5 * div { // E
            return checkLng >= phoneLng
        } else if 5 * div < safePhoneHeading && safePhoneHeading <= 7 * div { // SE
            return checkLat <= phoneLat && checkLng >= phoneLng
        } else if 7 * div < safePhoneHeading && safePhoneHeading <= 9 * div { // S
            return checkLat <= phoneLat
        } else if 9 * div < safePhoneHeading && safePhoneHeading <= 11 * div { // SW
            return checkLat <= phoneLat && checkLng <= phoneLng
        } else if 11 * div < safePhoneHeading && safePhoneHeading <= 13 * div { // W
            return checkLng <= phoneLng
        } else if 13 * div < safePhoneHeading && safePhoneHeading <= 15 * div { // NW
            return checkLat >= phoneLat && checkLng <= phoneLng
        } else { // N
            return checkLat >= phoneLat
        }
    }

    func sign(p1: CLLocationCoordinate2D, p2: CLLocationCoordinate2D, p3: CLLocationCoordinate2D) -> Double {
        return (p1.longitude - p3.longitude) * (p2.latitude - p3.latitude) - (p2.longitude - p3.longitude) * (p1.latitude - p3.latitude)
    }

    func pointInTriangle(pt: CLLocationCoordinate2D, v1: CLLocationCoordinate2D, v2: CLLocationCoordinate2D, v3: CLLocationCoordinate2D) -> Bool {
        let d1 = sign(p1: pt, p2: v1, p3: v2)
        let d2 = sign(p1: pt, p2: v2, p3: v3)
        let d3 = sign(p1: pt, p2: v3, p3: v1)
        
        let hasNeg = d1 < 0 || d2 < 0 || d3 < 0
        let hasPos = d1 > 0 || d2 > 0 || d3 > 0
        
        return !(hasNeg && hasPos)
    }
    
    func locationWithBearing(bearing:Double, distanceMeters:Double, origin:CLLocationCoordinate2D) -> CLLocationCoordinate2D {
        let distRadians = distanceMeters / (6372797.6) // earth radius in meters
        let bearingRadians = bearing * (.pi / 180)
        // print("bearingRadians: \(bearingRadians)")

        let lat1 = origin.latitude * Double.pi / 180
        let lon1 = origin.longitude * Double.pi / 180

        let lat2 = asin(sin(lat1) * cos(distRadians) + cos(lat1) * sin(distRadians) * cos(bearingRadians))
        let lon2 = lon1 + atan2(sin(bearingRadians) * sin(distRadians) * cos(lat1), cos(distRadians) - sin(lat1) * sin(lat2))
        
//        print(CLLocationCoordinate2D(latitude: lat2 * 180 / Double.pi, longitude: lon2 * 180 / Double.pi))

        return CLLocationCoordinate2D(latitude: lat2 * 180 / Double.pi, longitude: lon2 * 180 / Double.pi)
    }
    
    func coneAlertCheck(phoneHeading: Double, phoneLat: Double, phoneLng: Double, checkLat: Double, checkLng: Double, distance: Double, angle: Double) -> Bool {
        
        print("coneAlertCheck")
        let safePhoneHeading = getSafeHeading(phoneHeading)
        let point1 = locationWithBearing(bearing: getSafeHeading(safePhoneHeading + angle/2), distanceMeters: distance, origin: CLLocationCoordinate2D(latitude: phoneLat, longitude: phoneLng))
        let point2 = locationWithBearing(bearing: getSafeHeading(safePhoneHeading - angle/2), distanceMeters: distance, origin: CLLocationCoordinate2D(latitude: phoneLat, longitude: phoneLng))
        print("pt: \(CLLocationCoordinate2D(latitude: checkLat, longitude: checkLng)), v1: \(CLLocationCoordinate2D(latitude: phoneLat, longitude: phoneLng)), v2: \(point1), v3: \(point2)")
        
        if MQTTManager.sharedInstance.devPoints.count != 0 {
            
            MQTTManager.sharedInstance.devPoints[0] = MyAnnotationItem(name: "p1", image: "walker-vector", coordinate: point1)
            MQTTManager.sharedInstance.devPoints[1] = MyAnnotationItem(name: "p2", image: "walker-vector", coordinate: point2)
            
        }
        return pointInTriangle(
            pt: CLLocationCoordinate2D(latitude: checkLat, longitude: checkLng),
            v1: CLLocationCoordinate2D(latitude: phoneLat, longitude: phoneLng),
            v2: point1,
            v3: point2
        )
    }
}
