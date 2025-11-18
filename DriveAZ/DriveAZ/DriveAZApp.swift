//
//  DriveAZApp.swift
//  DriveAZ
//
//  Created by Ben on 1/21/22.
//

import SwiftUI
import CocoaLumberjack

@main
struct DriveAZApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }

    var window: UIWindow? {
        print("window")
        print(UIApplication.shared.connectedScenes.first)
        print(UIApplication.shared.connectedScenes)
        guard let scene = UIApplication.shared.connectedScenes.first,
              let windowSceneDelegate = scene.delegate as? UIWindowSceneDelegate,
              let window = windowSceneDelegate.window else {
            return nil
        }
        return window
    }

    init() {
        
        let fileLogger: DDFileLogger = DDFileLogger() // File Logger
        fileLogger.rollingFrequency = 60 * 60 * 24 // 24 hours
        fileLogger.logFileManager.maximumNumberOfLogFiles = 7

        
        DDLog.add(DDOSLogger.sharedInstance, with: DDLogLevel.info)
        DDLog.add(fileLogger, with: DDLogLevel.info)
        print("DriveAZ App Started")
        print(window)
    }
}
