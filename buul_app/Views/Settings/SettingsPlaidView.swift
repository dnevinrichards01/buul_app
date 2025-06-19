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
    @EnvironmentObject var plaidManager: PlaidLinkManager
    @State private var selectedSetting: PlaidSettings?
    @State private var showAlert: Bool = false
    @State private var alertMessage: String = ""
    @State private var items: [String] = []
    
    var body: some View {
        ScrollView {
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
                
                ForEach(items.indices, id: \.self) { index in
                    let item = items[index]
                    Button {
                        plaidManager.updateInstitutionName = item
                        navManager.append(.plaidInfoUpdate)
                    } label: {
                        HStack {
                            Text("Update or edit connection to \(item)")
                                .font(.headline)
                                .foregroundStyle(.white)
                                .multilineTextAlignment(.leading)
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
                
                ForEach(PlaidSettings.allCases, id: \.self) { setting in
                    Button {
                        selectedSetting = nil
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                            selectedSetting = setting
                        }
                    } label: {
                        HStack {
                            Text(setting.displayName)
                                .font(.headline)
                                .foregroundStyle(.white)
                                .multilineTextAlignment(.leading)
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
        .refreshable {
            Task.detached {
                await fetchItems()
            }
        }
        .onChange(of: selectedSetting) { newSetting, oldSetting in
            if let selectedSetting = selectedSetting {
                switch selectedSetting {
                case .addItem:
                    navManager.append(.plaidInfoAdd)
                case .removeAccess:
                    navManager.append(.plaidSettingsHelp)
                }
            }
        }
        .onAppear {
            Task.detached {
                await MainActor.run {
                    selectedSetting = nil
                    items = sessionManager.plaidItems
                }
                await fetchItems()
            }
        }
        .environmentObject(plaidManager)
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden()
        .background(Color.black.ignoresSafeArea())
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
    
    private func fetchItems() async {
        await ServerCommunicator().callMyServer(
            path: "api/user/getplaiditems/",
            httpMethod: .get,
            app_version: sessionManager.app_version,
            sessionManager: sessionManager,
            responseType: GetPlaidItemsResponse.self
        ) { response in
            switch response {
            case .success(let responseData):
                if let _ = responseData.error, responseData.institutionNames == nil {
                    self.alertMessage = "We could not retrieve your linked accounts. Swipe up to retry."
                    self.showAlert = true
                } else if let _ = responseData.institutionNames, responseData.error == nil {
                    self.sessionManager.plaidItems = responseData.institutionNames ?? []
                    self.items = responseData.institutionNames ?? []
                } else if let _ = responseData.error, let _ = responseData.institutionNames {
                    self.alertMessage = "We could not retrieve your linked accounts. Swipe up to retry." + ServerCommunicator.NetworkError.decodingError.errorMessage
                    self.showAlert = true
                } else {
                    self.alertMessage = "We could not retrieve your linked accounts. Swipe up to retry." + ServerCommunicator.NetworkError.decodingError.errorMessage
                    self.showAlert = true
                }
            case .failure(let networkError):
                self.showAlert = true
                self.alertMessage = networkError.errorMessage
                switch networkError {
                case .statusCodeError(let status):
                    if status == 401 {
                        self.alertMessage = "Your session has expired. To retrieve updated information, please logout then sign in."
                    }
                default: break
                }
            }
        }
    }
}

struct GetPlaidItemsResponse: Codable {
    let institutionNames: [String]?
    let error: String?
}

enum PlaidSettings: CaseIterable {
    case addItem
    case removeAccess

    var displayName: String {
        switch self {
        case .addItem: return "Connect a new bank or institution"
        case .removeAccess: return "Remove or reduce Buul's access to your bank account data"
        }
    }
}


#Preview {
    SettingsPlaidView()
        .environmentObject(NavigationPathManager())
        .environmentObject(UserSessionManager())
}
