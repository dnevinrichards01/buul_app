//
//  SettingsPlaidView.swift
//  accumate_app
//
//  Created by Nevin Richards on 1/31/25.
//

import SwiftUI

struct SettingsPlaidView: View {
    @EnvironmentObject var navManager: NavigationPathManager
    @EnvironmentObject var sessionManager: UserSessionManager
    @State private var selectedSetting: PlaidSettings?
    @State private var showAlert: Bool = false
    @State private var alertMessage: String = ""
    
    var body: some View {
        VStack {
            HStack {
                Spacer()
                Text("Plaid Settings")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundStyle(.white)
                    .multilineTextAlignment(.center)
                    .padding(.top, 30)
                Spacer()
            }
            .padding(.bottom, 50)
            
            ForEach(PlaidSettings.allCases, id: \.self) { setting in
                Button {
                    selectedSetting = setting
                } label: {
                    HStack {
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
            Spacer()
        }
        .padding()
        .alert(alertMessage, isPresented: $showAlert) {
            Button("OK", role: .cancel) {
                showAlert = false
            }
            if sessionManager.refreshFailed {
                Button("Log Out", role: .destructive) {
                    Task {
                        showAlert = false
                        
                        sessionManager.refreshFailed = false
                        _ = await sessionManager.resetComplete()
                        navManager.reset(views: [.landing])
                    }
                }
            }
        }
//            .alert(sessionManager.refreshFailedMessage, isPresented: $sessionManager.refreshFailed) {
//                Button("OK", role: .cancel) {
//                    showAlert = false
//                    sessionManager.refreshFailed = false
//                }
//                Button("Log Out", role: .destructive) {
//                    Task {
//                        showAlert = false
//
//                        sessionManager.refreshFailed = false
//                        _ = await sessionManager.resetComplete()
//                        navManager.reset(views: [.landing])
//                    }
//                }
//            }
        .onChange(of: selectedSetting) { newSetting, oldSetting in
            if let selectedSetting = selectedSetting {
                switch selectedSetting {
                case .addItem:
                    navManager.append(.plaidInfoAdd)
                case .updateItem:
                    navManager.append(.plaidSettingsHelp)
                }
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden()
        .background(.black)
        .onAppear() {
            selectedSetting = nil
        }
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
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
}


enum PlaidSettings: CaseIterable {
    case addItem
    case updateItem
//    case help

    var displayName: String {
        switch self {
        case .addItem: return "Link more accounts and cards"
        case .updateItem: return "Update permission to bank account data"
//        case .help: return "Change your monthly investment"
        }
    }
}


#Preview {
    SettingsPlaidView()
        .environmentObject(NavigationPathManager())
        .environmentObject(UserSessionManager())
}
