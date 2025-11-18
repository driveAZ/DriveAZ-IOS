//
//  ContentView.swift
//  DriveAZ
//
//  Created by Ben on 1/21/22.
//

import SwiftUI
import MapKit
import CoreLocation
import B2VExtrasSwift

struct MainView: View {

    @ObservedObject var motionManager: MotionManager = MotionManager.sharedInstance
    @ObservedObject var phoneManager: PhoneManager = PhoneManager.sharedInstance

    @Environment(\.window) private var window

    var body: some View {
        ZStack {
            Rectangle()
            .foregroundColor(.clear)
            .frame(width: Constants.screenWidth + 100, height: Constants.screenHeight)
            .background(Constants.Blue)
            VStack {
                Spacer().frame(height: 35)
                HStack(alignment: .bottom, spacing: 21.19067) {
                    Text("Drive Arizona")
                      .font(
                        Font.custom("Manrope", size: 50)
                            .weight(.ultraLight)
                      )
                      .foregroundColor(.white)
                    Image("AZ")
                    .frame(width: 41.78591, height: 55.76807)
                }
                    .padding(.leading, 0)
                    .padding(.trailing, 3.00001)
                    .padding(.vertical, 0)
                    .frame(width: 365.97659, height: 76.88428, alignment: .bottomLeading)
                Spacer().frame(height: 63)
                HStack {
                    // H1
                    Spacer().frame(width: 35)
                    Text("Welcome to a safer road.")
                      .font(
                        Font.custom("Manrope", size: 55)
                          .weight(.ultraLight)
                      )
                      .foregroundColor(.white)
                      .frame(width: 395.625, alignment: .leading)
                }
                .frame(width: 395.625, height: 132)
                Spacer().frame(height: 71)
                
                Spacer().frame(height: 10)
                ZStack { // Start Button
                    Rectangle()
                      .foregroundColor(.clear)
                      .frame(width: UIScreen.screenWidth - 20, height: 98)
                      .cornerRadius(80)
                      .background(Constants.Blue).onTapGesture {
                          print("Start 4")
                          switchView()
                      }
                    Rectangle()
                      .foregroundColor(.clear)
                      .frame(width: UIScreen.screenWidth - 20, height: 98)
                      .cornerRadius(80)
                      .overlay(
                        RoundedRectangle(cornerRadius: 80)
                          .inset(by: 0.5)
                          .stroke(.white, lineWidth: 1).onTapGesture {
                              print("Start 1")
                              switchView()
                          }
                      ).onTapGesture {
                          print("Start 2")
                          switchView()
                      }
                    // H4
                    Text("Start")
                      .font(Font.custom("Manrope", size: 20))
                      .multilineTextAlignment(.center)
                      .foregroundColor(.white)
                }.onTapGesture {
                    print("Start 3")
                    switchView()
                }
            }
            .navigationBarHidden(true)
        }
    }

    init() {
    }

    func setActiveType(type: String) {
        print("setActiveType")
        motionManager.selectedMode = type
        motionManager.autoTravelModeDetection = false
    }
    
    func switchView(){
        print("button")
        print(acceptedEulVersion, currentEulaVersion)
        if acceptedEulVersion < currentEulaVersion {
            viewToShow = "eula"
            eulaCountForError = eulaCountForError + 1
            if eulaCountForError >= 5 {
                AlertManager.sharedInstance.errorAlertTitle = "Error"
                AlertManager.sharedInstance.errorAlertText = "This is a test error"
                AlertManager.sharedInstance.errorAlertNumber = 1
                AlertManager.sharedInstance.shouldShowErrorAlert = true
            }
        } else {
            viewToShow = "map"
        }
        LogInManager.sharedInstance.isLoggedIn = true
    }
}

var viewToShow = "main"
var vruToShow = ""
var viewToGoBackTo = "main"
let currentEulaVersion = 1
var acceptedEulVersion = 0
var eulaCountForError = 0

struct Constants {
  static let Blue: Color = Color(red: 0, green: 0.3, blue: 0.85)
    static let screenWidth: CGFloat = UIScreen.main.bounds.maxX
    static let screenHeight: CGFloat = UIScreen.main.bounds.maxY
  static let appHomescreenRowAppMargin: CGFloat = 35
  static let Grey04: Color = Color(red: 0.98, green: 0.98, blue: 0.98)
}

struct ContentView: View {
//    let window = UIWindow(windowScene: windowScene) // Or however you initially get the window
//    let rootView = MainView().environmentObject(AppData(window: window))
    @StateObject var alertManager: AlertManager = AlertManager.sharedInstance
    @ObservedObject var logInManager: LogInManager = LogInManager.sharedInstance
    
    @State private var region = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 37.7749, longitude: -122.4194), // Example coordinates
        span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
    )
    
    @State private var userLocation = CLLocationCoordinate2D(latitude: 37.7749, longitude: -122.4194)
    @State private var userHeading: CLLocationDirection? = nil
    @State private var userCourse: Double? = nil

    var isRunningTests = false

    var body: some View {
        ZStack {
            if isRunningTests || viewToShow == "main" {
                MainView()
            } else if viewToShow == "map" {
                OldMapView()
            } else if viewToShow == "settings" {
                SettingsView()
            } else if viewToShow == "list" {
                ListView()
            } else if viewToShow == "vru" {
                VRUView(id: vruToShow)
            } else if viewToShow == "eula" {
                EulaView()
            } else {
                MainView()
            }
        }.alert(alertManager.errorAlertTitle, isPresented: $alertManager.shouldShowErrorAlert) {
            Button("Ok", role: .cancel) {
                print("boop")
                exit(alertManager.errorAlertNumber)
            }
        } message: {
            Text(alertManager.errorAlertText)
        }
    }

    init() {
        UIApplication.shared.isIdleTimerDisabled = true
        LocationManager.sharedInstance.initLocationManager()

        print()
        print("content view init")
        print(ProcessInfo.processInfo.environment["XCTestConfigurationFilePath"] != nil)
        isRunningTests =  ProcessInfo.processInfo.arguments.contains("testMode")
        let thing = !logInManager.isLoggedIn
        let showLogIn = !logInManager.isLoggedIn || !isRunningTests
        print("isRunningTests \(isRunningTests)")
        print()

        if ProcessInfo.processInfo.arguments.contains("testOldPhone") {
            PhoneManager.sharedInstance.phoneDoesntSupport2M = true
        }
        if ProcessInfo.processInfo.arguments.contains("testLoggedOut") {
            LogInManager.sharedInstance.isLoggedIn = false
        }
        if ProcessInfo.processInfo.arguments.contains("testAddPSMToList") {
            VRUManager.sharedInstance.seenVRUs["test123"] = Examples.sharedInstance.examplePSM
        }
        
        
        let persistentData = ETXRegistrationManager.shared.loadPersistentData()
        if let acceptedEulaValue = persistentData.agreedToEula {
            acceptedEulVersion = acceptedEulaValue
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View { Group { ContentView() } }
}

extension UIScreen{
   static let screenWidth = UIScreen.main.bounds.size.width
   static let screenHeight = UIScreen.main.bounds.size.height
   static let screenSize = UIScreen.main.bounds.size
}
