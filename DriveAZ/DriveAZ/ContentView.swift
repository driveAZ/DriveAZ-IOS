//
//  ContentView.swift
//  DriveAZ
//
//  Created by Ben on 1/21/22.
//

import SwiftUI
import Darwin
import DriveAZSwiftLibSM

struct ContentView: View {
    var timer = Timer()
    var body: some View {
        Text("basicType: \(PSMManager.sharedInstance.psm.basicType)")
            .padding()
        Text("secMark: \(PSMManager.sharedInstance.psm.secMark)")
            .padding()
        Text("msgCnt: \(PSMManager.sharedInstance.psm.msgCnt)")
            .padding()
        Text("id: \(PSMManager.sharedInstance.psm.id.size)")
            .padding()
        Text("position.lat: \(PSMManager.sharedInstance.psm.position.lat)")
            .padding()
        Text("position.Long: \(PSMManager.sharedInstance.psm.position.Long)")
            .padding()
        Text("speed: \(PSMManager.sharedInstance.psm.speed)")
            .padding()
        Text("heading: \(PSMManager.sharedInstance.psm.heading)")
            .padding()
    }
    init() {
        LocationManager.sharedInstance.initLocationManager()
        print(BLEManager.sharedInstance.seenCompanyCodes.count)
//        psm = smc.createPSM()
    }
}

// struct ContentView_Previews: PreviewProvider {
//    static var previews: some View {
//        ContentView()
//    }
// }
