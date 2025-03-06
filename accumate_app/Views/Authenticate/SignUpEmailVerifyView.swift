//
//  SwiftUIView.swift
//  accumate_app
//
//  Created by Nevin Richards on 12/12/24.
//

import SwiftUI
import Combine
import Foundation

struct SignUpEmailVerifyView: View {
    @State private var otp: String = ""
    @State private var errorMessage: String?
    @State private var buttonDisabled = true
    @State private var submitted = false
    
    @EnvironmentObject var navManager : NavigationPathManager
    @EnvironmentObject var sessionManager : UserSessionManager
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            VStack (alignment: .center) {
                
                Text("Verify Your Email")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundStyle(.white)
                    .multilineTextAlignment(.center)
                    .padding(.bottom, 20)
                Text("Enter the code sent to your email address")
                    .font(.headline)
                    .foregroundStyle(.white.opacity(0.8))
                    .multilineTextAlignment(.leading)
            }
            .frame(maxWidth: .infinity)
            
            Spacer()
            OTPFieldView(otp: $otp)
            if let errorMessage = errorMessage {
                Text(errorMessage)
                    .font(.headline)
                    .foregroundStyle(.red)
                    .multilineTextAlignment(.leading)
                    .padding()
            }
            Spacer()
            
            // Continue Button
            VStack() {
                Button {
                    Task {
                        await MainActor.run {
                            buttonDisabled = true
                            submitted = false
                        }
                        // validate inputs
                        if let _errorMessage = SignUpFieldsUtils.validateOTP(otp) {
                            await MainActor.run {
                                errorMessage = _errorMessage
                                buttonDisabled = false
                            }
                            return
                        }
                        
                        // if passes, validate inputs in backend, create user / login if relevant
                        if let _errorMessage = await SignUpFieldsUtils.sendEmailOTP(otp) {
                            await MainActor.run {
                                errorMessage = _errorMessage
                                buttonDisabled = false
                            }
                            return
                        }
                        
                        // update state
                        sessionManager.updateSignUpFieldsState(
                            email: sessionManager.unverifiedEmail
                        )
                        await MainActor.run {
                            submitted = true
                            errorMessage = nil
                        }
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
        .onChange(of: submitted) {
            if !submitted { return }
            buttonDisabled = false
            navManager.append(.signUpFullName)
        }
        .animation(.easeInOut(duration: 0.5), value: errorMessage)
        .background(Color.black.ignoresSafeArea())
        .navigationBarBackButtonHidden(true)
        .navigationBarTitleDisplayMode(.inline)
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
            ToolbarItem(placement: .principal) {
                Text("Sign Up")
                    .foregroundColor(.white)
                    .font(.system(size: 24, weight: .semibold))
                    .frame(maxHeight: 30)
            }
            ToolbarItemGroup(placement: .keyboard) {
                Spacer()
                Button("Done") {
                    Utils.dismissKeyboard()
                }
                .foregroundColor(.blue) // Customize the button appearance
            }
        }
    }
    
    
    
    private func resendCode() {
        return
    }

    
}



#Preview {
    SignUpEmailVerifyView()
        .environmentObject(NavigationPathManager())
        .environmentObject(UserSessionManager())
}
