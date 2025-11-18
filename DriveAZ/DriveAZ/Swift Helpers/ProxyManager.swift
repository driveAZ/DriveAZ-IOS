//
//  ProxyManager.swift
//  DriveAZ
//
//  Created by Ben on 7/28/22.
//

import Foundation
import SmartDeviceLink

class ProxyManager: NSObject, SDLManagerDelegate {

    fileprivate var sdlManager: SDLManager!

    // IAP - USB/Bluetooth - production
    let lifecycleConfiguration = SDLLifecycleConfiguration(appName: "Mobile Safety Message", fullAppId: "1234")
    // TCP - Wifi - debugging
//    let lifecycleConfiguration = SDLLifecycleConfiguration(
//        appName: "Mobile Safety Message",
//        fullAppId: "1234",
//        ipAddress: "m.sdl.tools",
//        port: 17956
//    )

    static let sharedManager = ProxyManager()
    var isConnected = false

    private override init() {
        print("init start")
        super.init()

        lifecycleConfiguration.shortAppName = "DriveAZ"

//        SDLLockScreenConfiguration.enabled()

        setAppIcon("large-logo")

        let configuration = SDLConfiguration(
            lifecycle: lifecycleConfiguration,
            lockScreen: .enabled(),
            logging: .default(),
            fileManager: nil,
            encryption: nil
        )
        sdlManager = SDLManager(configuration: configuration, delegate: self)
        print("init done")
    }

    func setAppIcon(_ name: String) {
        if let appImage = UIImage(named: name) {
            let appIcon = SDLArtwork(image: appImage, name: "app-icon", persistent: true, as: .PNG /* or .PNG */)
            lifecycleConfiguration.appIcon = appIcon
        } else {
            print("no image??")
        }
    }

    func connect() {
        // Start watching for a connection with a SDL Core
        sdlManager.start(readyHandler: checkConnectResults(success:error:))
    }

    func checkConnectResults(success: Bool, error: Error?) {
        if error != nil {
            print("checkConnectResults")
            print(error)
            print()
        } else if success {
            self.handleConnectSuccess()
        }
    }

    func handleConnectSuccess() {
        self.isConnected = true
        self.sdlManager.screenManager.beginUpdates()
        self.sdlManager.screenManager.changeLayout(SDLTemplateConfiguration(predefinedLayout: .largeGraphicOnly)) { _ in
            // This listener will be ignored, and will use the handler set in the endUpdates call.
        }

        if let image = UIImage(named: "pedestrian") {
            let artwork = SDLArtwork(image: image, name: "pedestrian-image", persistent: true, as: .PNG /* or .PNG */)
            sdlManager.fileManager.upload(artwork: artwork)
        }

        if let appImage = UIImage(named: "large-logo") {
            self.sdlManager.screenManager.primaryGraphic = SDLArtwork(
                image: appImage,
                name: "large-logo-2",
                persistent: true,
                as: .PNG
            )
        }
        self.sdlManager.screenManager.endUpdates(completionHandler: { (error) in
            self.printErrorWithLocation(error, calledFrom: "handleConnectSuccess")
        })
    }

    func showRedAlert() {
        let alertView = SDLAlertView(text: "WARNING",
                                     secondaryText: "Pedestrian Ahead",
                                     tertiaryText: nil,
                                     timeout: nil,
                                     showWaitIndicator: nil,
                                     audioIndication: nil,
                                     buttons: [],
                                     icon: nil
        )
        if let appImage = UIImage(named: "pedestrian") {
            let artwork = SDLArtwork(image: appImage, name: "pedestrian", persistent: true, as: .PNG /* or .PNG */)
            alertView.icon = artwork
        }
//        let alertAudioData = SDLAlertAudioData(speechSynthesizerString: "Collision Alert")
//        alertView.audio = alertAudioData
        sdlManager.screenManager.presentAlert(alertView, withCompletionHandler: { (error) in
            self.printErrorWithLocation(error, calledFrom: "showRedAlert")
        })
    }

    func showYellowAlert() {
        let subtleAlert = SDLSubtleAlert(alertText1: "WARNING",
                                         alertText2: "Pedestrian Ahead",
                                         alertIcon: nil,
                                         ttsChunks: nil,
                                         duration: nil,
                                         softButtons: nil,
                                         cancelID: nil
        )

        let image = SDLImage(name: "pedestrian-image", isTemplate: true)
        subtleAlert.alertIcon = image
        sdlManager.send(request: subtleAlert) { (_, response, varB) in
            guard response?.success.boolValue == true else {
//                Print out the error if there is one
                print("error in showYellowAlert")
                print(varB)
                print()
                return
            }
        }
    }

    func printErrorWithLocation(_ error: Error?, calledFrom: String) {
        if let error = error {
            print("called from \(calledFrom)")
            print(error)
            print()
        }
    }

    func managerDidDisconnect() {
        print("managerDidDisconnect")
        isConnected = false
    }

    func hmiLevel(_ oldLevel: SDLHMILevel, didChangeToLevel newLevel: SDLHMILevel) {
        print("Went from HMI level \(oldLevel) to HMI level \(newLevel)")
    }

    func didReceiveSystemInfo(_ systemInfo: SDLSystemInfo) -> Bool {
        print("Connected to system: \(systemInfo)")
        return true
    }
}
