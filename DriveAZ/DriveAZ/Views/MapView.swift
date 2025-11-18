//
//  MapView.swift
//  DriveAZ
//
//  Created by Ben on 5/18/22.
//

import Foundation
import SwiftUI
import MapKit
import CoreLocation
import B2VExtras
import B2VExtrasSwift
@_spi(Experimental) import MapboxMaps

struct MyAnnotationItem: Identifiable {
    var name: String
    var image: String
    var coordinate: CLLocationCoordinate2D
    let id = UUID()
}

struct GRMAnnotationItem: Identifiable, Equatable, Comparable {
    static func < (lhs: GRMAnnotationItem, rhs: GRMAnnotationItem) -> Bool {
        return lhs.id < rhs.id
    }
    
    static func == (lhs: GRMAnnotationItem, rhs: GRMAnnotationItem) -> Bool {
        return lhs.id == rhs.id &&
            lhs.messageType == rhs.messageType &&
            lhs.grm.position.latitude == rhs.grm.position.latitude &&
            lhs.grm.position.longitude == rhs.grm.position.longitude
    }
    
    var grm: Georoutedmsg_GeoRoutedMsg
    var messageFrame: MessageFrame
    var messageType: String
    var specificMessageType: String?
    let id: String
    var showAlert = true
    var lastAlertTimeStamp: Double?
    var lastMessageTimeStamp: Double
    var timObject: [String:Any]?
}

struct OldMapView: View, LocationManagerDelegate {
    @State private var region = MKCoordinateRegion(
        center: LocationManager.sharedInstance.lastSeenLocation?.coordinate
            ?? CLLocationCoordinate2D(latitude: 37.3349, longitude: -122.00902),
        span: MKCoordinateSpan(latitudeDelta: 0.004, longitudeDelta: 0.004)
    )
    @State private var position: MapCameraPosition = .userLocation(
        followsHeading: true,
        fallback: .region(MKCoordinateRegion(
            center: LocationManager.sharedInstance.lastSeenLocation?.coordinate
                ?? CLLocationCoordinate2D(latitude: 37.3349, longitude: -122.00902),
            span: MKCoordinateSpan(latitudeDelta: 0.004, longitudeDelta: 0.004)
        ))
    )
    let defaultViewport: Viewport = .followPuck(zoom: 16, bearing: .course ,pitch: 60)
    @State var viewport: Viewport = .followPuck(zoom: 16, bearing: .course ,pitch: 60)
    
//    @State private var position: MapCameraPosition = .automatic
    
    @ObservedObject var vruManager: VRUManager = VRUManager.sharedInstance
    // Observe MQTTManager so we have access to lastSeenGRMs.
    @ObservedObject var mqttManager: MQTTManager = MQTTManager.sharedInstance
    
    var body: some View {
        ZStack {
            MapboxMaps.Map(viewport: $viewport) {
                Puck2D(bearing: .course)
                
                PointAnnotationGroup(mqttManager.alertArray, id: \.id) { item in
                                PointAnnotation(coordinate: CLLocationCoordinate2D(
                                        latitude: item.grm.position.latitude,
                                        longitude: item.grm.position.longitude))
                                .image(named: msgToIconString(item)).iconSize(0.6)
                                .onTapGesture{
                                    print("settings map \(item.id)")
                                    viewToShow = "vru"
                                    vruToShow = item.id
                                    viewToGoBackTo = "map"
                                    tempButton()
                                }
                            }
            }
            VStack {
                // Show alerts for GRMs that have showAlert == true.
                // reduce only shows one of each color at a time
                ForEach(Array(Array(mqttManager.lastSeenGRMs.values).filter({ $0.showAlert }).reduce(into: [String: GRMAnnotationItem](), { result, message in
                    result[message.specificMessageType] = message
                }).values).sorted(), id: \.id) { grm in
                    ZStack {
                        
                        // commented out for while we have only one of each type
//                        if grm.messageType == "TIM" {
//                            Rectangle()
//                              .foregroundColor(.clear)
//                              .frame(width: 350, height: 116)
//                              .background(msgToBacgroundColor(grm))
//                              .cornerRadius(30)
//                              .shadow(color: .black.opacity(0.25), radius: 10, x: 0, y: 4)
//                              .offset(y:42)
//                            
//                            Text(msgToDistanceString(grm))
//                              .font(Font.custom("Manrope", size: 30))
//                              .multilineTextAlignment(.center)
//                              .foregroundColor(.white)
//                              .offset(y:57+12)
//                            
//                        }
                        Rectangle()
                            .foregroundColor(.clear)
                            .frame(width: 410, height: 84)
                            .background(msgToColor(grm))
                            .cornerRadius(30)
                        HStack {
                            Spacer(minLength: 5)
                            Image(msgToVectorString(grm))
                                .frame(width: 42.76, height: 36.89)
                                .foregroundColor(.white)
                                .background(msgToColor(grm))
                            Spacer()
                            Text(msgToNameString(grm))
                                .font(Font.custom("Manrope", size: 35))
                                .multilineTextAlignment(.center)
                                .foregroundColor(.white)
                            Spacer()
                        }
                    }
                }
                Spacer()
            }
            VStack {
                Spacer()
                HStack {
                    Image("Group 104")
                        .padding(.leading, 10)
                        .padding(.bottom, 10)
                        .onTapGesture {
                            viewport = defaultViewport
                        }
                    Spacer()
                    Image("Group 99")
                        .padding(.trailing, 10)
                        .padding(.bottom, 10)
                        .onTapGesture {
                            print("cool")
                            viewToShow = "settings"
                            tempButton()
                        }
                }
                .padding(.trailing, 10)
                .padding(.bottom, 30)
            }
        }
    }
    
    init() {
        
        print("map init")
        region.span = MKCoordinateSpan(latitudeDelta: 0.004, longitudeDelta: 0.004)
        LocationManager.sharedInstance.delegate = self
        let key = Bundle.main.object(forInfoDictionaryKey: "DAZ_MAPBOX_KEY") as? String
        MapboxOptions.accessToken = key!
        print("Mapbox key is", key ?? "NO KEY")
    }
    
    func msgToIconString(_ grmAnnotation: GRMAnnotationItem) -> String {
        if grmAnnotation.messageType == "BSM" {
            return "car-icon" // Car icon for BSM
        } else if grmAnnotation.messageType == "PSM" {
            if grmAnnotation.messageFrame.value.choice.PersonalSafetyMessage.basicType == 2 {
                return "bike-icon" // Cyclist icon
            }
            return "walker-icon" // Pedestrian icon
        } else if grmAnnotation.messageType == "TIM" {
            if MQTTManager.sharedInstance.msgToTIMString(grmAnnotation) == "boq" {
                return "traffic-icon"
            } else if MQTTManager.sharedInstance.msgToTIMString(grmAnnotation) == "workzone" {
                return "alert-icon"
            }
        }
        return "default-icon" // Fallback icon
    }
    
    func msgToVectorString(_ grmAnnotation: GRMAnnotationItem) -> String {
        if grmAnnotation.messageType == "BSM" {
            return "car-vector" // Car icon for BSM
        } else if grmAnnotation.messageType == "PSM" {
            if grmAnnotation.messageFrame.value.choice.PersonalSafetyMessage.basicType == 2 {
                return "bike-vector" // Cyclist icon
            }
            return "walker-vector" // Pedestrian icon
        } else if grmAnnotation.messageType == "TIM" {
            if MQTTManager.sharedInstance.msgToTIMString(grmAnnotation) == "boq" {
                return "traffic-vector"
            } else if MQTTManager.sharedInstance.msgToTIMString(grmAnnotation) == "workzone" {
                return "alert-vector"
            }
        }
        return "alert-vector" // Fallback icon
    }
    
    func msgToNameString(_ grmAnnotation: GRMAnnotationItem) -> String {
        if grmAnnotation.messageType == "BSM" {
            return "Car"
        } else if grmAnnotation.messageType == "PSM" {
            if grmAnnotation.messageFrame.value.choice.PersonalSafetyMessage.basicType == 2 {
                return "Cyclist"
            }
            return "Pedestrian"
        } else if grmAnnotation.messageType == "TIM" {
            if MQTTManager.sharedInstance.msgToTIMString(grmAnnotation) == "boq" {
                return "Traffic Jam"
            } else if MQTTManager.sharedInstance.msgToTIMString(grmAnnotation) == "workzone" {
                return "Work Zone"
            }
        }
        return "Unknown"
    }
    
    func msgToColor(_ grmAnnotation: GRMAnnotationItem) -> Color {
        if grmAnnotation.messageType == "BSM" {
            return Color(red: 0.3, green: 0.8, blue: 0.2) // Car color
        } else if grmAnnotation.messageType == "PSM" {
            if grmAnnotation.messageFrame.value.choice.PersonalSafetyMessage.basicType == 2 {
                return Color(red: 0, green: 0.3, blue: 0.85) // Cyclist color
            }
            return Color(red: 0.79, green: 0.42, blue: 0.98) // Pedestrian color
        } else if grmAnnotation.messageType == "TIM" {
            if MQTTManager.sharedInstance.msgToTIMString(grmAnnotation) == "boq" {
                return Color(red: 0.96, green: 0.19, blue: 0.28)
            } else if MQTTManager.sharedInstance.msgToTIMString(grmAnnotation) == "workzone" {
                return Color(red: 1, green: 0.54, blue: 0)
            }
        }
        return Color.gray // Default color
    }
    
    func msgToBacgroundColor(_ grmAnnotation: GRMAnnotationItem) -> Color {
        if grmAnnotation.messageType == "TIM" {
            if MQTTManager.sharedInstance.msgToTIMString(grmAnnotation) == "boq" {
                return Color(red: 0.83, green: 0.13, blue: 0.21)
            } else if MQTTManager.sharedInstance.msgToTIMString(grmAnnotation) == "workzone" {
                return Color(red: 0.87, green: 0.48, blue: 0.01)
            }
        }
        return Color.gray
    }
    
    func msgToDistanceString(_ grmAnnotation: GRMAnnotationItem) -> String {
        if
            let phoneLoc = LocationManager.sharedInstance.lastSeenLocation
        {
            
            let dist = phoneLoc.distance(from: CLLocation(latitude: grmAnnotation.grm.position.latitude, longitude: grmAnnotation.grm.position.longitude))
            let miles = dist / 1609.344
            let feet = miles * 5280
            let value = Int(round(feet))
            let numberFormatter = NumberFormatter()
            numberFormatter.numberStyle = .decimal
            let formattedNumber = numberFormatter.string(from: NSNumber(value:value))
            return "\(formattedNumber ?? "\(value)") feet"
        }
        return ""
    }

    
    func tempButton() {
        print("button")
        LogInManager.sharedInstance.isLoggedIn = true
        let idk = MQTTManager.sharedInstance.lastSeenGRMs
        for key in MQTTManager.sharedInstance.lastSeenGRMs.keys {
            print(key)
            let thing = MQTTManager.sharedInstance.lastSeenGRMs[key]
            print(thing?.grm.position.latitude, thing?.grm.position.longitude)
            if let t = thing {
                print(AlertManager.sharedInstance.getLocationFromAGRM(grm: t))
            } else {
                print("no grm")
            }
        }
        let location1 = LocationManager.sharedInstance.lastSeenLocation?.coordinate
        print("break: location: \(location1)")
        let course = LocationManager.sharedInstance.lastSeenCourse
        print("break: course: \(course)")
        let locationCourse = LocationManager.sharedInstance.lastSeenLocation?.course
        print("break: location.course: \(locationCourse)")
        let speed = LocationManager.sharedInstance.lastSeenLocation?.speed
        print("break: speed: \(speed)")
        if
            let location = LocationManager.sharedInstance.lastSeenLocation
        {
            let alertDistance = AlertManager.sharedInstance.getAlertDistance(location)
            print("break: alertDistance: \(alertDistance)")
        } else {
            print("break: nil alertDistance")
        }
        
        
        
        if MQTTManager.sharedInstance.devPoints.count != 0 {
            let devpoint0 = MQTTManager.sharedInstance.devPoints[0]
            let devpoint1 = MQTTManager.sharedInstance.devPoints[1]
            print("break: devPoints[0]: \(devpoint0)")
            print("break: devPoints[1]: \(devpoint1)")
            
            
        } else {
            print("no dev points")
        }
            
    }
    
    mutating func locationIsUpdated() {
        print("MAP locationIsUpdated")
        
        print("map position followsUserHeading", position.followsUserHeading)
        print("map position followsUserLocation", position.followsUserLocation)
        print("map position camera", position.camera)
        print("map position region", position.region)
        
        
        var course = LocationManager.sharedInstance.lastSeenCourse ?? 0
        
        if UIDevice.current.isSimulator {
            course = AlertManager.sharedInstance.simulatorHeading
        }
        
        
        let conePoint1 = AlertManager.sharedInstance.locationWithBearing(bearing: AlertManager.sharedInstance.getSafeHeading(course + AlertManager.sharedInstance.alertAngle/2), distanceMeters: AlertManager.sharedInstance.getAlertDistance(LocationManager.sharedInstance.lastSeenLocation!), origin: CLLocationCoordinate2D(latitude: LocationManager.sharedInstance.lastSeenLocation!.coordinate.latitude, longitude: LocationManager.sharedInstance.lastSeenLocation!.coordinate.longitude))
        
        let conePoint2 = AlertManager.sharedInstance.locationWithBearing(bearing: AlertManager.sharedInstance.getSafeHeading(course - AlertManager.sharedInstance.alertAngle/2), distanceMeters: AlertManager.sharedInstance.getAlertDistance(LocationManager.sharedInstance.lastSeenLocation!), origin: CLLocationCoordinate2D(latitude: LocationManager.sharedInstance.lastSeenLocation!.coordinate.latitude, longitude: LocationManager.sharedInstance.lastSeenLocation!.coordinate.longitude))
        
        
        let timConePoint1 = AlertManager.sharedInstance.locationWithBearing(bearing: AlertManager.sharedInstance.getSafeHeading(course + AlertManager.sharedInstance.alertAngle/2), distanceMeters: 500, origin: CLLocationCoordinate2D(latitude: LocationManager.sharedInstance.lastSeenLocation!.coordinate.latitude, longitude: LocationManager.sharedInstance.lastSeenLocation!.coordinate.longitude))
        
        let timConePoint2 = AlertManager.sharedInstance.locationWithBearing(bearing: AlertManager.sharedInstance.getSafeHeading(course - AlertManager.sharedInstance.alertAngle/2), distanceMeters: 500, origin: CLLocationCoordinate2D(latitude: LocationManager.sharedInstance.lastSeenLocation!.coordinate.latitude, longitude: LocationManager.sharedInstance.lastSeenLocation!.coordinate.longitude))
        
        
        let pt = CLLocationCoordinate2D(latitude: 43.245545, longitude: -83.798649)
        let v1 = CLLocationCoordinate2D(latitude: 43.24551227743429, longitude: -83.79885937279616)
        let v2 = CLLocationCoordinate2D(latitude: 43.245574941230196, longitude: -83.79882351929369)
        let v3 = CLLocationCoordinate2D(latitude: 43.24557505461567, longitude: -83.79889485050583)
        
//        mqttManager.devPoints = [
//            MyAnnotationItem(name: "pt", image: "walker-vector", coordinate: pt),
//            MyAnnotationItem(name: "v1", image: "alert-vector", coordinate: v1),
//            MyAnnotationItem(name: "v2", image: "alert-vector", coordinate: v2),
//            MyAnnotationItem(name: "v3", image: "alert-vector", coordinate: v3)
//        ]
        
        mqttManager.devPoints = [
            MyAnnotationItem(name: "p1", image: "walker-vector", coordinate: conePoint1),
            MyAnnotationItem(name: "p2", image: "walker-vector", coordinate: conePoint2),
            MyAnnotationItem(name: "t1", image: "alert-vector", coordinate: timConePoint1),
            MyAnnotationItem(name: "t2", image: "alert-vector", coordinate: timConePoint2)
        ]
        
        MQTTManager.sharedInstance.locationIsUpdated()
        MQTTManager.sharedInstance.mapUpdates = MQTTManager.sharedInstance.mapUpdates + 1
//        tempButton()
    }
}

struct FirstView: View {
    var body: some View {
        OldMapView()
    }
}

struct FirstView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            OldMapView()
        }
    }
}
