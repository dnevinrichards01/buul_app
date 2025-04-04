//
//  SignUpPasswordView.swift
//  accumate_app
//
//  Created by Nevin Richards on 2/7/25.
//

import SwiftUI

@MainActor
struct SignUpPasswordView: View {
    @State private var password: String = ""
    @State private var password2: String = ""
    @FocusState private var focusedField: Int?
    
    @State private var errorMessages: [String?]? = nil
    
    @State private var userCreated: Bool = false
    @State private var tokensRecieved: Bool = false
    @State private var alertMessage: String = ""
    @State private var showAlert: Bool = false
    @State private var reEnterField: SignUpFields?
    @State private var buttonDisabled: Bool = false
    
    private var alertMessagePhoneNumber: String = "This phone number has been taken since you entered it"
    private var alertMessageEmail: String = "This email has been taken since you entered it"
    
    
    var signUpFields: [SignUpFields] = [.password, .password2]
    var signUpField: SignUpFields = .password
    var authenticate: Bool = false
    
    private var fieldBindings: [SignUpFields: Binding<String>] {
        [
            .password: $password,
            .password2: $password2,
        ]
    }
    
    @EnvironmentObject var navManager: NavigationPathManager
    @EnvironmentObject var sessionManager: UserSessionManager
    
    var body: some View {
        FieldsEntryView(
            title: nil,
            subtitle: nil,
            signUpFields: signUpFields,
            fieldBindings: fieldBindings,
            suggestLogIn: signUpField == .phoneNumber && !authenticate,
            isSignUp: true,
            buttonText: "Create Account",
            alertMessage: $alertMessage,
            showAlert: $showAlert,
            errorMessages: $errorMessages,
            buttonDisabled: $buttonDisabled,
            focusedField: $focusedField
        )
        .onChange(of: showAlert) { oldValue, newValue in
            if oldValue == true && newValue == false {
                guard let _ = reEnterField else { return }
                if reEnterField == .email {
                    reEnterField = nil
                    navManager.path.removeLast(3)
                } else if reEnterField == .phoneNumber {
                    reEnterField = nil
                    navManager.path.removeLast(4)
                } else if reEnterField == .fullName {
                    reEnterField = nil
                    navManager.path.removeLast(1)
                } else {
                    return
                }
            }
        }
        .onChange(of: buttonDisabled) { oldValue, newValue in
            if !buttonDisabled { return }
            
            if userCreated && !tokensRecieved {
                login()
                return
            }
            
            let errorMessagesDictLocal = SignUpFieldsUtils.validateInputs(
                signUpFields: signUpFields,
                password: password,
                password2: password2
            )
            if let errorMessagesList = SignUpFieldsUtils.parseErrorMessages(signUpFields, errorMessagesDictLocal) {
                errorMessages = errorMessagesList
                buttonDisabled = false
            } else {
                createUser()
            }
        }
        .onChange(of: userCreated) {
            if !userCreated { return }
            login()
        }
        .onChange(of: tokensRecieved) {
            Task {
                if !tokensRecieved { return }
                let accessSaved = await sessionManager.accessTokenSet(sessionManager.accessToken)
                let refreshSaved = await sessionManager.refreshTokenSet(sessionManager.refreshToken)
                if !accessSaved || !refreshSaved {
                    alertMessage = "Your account has been created but an internal error is preventing you from logging in. Press 'Create Account' to retry login."
                    showAlert = true
                    return
                }
                buttonDisabled = false
                sessionManager.isLoggedIn = true
                navManager.append(.accountCreated)
            }
        }
        .animation(.easeInOut(duration: 0.5), value: errorMessages)
        .padding()
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
        }
    }
    
    private func createUser() {
        ServerCommunicator().callMyServer(
            path: "api/user/createuser/",
            httpMethod: .post,
            params: [
                "pre_account_id" : sessionManager.preAccountId as Any,
                "password" : password as Any,
                "email" : sessionManager.email as Any,
                "username" : sessionManager.email as Any,
                "full_name" : sessionManager.fullName as Any,
                "phone_number" : sessionManager.phoneNumber as Any
            ],
            responseType: CreateUserRequest.self
        ) { response in
            // extract errorMessages and network error from the Result<T, NetworkError> object
            var errorMessages: CreateUserRequestErrors?
            var networkError: ServerCommunicator.NetworkError?
            switch response {
            case .success(let responseData):
                errorMessages = responseData.error
            case .failure(let error):
                networkError = error
            }
            
            // error if network error
            if let networkError = networkError {
//                if !sessionManager.refreshFailed {
                    self.alertMessage = networkError.errorMessage
                    self.showAlert = true
//                }
                self.buttonDisabled = false
                return
            }
            
            // process response
            if let errorMessages = errorMessages {
                do {
                    // process errors into a list
                    let errorMessagesDictBackend = try SignUpFieldsUtils.keysStringToSignUpFields(errorMessages)
                    if let errorMessagesList = SignUpFieldsUtils.parseErrorMessages(signUpFields, errorMessagesDictBackend) {
                        // if an earlier field is messed up, error and send them back to it
                        if errorMessagesDictBackend[.password] == nil {
                            if let _ = errorMessagesDictBackend[.phoneNumber] {
                                self.sessionManager.phoneNumber = nil
//                                if !sessionManager.refreshFailed {
                                    self.alertMessage = alertMessagePhoneNumber
                                    self.showAlert = true
//                                }
                                self.reEnterField = .phoneNumber
                            } else if let _ = errorMessagesDictBackend[.email] {
                                self.sessionManager.email = nil
//                                if !sessionManager.refreshFailed {
                                    self.alertMessage = alertMessageEmail
                                    self.showAlert = true
//                                }
                                self.reEnterField = .email
                            }
                        }
                        // apply the error messages
                        self.errorMessages = errorMessagesList // maybe upgrade this with sessionManager
                        self.buttonDisabled = false
                        return
                    } // if code ends up here it indicates error with username field
                } catch {
                    // error (Decoding error) if difficulty parsing the response
//                    if !sessionManager.refreshFailed {
                        self.alertMessage = ServerCommunicator.NetworkError.decodingError.errorMessage
                        self.showAlert = true
//                    }
                    self.buttonDisabled = false
                    return
                }
            // if no error messages, set error messages to nil
            } else {
                self.errorMessages = nil
                self.userCreated = true
            }
        }
    }
    
    
    private func login() {
        ServerCommunicator().callMyServer(
            path: "api/token/",
            httpMethod: .post,
            params: [
                "username" : sessionManager.email as Any,
                "password" : password as Any,
            ],
            responseType: LoginResponse.self
        ) { response in
            // extract errorMessages and network error from the Result<T, NetworkError> object
            var accessToken: String?
            var refreshToken: String?
            var networkError: ServerCommunicator.NetworkError?
            switch response {
            case .success(let responseData):
                accessToken = responseData.access
                refreshToken = responseData.refresh
            case .failure(let error):
                networkError = error
            }
            
            // error if network error
            if let networkError = networkError {
//                if !sessionManager.refreshFailed {
                    self.alertMessage = "Your account was created but we ran into trouble loggin you in." + networkError.errorMessage + "Press 'Create Account' to retry login."
                    self.showAlert = true
//                }
                self.buttonDisabled = false
                return
            }
            // process response
            if let accessToken = accessToken, let refreshToken = refreshToken {
                sessionManager.refreshToken = refreshToken
                sessionManager.accessToken = accessToken
                self.tokensRecieved = true
            } else {
//                if !sessionManager.refreshFailed {
                    self.alertMessage = "Your account was created but we ran into trouble loggin you in." + ServerCommunicator.NetworkError.nilData.errorMessage + "Press 'Create Account' to retry login."
                    self.showAlert = true
//                }
                self.buttonDisabled = false
            }
        }
    }
    
}

struct CreateUserRequest: Codable {
    let success: String?
    let error: CreateUserRequestErrors?
}
struct CreateUserRequestErrors: Codable {
    let fullName: String?
    let email: String?
    let phoneNumber: String?
    let password: String?
}


#Preview {
    SignUpPasswordView()
        .environmentObject(NavigationPathManager())
        .environmentObject(UserSessionManager())
}


