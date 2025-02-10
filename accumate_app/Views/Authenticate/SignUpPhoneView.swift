//
//  SwiftUIView.swift
//  accumate_app
//
//  Created by Nevin Richards on 12/12/24.
//

import SwiftUI
import Combine

struct SignUpPhoneView: View {
    @State private var phoneNumber: String = "+1"
    @State private var errorMessage: String?
    @State private var submitted: Bool = false
    @State private var buttonDisabled: Bool = false
    
    @EnvironmentObject var navManager: NavigationPathManager
    @EnvironmentObject var sessionManager: UserSessionManager
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Spacer()
                .frame(height: 20)
            HStack {
                Spacer()
                Text("Already a member?")
                    .foregroundColor(.white.opacity(0.9))
                    .font(.system(size: 12))
                    .background(.black)
                    .cornerRadius(10)
                Button {
                    navManager.append(NavigationPathViews.login)
                } label: {
                    Text("Log In")
                        .foregroundColor(.blue)
                        .font(.system(size: 12))
                        .background(.black)
                        .cornerRadius(10)
                }
            }
            
            Spacer()
                .frame(height: 30)
            
            SignUpFieldView(
                instruction: SignUpFields.phoneNumber.instruction,
                placeholder: SignUpFields.phoneNumber.placeholder,
                inputValue: $phoneNumber,
                keyboard: SignUpFields.phoneNumber.keyboardType,
                errorMessage: errorMessage
            )
            
            Spacer()
            
            VStack() {
                Button {
                    Task {
                        await MainActor.run {
                            buttonDisabled = true
                            submitted = false
                        }
                        // validate inputs
                        if let _errorMessage = SignUpFieldsUtils.validatePhoneNumber(phoneNumber) {
                            await MainActor.run {
                                sessionManager.phoneNumber = nil
                                errorMessage = _errorMessage
                                buttonDisabled = false
                            }
                            return
                        }
                        
                        // if passes, validate inputs in backend, create user / login if relevant
                        let errorMessagesDict = await SignUpFieldsUtils.validateInputsBackend(
                            phoneNumber: phoneNumber
                        )
                        if let errorMessagesList = SignUpFieldsUtils.parseErrorMessages(errorMessagesDict) {
                            await MainActor.run {
                                sessionManager.phoneNumber = nil
                                errorMessage = errorMessagesList[0]
                                buttonDisabled = false
                            }
                            return
                        }
                        
                        // update state
                        sessionManager.updateSignUpFieldsState(
                            phoneNumber: phoneNumber
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
                .disabled(buttonDisabled)
                
                Text("By signing up, you agree to our Terms and Privacy Policy")
                    .foregroundColor(.gray)
                    .font(.system(size: 12))
                    .multilineTextAlignment(.center)
                    .frame(maxWidth: .infinity)

            }
        }
        .padding(30)
        .onChange(of: phoneNumber) {
            phoneNumber = SignUpFieldsUtils.formatPhoneNumber(phoneNumber)
        }
        .onChange(of: submitted) {
            if !submitted { return }
            buttonDisabled = false
            navManager.append(.signUpEmail)
        }
        .animation(.easeInOut(duration: 0.5), value: errorMessage)
        .background(Color.black)
        .navigationBarBackButtonHidden(true)
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            if let _phoneNumber = sessionManager.phoneNumber { 
                phoneNumber = !sessionManager.isLoggedIn ? _phoneNumber : "+1"
            } else {
                phoneNumber = "+1"
            }
            
        }
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button {
                    navManager.path.removeLast()
                } label: {
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
    SignUpPhoneView()
        .environmentObject(NavigationPathManager())
        .environmentObject(UserSessionManager())
}
