//
//  SwiftUIView.swift
//  accumate_app
//
//  Created by Nevin Richards on 12/12/24.
//

import SwiftUI
import Combine
import Foundation

struct SignUpEmailView: View {
    @State private var email: String = ""
    @State private var errorMessage: String?
    @State private var submitted: Bool = false
    @State private var buttonDisabled: Bool = false

    @EnvironmentObject var navManager : NavigationPathManager
    @EnvironmentObject var sessionManager: UserSessionManager
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Spacer()
                .frame(height: 50)
            
            SignUpFieldView(
                instruction: SignUpFields.email.instruction,
                placeholder: SignUpFields.email.placeholder,
                inputValue: $email,
                keyboard: SignUpFields.email.keyboardType,
                errorMessage: errorMessage,
                signUpField: .email
            )
            Spacer()
            
            // Continue Button
            VStack() {
                Button {
//                    Task {
//                        await MainActor.run {
//                            buttonDisabled = true
//                            submitted = false
//                        }
//                        // validate inputs
//                        if let _errorMessage = SignUpFieldsUtils.validateEmail(email) {
//                            await MainActor.run {
//                                sessionManager.email = nil
//                                sessionManager.unverifiedEmail = nil
//                                errorMessage = _errorMessage
//                                buttonDisabled = false
//                            }
//                            return
//                        }
//                        
//                        // if passes, validate inputs in backend, create user / login if relevant
//                        let errorMessagesDict = await SignUpFieldsUtils.validateInputsBackend(
//                            email: email
//                        )
//                        if let errorMessagesList = SignUpFieldsUtils.parseErrorMessages(errorMessagesDict) {
//                            await MainActor.run {
//                                sessionManager.email = nil
//                                sessionManager.unverifiedEmail = nil
//                                errorMessage = errorMessagesList[0]
//                                buttonDisabled = false
//                            }
//                            return
//                        }
//                        
//                        // update state
//                        sessionManager.unverifiedEmail = email
//                        await MainActor.run {
//                            submitted = true
//                            errorMessage = nil
//                        }
//                    }
                } label: {
                    Text("Continue")
                        .font(.headline)
                        .foregroundColor(.black)
                        .frame(maxWidth: .infinity, minHeight: 50)
                        .background(.white)
                        .cornerRadius(10)
                }
                .padding([.top, .bottom], 20)
                .disabled(buttonDisabled)
                
                Text("By signing up, you agree to our Terms and Privacy Policy")
                    .foregroundColor(.gray)
                    .font(.system(size: 12))
                    .multilineTextAlignment(.center)
                    .frame(maxWidth: .infinity)

            }
        }
        .padding(30)
        .onChange(of: submitted) {
            if !submitted { return }
            buttonDisabled = false
            navManager.append(.signUpEmailVerify)
        }
        .animation(.easeInOut(duration: 0.5), value: errorMessage)
        .onAppear {
            if let _email = sessionManager.email {
                email = !sessionManager.isLoggedIn ? _email : ""
            } else if let _unverifiedEmail = sessionManager.unverifiedEmail {
                email = !sessionManager.isLoggedIn ? _unverifiedEmail : "" 
            }
        }
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
}

#Preview {
    SignUpEmailView()
        .environmentObject(NavigationPathManager())
        .environmentObject(UserSessionManager())
}
