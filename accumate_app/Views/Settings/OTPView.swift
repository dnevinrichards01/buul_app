//
//  ChangeEmailOTPView.swift
//  accumate_app
//
//  Created by Nevin Richards on 2/1/25.
//

import SwiftUI

import SwiftUI
import Combine
import Foundation

struct OTPView: View {
    @State private var otp: String = ""
    @State private var errorMessage: String?
    @State private var showAlert: Bool = false
    @State private var alertMessage: String = ""
    @State private var buttonDisabled: Bool = false
    @State private var resendCodeDisabled: Bool = false
    @State private var submitted: Bool = false
    @State private var reEnterInfo: Bool = false
    
    var title: String
    var subtitle: String
    var goBackNPagesToRedoEntries: Int
    var goBackNPagesIfCompleted: Int
    var nextPage: NavigationPathViews?
    var OTPField: OTPFields
    var authenticate: Bool
    
    @EnvironmentObject var navManager: NavigationPathManager
    @EnvironmentObject var sessionManager: UserSessionManager
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            VStack (alignment: .center) {
                Text(title)
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundStyle(.white)
                    .multilineTextAlignment(.center)
                    .padding(.bottom, 20)
                Text(subtitle)
                    .font(.headline)
                    .foregroundStyle(.white.opacity(0.8))
                    .multilineTextAlignment(.leading)
            }
            .frame(maxWidth: .infinity)
            
            Spacer()
            OTPFieldView(otp: $otp)
                .padding(.bottom, 10)
            if let error = errorMessage {
                Text(error)
                    .foregroundColor(.red)
                    .font(.system(size: 18))
                    .background(.black)
                    .cornerRadius(10)
                    .padding(.bottom, 10)
            } else {
                Spacer()
                    .frame(height: 20)
            }
            Spacer()
            
            VStack() {
                Button {
                    buttonDisabled = true
                } label: {
                    Text("Continue")
                        .font(.headline)
                        .foregroundColor(.black)
                        .frame(maxWidth: .infinity, minHeight: 50)
                        .background(.white)
                        .cornerRadius(10)
                }
                .disabled(buttonDisabled)
                .padding([.top, .bottom], 20)
                
                Button {
                    resendCodeDisabled = true
                } label: {
                    Text("Click here to resend code")
                        .foregroundColor(.white)
                        .font(.system(size: 14))
                        .multilineTextAlignment(.center)
                        .frame(maxWidth: .infinity)
                        .bold()
                }
                .disabled(resendCodeDisabled)
            }
        }
        .alert(alertMessage, isPresented: $showAlert) {
            if showAlert {
                Button("OK", role: .cancel) { showAlert = false }
            }
        }
        .onChange(of: showAlert) { oldValue, newValue in
            if oldValue && !newValue {
                if reEnterInfo == submitted { return }
                
                sessionManager.verificationEmail = nil
                sessionManager.verificationPhoneNumber = nil
                sessionManager.stringToVerify = nil
                sessionManager.boolToVerify = nil
                
                if reEnterInfo {
                    reEnterInfo = false
                    navManager.removeLast(goBackNPagesToRedoEntries)
                } else if submitted {
                    submitted = false
                    if let nextPage = nextPage {
                        navManager.append(nextPage)
                    } else {
                        navManager.removeLast(goBackNPagesIfCompleted)
                    }
                }
            }
        }
        .onChange(of: buttonDisabled) {
            if !buttonDisabled || resendCodeDisabled { return }
            if otp == Utils.truncateTo6Digits(text: otp) && otp.count == 6 {
                submitOTP()
            } else {
                errorMessage = "The code must be exactly 6 digits."
                buttonDisabled = false
            }
            
        }
        .onChange(of: resendCodeDisabled) {
            if !resendCodeDisabled || buttonDisabled { return }
            resendOTP()
        }
        .onChange(of: submitted) {
            guard submitted && isSignUpFlowEmailPhoneVerification() else { return }
            if let nextPage = nextPage {
                navManager.append(nextPage)
            } else {
                navManager.removeLast(goBackNPagesIfCompleted)
            }
        }
        .animation(.easeInOut(duration: 0.5), value: errorMessage)
        .padding(30)
        .background(Color.black.ignoresSafeArea())
        .navigationBarBackButtonHidden(true)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                Button(action: {
                    sessionManager.verificationEmail = nil
                    sessionManager.verificationPhoneNumber = nil
                    sessionManager.stringToVerify = nil
                    sessionManager.boolToVerify = nil
                    submitted = false
                    reEnterInfo = false
                    navManager.path.removeLast()
                }) {
                    Image(systemName: "chevron.left")
                        .foregroundColor(.white)
                        .font(.system(size: 20, weight: .medium))
                        .frame(maxHeight: 30)
                }
            }
            ToolbarItemGroup(placement: .keyboard) {
                Spacer()
                Button("Done") {
                    Utils.dismissKeyboard()
                }
                .foregroundColor(.blue)
            }
        }
    }
    
    private func isSignUpFlowEmailPhoneVerification() -> Bool {
        return !authenticate && OTPField == .phoneNumber || OTPField == .email
    }
    
    private func successMessage() -> String {
        let fieldString = Utils.camelCaseToSnakeCase(OTPField.rawValue)
        
        if OTPField == .deleteAccount {
            return "Your account has been deleted."
        } else {
            return "Your \(fieldString) has been updated."
        }
    }
    
    private func generateOTPParams(isRequestOTP: Bool) -> [String : Any] {
        let fieldString = Utils.camelCaseToSnakeCase(OTPField.rawValue)
        
        var fieldValue: Any = sessionManager.stringToVerify as Any
        if OTPField == .deleteAccount {
            fieldValue = sessionManager.boolToVerify as Any
        }
        
        var params = [
            "field": fieldString as Any,
            fieldString: fieldValue
        ]
        
        if isRequestOTP {
            if OTPField == .password {
                params["password2"] = sessionManager.stringToVerify as Any
            }
        } else {
            params["code"] = otp as Any
        }
        
        if OTPField == .phoneNumber && !authenticate {
            params["verification_phone_number"] = sessionManager.verificationPhoneNumber as Any
        } else {
            params["verification_email"] = sessionManager.verificationEmail as Any
        }
        
        return params
    }
    
    private func submitOTP() {
        ServerCommunicator().callMyServer(
            path: Utils.getOTPEndpoint(OTPField, authenticate),
            httpMethod: .post,
            params: generateOTPParams(isRequestOTP: false),
            sessionManager: authenticate ? sessionManager : nil,
            responseType: OTPRequest.self
        ) { response in
            switch response {
            case .success(let responseData):
                if let errors = responseData.error, responseData.success == nil {
                    do {
                        // process errors into a list
                        let errorMessagesDictBackend = try SignUpFieldsUtils.keysStringToSignUpFields(errors)
                        if errorMessagesDictBackend.count > 0 {
                            // if an earlier field is messed up, error and send them back to it
                            if let errorMessage = errorMessagesDictBackend[.code] {
                                self.errorMessage = errorMessage
                                self.buttonDisabled = false
                                return
                            } else {
                                
                                self.alertMessage = "We spotted an error on the previous page. Please fill out the fields again."
                                self.reEnterInfo = true
                                self.showAlert = true
                                self.buttonDisabled = false
                                return
                            }
                        } // if code ends up here it indicates error with username field
                    } catch {
                        // error (Decoding error) if difficulty parsing the response
                        self.alertMessage = ServerCommunicator.NetworkError.decodingError.errorMessage
                        self.showAlert = true
                        self.buttonDisabled = false
                        return
                    }
                } else if let _ = responseData.success, responseData.error == nil {
                    if !isSignUpFlowEmailPhoneVerification() {
                        self.alertMessage = successMessage()
                        self.showAlert = true
                    } else {
                        if self.OTPField == .phoneNumber {
                            self.sessionManager.phoneNumber = self.sessionManager.stringToVerify
                        } else if self.OTPField == .email {
                            self.sessionManager.email = self.sessionManager.stringToVerify
                        }
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
    
    private func resendOTP() {
        ServerCommunicator().callMyServer(
            path: Utils.getOTPEndpoint(OTPField, authenticate),
            httpMethod: .put,
            params: generateOTPParams(isRequestOTP: true),
            sessionManager: authenticate ? sessionManager : nil,
            responseType: OTPRequest.self
        ) { response in
            switch response {
            case .success(let responseData):
                if let _ = responseData.error, responseData.success == nil {
                    self.alertMessage = "We spotted an error on the previous page. Please fill out the fields again."
                    self.reEnterInfo = true
                    self.showAlert = true
                    self.resendCodeDisabled = false
                    return
                } else if let _ = responseData.success, responseData.error == nil {
                    self.resendCodeDisabled = false
                } else if let _ = responseData.error, let _ = responseData.success {
                    self.alertMessage = ServerCommunicator.NetworkError.decodingError.errorMessage
                    self.showAlert = true
                    self.resendCodeDisabled = false
                } else {
                    self.alertMessage = ServerCommunicator.NetworkError.decodingError.errorMessage
                    self.showAlert = true
                    self.resendCodeDisabled = false
                }
            case .failure(let networkError):
                self.alertMessage = networkError.errorMessage
                self.showAlert = true
                self.resendCodeDisabled = false
            }
        }
    }
}

struct OTPRequest: Codable {
    let success: String?
    let error: OTPRequestErrors?
}
struct OTPRequestErrors: Codable {
    let email: String?
    let password: String?
    let password2: String?
    let fullName: String?
    let phoneNumber: String?
    let verificationEmail: String?
    let verificationPhoneNumber: String?
    let symbol: String?
    let brokerage: String?
    let deleteAccount: String?
    let field: String?
    let code: String?
}

enum OTPFields: String, CaseIterable {
    case email
    case phoneNumber
    case fullName
    case brokerage
    case etf
    case password
    case deleteAccount
}

#Preview {
    OTPView(
        title: "Change Email",
        subtitle: "Enter the code sent to your email",
        goBackNPagesToRedoEntries: 1,
        goBackNPagesIfCompleted: 0,
        nextPage: .changeEmail,
        OTPField: .email,
        authenticate: false
    )
    .environmentObject(NavigationPathManager())
    .environmentObject(UserSessionManager())
}
