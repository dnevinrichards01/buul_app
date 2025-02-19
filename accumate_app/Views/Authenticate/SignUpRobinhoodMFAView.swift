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
    @State private var keyboardHeight: CGFloat = 0
    @State private var cancellable: AnyCancellable?
    @State private var otp: String = ""
    @State private var errorMessage: String?
    @State private var showAlert: Bool = false
    
    @EnvironmentObject var navManager : NavigationPathManager
    @EnvironmentObject var sessionManager: UserSessionManager
    var isSignUp: Bool
    private var email: String = "accumate-verify@accumatewealth.com"
    
    init(isSignUp: Bool = true) {
        self.isSignUp = isSignUp
    }
    
    
    var body: some View {
//
        VStack(alignment: .leading, spacing: 0) {
            let mfaMethod: RobinhoodMFAMethod = sessionManager.rhMfaMethod ?? .sms
            if mfaMethod == .app {
                VStack (alignment: .leading, spacing: 7) {
                    Text("Code Verification")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundStyle(.white)
                        .multilineTextAlignment(.center)
                        .padding(.bottom, 20)
                    Text("Enter the code in your authenticator app associated with your Robinhood account")
                        .font(.headline)
                        .foregroundStyle(.white.opacity(0.8))
                        .multilineTextAlignment(.leading)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                Spacer()
                OTPFieldView(otp: $otp)
                Spacer()
            } else if mfaMethod == .sms {
                VStack (alignment: .leading, spacing: 7) {
                    Text("Code Verification")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundStyle(.white)
                        .multilineTextAlignment(.center)
                    Text("Enter the code sent by Robinhood to your mobile device")
                        .font(.headline)
                        .foregroundStyle(.white.opacity(0.8))
                        .multilineTextAlignment(.leading)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                Spacer()
                OTPFieldView(otp: $otp)
                Spacer()
            } else if mfaMethod == .deviceApprovals {
                VStack (alignment: .leading, spacing: 7) {
                    Text("Device Verification")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundStyle(.white)
                        .multilineTextAlignment(.center)
                    Text("Open Robinhood on your device and click approve. \nThen return to Accumate and click continue")
                        .font(.headline)
                        .foregroundStyle(.white.opacity(0.8))
                        .multilineTextAlignment(.leading)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }
            
            Spacer()
            
            VStack() {
                Button {
                    errorMessage = validateMFA()
                    if let _ = errorMessage {
                        showAlert = true
                    } else {
                        sessionManager.rhMfaMethod = nil
                        if isSignUp {
                            navManager.append(NavigationPathViews.plaidInfo)
                        } else {
                            showAlert = true
                        }
                    }
                } label: {
                    Text("Continue")
                        .font(.headline)
                        .foregroundColor(.black)
                        .frame(maxWidth: .infinity, minHeight: 50)
                        .background(.white)
                        .cornerRadius(10)
                }
                .padding([.top, .bottom], 20)
                .alert(getAlertMessage(), isPresented: $showAlert) {
                    Button("OK", role: .cancel) {showAlert = false }
                }
                .onChange(of: showAlert) { oldValue, newValue in
                    if oldValue == true && newValue == false {
                        if isSignUp || errorMessage != nil {
                            errorMessage = nil
                        } else {
                            navManager.path.removeLast(4)
                        }
                    }
                }
                
                VStack (alignment: .center, spacing: 0) {
                    Text("If experiencing difficulties, contact us at:")
                        .foregroundColor(.white)
                        .font(.subheadline)
                    Text(email)
                        .font(.subheadline)
                        .foregroundColor(.blue)
                        .contextMenu {
                            Button(action: {
                                UIPasteboard.general.string = email
                            }) {
                                Label("Copy Email", systemImage: "doc.on.doc")
                            }
                        }
                }

                
                
            }
            .padding(.bottom, keyboardHeight) // Adjust based on keyboard height
            .animation(.easeInOut(duration: 0.3), value: keyboardHeight)
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
            if isSignUp {
                ToolbarItem(placement: .principal) {
                    Text("Sign Up")
                        .foregroundColor(.white)
                        .font(.system(size: 24, weight: .semibold))
                        .frame(maxHeight: 30)
                }
            }
            ToolbarItemGroup(placement: .keyboard) {
                Spacer()
                Button("Done") {
                    dismissKeyboard()
                }
                .foregroundColor(.blue) // Customize the button appearance
            }
        }
        .padding(30)
        .background(Color.black.ignoresSafeArea())
        .navigationBarBackButtonHidden(true)
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
//            if let countryCode = Locale.current.regionCode {
//                phoneNumber = "+\(countryCodeToPrefix[countryCode] ?? "1")"
//            }
            startKeyboardObserver()
        }
        .onDisappear {
            cancellable?.cancel()
        }
        
    }
    
    private func dismissKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
    
    func startKeyboardObserver() {
        cancellable = NotificationCenter.default.publisher(for: UIResponder.keyboardWillChangeFrameNotification)
            .compactMap { notification -> CGFloat? in
                if let frame = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect {
                    return frame.height > 0 ? frame.height : 0
                }
                return nil
            }
            .sink { height in
                withAnimation {
                    keyboardHeight = 0
                }
            }
    }
    
    private func getAlertMessage() -> String {
        if let errorMessage = errorMessage {
            return errorMessage
        } else {
            return "Your brokerage information has been updated"
        }
    }
    
    private func validateMFA() -> String? {
        let mfaMethod: RobinhoodMFAMethod = sessionManager.rhMfaMethod ?? .sms
        var error: String?
        if mfaMethod == .app || mfaMethod == .sms {
            error = validateOTP()
        } else if mfaMethod == .deviceApprovals {
            error = validateDeviceApprovalLogin()
        }
        return error
    }
    
    private func validateOTP() -> String? {
        _ = "Code is incorrect or expired. \nEnter a new code or resubmit your login credentials on the previous page."
        return nil
    }
    
    private func validateDeviceApprovalLogin() -> String? {
        _ = "Login unsuccessful or expired. \nResubmit your login credentials on the previous page."
        return nil
    }

    
}





#Preview {
    SignUpRobinhoodMFAView()
        .environmentObject(NavigationPathManager())
        .environmentObject(UserSessionManager())
}
