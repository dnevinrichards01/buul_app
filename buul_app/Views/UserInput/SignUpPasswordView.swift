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
    @State private var email: String = ""
    @State private var isSecurePassword: Bool = true
    @State private var isSecurePassword2: Bool = true
    @State private var isSecureEmail: Bool = true
    
    @FocusState private var focusedField: Int?
    
    @State private var errorMessages: [String?]? = nil
    
    @State private var userCreated: Bool = false
    @State private var tokensRecieved: Bool = false
    @State private var alertMessage: String = ""
    @State private var showAlert: Bool = false
    @State private var reEnterField: SignUpFields?
    @State private var buttonDisabled: Bool = false
    @State private var buttonText: String = "Create Account"
    @State private var hideFields: [SignUpFields] = []
    
    
    var signUpFields: [SignUpFields] = [.email, .password, .password2, .phoneNumber]
    var authenticate: Bool = false
    var isUserName: Bool = true
    
    private var fieldBindings: [SignUpFields: Binding<String>] {
        [
            .email: $email,
            .password: $password,
            .password2: $password2,
        ]
    }
    private var isSecureBindings: [SignUpFields: Binding<Bool>] {
        [
            .email: $isSecureEmail,
            .password: $isSecurePassword,
            .password2: $isSecurePassword2,
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
            suggestLogIn: false,
            isSignUp: true,
            buttonText: $buttonText,
            isUserName: isUserName,
            alertMessage: $alertMessage,
            showAlert: $showAlert,
            errorMessages: $errorMessages,
            buttonDisabled: $buttonDisabled,
            focusedField: $focusedField,
            isNewPassword: true,
            isSecureBindings: isSecureBindings,
            hideFields: $hideFields
        )
        .onAppear {
            email = sessionManager.email ?? ""
            password2 = ""
            focusedField = nil
            errorMessages = nil
            userCreated = false
            tokensRecieved = false
            alertMessage = ""
            showAlert = false
            buttonDisabled = false
        }
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
        .onChange(of: buttonDisabled) {
            if !buttonDisabled { return }
            
            Task.detached {
                await MainActor.run {
                    isSecureEmail = true
                    isSecurePassword = true
                    isSecurePassword2 = true
                    UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
                }
                
                let userCreated = await self.userCreated
                let tokensRecieved = await self.tokensRecieved
                if userCreated && !tokensRecieved {
                    await login()
                    return
                }
                
                let errorMessagesDictLocal = SignUpFieldsUtils.validateInputs(
                    signUpFields: signUpFields,
                    password: await password,
                    password2: await password2
                )
                if let errorMessagesList = SignUpFieldsUtils.parseErrorMessages(signUpFields, errorMessagesDictLocal) {
                    await MainActor.run {
                        errorMessages = errorMessagesList
                        buttonDisabled = false
                    }
                } else {
                    await createUser()
                }
            }
        }
        .onChange(of: userCreated) {
            guard userCreated else { return }
            Task.detached {
                await login()
            }
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
                
                sessionManager.isLoggedIn = true
                buttonText = "Account Created!"

                // Delay navigation so Keychain can intercept form submission
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.7) {
                    buttonDisabled = false
                    navManager.append(.accountCreated)
                }
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
    
    private func createUser() async {
        await ServerCommunicator().callMyServer(
            path: "api/user/createuser/",
            httpMethod: .post,
            params: [
                "pre_account_id" : sessionManager.preAccountId as Any,
                "password" : password as Any,
                "email" : email as Any,
                "full_name" : sessionManager.fullName as Any,
                "phone_number" : sessionManager.phoneNumber as Any
            ],
            app_version: sessionManager.app_version,
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
                                self.alertMessage = "We found an error with your number. Please re-enter it."
                                self.showAlert = true
                                self.reEnterField = .phoneNumber
                            } else if let _ = errorMessagesDictBackend[.email] {
                                self.sessionManager.email = nil
                                self.alertMessage = "We found an error with your email. Please re-enter it."
                                self.showAlert = true
                                self.reEnterField = .email
                            }
                        }
                        // apply the error messages
                        self.errorMessages = errorMessagesList // maybe upgrade this with sessionManager
                        self.buttonDisabled = false
                        return
                    } // if code ends up here it indicates error with username field
                } catch {
                    self.alertMessage = ServerCommunicator.NetworkError.decodingError.errorMessage
                    self.showAlert = true
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
    
    
    private func login() async {
        await ServerCommunicator().callMyServer(
            path: "api/token/",
            httpMethod: .post,
            params: [
                "email" : sessionManager.email as Any,
                "password" : password as Any,
                "app_version": sessionManager.app_version as Any
            ],
            app_version: sessionManager.app_version,
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
                self.alertMessage = "Your account was created but we ran into trouble loggin you in." + networkError.errorMessage + "Press 'Create Account' to retry login."
                self.showAlert = true
                self.buttonDisabled = false
                return
            }
            // process response
            if let accessToken = accessToken, let refreshToken = refreshToken {
                sessionManager.refreshToken = refreshToken
                sessionManager.accessToken = accessToken
                self.tokensRecieved = true
            } else {
                self.alertMessage = "Your account was created but we ran into trouble loggin you in." + ServerCommunicator.NetworkError.nilData.errorMessage + "Press 'Create Account' to retry login."
                self.showAlert = true
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


