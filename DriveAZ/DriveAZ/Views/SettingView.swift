//
//  SettingView.swift
//  DriveAZ
//
//  Created by Ben on 5/18/22.
//

import Foundation
import SwiftUI
import MapKit
import CoreLocation
import B2VExtrasSwift

struct SettingsView: View {
    @State private var anonymousTracking = true
    @State private var dataSaver = false
    @State private var geofencingEnabled = false
    @State private var showLogIn = false
    @State private var showingDetail = false
    
    @ObservedObject var alertManager: AlertManager = AlertManager.sharedInstance
    @ObservedObject var mqttManager: MQTTManager = MQTTManager.sharedInstance
    
    var body: some View {
        ZStack {
            VStack {
                HStack{
                    Spacer()
                    // H3
                    Text("Settings")
                        .font(Font.custom("Manrope", size: 30))
                        .multilineTextAlignment(.center)
                        .foregroundColor(.black)
                    Spacer()
                }
                ScrollView {
                    ZStack {
                        Rectangle()
                            .foregroundColor(.clear)
                            .frame(width: 390.78711, height: 115.42383)
                            .background(Constants.Grey04)
                            .cornerRadius(20)
                        HStack {
                            Spacer()
                            VStack {
                                // P1
                                Text("VRU Mode")
                                    .font(
                                        Font.custom("Manrope", size: 16)
                                            .weight(.medium)
                                    )
                                    .foregroundColor(.black)
                                    .frame(width: 190.87012, alignment: .leading)// P2
                                Text("Will broadcast safety message as pedestrian")
                                    .font(Font.custom("Manrope", size: 14))
                                    .foregroundColor(Color(red: 0.22, green: 0.22, blue: 0.22))
                                    .frame(width: 208.30957, alignment: .topLeading)
                            }
                            Toggle("", isOn: Binding(
                                get: { MQTTManager.sharedInstance.vruMode },
                                set: { MQTTManager.sharedInstance.vruMode = $0 }
                            ))
                            Spacer()
                        }
                    }
                    ZStack {
                        Rectangle()
                            .foregroundColor(.clear)
                            .frame(width: 390.78711, height: 115.42383)
                            .background(Constants.Grey04)
                            .cornerRadius(20)
                        HStack {
                            Spacer()
                            VStack {
                                // P1
                                Text("Send While Not Moving")
                                    .font(
                                        Font.custom("Manrope", size: 16)
                                            .weight(.medium)
                                    )
                                    .foregroundColor(.black)
                                    .frame(width: 190.87012, alignment: .leading)// P2
                                Text("Send messages even if location is not changing")
                                    .font(Font.custom("Manrope", size: 14))
                                    .foregroundColor(Color(red: 0.22, green: 0.22, blue: 0.22))
                                    .frame(width: 208.30957, alignment: .topLeading)
                            }
                            Toggle("", isOn: Binding(
                                get: { MQTTManager.sharedInstance.sendWhileNotMoving },
                                set: { MQTTManager.sharedInstance.updateSendWhileNotMoving($0) }
                            ))
                            Spacer()
                        }
                    }
                    ZStack {
                        Rectangle()
                            .foregroundColor(.clear)
                            .frame(width: 390.78711, height: 77)
                            .background(Constants.Grey04)
                            .cornerRadius(20)
                        HStack {
                            Spacer()
                            VStack {
                                // P1
                                Text("Publish to Public Topic")
                                    .font(
                                        Font.custom("Manrope", size: 16)
                                            .weight(.medium)
                                    )
                                    .foregroundColor(.black)
                                    .frame(width: 190.87012, alignment: .leading)// P2
                            }
                            Toggle("", isOn: Binding(
                                get: { MQTTManager.sharedInstance.sendingOnPublic },
                                set: { MQTTManager.sharedInstance.updateSendingOnPublicChannel($0) }
                            ))
                            Spacer()
                        }
                    }
                    ZStack {
                        Rectangle()
                            .foregroundColor(.clear)
                            .frame(width: 390.78711, height: 77)
                            .background(Constants.Grey04)
                            .cornerRadius(20)
                        HStack {
                            Spacer()
                            VStack {
                                // P1
                                Text("Publish to Vendor Topic")
                                    .font(
                                        Font.custom("Manrope", size: 16)
                                            .weight(.medium)
                                    )
                                    .foregroundColor(.black)
                                    .frame(width: 190.87012, alignment: .leading)// P2
                            }
                            Toggle("", isOn: Binding(
                                get: { MQTTManager.sharedInstance.sendingOnVendor },
                                set: { MQTTManager.sharedInstance.updateSendingOnVendorChannel($0) }
                            ))
                            Spacer()
                        }
                    }
                    ZStack {
                        Rectangle()
                            .foregroundColor(.clear)
                            .frame(width: 390.78711, height: 77)
                            .background(Constants.Grey04)
                            .cornerRadius(20)
                        HStack {
                            Spacer()
                            VStack {
                                // P1
                                Text("Subscribe to Public Topic")
                                    .font(
                                        Font.custom("Manrope", size: 16)
                                            .weight(.medium)
                                    )
                                    .foregroundColor(.black)
                                    .frame(width: 190.87012, alignment: .leading)// P2
                            }
                            Toggle("", isOn: Binding(
                                get: { MQTTManager.sharedInstance.listeningOnPublic },
                                set: { MQTTManager.sharedInstance.updateListeningOnPublicChannel($0) }
                            ))
                            Spacer()
                        }
                    }
                    ZStack {
                        Rectangle()
                            .foregroundColor(.clear)
                            .frame(width: 390.78711, height: 77)
                            .background(Constants.Grey04)
                            .cornerRadius(20)
                        HStack {
                            Spacer()
                            VStack {
                                // P1
                                Text("Subscribe to Vendor Topic")
                                    .font(
                                        Font.custom("Manrope", size: 16)
                                            .weight(.medium)
                                    )
                                    .foregroundColor(.black)
                                    .frame(width: 190.87012, alignment: .leading)// P2
                            }
                            Toggle("", isOn: Binding(
                                get: { MQTTManager.sharedInstance.listeningOnVendor },
                                set: { MQTTManager.sharedInstance.updateListeningOnVendorChannel($0) }
                            ))
                            Spacer()
                        }
                    }
                    
                    ZStack {
                        VStack {
                            HStack {
                                Text("Seen Messages")
                                .font(Font.custom("Manrope", size: 30))
                                .multilineTextAlignment(.center)
                                .foregroundColor(.black)
                            }
                            ForEach(Array(mqttManager.lastSeenGRMs.values), id: \.id) { grm in
                                ZStack {
                                    HStack(alignment: .center, spacing: 10) {
                                        // P2
                                        Text("\(grm.messageType)")
                                          .font(Font.custom("Manrope", size: 14))
                                          .foregroundColor(Color(red: 0.22, green: 0.22, blue: 0.22))
                                        // P2
                                        Text("\(grm.id)")
                                          .font(Font.custom("Manrope", size: 14))
                                          .multilineTextAlignment(.trailing)
                                          .foregroundColor(Color(red: 0.22, green: 0.22, blue: 0.22))
                                          .frame(width: 271, alignment: .topTrailing)
                                    }
                                    .padding(.horizontal, 20)
                                    .padding(.vertical, 10)
                                    .frame(width: 392, alignment: .center)
                                    .background(Constants.Grey04)
                                    .cornerRadius(50)
                                }.onTapGesture{
                                    print("settings \(grm.id)")
                                    viewToShow = "vru"
                                    vruToShow = grm.id
                                    viewToGoBackTo = "settings"
                                    tempButton()
                                }
                            }
                        }
                    }
                    
                    
                    Text("Messages Sent: \(mqttManager.numberOfSentMessages)")
                    Text("Messages Recieved: \(mqttManager.numberOfRecievedMessages)")
                    Text("Is Connected: \(mqttManager.isConnected)")
                    Text("MQTT Server: \(mqttManager.mqttHost)")
                    Text("PSMs unable to process: \(mqttManager.psmDecodeFailures)")
                    Text("TIMs unable to process: \(mqttManager.timDecodeFailures)")
                }
            }.padding(.bottom, 120)
            
            VStack {
                Spacer()
                HStack{
                    Spacer()
                    Image("Group 104")
                        .padding(.trailing, 10)
                        .padding(.bottom, 10)
                        .onTapGesture {
                            print("cool")
                            viewToShow = "map"
                            tempButton()
                        }
                }
                .padding(.trailing, 10)
                .padding(.bottom, 10)
            }
        }
    }

    var window: UIWindow? {
        guard let scene = UIApplication.shared.connectedScenes.first,
              let windowSceneDelegate = scene.delegate as? UIWindowSceneDelegate,
              let window = windowSceneDelegate.window else {
            return nil
        }
        return window
    }

    init() {
    }

    func signOut() {
        print("signOut")
        print("")
    }

    func showRedAlert() {
        print("showRedAlert")
//        alertManager.showingRedAlert = true
//        Timer.scheduledTimer(withTimeInterval: 5, repeats: false, block: { _ in
//            alertManager.showingRedAlert = false
//        })
//        ProxyManager.sharedManager.showRedAlert()
    }

    func showYellowAlert() {
        print("showYellowAlert")
//        alertManager.showingYellowAlert = true
//        Timer.scheduledTimer(withTimeInterval: 5, repeats: false, block: { _ in
//            alertManager.showingYellowAlert = false
//        })
//        ProxyManager.sharedManager.showYellowAlert()
    }
    
    func toggleGeofencing(geofencingEnabled: Bool) {
        print("toggleGeofencing")
        LocationManager.sharedInstance.toggleGeofencing(value: geofencingEnabled)
    }
    

    func connectSDL() {
        print("connectSDL")
        ProxyManager.sharedManager.connect()
    }
    
    func tempButton(){
        print("button")
        LogInManager.sharedInstance.isLoggedIn = true
    }
    
}

struct GeofencingView: View {
    @Environment(\.dismiss) private var dismiss

    @State private var latitude: String = String(LocationManager.sharedInstance.geofencingLatitude)
    @State private var longitude: String = String(LocationManager.sharedInstance.geofencingLongitude)
    @State private var radius: String = String(LocationManager.sharedInstance.geofencingRadius)
    
    var body: some View {
        CustomNavigationView(
            leftDestination: LastView(),
            rightDestination: EmptyView(),
            isRoot: false,
            isLast: true,
            title: "Geofencing Settings",
            leftButton: nil,
            rightButton: nil
        )
        {
            ZStack {
                VStack{
                    Spacer()
                    Text("Latitude:")
                    TextField("Latitude",
                              text: $latitude)
                        .textInputAutocapitalization(.never)
                        .disableAutocorrection(true)
                        .keyboardType(.numberPad)
                        .multilineTextAlignment(.center)
                        .textFieldStyle(.roundedBorder)
                        .onAppear(perform: {
                            latitude = String(LocationManager.sharedInstance.geofencingLatitude)
                        })
                        .selectAllTextOnEditing()
                    Text("Longitude:")
                    TextField("Longitude",
                              text: $longitude)
                        .textInputAutocapitalization(.never)
                        .disableAutocorrection(true)
                        .keyboardType(.numberPad)
                        .multilineTextAlignment(.center)
                        .textFieldStyle(.roundedBorder)
                        .onAppear(perform: {
                            latitude = String(LocationManager.sharedInstance.geofencingLongitude)
                        })
                        .selectAllTextOnEditing()
                    Spacer().frame(height: 25)
                    Text("Radius:")
                    TextField("Radius",
                              text: $radius)
                        .textInputAutocapitalization(.never)
                        .disableAutocorrection(true)
                        .keyboardType(.numberPad)
                        .multilineTextAlignment(.center)
                        .textFieldStyle(.roundedBorder)
                        .onAppear(perform: {
                            latitude = String(LocationManager.sharedInstance.geofencingRadius)
                        })
                        .selectAllTextOnEditing()
                    Spacer()
                    Group {
                        Button{
                            useGPSLocation()
                        } label: {
                            Text("Use GPS Location")
                        }
                        .id("use-gps-location")
                        .accessibilityLabel("use-gps-location")
                        .buttonStyle(.bordered)
                        Button {
                            LocationManager.sharedInstance.updateGeofencing(latitude: Double(latitude) ?? 0.0,
                                                                            longitude: Double(longitude) ?? 0.0,
                                                                            radius: Double(radius) ?? 0.0)
                            dismiss()
                        } label: {
                            Text("SAVE")
                        }
                        .id("save")
                        .accessibilityLabel("save")
                        .buttonStyle(.bordered)
                    }
                }
            }
        }
    }
    
    func useGPSLocation() {
        let location: CLLocation? = LocationManager.sharedInstance.lastSeenLocation
        latitude = String(Double(location!.coordinate.latitude))
        longitude = String(Double(location!.coordinate.longitude))
        radius = "100"
    }
}

struct LastView: View {
    @ObservedObject var alertManager: AlertManager = AlertManager.sharedInstance
    var body: some View {
        CustomNavigationView(
            leftDestination: EmptyView(),
            rightDestination: EmptyView(),
            isRoot: false,
            isLast: false,
            title: "Settings",
            leftButton: nil,
            rightButton: nil
        ) {
            ZStack {
                SettingsView()
            }
        }
    }
}

struct LastView_Previews: PreviewProvider {
    static var previews: some View { Group { LastView() } }
}

// modifier to select all text in textfield on click
public struct SelectTextOnEditingModifier: ViewModifier {
    public func body(content: Content) -> some View {
        content
            .onReceive(NotificationCenter.default.publisher(for: UITextField.textDidBeginEditingNotification))
        { obj in
                if let textField = obj.object as? UITextField {
                    textField.selectedTextRange = textField.textRange(
                        from: textField.beginningOfDocument, to: textField.endOfDocument)
                }
            }
    }
}

extension View {
    /// Select all the text in a TextField when starting to edit.
    /// This will not work with multiple TextField's in a single view due to
    /// not able to match the selected TextField with underlying UITextField
    
    public func selectAllTextOnEditing() -> some View {
        modifier(SelectTextOnEditingModifier())
    }
}
