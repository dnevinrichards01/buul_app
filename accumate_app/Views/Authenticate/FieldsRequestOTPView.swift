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
    var OTPField: OTPFields
    var authenticate: Bool
    
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
        VStack {
            VStack (alignment: .center) {
                if let title = title {
                    Text(title)
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundStyle(.white)
                        .multilineTextAlignment(.center)
                        .fixedSize(horizontal: false, vertical: true)
                        .padding(.bottom, 20)
                }
                if let subtitle = subtitle {
                    Text(subtitle)
                        .font(.headline)
                        .foregroundStyle(.white.opacity(0.8))
                        .multilineTextAlignment(.leading)
                        .fixedSize(horizontal: false, vertical: true)
                }
            }
            .frame(maxWidth: .infinity)
            .padding()
            
            if OTPField == .phoneNumber && !authenticate {
                HStack {
                    Spacer()
                    Text("Already a member?")
                        .foregroundColor(.white.opacity(0.9))
                        .font(.system(size: 12))
                        .background(.black)
                        .cornerRadius(10)
                    Button {
                        navManager.append(.login)
                    } label: {
                        Text("Log In")
                            .foregroundColor(.blue)
                            .font(.system(size: 12))
                            .background(.black)
                            .cornerRadius(10)
                    }
                }
                .padding()
            }
            
            ForEach(0..<signUpFields.count, id: \.self) { index in
                let signUpField = signUpFields[index]
                if let binding = fieldBindings[signUpField], signUpFields.contains(signUpField) {
                    SignUpFieldView(
                        instruction: signUpField.resetInstruction,
                        placeholder: signUpField.placeholder,
                        inputValue: binding,
                        keyboard: signUpField.keyboardType,
                        errorMessage: errorMessages?[index],
                        signUpField: signUpField
                    )
                    .focused($focusedField, equals: index)
                }
            }
            
            Spacer()
            
            Button {
                buttonDisabled = true
            } label: {
                Text("Send")
                    .font(.headline)
                    .foregroundColor(.black)
                    .frame(maxWidth: .infinity, minHeight: 50)
                    .background(.white)
                    .cornerRadius(10)
            }
            .disabled(buttonDisabled)
            .padding(20)
            
        }
        .padding()
        .alert(alertMessage, isPresented: $showAlert) {
            if showAlert {
                Button("OK", role: .cancel) {
                    showAlert = false
                }
            }
        }
        .onChange(of: buttonDisabled) {
            if !buttonDisabled { return }
            let errorMessagesDictLocal = SignUpFieldsUtils.validateInputs(
                signUpFields: signUpFields,
                password: password,
                password2: password2,
                verificationEmail: verificationEmail
            )
            if let errorMessagesList = SignUpFieldsUtils.parseErrorMessages(signUpFields, errorMessagesDictLocal) {
                errorMessages = errorMessagesList
                buttonDisabled = false
            } else {
                sendEmailOTP()
            }
        }
        .onChange(of: submitted) {
            if !submitted { return }
            submitted = false
            navManager.append(nextPage)
        }
        .animation(.easeInOut(duration: 0.5), value: errorMessages)
        .background(.black)
        .navigationBarBackButtonHidden(true)
        .navigationBarTitleDisplayMode(.inline)
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
    
    private func generateOTPParams() -> [String : Any] {
        let fieldString = Utils.camelCaseToSnakeCase(OTPField.rawValue)
        
        var verificationEmail = verificationEmail
        var verificationPhoneNumber = verificationPhoneNumber
        
        var fieldValue: Any
        switch OTPField {
        case .email:
            verificationEmail = email
            fieldValue = email
        case .phoneNumber:
            verificationPhoneNumber = phoneNumber
            fieldValue = phoneNumber
        case .fullName:
            fieldValue = fullName
        case .password:
            fieldValue = password
        default:
            fieldValue = -1
        }
        
        var params = [
            "field": fieldString as Any,
            fieldString: fieldValue as Any
        ]
        
        if OTPField == .password {
            params["password2"] = password2 as Any
        }
        
        if OTPField == .phoneNumber && !authenticate {
            params["verification_phone_number"] = verificationPhoneNumber as Any
        } else {
            params["verification_email"] = verificationEmail as Any
        }
        
        return params
    }
    
    private func getStateFromOTPField() -> String? {
        switch OTPField {
        case .email:
            return email
        case .phoneNumber:
            return phoneNumber
        case .fullName:
            return fullName
        case .password:
            return password
        default:
            return nil
        }
    }
    
    private func sendEmailOTP() {
        ServerCommunicator().callMyServer(
            path: Utils.getOTPEndpoint(OTPField, authenticate),
            httpMethod: .put,
            params: generateOTPParams(),
            responseType: OTPRequest.self
        ) { response in
            switch response {
            case .success(let responseData):
                if let errors = responseData.error, responseData.success == nil {
                    do {
                        // process errors into a list
                        let errorMessagesDictBackend = try SignUpFieldsUtils.keysStringToSignUpFields(errors)
                        if let errorMessagesList = SignUpFieldsUtils.parseErrorMessages(signUpFields, errorMessagesDictBackend) {
                            // apply the error messages
                            self.errorMessages = errorMessagesList
                            self.buttonDisabled = false
                            return
                        } // if code ends up here it indicates error with username field
                    } catch {
                        // error (Decoding error) if difficulty parsing the response
                        self.alertMessage = ServerCommunicator.NetworkError.decodingError.errorMessage
                        self.showAlert = true
                        self.buttonDisabled = false
                        return
                    }
                } else if let _ = responseData.success, responseData.error == nil {
                    self.errorMessages = nil
                    
                    if OTPField == .email {
                        if !authenticate {
                            self.sessionManager.verificationEmail = self.email
                        } else {
                            self.sessionManager.verificationEmail = self.verificationEmail
                        }
                    } else if OTPField == .phoneNumber {
                        if !authenticate {
                            self.sessionManager.verificationPhoneNumber = self.phoneNumber
                            self.sessionManager.phoneNumber = self.phoneNumber // temp, bc can't yet do sms verification
                        } else {
                            self.sessionManager.verificationPhoneNumber = self.verificationPhoneNumber
                        }
                    } else {
                        self.sessionManager.verificationEmail = self.verificationEmail
                    }
                    
                    if OTPField == .deleteAccount {
                        self.sessionManager.boolToVerify = true
                    } else {
                        self.sessionManager.stringToVerify = getStateFromOTPField()
                    }
                    
                    self.buttonDisabled = false
                    self.submitted = true
                } else if let _ = responseData.error, let _ = responseData.success {
                    self.alertMessage = ServerCommunicator.NetworkError.decodingError.errorMessage
                    self.showAlert = true
                    self.buttonDisabled = false
                } else {
                    self.alertMessage = ServerCommunicator.NetworkError.decodingError.errorMessage
                    self.showAlert = true
                    self.buttonDisabled = false
                }
            case .failure(let networkError):
                self.alertMessage = networkError.errorMessage
                self.showAlert = true
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
        OTPField: .password,
        authenticate: false
    )
        .environmentObject(NavigationPathManager())
        .environmentObject(UserSessionManager())
}
