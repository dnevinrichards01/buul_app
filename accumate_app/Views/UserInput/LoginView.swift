//
//  SwiftUIView.swift
//  accumate_app
//
//  Created by Nevin Richards on 12/13/24.
//

import SwiftUI

struct LoginView: View {
    @State private var password: String = ""
    @State private var email: String = ""
    @State private var isSecurePassword: Bool = true
    @State private var isSecureEmail: Bool = true
    
    @FocusState private var focusedField: Int?
    
    @State private var errorMessages: [String?]? = nil
    @State private var submitted: Bool = false
    @State private var showAlert: Bool = false
    @State private var alertMessage: String = ""
    @State private var buttonDisabled: Bool = false
    @State private var tokensRecieved: Bool = false
    @State private var accessToken: String?
    @State private var refreshToken: String?
    @State private var tokensSaved: Bool = false
    @State private var buttonText: String = "Continue"
    
    var signUpFields: [SignUpFields] = [.email, .password]
    
    var authenticate = false
    var isUserName: Bool = true
    
    private var fieldBindings: [SignUpFields: Binding<String>] {
        [
            .password: $password,
            .email: $email,
        ]
    }
    
    private var isSecureBindings: [SignUpFields: Binding<Bool>] {
        [
            .password: $isSecurePassword,
            .email: $isSecureEmail,
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
            isLogin: true,
            isSignUp: false,
            buttonText: $buttonText,
            isUserName: isUserName,
            alertMessage: $alertMessage,
            showAlert: $showAlert,
            errorMessages: $errorMessages,
            buttonDisabled: $buttonDisabled,
            focusedField: $focusedField,
            isSecureBindings: isSecureBindings
        )
        .onChange(of: buttonDisabled) {
            if !buttonDisabled { return }
            
            let errorMessagesDictLocal = SignUpFieldsUtils.validateInputs(
                signUpFields: signUpFields,
                password: password,
                email: email
            )
            if let errorMessagesList = SignUpFieldsUtils.parseErrorMessages(signUpFields, errorMessagesDictLocal) {
                errorMessages = errorMessagesList
                buttonDisabled = false
            } else {
                login()
            }
        }
        .onChange(of: tokensRecieved) {
            Task {
                if !tokensRecieved { return }
                // save tokens
                if let refreshToken = refreshToken, let accessToken = accessToken {
                    let refreshTokenSaved: Bool = await sessionManager.refreshTokenSet(refreshToken)
                    let accessTokenSaved: Bool = await sessionManager.accessTokenSet(accessToken)
                    if refreshTokenSaved && accessTokenSaved {
                        print("saved")
                        self.tokensSaved = true
                        return
                    }
                }
                // tokens failed to save
                self.tokensRecieved = false
                self.buttonDisabled = false
                _ = await sessionManager.resetComplete() // await
//                if !sessionManager.refreshFailed {
                    self.alertMessage = ServerCommunicator.NetworkError.decodingError.errorMessage
                    self.showAlert = true
//                }
            }
        }
        .onChange(of: tokensSaved) {
            print(tokensSaved)
            if !tokensSaved { return }
            getUserInfo()
        }
        .onChange(of: submitted) {
            if !submitted { return }
            self.buttonDisabled = false
            if let destination: NavigationPathViews = sessionManager.signUpFlowPlacement() {
                let destinationPath: [NavigationPathViews] = sessionManager.signUpFlowPlacementPaths(destination)
                navManager.extend(destinationPath)
            } else {
                navManager.append(.home)
            }
        }
        .padding()
        .animation(.easeInOut(duration: 0.5), value: errorMessages)
        .background(Color.black.ignoresSafeArea())
        .navigationBarBackButtonHidden(true)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button(action: {
                    sessionManager.accessToken = nil
                    sessionManager.refreshToken = nil
                    navManager.path.removeLast()
                }) {
                    Image(systemName: "chevron.left")
                        .foregroundColor(.white)
                        .font(.system(size: 20, weight: .medium))
                        .frame(maxHeight: 30)
                }
            }
        }
    }
    
    private func login() {
        ServerCommunicator().callMyServer(
            path: "api/token/",
            httpMethod: .post,
            params: [
                "email" : email as Any,
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
                switch networkError {
                case .statusCodeError(let status):
                    if status == 401 {
                        errorMessages = SignUpFieldsUtils.parseErrorMessages(
                            signUpFields,
                            [.password : "We could not find an account with these credentials."]
                        )
                        self.buttonDisabled = false
                        return
                    }
                default: break
                }
//                if !sessionManager.refreshFailed {
                    self.alertMessage = networkError.errorMessage
                    self.showAlert = true
//                }
                self.buttonDisabled = false
                return
            }
            
            // process response
            if let accessToken = accessToken, let refreshToken = refreshToken {
                self.errorMessages = nil
                self.refreshToken = refreshToken
                self.accessToken = accessToken
                self.sessionManager.refreshToken = refreshToken
                self.sessionManager.accessToken = accessToken
                self.tokensRecieved = true
            } else {
                self.errorMessages = nil
//                if !sessionManager.refreshFailed {
                    self.alertMessage = ServerCommunicator.NetworkError.nilData.errorMessage
                    self.showAlert = true
//                }
                self.buttonDisabled = false
            }
        }
    }
    
    private func getUserInfo() {
        ServerCommunicator().callMyServer(
            path: "api/user/getuserinfo/",
            httpMethod: .get,
            sessionManager: sessionManager,
            responseType: GetUserInfoResponse.self
        ) { response in
            // extract errorMessages and network error from the Result<T, NetworkError> object
            switch response {
            case .success(let responseData):
                self.sessionManager.phoneNumber = responseData.phoneNumber
                self.sessionManager.email = responseData.email
                self.sessionManager.fullName = responseData.fullName
                self.sessionManager.etfSymbol = responseData.etf
                if let brokerage = responseData.brokerage {
                    self.sessionManager.brokerageName = Utils.snakeCaseToCamelCase(brokerage)
                } else {
                    self.sessionManager.brokerageName = nil
                }
                self.sessionManager.brokerageCompleted = responseData.brokerageCompleted
                self.sessionManager.linkCompleted = responseData.linkCompleted
                self.sessionManager.isLoggedIn = true
                self.submitted = true
            case .failure(let networkError):
//                if !sessionManager.refreshFailed {
                    self.alertMessage = networkError.errorMessage
                    self.showAlert = true
//                }
                switch networkError {
                case .statusCodeError(let status):
                    if status == 401 {
                        self.alertMessage = "We were unable to log you into your account. Please try again or contact Buul."
                    }
                    print("status code", status)
                default:
                    break
                }
                print("re-initializing")
                self.accessToken = nil
                self.refreshToken = nil
                self.sessionManager.accessToken = nil
                self.sessionManager.refreshToken = nil
                self.tokensRecieved = false
                self.tokensSaved = false
                
                self.buttonDisabled = false
            }
        }
    }
}


struct LoginResponse: Codable {
    let access: String
    let refresh: String
}

struct GetUserInfoResponse: Codable {
    let fullName: String?
    let email: String?
    let phoneNumber: String?
    let brokerage: String?
    let brokerageCompleted: Bool
    let etf: String?
    let linkCompleted: Bool
}

#Preview {
    LoginView(signUpFields: [.email, .password])
        .environmentObject(NavigationPathManager())
        .environmentObject(UserSessionManager())
}
