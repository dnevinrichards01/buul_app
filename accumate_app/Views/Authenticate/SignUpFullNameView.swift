//
//  SwiftUIView.swift
//  accumate_app
//
//  Created by Nevin Richards on 12/12/24.
//

import SwiftUI
import Combine
import Foundation

struct SignUpFullNameView: View {
    @State private var fullName: String = ""
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
                instruction: SignUpFields.fullName.instruction,
                placeholder: SignUpFields.fullName.placeholder,
                inputValue: $fullName,
                keyboard: SignUpFields.fullName.keyboardType,
                errorMessage: errorMessage
            )
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
                        if let _errorMessage = SignUpFieldsUtils.validateFullname(fullName) {
                            await MainActor.run {
                                sessionManager.fullName = nil
                                errorMessage = _errorMessage
                                buttonDisabled = false
                            }
                            return
                        }
                        
                        // if passes, validate inputs in backend, create user / login if relevant
                        let errorMessagesDict = await SignUpFieldsUtils.validateInputsBackend(
                            fullName: fullName
                        )
                        if let errorMessagesList = SignUpFieldsUtils.parseErrorMessages(errorMessagesDict) {
                            await MainActor.run {
                                sessionManager.fullName = nil
                                errorMessage = errorMessagesList[0]
                                buttonDisabled = false
                            }
                            return
                        }
                        
                        // update state
                        sessionManager.updateSignUpFieldsState(
                            fullName: fullName
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
            }
        }
        .padding(30)
        .onChange(of: submitted) {
            if !submitted { return }
            buttonDisabled = false
            navManager.append(.signUpPassword)
        }
        .onAppear {
            if let _fullName = sessionManager.fullName {
                fullName = !sessionManager.isLoggedIn ? _fullName : ""
            }
            
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
}



#Preview {
    SignUpFullNameView()
        .environmentObject(NavigationPathManager())
        .environmentObject(UserSessionManager())
}
