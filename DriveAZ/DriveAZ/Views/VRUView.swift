//
//  VRUView.swift
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

struct VRUView: View {

    var id: String
    var psm: PersonalSafetyMessage? {
        if id == "self" {
            return smManager.psm
        }
        return vruManager.seenVRUs[id]
    }
    @ObservedObject var vruManager: VRUManager = VRUManager.sharedInstance
    @ObservedObject var smManager: SafetyMessageManager = SafetyMessageManager.sharedInstance
    @ObservedObject var mqttManager: MQTTManager = MQTTManager.sharedInstance
    

    struct DataPoint: Identifiable {
        let label: String
        let key: String
        let value: String
        let id = UUID()
    }

    var dataPoints = [
        "Latitude",
        "Longitude",
        "Elevation (m)",
        "Heading (deg)",
        "Speed (m/s)",
        "Latitude Acceleration (m/s^2)",
        "Longitude Acceleration (m/s^2)"
    ]
    
    @State var data: [String:String] = [:]

    init(
        id: String
    ) {
        print("settings init")
        self.id = id
        updateData()
    }
    
    mutating func updateData() {
        if
            let grm = mqttManager.lastSeenGRMs[id],
            grm.messageType == "PSM"
        {
            print("settings psm")
            let psm = grm.messageFrame.value.choice.PersonalSafetyMessage
            data["Latitude"] = "\(latitudeRangeMap.mapReverse(psm.position.lat) ?? 0)"
            data["Longitude"] = "\(longitudeRangeMap.mapReverse(psm.position.Long) ?? 0)"
            if let elevationPointer = psm.position.elevation,
               let elevationValue = elevationRangeMap.mapReverse(elevationPointer.pointee) {
                data["Elevation (m)"] = "\(elevationValue)"
            } else {
                data["Elevation (m)"] = "--.--"
            }
            data["Heading (deg)"] = "\(headingRangeMap.mapReverse(psm.heading) ?? 0)"
            data["Speed (m/s)"] = "\(speedRangeMap.mapReverse(psm.speed) ?? 0)"
            if
                let accelSetPointer = psm.accelSet,
                let accelSetValue = accelSet4WayAccelerationLateralRangeMap.mapReverse(
                    accelSetPointer.pointee.lat
                )
            {
                data["Latitude Acceleration (m/s^2)"] = "\(accelSetValue)"
            } else {
                data["Latitude Acceleration (m/s^2)"] = "--.--"
            }
            if
                let accelSetPointer = psm.accelSet,
                let accelSetValue = accelSet4WayAccelerationLateralRangeMap.mapReverse(
                    accelSetPointer.pointee.Long
                )
            {
                data["Longitude Acceleration (m/s^2)"] = "\(accelSetValue)"
            } else {
                data["Longitude Acceleration (m/s^2)"] = "--.--"
            }
        } else if let grm = mqttManager.lastSeenGRMs[id],
                  grm.messageType == "TIM" {
            
            print("settings tim")
            dataPoints = [
                "TIM type",
                "Latitude",
                "Longitude"
            ]
            
            let timString = MQTTManager.sharedInstance.msgToTIMString(grm)
            data["TIM type"] = "Unknown"
            if timString == "boq" {
                data["TIM type"] = "Back of Queue"
            } else if timString == "workzone" {
                data["TIM type"] = "Workzone"
            }
            
            if
                let (lat, long) = MQTTManager.sharedInstance.getTIMLLatLng(grm)
            {
                data["Latitude"] = "\(Double(lat)/1e7)"
                data["Longitude"] = "\(Double(long)/1e7)"
            }
            
            
        }
    }
    
    func tempButton(){
        print("button")
        LogInManager.sharedInstance.isLoggedIn = true
    }

    var body: some View {
        ZStack {
            Color(red: 242/255, green: 242/255, blue: 247/255).ignoresSafeArea()
            VStack {
                Text("Transmitted Data")
                    .font(.custom("Ford Antenna Semibold", size: 14))
                    .foregroundColor(Color(#colorLiteral(red: 0, green: 0.2, blue: 0.47, alpha: 1)))
                    .multilineTextAlignment(.center)
                List(dataPoints, id: \.self) { item in
                    HStack {
                        Text(item).font(.custom("Open Sans Regular", size: 17)).tracking(-0.41)
                        Spacer()
                        
                        switch dataPoints.firstIndex(of: item) {
                        case 0: // Latitude
                            Text(data[item] ?? "--.--")
                                .font(.custom("Open Sans Regular", size: 17))
                                .foregroundColor(Color(#colorLiteral(red: 0.5, green: 0.5, blue: 0.5, alpha: 1)))
                                .tracking(-0.41)
                        case 1: // Longitude
                            Text(data[item] ?? "--.--")
                                .font(.custom("Open Sans Regular", size: 17))
                                .foregroundColor(Color(#colorLiteral(red: 0.5, green: 0.5, blue: 0.5, alpha: 1)))
                                .tracking(-0.41)
                        case 2: // Elevation
                            Text(data[item] ?? "--.--")
                                .font(.custom("Open Sans Regular", size: 17))
                                .foregroundColor(Color(#colorLiteral(red: 0.5, green: 0.5, blue: 0.5, alpha: 1)))
                                .tracking(-0.41)
                        case 3: // Heading
                            Text(data[item] ?? "--.--")
                                .font(.custom("Open Sans Regular", size: 17))
                                .foregroundColor(Color(#colorLiteral(red: 0.5, green: 0.5, blue: 0.5, alpha: 1)))
                                .tracking(-0.41)
                        case 4: // Speed
                            Text(data[item] ?? "--.--")
                                .font(.custom("Open Sans Regular", size: 17))
                                .foregroundColor(Color(#colorLiteral(red: 0.5, green: 0.5, blue: 0.5, alpha: 1)))
                                .tracking(-0.41)
                        case 5: // Latitude Acceleration
                            Text(data[item] ?? "--.--")
                                .font(.custom("Open Sans Regular", size: 17))
                                .foregroundColor(Color(#colorLiteral(red: 0.5, green: 0.5, blue: 0.5, alpha: 1)))
                                .tracking(-0.41)
                        case 6: // Longitude Acceleration
                            Text(data[item] ?? "--.--")
                                .font(.custom("Open Sans Regular", size: 17))
                                .foregroundColor(Color(#colorLiteral(red: 0.5, green: 0.5, blue: 0.5, alpha: 1)))
                                .tracking(-0.41)
                        case 7: // Path Prediction
                            Text(data[item] ?? "--.--")
                                .font(.custom("Open Sans Regular", size: 17))
                                .foregroundColor(Color(#colorLiteral(red: 0.5, green: 0.5, blue: 0.5, alpha: 1)))
                                .tracking(-0.41)
                        default:
                            Text("???")
                                .font(.custom("Open Sans Regular", size: 17))
                                .foregroundColor(Color(#colorLiteral(red: 0.5, green: 0.5, blue: 0.5, alpha: 1)))
                                .tracking(-0.41)
                        }

                    }
                }
            }
            
            VStack {
                Spacer()
                HStack{
                    Spacer()
                    Image("Group 101")
                        .padding(.trailing, 10)
                        .padding(.bottom, 10)
                        .onTapGesture {
                            print("cool")
                            viewToShow = viewToGoBackTo
                            tempButton()
                        }
                }
                .padding(.trailing, 10)
                .padding(.bottom, 30)
            }
        }
        .offset(x: 0, y: -8)
        .frame(width: 375, height: 725)
        .onReceive(mqttManager.$lastSeenGRMs) { newValue in
            print("settings onReceive(mqttManager.$someData)")
            if
                let grm = mqttManager.lastSeenGRMs[id],
                grm.messageType == "PSM"
            {
                print("settings psm")
                let psm = grm.messageFrame.value.choice.PersonalSafetyMessage
                data["Latitude"] = "\(latitudeRangeMap.mapReverse(psm.position.lat) ?? 0)"
                data["Longitude"] = "\(longitudeRangeMap.mapReverse(psm.position.Long) ?? 0)"
                if let elevationPointer = psm.position.elevation,
                   let elevationValue = elevationRangeMap.mapReverse(elevationPointer.pointee) {
                    data["Elevation (m)"] = "\(elevationValue)"
                } else {
                    data["Elevation (m)"] = "--.--"
                }
                data["Heading (deg)"] = "\(headingRangeMap.mapReverse(psm.heading) ?? 0)"
                data["Speed (m/s)"] = "\(speedRangeMap.mapReverse(psm.speed) ?? 0)"
                if
                    let accelSetPointer = psm.accelSet,
                    let accelSetValue = accelSet4WayAccelerationLateralRangeMap.mapReverse(
                        accelSetPointer.pointee.lat
                    )
                {
                    data["Latitude Acceleration (m/s^2)"] = "\(accelSetValue)"
                } else {
                    data["Latitude Acceleration (m/s^2)"] = "--.--"
                }
                if
                    let accelSetPointer = psm.accelSet,
                    let accelSetValue = accelSet4WayAccelerationLateralRangeMap.mapReverse(
                        accelSetPointer.pointee.Long
                    )
                {
                    data["Longitude Acceleration (m/s^2)"] = "\(accelSetValue)"
                } else {
                    data["Longitude Acceleration (m/s^2)"] = "--.--"
                }
            } else if let grm = mqttManager.lastSeenGRMs[id],
                      grm.messageType == "TIM" {
                
        
                let timString = MQTTManager.sharedInstance.msgToTIMString(grm)
                data["TIM type"] = "Unknown"
                if timString == "boq" {
                    data["TIM type"] = "Back of Queue"
                } else if timString == "workzone" {
                    data["TIM type"] = "Workzone"
                }
                
                if
                    let (lat, long) = MQTTManager.sharedInstance.getTIMLLatLng(grm)
                {
                    data["Latitude"] = "\(Double(lat)/1e7)"
                    data["Longitude"] = "\(Double(long)/1e7)"
                }
                
                
            }
        }
    }

    func getPSM() -> PersonalSafetyMessage? {
        return psm
    }
}

struct ThirdView: View {
    var id: String

    init(
        id: String
    ) {
        self.id = id
    }
    var body: some View {
        CustomNavigationView(
            leftDestination: EmptyView(),
            rightDestination: EmptyView(),
            isRoot: false,
            isLast: true,
            title: id,
            leftButton: nil,
            rightButton: nil
        ) {
            VRUView(id: id)
                .navigationBarHidden(true)
        }
        .navigationBarHidden(true)
    }
}

struct ThirdView_Previews: PreviewProvider {
    static var previews: some View { Group { ThirdView(id: "Preview") } }
}
