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
    
    @FocusState private var focusedField: Int?
    @State private var errorMessages: [String?]? = nil
    @State private var submitted: Bool = false
    @State private var showAlert: Bool = false
    @State private var alertMessage: String = ""
    @State private var buttonDisabled: Bool = false
    @State private var tokensRecieved: Bool = false
    @State private var tokensSaved: Bool = false
    @State private var userInfoNotRecieved: Bool = false
    
    var signUpFields: [SignUpFields] = [.password, .email]
    
    
    private var fieldBindings: [SignUpFields: Binding<String>] {
        [
            .password: $password,
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
                    navManager.append(NavigationPathViews.emailRecover)
                } label: {
                    Text("email")
                        .foregroundColor(.blue)
                        .font(.system(size: 15))
                }
                Text("or")
                    .foregroundColor(.white.opacity(0.9))
                    .font(.system(size: 15))
                Button {
                    navManager.append(NavigationPathViews.passwordRecoverInitiate)
                } label: {
                    Text("password?")
                        .foregroundColor(.blue)
                        .font(.system(size: 15))
                }
            }
            .padding()
            
            Spacer()
            
            Button {
                buttonDisabled = true
                submitted = false
            } label: {
                Text("Continue")
                    .font(.headline)
                    .foregroundColor(.black)
                    .frame(maxWidth: .infinity, minHeight: 50)
                    .background(.white)
                    .cornerRadius(10)
            }
            .disabled(buttonDisabled)
        }
        .padding()
        .alert(alertMessage, isPresented: $showAlert) {
            if showAlert {
                Button("OK", role: .cancel) { showAlert = false }
            }
        }
        .onChange(of: buttonDisabled) {
            if !buttonDisabled { return }
            
            let errorMessagesDictLocal = SignUpFieldsUtils.validateInputs(
                password: password,
                email: email
            )
            if let errorMessagesList = SignUpFieldsUtils.parseErrorMessages(errorMessagesDictLocal) {
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
                if let refreshToken = sessionManager.refreshToken, let accessToken = sessionManager.accessToken {
                    let refreshTokenSaved: Bool = await sessionManager.refreshTokenSet(refreshToken)
                    let accessTokenSaved: Bool = await sessionManager.accessTokenSet(accessToken)
                    if refreshTokenSaved && accessTokenSaved {
                        print("saved")
                        print(refreshToken, accessToken)
                        self.tokensSaved = true
                        return
                    }
                }
                // tokens failed to save
                self.tokensRecieved = false
                self.buttonDisabled = false
                _ = await sessionManager.reset()
                self.alertMessage = ServerCommunicator.NetworkError.decodingError.errorMessage
                self.showAlert = true
            }
        }
        .onChange(of: tokensSaved) {
            getUserInfo()
        }
        .onChange(of: submitted) {
            if !submitted { return }
            if let destination: NavigationPathViews = sessionManager.signUpFlowPlacement() {
                let destinationPath: [NavigationPathViews] = sessionManager.signUpFlowPlacementPaths(destination)
                navManager.extend(destinationPath)
            } else {
                navManager.append(.home)
            }
        }
        .onChange(of: userInfoNotRecieved) {
            Task {
                if !userInfoNotRecieved { return }
                _ = await sessionManager.reset()
            }
        }
        .animation(.easeInOut(duration: 0.5), value: errorMessages)
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
                    Utils.dismissKeyboard()
                }
                .foregroundColor(.blue) // Customize the button appearance
            }
        }
    }
    
    private func login() {
        ServerCommunicator().callMyServer(
            path: "api/token/",
            httpMethod: .post,
            params: [
                "username" : email as Any,
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
                            [.password : "We could not find an account with these credentials."]
                        )
                        self.buttonDisabled = false
                        return
                    }
                default:
                    self.alertMessage = networkError.errorMessage
                    self.showAlert = true
                    self.buttonDisabled = false
                    return
                }
                self.alertMessage = networkError.errorMessage
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
                self.alertMessage = ServerCommunicator.NetworkError.nilData.errorMessage
                self.showAlert = true
                self.buttonDisabled = false
            }
        }
    }
    
    private func getUserInfo() {
        ServerCommunicator().callMyServer(
            path: "api/user/userinfo/",
            httpMethod: .get,
            accessToken: sessionManager.accessToken,
            responseType: GetUserInfoResponse.self
        ) { response in
            // extract errorMessages and network error from the Result<T, NetworkError> object
            switch response {
            case .success(let responseData):
                sessionManager.phoneNumber = responseData.phoneNumber
                sessionManager.email = responseData.email
                sessionManager.fullName = responseData.fullName
                sessionManager.etfSymbol = responseData.etf
                sessionManager.brokerageName = responseData.brokerage?.capitalized
                sessionManager.isLoggedIn = true
                buttonDisabled = false
                self.submitted = true
            case .failure(let error):
                print("user ingo failuree")
                self.alertMessage = error.errorMessage
                self.showAlert = true
                self.buttonDisabled = false
                self.userInfoNotRecieved = true
            }
        }
    }
}


struct LoginResponse: Codable {
    let access: String?
    let refresh: String?
}

struct GetUserInfoResponse: Codable {
    let fullName: String?
    let email: String?
    let phoneNumber: String?
    let brokerage: String?
    let etf: String?
}

#Preview {
    LoginView(signUpFields: [.email, .password])
        .environmentObject(NavigationPathManager())
        .environmentObject(UserSessionManager())
}
