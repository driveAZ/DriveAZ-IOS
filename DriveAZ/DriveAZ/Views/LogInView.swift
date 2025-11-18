//
//  LogInView.swift
//  DriveAZ
//
//  Created by Ben on 7/18/22.
//

import Foundation
import SwiftUI

struct LogInView: View {

    let userAlreadyLoggedInMessage
        = "There is already a user which is signed in. Please log out the user before calling showSignIn."

    var body: some View {
        VStack {
            Button(action: signIn) {
                Text("Sign In")
            }.id("sign-in-button").accessibilityLabel("sign-in-button")
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
        print("LogInView init")
    }

    func signIn() {
        if let window = window {
            print("signInWithWebUI Start")
            print(window)
        } else {
            print("window is nil")
        }
        print("")
    }
}
