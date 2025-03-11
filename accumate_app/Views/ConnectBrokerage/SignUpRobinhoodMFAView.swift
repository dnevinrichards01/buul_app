//
//  SignUpRobinhoodMFAView.swift
//  accumate_app
//
//  Created by Nevin Richards on 2/4/25.
//

import SwiftUI
import Combine
import Foundation

struct SignUpRobinhoodMFAView: View {
    @State private var otp: String = ""
    @State private var errorMessage: String?
    @State private var buttonDisabled: Bool = false
    @State private var requested: Bool = false
    @State private var recieved: Bool = false
    @State private var reEnterFields: Bool = false
    @State private var alertMessage: String = ""
    @State private var showAlert: Bool = false
    @State private var mfaMethod: RobinhoodMFAMethod?
    @State private var resendCode: Bool = false

    @EnvironmentObject var navManager : NavigationPathManager
    @EnvironmentObject var sessionManager: UserSessionManager
    var isSignUp: Bool
    
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            if let mfaMethod = mfaMethod, mfaMethod == .app {
                VStack (alignment: .leading, spacing: 7) {
                    Text(getTitle(mfaMethod))
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundStyle(.white)
                        .multilineTextAlignment(.center)
                        .padding(.bottom, 20)
                    Text(getDescription(mfaMethod))
                    .font(.headline)
                    .foregroundStyle(.white.opacity(0.8))
                    .multilineTextAlignment(.leading)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                Spacer()
                OTPFieldView(otp: $otp)
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
            } else if let mfaMethod = mfaMethod, mfaMethod == .sms {
                VStack (alignment: .leading, spacing: 7) {
                    Text(getTitle(mfaMethod))
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundStyle(.white)
                        .multilineTextAlignment(.center)
                    Text(getDescription(mfaMethod))
                        .font(.headline)
                        .foregroundStyle(.white.opacity(0.8))
                        .multilineTextAlignment(.leading)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                Spacer()
                OTPFieldView(otp: $otp)
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
            } else if let mfaMethod = mfaMethod, mfaMethod == .prompt {
                VStack (alignment: .leading, spacing: 7) {
                    Text(getTitle(mfaMethod))
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundStyle(.white)
                        .multilineTextAlignment(.center)
                    Text(getDescription(mfaMethod))
                        .font(.headline)
                        .foregroundStyle(.white.opacity(0.8))
                        .multilineTextAlignment(.leading)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
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
            }
            
            Spacer()
            
            VStack() {
                VStack() {
                    Button {
                        buttonDisabled = true
                        resendCode = false
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
                    
                    if mfaMethod == .sms {
                        Button {
                            buttonDisabled = true
                            resendCode = true
                        } label: {
                            Text("Click here to resend code")
                                .foregroundColor(.white)
                                .font(.system(size: 14))
                                .multilineTextAlignment(.center)
                                .frame(maxWidth: .infinity)
                                .bold()
                        }
                        .disabled(buttonDisabled)
                    }
                }
            }
        }
        .onAppear {
            mfaMethod = sessionManager.robinhoodMFAType
        }
        .alert(alertMessage, isPresented: $showAlert) {
            Button("OK", role: .cancel) {
                Task {
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
//        .alert(sessionManager.refreshFailedMessage, isPresented: $sessionManager.refreshFailed) {
//            Button("OK", role: .cancel) {
//                showAlert = false
//                sessionManager.refreshFailed = false
//            }
//            Button("Log Out", role: .destructive) {
//                Task {
//                    showAlert = false
//                    sessionManager.refreshFailed = false
//                    _ = await sessionManager.resetComplete()
//                    navManager.reset(views: [.landing])
//                }
//            }
//        }
        .onChange(of: showAlert) { oldValue, newValue in
            if oldValue == true && newValue == false {
                if mfaMethod == nil || reEnterFields {
                    navManager.removeLast(1)
                } else if recieved {
                    sessionManager.brokerageEmail = nil
                    sessionManager.brokeragePassword = nil
                    sessionManager.robinhoodMFAType = nil
                    navManager.removeLast(5)
                }
            }
        }
        .onChange(of: buttonDisabled) {
            if !buttonDisabled { return }
            requestSignIn()
        }
        .onChange(of: requested) {
            if !requested { return }
            sleep(2)
            recieveSignInResult()
        }
        .onChange(of: recieved) {
            if !recieved { return }
            recieved = false
            
//            if robinhoodMFAType != mfaMethod {
//                let prevPath: [NavigationPathViews] = Array(navManager.path)
//                prevPath.removeLast(1)
//                switch mfaMethod {
//                case .sms:
//                    prevPath.append(.)
//                case .app:
//                    <#code#>
//                case .prompt:
//                    <#code#>
//                case nil:
//                    <#code#>
//                }
//                
//                
//                navManager.reset(
//            }
            
            if isSignUp {
                sessionManager.brokerageCompleted = true
                navManager.append(.plaidInfo)
            } else {
                alertMessage = "Your brokerage information has been updated."
                showAlert = true
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
            ToolbarItemGroup(placement: .keyboard) {
                Spacer()
                Button("Done") {
                    Utils.dismissKeyboard()
                }
                .foregroundColor(.blue) // Customize the button appearance
            }
        }
        .padding(30)
        .background(Color.black.ignoresSafeArea())
        .navigationBarBackButtonHidden(true)
        .navigationBarTitleDisplayMode(.inline)
    }
    
    private func getDescription(_ mfaMethod: RobinhoodMFAMethod) -> String {
        switch mfaMethod {
        case .sms:
            return "Enter the code sent by Robinhood to your mobile device"
        case .app:
            return "Enter the code in your authenticator app associated with your Robinhood account"
        case .prompt:
            return "Open Robinhood on your device and click approve. \nThen return to Accumate and click continue"
        }
    }
    
    private func getTitle(_ mfaMethod: RobinhoodMFAMethod) -> String {
        switch mfaMethod {
        case .sms:
            return "Code Verification"
        case .app:
            return "Code Verification"
        case .prompt:
            return "Device Verification"
        }
    }
    
    private func getParams(mfaMethod: RobinhoodMFAMethod?, resendCode: Bool) -> [String : Any]? {
        
        var params: [String : Any] = [
            "username": sessionManager.brokerageEmail as Any,
            "password": sessionManager.brokeragePassword as Any
        ]
        
        guard let mfaMethod = mfaMethod, !resendCode else { return params }
        let mfaFieldString = Utils.camelCaseToSnakeCase(mfaMethod.rawValue)
        if [.app, .sms].contains(mfaMethod) {
            params[mfaFieldString] = otp
        } else {
            params[mfaFieldString] = true
        }
        
//        if mfaMethod == .app {
//            params[mfaFieldString] = otp as Any
//        } else if mfaMethod == .challengeCode {
//            params = [mfaFieldString : otp]
//        }
        
        return params
    }

    private func requestSignIn() {
        ServerCommunicator().callMyServer(
            path: "rh/login/",
            httpMethod: .post,
            params: getParams(mfaMethod: self.mfaMethod, resendCode: self.resendCode),
            sessionManager: sessionManager,
            responseType: OTPRequest.self
        ) { response in
            switch response {
            case .success(let responseData):
                // validation errors
                if let errors = responseData.error, responseData.success == nil {
                    if let codeErrorMessage = errors.code {
                        self.errorMessage = codeErrorMessage
                        self.buttonDisabled = false
                        return
                    }
                    self.reEnterFields = true
//                    if !sessionManager.refreshFailed {
                        self.alertMessage = "There may be an error in your username and password. Please re-enter them."
                        self.showAlert = true
//                    }
                    self.buttonDisabled = false
                // success, set up OTP information
                } else if let _ = responseData.success, responseData.error == nil {
                    self.errorMessage = nil
                    self.requested = true
                // alert because unexpected response
                } else if let _ = responseData.error, let _ = responseData.success {
                    self.errorMessage = nil
//                    if !sessionManager.refreshFailed {
                        self.alertMessage = ServerCommunicator.NetworkError.decodingError.errorMessage
                        self.showAlert = true
//                    }
                    self.buttonDisabled = false
                // alert because unexpected response
                } else {
                    self.errorMessage = nil
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
                self.errorMessage = nil
                self.buttonDisabled = false
            }
        }
    }
    
    private func recieveSignInResult(retries: Int = 7) {
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
                        for mfaMethod in RobinhoodMFAMethod.allCases {
                            if Utils.camelCaseToSnakeCase(mfaMethod.rawValue) == challengeType {
                                self.sessionManager.robinhoodMFAType = mfaMethod
                                self.mfaMethod = mfaMethod
                            }
                        }
                    }
                    
                    self.errorMessage = errors.errorMessage
                    self.requested = false
                    self.buttonDisabled = false
                    return
                // success, set up OTP information
                } else if let _ = responseData.success, responseData.error == nil {
                    self.errorMessage = nil
                    self.recieved = true
                    self.sessionManager.robinhoodMFAType = nil
                    self.buttonDisabled = false
                // not yet ready
                } else if let _ = responseData.error, let _ = responseData.success {
                    
                    if retries > 0 {
                        sleep(1)
                        recieveSignInResult(retries: retries - 1)
                        return
                    }
                    self.errorMessage = nil
//                    if !sessionManager.refreshFailed {
                        self.alertMessage = ServerCommunicator.NetworkError.networkError.errorMessage
                        self.showAlert = true
//                    }
                    self.requested = false
                    self.buttonDisabled = false
                // alert because unexpected response
                } else {
                    self.errorMessage = nil
//                    if !sessionManager.refreshFailed {
                        self.alertMessage = ServerCommunicator.NetworkError.decodingError.errorMessage
                        self.showAlert = true
//                    }
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
                self.errorMessage = nil
                self.buttonDisabled = false
            }
        }
    }
    
}





#Preview {
    SignUpRobinhoodMFAView(isSignUp: true)
        .environmentObject(NavigationPathManager())
        .environmentObject(UserSessionManager())
}
