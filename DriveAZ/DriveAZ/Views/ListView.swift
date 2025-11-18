//
//  ListView.swift
//  DriveAZ
//
//  Created by Ben on 5/18/22.
//

import Foundation
import SwiftUI
import MapKit
import CoreLocation
import B2VExtrasSwift

struct ListView: View {

    struct VRU: Identifiable {
        let type: String
        let userId: String
        let id = UUID()
    }
    var vrus: [VRU] = []
    @ObservedObject var vruManager: VRUManager = VRUManager.sharedInstance

    init() {
        print("Array(vruManager.seenVRUs.keys)")
        print(Array(vruManager.seenVRUs.keys))
    }
    var body: some View {
        List {
            Section(header: Text("Nearby VRUs")) {
                ForEach(Array(vruManager.seenVRUs.keys), id: \.self) { key in
                    NavigationLink(destination: ThirdView(id: key)) {
                        ListDetail(
                            type: personalDeviceUserTypeIntToString(vruManager.seenVRUs[key]?.basicType),
                            id: key
                        )
                    }
                    .navigationBarHidden(true)

                }
            }
            Section(header: Text("Other VRUs")) {
//                ForEach(vrus) { item in
//                    NavigationLink(destination: ThirdView(id: item.userId)) {
//                        HStack {
//                            Text(item.type).font(.custom("Open Sans Regular", size: 17)).tracking(-0.41)
//                            Spacer()
//                            Text(item.userId)
//                                .font(.custom("Open Sans Regular", size: 17))
//                                .foregroundColor(Color(#colorLiteral(red: 0.5, green: 0.5, blue: 0.5, alpha: 1)))
//                                .tracking(-0.41)
//                        }
//                    }
//                    .navigationBarHidden(true)
//                }
            }
            Section(header: Text("User")) {
                NavigationLink(destination: ThirdView(id: "self")) {
                    ListDetail(
                        type: personalDeviceUserTypeIntToString(SafetyMessageManager.sharedInstance.psm.basicType),
                        id: SafetyMessageManager.sharedInstance.psmID
                    )
                }
                .navigationBarHidden(true)
            }
        }
        .offset(x: 0, y: -8)
        .frame(width: 375, height: 725)
    }
}

struct ListDetail: View {
    let type: String
    let id: String

    init(type: String?, id: String?) {
        self.type = type ?? "Unknown"
        self.id = id ?? "----"
    }

    var body: some View {
            HStack {
                Text(type)
                    .font(.custom("Open Sans Regular", size: 17)).tracking(-0.41)
                Spacer()
                Text(id)
                    .font(.custom("Open Sans Regular", size: 17))
                    .foregroundColor(Color(#colorLiteral(red: 0.5, green: 0.5, blue: 0.5, alpha: 1)))
                    .tracking(-0.41)
            }
    }
}

struct SecondView: View {
    var body: some View {
        CustomNavigationView(
            leftDestination: EmptyView(),
            rightDestination: EmptyView(),
            isRoot: false,
            isLast: true,
            title: "VRU List",
            leftButton: nil,
            rightButton: nil
        ) {
            ListView()
        }
    }
}

struct SecondView_Previews: PreviewProvider {
    static var previews: some View { Group { SecondView() } }
}
