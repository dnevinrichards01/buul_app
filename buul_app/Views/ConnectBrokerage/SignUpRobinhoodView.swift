//
//  RobinhoodView.swift
//  accumate_app
//
//  Created by Nevin Richards on 12/14/24.
//

import SwiftUI

struct SignUpRobinhoodView: View {
    @EnvironmentObject var navManager: NavigationPathManager
    @EnvironmentObject var sessionManager: UserSessionManager
    
    @State private var password: String = ""
    @State private var password2: String = ""
    @State private var email: String = ""
    
    @State private var isSecurePassword: Bool = true
    @State private var isSecurePassword2: Bool = true
    @State private var isSecureEmail: Bool = true
    
    @State private var mfaMethod: RobinhoodMFAMethod?
    
    @State private var showAlert: Bool = false
    @State private var alertMessage: String = "" // Your brokerage information has been updated
    @State private var timedOut: Bool = false
    @State private var buttonDisabled: Bool = false
    @State private var errorMessages: [String?]? = nil
    @State private var requested: Bool = false
    @State private var recieved: Bool = false
    
    var signUpFields: [SignUpFields]
    var title: String?
    var isSignUp: Bool
    
    
    private var fieldBindings: [SignUpFields: Binding<String>] {
        [
            .password: $password,
            .password2: $password2,
            .email: $email
        ]
    }
    
    private var isSecureBindings: [SignUpFields: Binding<Bool>] {
        [
            .password: $isSecurePassword,
            .password2: $isSecurePassword2,
            .email: $isSecureEmail
        ]
    }
    
    var body: some View {
        ZStack {
            RobinhoodFieldsEntryView(
                title: nil,
                subtitle: nil,
                signUpFields: signUpFields,
                fieldBindings: fieldBindings,
                isSecureBindings: isSecureBindings,
                suggestLogIn: false,
                isSignUp: true,
                alertMessage: $alertMessage,
                showAlert: $showAlert,
                errorMessages: $errorMessages,
                buttonDisabled: $buttonDisabled,
                timedOut: $timedOut
            )
            if buttonDisabled {
                LoadingCircle()
            }
        }
        .onChange(of: showAlert) { oldValue, newValue in
            guard oldValue && !newValue else { return }
            if recieved && !isSignUp {
                recieved = false
                sessionManager.robinhoodMFAType = nil
                sessionManager.brokerageEmail = nil
                sessionManager.brokeragePassword = nil
                if mfaMethod == nil {
                    navManager.removeLast(4)
                }
            } else if timedOut {
                buttonDisabled = true
                requestSignIn()
            }
        }
        .onChange(of: buttonDisabled) {
            if !buttonDisabled { return }
            let errorMessagesDictLocal = SignUpFieldsUtils.validateInputs(
                signUpFields: signUpFields,
                password: password,
                password2: password2,
                email: email
            )
            if let errorMessagesList = SignUpFieldsUtils.parseErrorMessages(signUpFields, errorMessagesDictLocal) {
                errorMessages = errorMessagesList
                buttonDisabled = false
            } else {
                requestSignIn()
            }
        }
        .onChange(of: requested) {
            if !requested { return }
            sleep(2)
            recieveSignInResult()
        }
        .onChange(of: recieved) {
            if !recieved { return }
            errorMessages = nil
            
            if mfaMethod == nil {
                if isSignUp {
                    recieved = false
                    print("recieved mfa issignup")
                    sessionManager.brokerageCompleted = true
                    navManager.append(.plaidInfo)
                } else {
                    alertMessage = "Your brokerage has been linked."
                    showAlert = true
                }
            }
            else if [.app, .sms, .prompt].contains(mfaMethod) { // remove .prompt
                recieved = false
                if isSignUp {
                    navManager.append(.signUpMfaRobinhood)
                } else {
                    navManager.append(.mfaRobinhood)
                }
            }
        }
        .background(Color.black.ignoresSafeArea())
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button(action: {
                    sessionManager.brokerageEmail = nil
                    sessionManager.brokeragePassword = nil
                    sessionManager.robinhoodMFAType = nil
                    navManager.path.removeLast()
                }) {
                    Image(systemName: "chevron.left")
                        .foregroundColor(.white)
                        .font(.system(size: 20, weight: .medium))
                        .frame(maxHeight: 30)
                }
            }
            ToolbarItem(placement: .principal) {
                Text("Connect to Robinhood")
                    .foregroundColor(.white)
                    .font(.system(size: 24, weight: .semibold))
                    .frame(maxHeight: 30)
            }
        }
    }
    
       
    private func requestSignIn() {
        ServerCommunicator().callMyServer(
            path: "rh/login/",
            httpMethod: .post,
            params: [
                "username": email,
                "password": password,
            ],
            sessionManager: sessionManager,
            responseType: OTPRequest.self
        ) { response in
            switch response {
            case .success(let responseData):
                // validation errors
                if let errors = responseData.error, responseData.success == nil {
                    do {
                        // process and display error messages
                        let errorMessagesDictBackend = try SignUpFieldsUtils.keysStringToSignUpFields(errors)
                        if let errorMessagesList = SignUpFieldsUtils.parseErrorMessages(signUpFields, errorMessagesDictBackend) {
                            // apply the error messages
                            self.errorMessages = errorMessagesList
                            self.buttonDisabled = false
                            return
                        }
                    } catch {}
                    // alert if error with username field or with processing error messages
//                    if !sessionManager.refreshFailed {
                        self.alertMessage = ServerCommunicator.NetworkError.decodingError.errorMessage
                        self.showAlert = true
//                    }
                    self.buttonDisabled = false
                    return
                // success, set up OTP information
                } else if let _ = responseData.success, responseData.error == nil {
                    self.errorMessages = nil
                    self.requested = true
                // not yet ready
                } else if let _ = responseData.error, let _ = responseData.success {
//                    if !sessionManager.refreshFailed {
                        self.alertMessage = ServerCommunicator.NetworkError.decodingError.errorMessage
                        self.showAlert = true
//                    }
                    self.buttonDisabled = false
                // alert because unexpected response
                } else {
//                    if !sessionManager.refreshFailed {
                        self.alertMessage = ServerCommunicator.NetworkError.decodingError.errorMessage
                        self.showAlert = true
//                    }
                    self.buttonDisabled = false
                }
            case .failure(let networkError):
//                if !sessionManager.refreshFailed {
                    self.showAlert = true
                    self.alertMessage = networkError.errorMessage
//                }
                switch networkError {
                case .statusCodeError(let status):
                    if status == 401 {
                        self.alertMessage = "Your session has expired. To retrieve updated information, please logout then sign in."
                    }
                default: break
                }
                self.buttonDisabled = false
            }
        }
    }
    
    private func recieveSignInResult(retries: Int = 10) {
        ServerCommunicator().callMyServer(
            path: "rh/login/",
            httpMethod: .get,
            params: nil,
            sessionManager: sessionManager,
            responseType: RobinhoodSignInResponse.self
        ) { response in
            switch response {
            case .success(let responseData):
                // validation errors
                if let errors = responseData.error, responseData.success == nil {
                    // alert if error with username field or with processing error messages
                    if let challengeType = errors.challengeType {
//                        challengeType = "sms" // "app"
                        for mfaMethod in RobinhoodMFAMethod.allCases {
                            if Utils.camelCaseToSnakeCase(mfaMethod.rawValue) == challengeType {
                                self.sessionManager.robinhoodMFAType = mfaMethod
                                self.mfaMethod = mfaMethod
                            }
                        }
                        self.sessionManager.brokerageEmail = email
                        self.sessionManager.brokeragePassword = password
                        self.requested = false
                        self.recieved = true
                        self.buttonDisabled = false
                        return
                    }
                    self.errorMessages = SignUpFieldsUtils.parseErrorMessages(
                        signUpFields,
                        [.password : errors.errorMessage]
                    )
                    self.requested = false
                    self.buttonDisabled = false
                    return
                // success, set up OTP information
                } else if let _ = responseData.success, responseData.error == nil {
                    
                    self.requested = false
                    self.recieved = true
                    self.mfaMethod = nil
                    self.sessionManager.robinhoodMFAType = nil
                    self.buttonDisabled = false
                // not yet ready
                } else if responseData.error == nil && responseData.success == nil {
                    
                    if retries > 0 {
                        sleep(1)
                        recieveSignInResult(retries: retries - 1)
                        return
                    }
                    
                    self.alertMessage = "We timed out waiting for a response. Would you like to continue waiting?"
                    self.showAlert = true
                    self.errorMessages = nil
                    self.requested = false
                    self.buttonDisabled = false
                    self.timedOut = true
                // alert because unexpected response
                } else {
                    self.errorMessages = nil
                    self.alertMessage = ServerCommunicator.NetworkError.decodingError.errorMessage
                    self.showAlert = true
                    self.requested = false
                    self.buttonDisabled = false
                }
            case .failure(let networkError):
                self.requested = false
//                if !sessionManager.refreshFailed {
                    self.showAlert = true
                    self.alertMessage = networkError.errorMessage
//                }
                switch networkError {
                case .statusCodeError(let status):
                    if status == 401 {
                        self.alertMessage = "Your session has expired. To retrieve updated information, please logout then sign in."
                    }
                default: break  
                }
                
                self.buttonDisabled = false
            }
        }
    }
}

struct RobinhoodSignInResponse: Codable {
    let success: String?
    let error: RobinhoodSignInResponseErrors?
}

struct RobinhoodSignInResponseErrors: Codable {
    let challengeType: String?
    let errorMessage: String?
}

enum RobinhoodMFAMethod: String, CaseIterable {
    // for sms and app let them enter the code, depending on the method we change the params.
    // must save / delete the password / sms / brokerage
    case sms
    case app
    case prompt // raise error
}

#Preview {
    SignUpRobinhoodView(
        signUpFields: [.email, .password],
        isSignUp: true
    )
    .environmentObject(NavigationPathManager())
    .environmentObject(UserSessionManager())
}
