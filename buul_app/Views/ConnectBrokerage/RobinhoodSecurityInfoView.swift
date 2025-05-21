//
//  RobinhoodSecurityInfoView.swift
//  accumate_app
//
//  Created by Nevin Richards on 2/2/25.
//

import SwiftUI

struct RobinhoodSecurityInfoView: View {
    @EnvironmentObject var navManager: NavigationPathManager
    @EnvironmentObject var sessionManager: UserSessionManager
    var isSignUp: Bool
    @State private var brokerage: Brokerages?
    @State var showAlert: Bool = false
    @State var alertMessage: String = ""
    
    init(isSignUp: Bool) {
        self.isSignUp = isSignUp
    }
    
    var body: some View {
        VStack {
            VStack(alignment: .leading, spacing: -1) {
                // Header Image and Title
                HStack(spacing: 0) {
                    Image("BuulLogo")
                        .resizable()
                        .frame(width: 80, height: 80)
                    Text("+")
                        .font(.largeTitle)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                        .foregroundStyle(.white)
                    if let brokerage = self.brokerage {
                        Image(brokerage.secondaryImageName)
                            .resizable()
                            .frame(width: brokerage.secondaryImageDim[0], height: brokerage.secondaryImageDim[1])
                            .padding(.leading, -6)
                            .padding(.bottom, brokerage.secondaryImageDim[1])
                    } else {
                        if let brokerageName = sessionManager.brokerageName {
                            Text(String(brokerageName.prefix(30)))
                                .font(.custom("Times New Roman", size: 30))
                                .fontWeight(.black)
                                .foregroundStyle(.white)
                                .padding(.top, 5)
                        } else {
                            Image(systemName: "briefcase.fill")
                                .resizable()
                                .renderingMode(.template)
                                .foregroundStyle(.white)
                                .frame(width: 100, height: 100)
                                .padding(.leading, -6)
                                .padding(.bottom, 5)
                        }
                    }
                }
                .padding(.bottom, 10)
                .padding(.top, 50)
                .frame(maxWidth: .infinity, alignment: .center)
//                .multilineTextAlignment(.center)
                
                Text("Buul connects to \(brokerage?.displayName ?? "your brokerage") using")
                    .font(.headline)
                    .foregroundStyle(.white)
                
                Text("Bank Level Security")
                    .font(.headline)
                    .fontWeight(.bold)
                    .foregroundStyle(.white)
                
                Text("Here's how Buul uses this connection:")
                    .font(.subheadline)
                    .padding(.top, 8)
                    .foregroundStyle(.white.opacity(0.8))
            }
            .padding(.bottom, 20)
            .padding(.horizontal)
            
            // Feature List
            VStack(alignment: .center, spacing: 20) {
                FeatureItem(iconName: "antenna.radiowaves.left.and.right", title: "Brokerage API Access", description: "Buul sends buy and sell notifications to your brokerage.")
                FeatureItem(iconName: "person.fill", title: "Basic Personal Information", description: "We collect your full name, date of birth, address, and investing preferences.")
                FeatureItem(iconName: "shield.fill", title: "Bank Level Security", description: "Buul uses Bank Level Security to connect to \(brokerage?.displayName ?? "your brokerage"). We never store your login credentials and encrypt all data.")
            }
            .padding(.horizontal)
            .frame(maxWidth: .infinity, alignment: .center)
            
            Spacer()
            
            // Continue Button
            Button {
                if isSignUp {
                    navManager.append(brokerage?.signUpConnect ?? .signUpConnectBrokerageLater)
                } else {
                    navManager.append(brokerage?.changeConnect ?? .connectBrokerageLater)
                }
            } label: {
                Text("Connect")
                    .font(.headline)
                    .foregroundColor(.black)
                    .frame(maxWidth: .infinity, minHeight: 50)
                    .background(.white)
                    //.background(Color(red: 75/255, green: 135/255, blue: 120/255))
                    .cornerRadius(10)
            }
            .padding()
        }
        .alert(alertMessage, isPresented: $showAlert) {
            if showAlert {
                Button("OK", role: .cancel) {
                    showAlert = false
                }
            }
        }
        .onChange(of: showAlert) { oldValue, newValue in
            if oldValue && !newValue {
                if brokerage == nil {
                    navManager.removeLast(1)
                }
            }
        }
        .onAppear {
            self.brokerage = Utils.getBrokerage(sessionManager: sessionManager)
        }
        .background(Color.black.ignoresSafeArea())
        .navigationBarBackButtonHidden(true)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button {
                    navManager.removeLast(1)
                } label: {
                    Image(systemName: "chevron.left")
                        .foregroundColor(.white)
                        .font(.system(size: 20, weight: .medium))
                        .frame(maxHeight: 30)
                }
            }
        }
    }
    
    
}

struct FeatureItem: View {
    let iconName: String
    let title: String
    let description: String
    
    var body: some View {
        HStack(alignment: .top, spacing: 16) {
            Image(systemName: iconName)
                .resizable()
                .frame(width: 24, height: 24)
                .foregroundColor(.white)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.headline)
                    .foregroundStyle(.white)
                    .padding(.bottom, 5)
                Text(description)
                    .font(.subheadline)
                    .foregroundColor(.white.opacity(0.8))
                    .lineSpacing(-4)
            }
        }
        .frame(maxWidth: .infinity, alignment: .topLeading)
        .background(.black)
    }
}


#Preview {
    RobinhoodSecurityInfoView(isSignUp: true)
        .environmentObject(NavigationPathManager())
}
