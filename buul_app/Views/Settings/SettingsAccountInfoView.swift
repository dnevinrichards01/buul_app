//
//  SettingsAccountInfoView.swift
//  accumate_app
//
//  Created by Nevin Richards on 1/31/25.
//

import SwiftUI

struct SettingsAccountInfoView: View {
    @EnvironmentObject var navManager: NavigationPathManager
    @EnvironmentObject var sessionManager: UserSessionManager
    @State private var selectedAccountInfo: AccountInfo?

    var body: some View {
        VStack {
            HStack {
                Spacer()
                Text("Your Account Information")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundStyle(.white)
                    .multilineTextAlignment(.center)
                    .padding(.top, 30)
                Spacer()
            }
            .padding(.bottom, 50)
            
            ForEach(AccountInfo.allCases, id: \.self) { accountInfo in
                Button {
                    selectedAccountInfo = accountInfo
                } label: {
                    VStack {
                        SettingsAccountInfoFieldView(
                            instruction: accountInfo.label,
                            info: getValue(accountInfo: accountInfo, userSession: sessionManager)
                        )
                        .padding(.horizontal)
                        .padding(.vertical, 10)
                        
                        Divider()
                            .frame(height: 1.5)
                            .background(.white.opacity(0.6))
                    }
                }
            }
            Spacer()
        }
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden()
        .background(Color.black.ignoresSafeArea())
        .onAppear() {
            selectedAccountInfo = nil
        }
        .onChange(of: selectedAccountInfo) {
            if let selectedAccountInfo = selectedAccountInfo {
                switch selectedAccountInfo {
                case .password:
                    navManager.append(NavigationPathViews.changePassword)
                case .email:
                    navManager.append(NavigationPathViews.changeEmail)
                case .phone:
                    navManager.append(NavigationPathViews.changePhone)
                case .name:
                    navManager.append(NavigationPathViews.changeName)
                }
            }
        }
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                Button(action: {
                    navManager.path.removeLast()
                }) {
                    Image(systemName: "chevron.left")
                        .foregroundColor(.white)
                        .font(.system(size: 20, weight: .medium))
                        .frame(maxHeight: 30)
                }
            }
        }
    }
    
    func getValue(accountInfo: AccountInfo, userSession: UserSessionManager) -> String {
        switch accountInfo {
        case .password:
            return "********" // Assuming UserSessionManager has a password property
        case .email:
            return userSession.email ?? "Could not load or find email"
        case .phone:
            return userSession.phoneNumber ?? "Could not load or find email"
        case .name:
            return userSession.fullName ?? "Could not load or find email"
        }
    }
}

enum AccountInfo: CaseIterable {
    case password
    case email
    case phone
    case name

    var label: String {
        switch self {
        case .password: return "Password"
        case .email: return "Email"
        case .phone: return "Phone Number"
        case .name: return "Full Name"
        }
    }
}

#Preview {
    SettingsAccountInfoView()
        .environmentObject(NavigationPathManager())
        .environmentObject(UserSessionManager())
}
