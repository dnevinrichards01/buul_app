//
//  SettingsDeleteView.swift
//  accumate_app
//
//  Created by Nevin Richards on 1/31/25.
//

import SwiftUI

struct SettingsDeleteView: View {
    @State private var showAlert: Bool = false
    @State private var errorMessage: String?
    
    @EnvironmentObject var navManager: NavigationPathManager
    @EnvironmentObject var sessionManager: UserSessionManager
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            VStack (alignment: .center) {
                Text("Are you sure you want to delete your account?")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundStyle(.white)
                    .multilineTextAlignment(.center)
                    .padding(.bottom, 20)
                Text("This action cannot be reversed. All your data will be deleted")
                    .font(.headline)
                    .foregroundStyle(.white.opacity(0.8))
                    .multilineTextAlignment(.leading)
            }
            .frame(maxWidth: .infinity)
            
            
            Spacer()
            
            if let errorMessage = errorMessage {
                Text(errorMessage)
                    .font(.headline)
                    .foregroundStyle(.red)
                    .multilineTextAlignment(.leading)
            }
            
            
            VStack() {
                Button {
                    let error = deleteAccount()
                    if error != "" {
                        withAnimation(.easeInOut(duration: 0.5)) {
                            errorMessage = error
                        }
                    } else {
                        showAlert = true
                        sessionManager.isLoggedIn = false
                    }
                } label: {
                    Text("Delete Account")
                        .font(.headline)
                        .foregroundColor(.black)
                        .frame(maxWidth: .infinity, minHeight: 50)
                        .background(.white)
                        .cornerRadius(10)
                }
                .padding([.top, .bottom], 20)
                .alert("Your account has been deleted", isPresented: $showAlert) {
                    Button("OK", role: .cancel) { showAlert = false }
                }
                .onChange(of: showAlert) { oldValue, newValue in
                    if oldValue == true && newValue == false {
                        navManager.resetNavigation()
                    }
                }
            }
        }
        .padding(30)
        .background(Color.black.ignoresSafeArea())
        .navigationBarBackButtonHidden(true)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button(action: {
                    navManager.path.removeLast(2)
                }) {
                    Image(systemName: "chevron.left")
                        .foregroundColor(.white)
                        .font(.system(size: 20, weight: .medium))
                        .frame(maxHeight: 30)
                }
            }
        }
    }
    
    func deleteAccount() -> String {
        return ""
    }
}

#Preview {
    SettingsDeleteView()
}
