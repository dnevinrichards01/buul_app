//
//  HomeAccountView.swift
//  accumate_app
//
//  Created by Nevin Richards on 1/31/25.
//

import SwiftUI

struct HomeAccountView: View {
    
    private var name: String = "Nevin Richards"
    @EnvironmentObject var navManager: NavigationPathManager
    @EnvironmentObject var sessionManager: UserSessionManager
    @State private var selectedSetting: AccountSettings?
    @State private var showAlert: Bool = false
    @State private var alertMessage: String = ""
    @State private var logout: Bool = false

    var body: some View {
        VStack {
            HStack {
                Spacer()
                Text(name + "'s Account")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundStyle(.white)
                    .multilineTextAlignment(.center)
                    .padding(.top, 30)
                Spacer()
            }
            .padding(.bottom, 50)
            
            ForEach(AccountSettings.allCases, id: \.self) { setting in
                Button {
                    selectedSetting = setting
                } label: {
                    HStack {
                        Image(systemName: setting.systemImageName)
                            .resizable()
                            .scaledToFit()
                            .padding(2)
                            .frame(width: 30, height: 30)
                            .foregroundStyle(.white)
                        Text(setting.displayName)
                            .font(.headline)
                            .foregroundStyle(.white)
                        Spacer()
                        Image(systemName: "chevron.right")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 20, height: 20)
                            .foregroundStyle(.white.opacity(0.8))
                            .padding(.trailing, 20)
                    }
                }
                Divider()
                    .frame(height: 1)
                    .background(.white.opacity(0.8))
                    .padding(.vertical, 5)
            }
            .alert(alertMessage, isPresented: $showAlert) {
                Button("OK", role: .cancel) { showAlert = false}
            }
            .onChange(of: showAlert) { oldValue, newValue in
                if oldValue == true && newValue == false {
                    if logout {
                        sessionManager.isLoggedIn = false
                        navManager.reset(views: [.landing])
                    }
                }
            }
            .onChange(of: selectedSetting) { newSetting, oldSetting in
                if let selectedSetting = selectedSetting {
                    switch selectedSetting {
                    case .accountInfo:
                        navManager.append(NavigationPathViews.accountInfo)
                    case .bank:
                        navManager.append(NavigationPathViews.bank)
                    case .help:
                        navManager.append(NavigationPathViews.help)
                    case .delete:
                        navManager.append(NavigationPathViews.deleteOTP)
                    case .logout:
                        logout = true
                    }
                }
            }
            Spacer()
        }
        .onChange(of: logout) {
            Task {
                let logoutSuccess: Bool = await sessionManager.reset()
                if !logoutSuccess {
                    alertMessage = "Your session data could not be removed. Please try again or contact Accumate"
                } else {
                    alertMessage = "You have been logged out."
                }
                showAlert = true
            }
        }
        .background(.black)
        .onAppear() {
            selectedSetting = nil
        }
    }
}

enum AccountSettings: CaseIterable {
    case accountInfo
    case bank
    case help
    case delete
    case logout
    
    /// Returns the corresponding SF Symbol name
    var systemImageName: String {
        switch self {
        case .accountInfo: return "person.crop.circle.fill"
        case .bank: return "building.columns.fill"
        case .help: return "questionmark.circle.fill"
        case .delete: return "trash.fill"
        case .logout: return "arrow.right.square"
        }
    }
    
    /// Returns a user-friendly display name
    var displayName: String {
        switch self {
        case .accountInfo: return "Account Information"
        case .bank: return "Banking Information"
        case .help: return "Help & Support"
        case .delete: return "Delete"
        case .logout: return "Logout"
        }
    }
}



#Preview {
    HomeAccountView()
        .environmentObject(NavigationPathManager())
        .environmentObject(UserSessionManager())
}
