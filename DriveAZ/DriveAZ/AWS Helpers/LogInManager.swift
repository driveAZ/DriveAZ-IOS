//
//  LogInManager.swift
//  DriveAZ
//
//  Created by Ben on 6/1/22.
//

import Foundation
import SwiftUI

class LogInManager: ObservableObject {
    let defaults = UserDefaults.standard
    static let sharedInstance = LogInManager()
    @Published var isLoggedIn = false

    private init() {
        print("LogInManager init")
        isLoggedIn = defaults.object(forKey: "UserIsLoggedIn") as? Bool ?? false
    }

    func loggedIn() {
        isLoggedIn = true
        defaults.set(true, forKey: "UserIsLoggedIn")
    }

    func loggedOut() {
        isLoggedIn = false
        defaults.set(false, forKey: "UserIsLoggedIn")
    }
}

// func configureAmplify() {
//    let dataStorePlugin = AWSDataStorePlugin(modelRegistration: AmplifyModels())
//    do {
//        try Amplify.add(plugin: dataStorePlugin)
//        try Amplify.configure()
//        print("Initialized Amplify");
//    } catch {
//        // simplified error handling for the tutorial
//        print("Could not initialize Amplify: \(error)")
//    }
// }

struct WindowKey: EnvironmentKey {
    static let defaultValue: UIWindow? = nil
}

extension EnvironmentValues {
    var window: WindowKey.Value {
        get { return self[WindowKey.self] }
        set { self[WindowKey.self] = newValue }
    }
}
