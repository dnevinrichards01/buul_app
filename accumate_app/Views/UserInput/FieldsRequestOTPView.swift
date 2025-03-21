//
//  PasswordRecoverInitiateView.swift
//  accumate_app
//
//  Created by Nevin Richards on 2/2/25.
//

import SwiftUI

struct FieldsRequestOTPView: View {
    
    @EnvironmentObject var navManager: NavigationPathManager
    @EnvironmentObject var sessionManager: UserSessionManager
    
    @FocusState private var focusedField: Int?
    @State private var verificationEmail: String = ""
    @State private var verificationPhoneNumber: String = ""
    @State private var password: String = ""
    @State private var password2: String = ""
    @State private var phoneNumber: String = ""
    @State private var brokerage: String = ""
    @State private var symbol: String = ""
    @State private var email: String = ""
    @State private var fullName: String = ""
    
    @State private var showAlert: Bool = false
    @State private var alertMessage: String = ""
    @State private var buttonDisabled: Bool = false
    @State private var errorMessages: [String?]? = nil
    @State private var submitted: Bool = false
    
    var signUpFields: [SignUpFields]
    var title: String?
    var subtitle: String?
    var nextPage: NavigationPathViews
    var signUpField: SignUpFields
    var authenticate: Bool
    var isSignUp: Bool
    
    
    private var fieldBindings: [SignUpFields: Binding<String>] {
        [
            .verificationEmail: $verificationEmail,
            .verificationPhoneNumber: $verificationPhoneNumber,
            .password: $password,
            .password2: $password2,
            .phoneNumber: $phoneNumber,
            .email: $email,
            .fullName: $fullName
        ]
    }
    
    
    var body: some View {
        ZStack {
            if signUpField == .brokerage {
                SelectOptionView(
                    title: title,
                    subtitle: subtitle,
                    signUpField: signUpFields[0],
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
                    signUpField: signUpFields[0],
                    alertMessage: $alertMessage,
                    showAlert: $showAlert,
                    buttonDisabled: $buttonDisabled,
                    selectedBrokerage: $brokerage,
                    selectedETF: $symbol
                )
            } else if signUpField == .deleteAccount {
                FieldsEntryView(
                    title: title,
                    subtitle: subtitle,
                    signUpFields: signUpFields,
                    fieldBindings: fieldBindings,
                    suggestLogIn: false,
                    isSignUp: false,
                    buttonText: "Next",
                    alertMessage: $alertMessage,
                    showAlert: $showAlert,
                    errorMessages: $errorMessages,
                    buttonDisabled: $buttonDisabled,
                    focusedField: $focusedField
                )
            } else  {
                FieldsEntryView(
                    title: title,
                    subtitle: subtitle,
                    signUpFields: signUpFields,
                    fieldBindings: fieldBindings,
                    suggestLogIn: signUpField == .phoneNumber && !authenticate,
                    isSignUp: [.email, .phoneNumber].contains(signUpField) && !authenticate,
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
        .onAppear {
            if let fieldValue = sessionManager.stringToVerify {
                phoneNumber = fieldValue
                email = fieldValue
                fullName = fieldValue
            } else if isSignUp {
                phoneNumber = sessionManager.phoneNumber ?? ""
                email = sessionManager.email ?? ""
                fullName = sessionManager.fullName ?? ""
            }
        }
        .onChange(of: buttonDisabled) {
            if !buttonDisabled { return }
            let errorMessagesDictLocal = SignUpFieldsUtils.validateInputs(
                signUpFields: signUpFields,
                password: password,
                password2: password2,
                fullName: fullName,
                phoneNumber: phoneNumber,
                email: email,
                verificationPhoneNumber: verificationPhoneNumber,
                verificationEmail: verificationEmail
            )
            if let errorMessagesList = SignUpFieldsUtils.parseErrorMessages(signUpFields, errorMessagesDictLocal) {
                errorMessages = errorMessagesList
                buttonDisabled = false
            } else {
                validateField()
            }
        }
        .onChange(of: submitted) {
            if !submitted { return }
            submitted = false
            
            if signUpField == .brokerage && isSignUp {
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
                    self.sessionManager.verificationEmail = nil
                    self.sessionManager.verificationPhoneNumber = nil
                    self.sessionManager.stringToVerify = nil
                    self.sessionManager.boolToVerify = nil
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
    
    private func generateOTPParams() -> [String : Any] {
        let fieldString = Utils.camelCaseToSnakeCase(signUpField.rawValue)
        
        var verificationEmail = isSignUp ? email : sessionManager.email
        if !isSignUp && !authenticate {
            verificationEmail = self.verificationEmail
        }
        let verificationPhoneNumber = isSignUp ? phoneNumber : sessionManager.phoneNumber
        
        var fieldValue: Any
        switch signUpField {
        case .email:
            fieldValue = email
        case .phoneNumber:
            fieldValue = phoneNumber
        case .fullName:
            fieldValue = fullName
        case .password:
            fieldValue = password
        case .brokerage:
            fieldValue = Utils.camelCaseToSnakeCase(brokerage)
        case .symbol:
            fieldValue = symbol
        case .deleteAccount:
            fieldValue = true
        default:
            fieldValue = -1
        }
        
        var params = [
            "field": fieldString as Any,
            fieldString: fieldValue as Any
        ]
        
        if signUpField == .password {
            params["password2"] = password2 as Any
        }
        
        if signUpField == .phoneNumber && !authenticate {
            params["verification_phone_number"] = verificationPhoneNumber as Any
        } else {
            params["verification_email"] = verificationEmail as Any
        }
        
        return params
    }
    
    private func getStateFromOTPField() -> String? {
        switch signUpField {
        case .email:
            return email
        case .phoneNumber:
            return phoneNumber
        case .fullName:
            return fullName
        case .password:
            return password
        case .brokerage:
            return brokerage
        case .symbol:
            return symbol
        default:
            return nil
        }
    }
    
    // make sure to set up double authentication for changing email or phone (verification code to both)
    private func validateField() {
        ServerCommunicator().callMyServer(
            path: Utils.getOTPEndpoint(signUpField, authenticate),
            httpMethod: .put,
            params: generateOTPParams(),
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
                    
                    // set verification method
                    if !authenticate && signUpField == .email {
                        self.sessionManager.email = self.email
                        self.sessionManager.verificationEmail = self.email
                    } else if !authenticate && signUpField == .phoneNumber {
                        // save number now instead of upon OTP entry, and don't set verificationPhoneNumber bc can't yet do sms verification
                        //                            self.sessionManager.verificationPhoneNumber = self.phoneNumber
                        self.sessionManager.phoneNumber = self.phoneNumber
                    } else if !authenticate && signUpField == .password {
                        self.sessionManager.verificationEmail = self.verificationEmail
                    } else {
                        self.sessionManager.verificationEmail = self.sessionManager.email //self.verificationEmail
                    }
                    
                    // set the value to verify
                    if signUpField == .deleteAccount {
                        self.sessionManager.boolToVerify = true
                    } else {
                        self.sessionManager.stringToVerify = getStateFromOTPField()
                        // don't save phoneNumber to stringToVerify because we currently aren't verifying it
                        if signUpField == .phoneNumber && isSignUp {
                            sessionManager.stringToVerify = nil
                        }
                    }
                    
                    self.buttonDisabled = false
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
                self.buttonDisabled = false
            }
        }
    }
}

#Preview {
    FieldsRequestOTPView(
        signUpFields: [.verificationEmail, .password, .password2],
        title: "Forgot your password?",
        subtitle: "We will send you a code if we have an account associated with this email.",
        nextPage: .passwordRecoveryOTP,
        signUpField: .password,
        authenticate: false,
        isSignUp: true
    )
        .environmentObject(NavigationPathManager())
        .environmentObject(UserSessionManager())
}
