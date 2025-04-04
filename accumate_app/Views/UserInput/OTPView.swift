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
    @State private var deleteSessionData: Bool = false
    
    var title: String?
    var subtitle: String?
    var goBackNPagesToRedoEntries: Int
    var goBackNPagesIfCompleted: Int
    @State var nextPage: NavigationPathViews?
    var signUpField: SignUpFields
    var authenticate: Bool
    
    @EnvironmentObject var navManager: NavigationPathManager
    @EnvironmentObject var sessionManager: UserSessionManager
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            VStack (alignment: .center) {
                if let title = title {
                    Text(title)
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundStyle(.white)
                        .multilineTextAlignment(.center)
                        .padding(.bottom, 20)
                }
                if let subtitle = subtitle {
                    Text(subtitle)
                        .font(.headline)
                        .foregroundStyle(.white.opacity(0.8))
                        .multilineTextAlignment(.leading)
                }
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
                Button("OK", role: .cancel) {
                    showAlert = false
                }
            }
            if sessionManager.refreshFailed {
                Button("Log Out", role: .destructive) {
                    Task {
                        showAlert = false
                        
                        sessionManager.refreshFailed = false
                        _ = await sessionManager.resetComplete()
                        navManager.reset(views: [.landing])
                    }
                }
            }
        }
        .onChange(of: showAlert) { oldValue, newValue in
            if oldValue && !newValue {
                let brokerage: Brokerages? = Utils.getBrokerage(sessionManager: sessionManager, brokerageString: sessionManager.stringToVerify)
                nextPage = brokerage?.changeSecurityInfo
                
                
                guard reEnterInfo || submitted else { return }
                if reEnterInfo {
                    reEnterInfo = false
                    print("redo?")
                    navManager.removeLast(goBackNPagesToRedoEntries)
                } else if submitted {
                    submitted = false
                    if let nextPage = nextPage {
                        print("append")
                        navManager.append(nextPage)
                    } else {
                        print("correct path")
                        navManager.removeLast(goBackNPagesIfCompleted)
                    }
                }
                sessionManager.verificationEmail = nil
                sessionManager.verificationPhoneNumber = nil
                sessionManager.stringToVerify = nil
                sessionManager.boolToVerify = nil
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
            if !submitted { return }
            
            if signUpField == .deleteAccount {
                Task {
                    let logoutSuccess: Bool = await sessionManager.resetComplete() //await
                    
                    if !logoutSuccess {
                        alertMessage = successMessage() + " But session data on this device could not be removed. Please try again or contact Accumate"
                    } else {
                        alertMessage = successMessage()
                    }
                    buttonDisabled = false
                    showAlert = true
                }
            } else if isSignUpFlowEmailPhoneVerification() {
                // save updated information
                if signUpField == .phoneNumber {
                    sessionManager.phoneNumber = sessionManager.stringToVerify
                } else if signUpField == .email {
                    sessionManager.email = sessionManager.stringToVerify
                } else {
                    alertMessage = successMessage() + " But an error prevented us from saving this change to your device. Please log out and log back in to get updated account information."
                    showAlert = true
                    buttonDisabled = false
                    return
                }
                // change pages upon completion
                buttonDisabled = false
                sessionManager.verificationEmail = nil
                sessionManager.verificationPhoneNumber = nil
                sessionManager.stringToVerify = nil
                sessionManager.boolToVerify = nil
                if let nextPage = nextPage {
                    print("append signup")
                    navManager.append(nextPage)
                } else {
                    print("incorrect path")
                    navManager.removeLast(goBackNPagesIfCompleted)
                }
            } else {
                alertMessage = successMessage()
                switch signUpField {
                case .email:
                    sessionManager.email = sessionManager.stringToVerify
                    showAlert = true
                case .password:
                    showAlert = true
                case .fullName:
                    sessionManager.fullName = sessionManager.stringToVerify
                    showAlert = true
                case .phoneNumber:
                    sessionManager.phoneNumber = sessionManager.stringToVerify
                    showAlert = true
                case .symbol:
                    sessionManager.etfSymbol = sessionManager.stringToVerify
                    showAlert = true
                case .brokerage:
                    sessionManager.brokerageName = sessionManager.stringToVerify
                    let brokerage: Brokerages? = Utils.getBrokerage(sessionManager: sessionManager, brokerageString: sessionManager.stringToVerify)
                    nextPage = brokerage?.changeSecurityInfo
                    navManager.append(nextPage ?? .robinhoodSecurityInfo)
                default:
                    alertMessage = successMessage() + " But an error prevented us from saving this change to your device. Please log out and log back in to get updated account information."
                    showAlert = true
                }
                
                buttonDisabled = false
            }
            
            // if not sign up process email / phone verification, delay action till user responds to alert
            
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
                    print("toolbar")
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
        return !authenticate && (signUpField == .phoneNumber || signUpField == .email)
    }
    
    private func successMessage() -> String {
        let fieldString = Utils.camelCaseToSnakeCase(signUpField.rawValue)
        
        if signUpField == .deleteAccount {
            return "Your account has been deleted."
        } else if signUpField == .brokerage {
            return "Your \(fieldString) choice been updated."
        } else {
            return "Your \(fieldString) has been updated."
        }
    }
    
    private func generateOTPParams(isRequestOTP: Bool) -> [String : Any] {
        let fieldString = Utils.camelCaseToSnakeCase(signUpField.rawValue)
        
        var fieldValue: Any = sessionManager.stringToVerify as Any
        if signUpField == .deleteAccount {
            fieldValue = sessionManager.boolToVerify as Any
        }
        
        var params = [
            "field": fieldString as Any,
            fieldString: fieldValue
        ]
        
        if isRequestOTP {
            if signUpField == .password {
                params["password2"] = sessionManager.stringToVerify as Any
            }
        } else {
            params["code"] = otp as Any
        }
        
        if signUpField == .phoneNumber && !authenticate {
            params["verification_phone_number"] = sessionManager.verificationPhoneNumber as Any
        } else {
            params["verification_email"] = sessionManager.verificationEmail as Any
        }
        
        if isSignUpFlowEmailPhoneVerification() {
            params["pre_account_id"] = sessionManager.preAccountId as Any
        }
        
        return params
    }
    
    private func submitOTP() {
        ServerCommunicator().callMyServer(
            path: Utils.getOTPEndpoint(signUpField, authenticate),
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
//                                if !sessionManager.refreshFailed {
                                    self.showAlert = true
                                    self.alertMessage = "We spotted an error on the previous page. Please fill out the fields again."
//                                }
                                self.reEnterInfo = true
                                self.buttonDisabled = false
                                return
                            }
                        } // if code ends up here it indicates error with username field
                    } catch {
                        // error (Decoding error) if difficulty parsing the response
//                        if !sessionManager.refreshFailed {
                            self.alertMessage = ServerCommunicator.NetworkError.decodingError.errorMessage
                            self.showAlert = true
//                        }
                        self.buttonDisabled = false
                        return
                    }
                } else if let _ = responseData.success, responseData.error == nil {
                    self.submitted = true
                } else if let _ = responseData.error, let _ = responseData.success {
//                    if !sessionManager.refreshFailed {
                        self.alertMessage = ServerCommunicator.NetworkError.decodingError.errorMessage
                        self.showAlert = true
//                    }
                    self.buttonDisabled = false
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
    
    private func resendOTP() {
        ServerCommunicator().callMyServer(
            path: Utils.getOTPEndpoint(signUpField, authenticate),
            httpMethod: .put,
            params: generateOTPParams(isRequestOTP: true),
            sessionManager: authenticate ? sessionManager : nil,
            responseType: OTPRequest.self
        ) { response in
            switch response {
            case .success(let responseData):
                if let _ = responseData.error, responseData.success == nil {
//                    if !sessionManager.refreshFailed {
                        self.showAlert = true
                        self.alertMessage = "We spotted an error on the previous page. Please fill out the fields again."
//                    }
                    self.reEnterInfo = true
                   
                    self.resendCodeDisabled = false
                    return
                } else if let _ = responseData.success, responseData.error == nil {
                    self.resendCodeDisabled = false
                } else if let _ = responseData.error, let _ = responseData.success {
//                    if !sessionManager.refreshFailed {
                        self.alertMessage = ServerCommunicator.NetworkError.decodingError.errorMessage
                        self.showAlert = true
//                    }
                    self.resendCodeDisabled = false
                } else {
//                    if !sessionManager.refreshFailed {
                        self.alertMessage = ServerCommunicator.NetworkError.decodingError.errorMessage
                        self.showAlert = true
//                    }
                    self.resendCodeDisabled = false
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
//
//enum OTPFields: String, CaseIterable {
//    case email
//    case phoneNumber
//    case fullName
//    case brokerage
//    case symbol
//    case password
//    case deleteAccount
//}

#Preview {
    OTPView(
        title: "Change Email",
        subtitle: "Enter the code sent to your email",
        goBackNPagesToRedoEntries: 1,
        goBackNPagesIfCompleted: 0,
        nextPage: .changeEmail,
        signUpField: .email,
        authenticate: false
    )
    .environmentObject(NavigationPathManager())
    .environmentObject(UserSessionManager())
}
