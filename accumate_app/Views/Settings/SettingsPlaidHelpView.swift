//
//  SettingsPlaidHelpView.swift
//  accumate_app
//
//  Created by Nevin Richards on 2/3/25.
//

import SwiftUI

struct SettingsPlaidHelpView: View {
    
    private var email: String = "notifications@bu-ul.com"
    private var plaidLink: String = "https://my.plaid.com"
    @State private var selectedHelpSetting: HelpSettings?
    
    @EnvironmentObject var navManager: NavigationPathManager
    @EnvironmentObject var sessionManager: UserSessionManager
    
    var body: some View {
        VStack() {
            ScrollView {
                VStack {
                    Text("Manage your data with Plaid")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundStyle(.white)
                        .multilineTextAlignment(.center)
                        .padding(.bottom, 50)
                    
                    VStack {
                        Text("To connect a new account or card or increase permissions for already connected ones, go to 'Link more accounts and cards' under 'Banking Information'")
                            .font(.headline)
                            .foregroundStyle(.white)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.bottom, 30)
                        
                        Text("To remove Buul's access, sign up for Plaid at the link below with the phone number you gave Plaid when signing up for Buul, or sign in if you already have an account.")
                            .font(.headline)
                            .foregroundStyle(.white)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.bottom, 5)
                        
                        Button {
                            if let url = URL(string: plaidLink) {
                                UIApplication.shared.open(url)
                            }
                        } label: {
                            Text(plaidLink)
                                .font(.headline)
                                .foregroundColor(.blue)
                                .lineLimit(nil)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .lineSpacing(1)
                        }
                        .padding(.bottom, 30)
                        
                        Text("Deleting your account will remove all of Buul's access to your bank and card data.")
                            .font(.headline)
                            .foregroundStyle(.white)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.bottom, 30)
                        
                        Text("If you encounter issues or have concerns please reach out to us at the following email address")
                            .font(.headline)
                            .foregroundStyle(.white)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.bottom, 5)
                        
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
        .background(Color.black.ignoresSafeArea())
        
        
    }
}

#Preview {
    SettingsPlaidHelpView()
        .environmentObject(NavigationPathManager())
        .environmentObject(UserSessionManager())
}
