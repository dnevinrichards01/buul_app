//
//  ChangeEmailOTPView.swift
//  accumate_app
//
//  Created by Nevin Richards on 2/1/25.
//

import SwiftUI

import SwiftUI
import Combine
import Foundation

struct OTPView: View {
    @State private var cancellable: AnyCancellable?
    @State private var otp: String = ""
    @State private var errorMessage: String?
    
    var title: String
    var subtitle: String
    var nextPage: NavigationPathViews
    
    @EnvironmentObject var navManager: NavigationPathManager
    @EnvironmentObject var sessionManager: UserSessionManager
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            VStack (alignment: .center) {
                Text(title)
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundStyle(.white)
                    .multilineTextAlignment(.center)
                    .padding(.bottom, 20)
                Text(subtitle)
                    .font(.headline)
                    .foregroundStyle(.white.opacity(0.8))
                    .multilineTextAlignment(.leading)
            }
            .frame(maxWidth: .infinity)
            
            Spacer()
            OTPFieldView(otp: $otp)
            Spacer()
            
            VStack() {
                Button {
                    if !validateOTPEmail() {
                        errorMessage = "Code is incorrect or expired"
                    } else {
                        navManager.path.append(nextPage)
                    }
                    
                } label: {
                    Text("Continue")
                        .font(.headline)
                        .foregroundColor(.black)
                        .frame(maxWidth: .infinity, minHeight: 50)
                        .background(.white)
                        .cornerRadius(10)
                }
                .padding([.top, .bottom], 20)
                
                Button {
                    resendCode()
                } label: {
                    Text("Click here to resend code")
                        .foregroundColor(.white)
                        .font(.system(size: 14))
                        .multilineTextAlignment(.center)
                        .frame(maxWidth: .infinity)
                        .bold()
                }
            }
        }
        .padding(30)
        .background(Color.black.ignoresSafeArea())
        .navigationBarBackButtonHidden(true)
        .navigationBarTitleDisplayMode(.inline)
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
            ToolbarItemGroup(placement: .keyboard) {
                Spacer()
                Button("Done") {
                    dismissKeyboard()
                }
                .foregroundColor(.blue)
            }
        }
    }
    
    private func dismissKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
    
    private func validateOTPEmail() -> Bool {
        return true
    }
    
    private func resendCode() {
        return
    }

    
}



#Preview {
    OTPView(
        title: "Change Email",
        subtitle: "Enter the code sent to your email",
        nextPage: NavigationPathViews.changeEmail
    )
    .environmentObject(NavigationPathManager())
    .environmentObject(UserSessionManager())
}
