//
//  EmailRecoverView.swift
//  accumate_app
//
//  Created by Nevin Richards on 2/2/25.
//

import SwiftUI

struct EmailRecoverView: View {
    @State private var email: String = ""
    @State private var showAlert: Bool = false
    @State private var alertMessage: String = ""
    @State private var buttonDisabled: Bool = false
    @State private var errorMessage: String?
    @FocusState private var focusedField: Int?
    @State private var focusedFieldCopy: Int?
    
    
    @EnvironmentObject var navManager: NavigationPathManager
    @EnvironmentObject var sessionManager: UserSessionManager
    
    var body: some View {
        VStack {
            VStack (alignment: .center) {
                Text("Forgot your email?")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundStyle(.white)
                    .multilineTextAlignment(.center)
                    .padding(.bottom, 20)
                Text("We will send you an email if we have an account associated with this email.")
                    .font(.headline)
                    .foregroundStyle(.white.opacity(0.8))
                    .multilineTextAlignment(.leading)
                    .frame(height: 50)
            }
            .frame(maxWidth: .infinity)
            .padding()
            
            SignUpFieldView(
                instruction: SignUpFields.email.instruction,
                placeholder: SignUpFields.email.placeholder,
                inputValue: $email,
                keyboard: SignUpFields.email.keyboardType,
                errorMessage: errorMessage,
                signUpField: .email,
                focusedField: $focusedField,
                focusedFieldCopy: $focusedFieldCopy,
                index: 0,
                totalFields: 1
            )
            .padding()
            
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
            .padding(20)
            
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
        .onChange(of: buttonDisabled) {
            if !buttonDisabled { return }
            sendEmail()
        }
        .animation(.easeInOut(duration: 0.5), value: errorMessage)
        .background(Color.black.ignoresSafeArea())
        .navigationBarBackButtonHidden(true)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
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
    }
    
    private func sendEmail() {
        ServerCommunicator().callMyServer(
            path: "api/user/sendemail/",
            httpMethod: .post,
            params: [
                "email": email
            ],
            sessionManager: sessionManager,
            responseType: SuccessErrorResponse.self
        ) { response in
            // extract errorMessages and network error from the Result<T, NetworkError> object
            switch response {
            case .success(let responseData):
                if let error = responseData.error, responseData.success == nil {
                    self.errorMessage = error
                    self.buttonDisabled = false
                } else if let _ = responseData.success, responseData.error == nil {
//                    if !sessionManager.refreshFailed {
                        self.alertMessage = "Your request was recieved. Please check your email."
                        self.showAlert = true
//                    }
                    self.errorMessage = nil
                    self.buttonDisabled = false
                } else if let _ = responseData.error, let _ = responseData.success {
//                    if !sessionManager.refreshFailed {
                        self.alertMessage = ServerCommunicator.NetworkError.decodingError.errorMessage
                        self.showAlert = true
//                    }
                    self.errorMessage = nil
                    self.buttonDisabled = false
                } else {
//                    if !sessionManager.refreshFailed {
                        self.alertMessage = ServerCommunicator.NetworkError.decodingError.errorMessage
                        self.showAlert = true
//                    }
                    self.errorMessage = nil
                    self.buttonDisabled = false
                }
            case .failure(let networkError):
//                if !sessionManager.refreshFailed {
                    self.alertMessage = networkError.errorMessage
                    self.showAlert = true
//                }
                self.errorMessage = nil
                self.buttonDisabled = false
            }
        }
    }
}

#Preview {
    EmailRecoverView()
        .environmentObject(NavigationPathManager())
        .environmentObject(UserSessionManager())
}
