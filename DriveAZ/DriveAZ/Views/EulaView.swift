//
//  EulaView.swift
//  DriveAZ
//
//  Created by Ben on 10/22/24.
//

import SwiftUI

struct EulaView: View {
    @State private var eulaAccepted: Int = 0
    
    var body: some View {
        ZStack {
            Rectangle()
            .foregroundColor(.clear)
            .frame(width: Constants.screenWidth, height: Constants.screenHeight)
            .background(Constants.Blue)
            VStack {
                ScrollView {
                    VStack {
                        Spacer(minLength: 60)
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
                        // P1
                        Spacer(minLength: 32)
                        Text("Safe driving disclosure\n\nBy using this app, you agree to the following terms and conditions related to safe driving practices. Please read carefully before accepting.\n\nAlways maintain full attention on the road while driving. Do not let notifications or alerts from this app distract you from the primary task of driving safely.\n\nYou must comply with all local, state, and federal traffic laws and regulations while using this app. The app's notifications are meant to assist but do not replace your responsibility as a driver.\n\nEnsure that your mobile device is securely mounted in a hands-free manner. Do not handle your device while driving unless your vehicle is safely parked and not in motion.\n\nYou are solely responsible for your actions and decisions while driving. The app provides alerts and notifications for informational purposes only and should not be solely relied upon for making driving decisions.\n\nWhile the app aims to provide timely alerts regarding potential hazards, it does not guarantee detection of all road hazards. You must remain vigilant and use your judgment in all driving situations.\n\nThe app is designed to be an aid and is not infallible. Factors such as signal loss, network issues, or app malfunctions can affect the performance of the app. Always use the app as a supplementary tool, not as a primary navigation or hazard detection system.\n\nRegularly update the app to ensure you have the latest features and improvements. Failure to do so may impact the app's performance and your safety.\n\nIn case of an emergency, prioritize calling emergency services over interacting with the app. Safely stop your vehicle before making any emergency communications.")
                          .font(
                            Font.custom("Manrope", size: 16)
                              .weight(.medium)
                          )
                          .foregroundColor(.white)
                          .frame(width: Constants.screenWidth - 32, alignment: .leading)
//                        
//                        Spacer(minLength: 1)
                    }
                }.frame(height: Constants.screenHeight - 268, alignment: .top)
                ZStack {
                    Image("Rectangle 40")
                      .frame(width: Constants.screenWidth, height: 268)
                      .background(.white)
                    VStack {
                        // P2
                        Spacer(minLength: 5)
                        Text("By tapping \"Accept,\" you acknowledge that you have read and understood this Safe Driving Disclosure and agree to adhere to these guidelines to ensure your safety and the safety of others on the road.")
                          .font(Font.custom("Manrope", size: 14))
                          .foregroundColor(.black)
                          .frame(width: Constants.screenWidth - 32, alignment: .leading)
                        Spacer(minLength: 1)
                        HStack {
                            
                            Spacer(minLength: 5)
                            ZStack {
                                Rectangle()
                                  .foregroundColor(.clear)
                                  .frame(width: (Constants.screenWidth/2) - 15, height: 98)
                                  .background(.black)
                                  .cornerRadius(Constants.appHomescreenRowAppMargin)
                                // H4
                                Text("Accept")
                                  .font(Font.custom("Manrope", size: 20))
                                  .multilineTextAlignment(.center)
                                  .foregroundColor(.white)
                            }.onTapGesture {
                                print("Accept 1")
                                acceptedEulVersion = currentEulaVersion
                                ETXRegistrationManager.shared.savePersistentEulaData(eulaAgreedTo: currentEulaVersion)
                                viewToShow = "map"
                                LogInManager.sharedInstance.isLoggedIn = true
                            }
                            Spacer(minLength: 5)
                            ZStack {
                                Rectangle()
                                  .foregroundColor(.clear)
                                  .frame(width: (Constants.screenWidth/2) - 15, height: 98)
                                  .background(.gray)
                                  .cornerRadius(Constants.appHomescreenRowAppMargin)
                                // H4
                                Text("Decline")
                                  .font(Font.custom("Manrope", size: 20))
                                  .multilineTextAlignment(.center)
                                  .foregroundColor(.white)
                            }.onTapGesture {
                                print("Decline 1")
                                viewToShow = "main"
                                LogInManager.sharedInstance.isLoggedIn = false
                            }

                            Spacer(minLength: 5)
                        }
                        
                        Spacer(minLength: 15)
                    }
                }.frame(height: 268, alignment: .bottom)
            }.frame(height: Constants.screenHeight, alignment: .top).accessibilityIdentifier("scroll")
        }
    }
    
    init() {
    }
}

#Preview {
    EulaView()
}
