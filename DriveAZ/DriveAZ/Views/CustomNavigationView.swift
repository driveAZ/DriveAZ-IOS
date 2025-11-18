//
//  CustomNavigationView.swift
//  DriveAZ
//
//  Created by Ben on 5/18/22.
//

import Foundation
import SwiftUI

struct CustomNavigationView<Content: View, LeftDestination: View, RightDestination: View>: View {
    let leftDestination: LeftDestination
    let rightDestination: RightDestination
    let isRoot: Bool
    let isLast: Bool
    let title: String
    let leftButton: String?
    let rightButton: String?
    let content: Content
    @State var rightPageActive = false
    @State var leftPageActive = false
    @Environment(\.presentationMode) var mode: Binding<PresentationMode>
    @ObservedObject var alertManager: AlertManager = AlertManager.sharedInstance

    init(
        leftDestination: LeftDestination,
        rightDestination: RightDestination,
        isRoot: Bool,
        isLast: Bool,
        title: String,
        leftButton: String?,
        rightButton: String?,
        @ViewBuilder content: () -> Content
    ) {
        self.leftDestination = leftDestination
        self.rightDestination = rightDestination
        self.isRoot = isRoot
        self.isLast = isLast
        self.title = title
        self.leftButton = leftButton
        self.rightButton = rightButton
        self.content = content()
    }

    var body: some View {
        NavigationView {
            ZStack {
                VStack {
                    ZStack {
                        Rectangle()
                            .fill(LinearGradient(
                                    gradient: Gradient(stops: [
                                .init(color: Color(#colorLiteral(red: 0, green: 0.20392157137393951, blue: 0.47058823704719543, alpha: 1)), location: 0.2864583432674408),
                                .init(color: Color(#colorLiteral(red: 0.1764705926179886, green: 0.5882353186607361, blue: 0.8039215803146362, alpha: 1)), location: 1)]),
                                    startPoint: UnitPoint(x: 1, y: 1),
                                    endPoint: UnitPoint(x: 0, y: 0)))
                        .frame(width: 375, height: 100)
                        HStack {
                            if isRoot {
                                Image("settings-button")
                                    .frame(width: 30)
                                .onTapGesture(count: 1, perform: {
                                    self.leftPageActive.toggle()
                                })
                                NavigationLink(
                                    destination: leftDestination.navigationBarHidden(true)
                                        .navigationBarHidden(true),
                                    isActive: self.$leftPageActive,
                                    label: {
                                        // no label
                                    })
                            } else {
                                Image(systemName: "arrow.left")
                                    .frame(width: 30)
                                .onTapGesture(count: 1, perform: {
                                    self.mode.wrappedValue.dismiss()
                                }).opacity(isRoot ? 0 : 1)

                            }
                            Spacer()
                            if title == "logo" {
                                Image("small-logo")
                            } else {
                                Text(title)
                                    .font(
                                        .custom("Ford Antenna Semibold", size: 18)
                                    ).foregroundColor(Color(#colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)))
                                    .multilineTextAlignment(.center)
                            }
                            Spacer()
                            if let imageName = rightButton {
                                Image(imageName)
                                    .frame(width: 30)
                                    .onTapGesture(count: 1, perform: {
                                        self.rightPageActive.toggle()
                                    })
                                    .opacity(isLast ? 0 : 1)
                            }
                            NavigationLink(
                                destination: rightDestination.navigationBarHidden(true)
                                    .navigationBarHidden(true),
                                isActive: self.$rightPageActive,
                                label: {
                                    // no label
                                })
                        }
                        .offset(x: 0, y: 10)
    //                        .padding([.leading,.trailing], 8)
    //                        .frame(width: geometry.size.width)
                        .font(.system(size: 22))

                    }
    //                    .frame(width: geometry.size.width, height: 90)
                    .edgesIgnoringSafeArea(.top)

    //                    Spacer()
                    self.content
    //                        .padding()
    //                        .background(color.opacity(0.3))
    //                        .cornerRadius(20)
    //                    Spacer()
                }.navigationBarHidden(true)
            }
        }
    }
}
