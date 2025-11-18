//
//  NewMapView.swift
//  DriveAZ
//
//  Created by Ben on 3/12/25.
//

import SwiftUI
import MapKit
import CoreLocation
import B2VExtras
import B2VExtrasSwift

struct MapView: UIViewRepresentable {
    @Binding var region: MKCoordinateRegion
    @Binding var userLocation: CLLocationCoordinate2D
    @Binding var userHeading: CLLocationDirection?
    @Binding var userCourse: Double?
    
    class Coordinator: NSObject, LocationManagerDelegate {
        
        var mapView: MKMapView
//        var locationManager: CLLocationManager
        var parent: MapView
        
        init(mapView: MKMapView, parent: MapView) {
            print("map Coordinator init")
            self.mapView = mapView
            self.parent = parent
//            self.locationManager = CLLocationManager()
            super.init()
            LocationManager.sharedInstance.delegate = self
            
//            self.locationManager.delegate = self
//            self.locationManager.desiredAccuracy = kCLLocationAccuracyBestForNavigation
//            self.locationManager.startUpdatingLocation()
//            self.locationManager.startUpdatingHeading()
            self.mapView.showsUserLocation = true
            self.mapView.userTrackingMode = .followWithHeading
        }
        
        
        func locationIsUpdated() {
            
            print("map didUpdateLocations 1")
            guard let location = LocationManager.sharedInstance.lastSeenLocation else { return }
            print("map didUpdateLocations 2")
            
            print("map userLocation", location.coordinate)
            print("map userCourse", location.course)
            print("")
            
            // Update the map region
            self.parent.userLocation = location.coordinate
            self.parent.userCourse = location.course
            self.parent.region = MKCoordinateRegion(
                center: location.coordinate,
                span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
            )
        }
        
        func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        }
        
        func locationManager(_ manager: CLLocationManager, didUpdateHeading newHeading: CLHeading) {
            // Update the heading
            self.parent.userHeading = newHeading.trueHeading
        }
    }
    
    func makeCoordinator() -> Coordinator {
        return Coordinator(mapView: MKMapView(), parent: self)
    }
    
    func makeUIView(context: Context) -> MKMapView {
        return MKMapView()
    }
    
    func updateUIView(_ uiView: MKMapView, context: Context) {
        // Update the map region
        uiView.setRegion(region, animated: true)
        
        if
            let course = userCourse,
            course != -1
        {
            uiView.camera.heading = course
        }
    }
}

struct NewContentView: View {
    @State private var region = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 37.7749, longitude: -122.4194), // Example coordinates
        span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
    )
    
    @State private var userLocation = CLLocationCoordinate2D(latitude: 37.7749, longitude: -122.4194)
    @State private var userHeading: CLLocationDirection? = nil
    @State private var userCourse: Double? = nil
    
    var body: some View {
        MapView(region: $region, userLocation: $userLocation, userHeading: $userHeading, userCourse: $userCourse)
            .edgesIgnoringSafeArea(.all)
            .onAppear {
                // Optional: Request location permissions here if needed
            }
    }
}
