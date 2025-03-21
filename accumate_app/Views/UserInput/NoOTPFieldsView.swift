//
//  PasswordRecoverInitiateView.swift
//  accumate_app
//
//  Created by Nevin Richards on 2/2/25.
//

import SwiftUI

struct NoOTPFieldsView: View {
    
    @EnvironmentObject var navManager: NavigationPathManager
    @EnvironmentObject var sessionManager: UserSessionManager
    
    @FocusState private var focusedField: Int?
    @State private var fullName: String = ""
    @State private var brokerage: String = ""
    @State private var symbol: String = ""
    
    @State private var showAlert: Bool = false
    @State private var alertMessage: String = ""
    @State private var buttonDisabled: Bool = false
    @State private var errorMessages: [String?]? = nil
    @State private var submitted: Bool = false
    
    var signUpFields: [SignUpFields]
    var signUpField: SignUpFields
    var title: String?
    var subtitle: String?
    var nextPage: NavigationPathViews
    var authenticate: Bool
    
    
    private var fieldBindings: [SignUpFields: Binding<String>] {
        [
            .fullName: $fullName,
            .brokerage: $brokerage,
            .symbol: $symbol
        ]
    }
    
    var body: some View {
        ZStack {
            if signUpField == .brokerage {
                SelectOptionView(
                    title: title,
                    subtitle: subtitle,
                    signUpField: signUpField,
                    alertMessage: $alertMessage,
                    showAlert: $showAlert,
                    buttonDisabled: $buttonDisabled,
                    selectedBrokerage: $brokerage,
                    selectedETF: $symbol
                )
            }
            else if signUpField == .symbol {
                SelectOptionView(
                    title: title,
                    subtitle: subtitle,
                    signUpField: signUpField,
                    alertMessage: $alertMessage,
                    showAlert: $showAlert,
                    buttonDisabled: $buttonDisabled,
                    selectedBrokerage: $brokerage,
                    selectedETF: $symbol
                )
            } else  {
                FieldsEntryView(
                    title: title,
                    subtitle: subtitle,
                    signUpFields: signUpFields,
                    fieldBindings: fieldBindings,
                    isSignUp: true,
                    buttonText: "Next",
                    alertMessage: $alertMessage,
                    showAlert: $showAlert,
                    errorMessages: $errorMessages,
                    buttonDisabled: $buttonDisabled,
                    focusedField: $focusedField
                )
            }
        }
        .padding()
        .background(Color.black.ignoresSafeArea())
        .onAppear() {
            fullName = sessionManager.fullName ?? ""
        }
        .onChange(of: buttonDisabled) {
            if !buttonDisabled { return }
            if signUpFields == [.fullName] && signUpField == .fullName {
                let errorMessagesDictLocal = SignUpFieldsUtils.validateInputs(
                    signUpFields: signUpFields,
                    fullName: fullName
                )
                if let errorMessagesList = SignUpFieldsUtils.parseErrorMessages(signUpFields, errorMessagesDictLocal) {
                    errorMessages = errorMessagesList
                    buttonDisabled = false
                } else {
                    validateField()
                }
            } else {
                validateField()
            }
        }
        .onChange(of: submitted) {
            if !submitted { return }
            submitted = false
            
            switch self.signUpField {
            case .fullName: sessionManager.fullName = fullName
            case .brokerage: sessionManager.brokerageName = brokerage
            case .symbol: sessionManager.etfSymbol = symbol
            default: break
            }
            
            buttonDisabled = false
            if signUpField == .brokerage {
                for brokerage in Brokerages.allCases {
                    if self.brokerage == brokerage.rawValue {
                        navManager.append(brokerage.signUpSecurityInfo)
                    }
                }
            } else {
                navManager.append(nextPage)
            }
        }
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
        }
    }
    
    private func generateParams() -> [String : Any] {
        let fieldString = Utils.camelCaseToSnakeCase(signUpField.rawValue)
        var fieldValue: Any
        switch signUpField {
        case .fullName:
            fieldValue = fullName as Any
        case .brokerage:
            fieldValue = Utils.camelCaseToSnakeCase(brokerage) as Any
        case .symbol:
            fieldValue = symbol as Any
        default:
            fieldValue = -1 as Any
        }
        return [fieldString : fieldValue]
    }
    
    // make sure to set up double authentication for changing email or phone (verification code to both)
    private func validateField() {
        ServerCommunicator().callMyServer(
            path: Utils.getSignUpFieldsValidateEndpoint(signUpField),
            httpMethod: .post,
            params: generateParams(),
            sessionManager: authenticate ? sessionManager : nil,
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
                            if signUpField == .fullName {
                                self.errorMessages = errorMessagesList
                                self.buttonDisabled = false
                                return
                            } else {
//                                if !sessionManager.refreshFailed {
                                    self.alertMessage = ServerCommunicator.NetworkError.decodingError.errorMessage
                                    self.showAlert = true
//                                }
                                self.buttonDisabled = false
                                return
                            }
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
                    self.submitted = true
                // alert because unexpected response
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
//                }
                
                self.buttonDisabled = false
            }
        }
    }
}

#Preview {
    NoOTPFieldsView(
        signUpFields: [.fullName],
        signUpField: .fullName,
        title: nil,
        subtitle: nil,
        nextPage: .signUpPassword,
        authenticate: false
    )
    .environmentObject(NavigationPathManager())
    .environmentObject(UserSessionManager())
}
