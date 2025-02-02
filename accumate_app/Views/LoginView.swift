//
//  SwiftUIView.swift
//  accumate_app
//
//  Created by Nevin Richards on 12/13/24.
//

import SwiftUI

struct LoginView: View {
    @State private var username: String = ""
    @State private var password: String = ""
    @State private var password2: String = ""
    @State private var fullName: String = ""
    @State private var phoneNumber: String = ""
    @State private var email: String = ""
    
    @FocusState private var focusedField: Int?
    @State private var isKeyboardVisible = false
    @State private var errorMessages: [String?]? = nil
    
    var signUpFields: [SignUpFields]
    
    private var fieldBindings: [SignUpFields: Binding<String>] {
        [
            .username: $username,
            .password: $password,
            .password2: $password2,
            .fullName: $fullName,
            .phoneNumber: $phoneNumber,
            .email: $email,
        ]
    }
    
    @EnvironmentObject var navManager: NavigationPathManager
    @EnvironmentObject var sessionManager: UserSessionManager
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            ForEach(SignUpFields.allCases.indices, id: \.self) { index in
                let signUpField = SignUpFields.allCases[index]
                if let binding = fieldBindings[signUpField], signUpFields.contains(signUpField) {
                    SignUpFieldView(
                        instruction: signUpField.loginInstruction,
                        placeholder: signUpField.placeholder,
                        inputValue: binding,
                        keyboard: signUpField.keyboardType,
                        errorMessage: errorMessages?[index]
                    )
                    .focused($focusedField, equals: index)
                }
            }
            
            HStack (alignment: .firstTextBaseline) {
                Spacer()
                Text("Forgot your")
                    .foregroundColor(.white.opacity(0.9))
                    .font(.system(size: 15))
                Button {
                    navManager.path.append(NavigationPathViews.emailRecover)
                } label: {
                    Text("email")
                        .foregroundColor(.blue)
                        .font(.system(size: 15))
                }
                Text("or")
                    .foregroundColor(.white.opacity(0.9))
                    .font(.system(size: 15))
                Button {
                    navManager.path.append(NavigationPathViews.passwordRecoverInitiate)
                } label: {
                    Text("password?")
                        .foregroundColor(.blue)
                        .font(.system(size: 15))
                }
            }
            .padding()
            
            Spacer()
            
            Button {

                let errorMessagesDict = validateLogin()
                var errorMessagesList: [String?] = []
                var isError = false
                for index in SignUpFields.allCases.indices {
                    let signUpField = SignUpFields.allCases[index]
                    if let errorMessage = errorMessagesDict[signUpField] {
                        if errorMessage != nil {
                            isError = true
                        }
                        errorMessagesList.append(errorMessage)
                    } else {
                        errorMessagesList.append(nil)
                    }
                }
                
                withAnimation(.easeInOut(duration: 0.5)) {
                    errorMessages = errorMessagesList
                }
                if !isError {
                    sessionManager.isLoggedIn = true
                    navManager.path.append(NavigationPathViews.home)
                }
            } label: {
                Text("Continue")
                    .font(.headline)
                    .foregroundColor(.black)
                    .frame(maxWidth: .infinity, minHeight: 50)
                    .background(.white)
                    .cornerRadius(10)
            }
        }
        .padding()
//        .ignoresSafeArea(.keyboard, edges: .all)
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
                Text("Login")
                    .foregroundColor(.white)
                    .font(.system(size: 24, weight: .semibold))
                    .frame(maxHeight: 30)
            }
            ToolbarItemGroup(placement: .keyboard) {
                Button {
                    if let _focusedField = focusedField {
                        focusedField = max(_focusedField - 1, 0)
                    }
                } label: {
                    Image(systemName: "chevron.left")
                        .foregroundColor(.blue)
                }
                Button {
                    if let _focusedField = focusedField {
                        focusedField = min(_focusedField + 1, signUpFields.count - 1)
                    }
                } label: {
                    Image(systemName: "chevron.right")
                        .foregroundColor(.blue)
                }
                Spacer()
                Button("Done") {
                    dismissKeyboard()
                }
                .foregroundColor(.blue) // Customize the button appearance
            }
        }
                
            
        
    }
    
    private func dismissKeyboard() {
        focusedField = nil
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
    
    private func validateLogin() -> [SignUpFields : String?] {
        let usernameErrorMessage = validateUsername()
        let passwordErrorMessage = validatePassword()
        return [
            .username : usernameErrorMessage,
            .password : passwordErrorMessage
        ]
    }
    
    private func validateFields() -> [SignUpFields : String?] {
        var errorMessagesDict: [SignUpFields : String?] = [:]
        for signUpField in fieldBindings.keys {
            let errorMessage: String?
            switch signUpField {
            case .username:
                errorMessage = validateUsername()
            case .password:
                errorMessage = validatePassword()
            case .password2:
                errorMessage = validatePassword2()
            case .fullName:
                errorMessage = validateFullname()
            case .phoneNumber:
                errorMessage = validatePhoneNumber()
            case .email:
                errorMessage = validateEmail()
            }
            errorMessagesDict[signUpField] = errorMessage
        }
        return errorMessagesDict
    }
    
    private func validateEmail() -> String? {
        return nil
    }
    
    private func validatePassword() -> String? {
        return nil
    }
    
    private func validatePassword2() -> String? {
        
        return nil
    }
    
    private func validateUsername() -> String? {
        return nil
    }
    
    private func validateFullname() -> String? {
        return nil
    }
    
    private func validatePhoneNumber() -> String? {
        return nil
    }
    
}



#Preview {
    LoginView(signUpFields: [.username, .password])
        .environmentObject(NavigationPathManager())
        .environmentObject(UserSessionManager())
}
