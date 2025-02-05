//
//  SettingsHelpView.swift
//  accumate_app
//
//  Created by Nevin Richards on 1/31/25.
//

import SwiftUI


struct SettingsHelpView: View {
    
    private var email: String = "accumate-verify@accumatewealth.com"
    @State private var selectedHelpSetting: HelpSettings?
    
    @EnvironmentObject var navManager: NavigationPathManager
    @EnvironmentObject var sessionManager: UserSessionManager
    
    var body: some View {
        VStack() {
            VStack {
                Text("Help & Support")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundStyle(.white)
                    .multilineTextAlignment(.center)
                    .padding(.bottom, 50)
                
                ForEach(HelpSettings.allCases, id: \.self) { setting in
                    Button {
                        selectedHelpSetting = setting
                    } label: {
                        HStack {
//                            Image(systemName: setting.displayName)
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
                        .padding(.top, -15)
                    
                }
                .onChange(of: selectedHelpSetting) { newSetting, oldSetting in
                    if newSetting != nil {
                        switch selectedHelpSetting {
                        case .faq:
                            break
                        case .none:
                            break
                        }
                    }
                }
                .padding(.bottom, 30)
                VStack {
                    Text("Please contact us at the address below with any questions, concerns, bugs, and more:")
                        .font(.headline)
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    
                    Text(email)
                        .font(.headline)
                        .foregroundColor(.blue)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .contextMenu {
                            Button(action: {
                                UIPasteboard.general.string = email
                            }) {
                                Label("Copy Email", systemImage: "doc.on.doc")
                            }
                        }
                }
            }
            Spacer()
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
        .navigationBarBackButtonHidden(true)
        .navigationBarTitleDisplayMode(.inline)
        .padding()
        .background(.black)
        
        
    }
}

enum HelpSettings: CaseIterable {
    case faq
//    case documents

    /// Returns a user-friendly display name
    var displayName: String {
        switch self {
        case .faq: return "FAQ - coming soon"
        }
    }
}


#Preview {
    SettingsHelpView()
        .environmentObject(NavigationPathManager())
        .environmentObject(UserSessionManager())
}
