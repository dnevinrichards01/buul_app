//
//  SignUpPasswordView.swift
//  accumate_app
//
//  Created by Nevin Richards on 2/7/25.
//

import SwiftUI

@MainActor
struct SignUpPasswordView: View {
    @State private var password: String = ""
    @State private var password2: String = ""
    @FocusState private var focusedField: Int?
    
    @State private var errorMessages: [String?]? = nil
    
    @State private var submitted: Bool = false
    @State private var alertMessage: String = ""
    @State private var showAlert: Bool = false
    @State private var reEnterField: SignUpFields?
    @State private var buttonDisabled: Bool = false
    
    private var alertMessagePhoneNumber: String = "This phone number has been taken since you entered it"
    private var alertMessageEmail: String = "This email has been taken since you entered it"
    
    
    var signUpFields: [SignUpFields] = [.password, .password2]
    private var fieldBindings: [SignUpFields: Binding<String>] {
        [
            .password: $password,
            .password2: $password2,
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
                        instruction: signUpField.instruction,
                        placeholder: signUpField.placeholder,
                        inputValue: binding,
                        keyboard: signUpField.keyboardType,
                        errorMessage: errorMessages?[index]
                    )
                    .focused($focusedField, equals: index)
                }
            }
            
            Spacer()
            
            Button {
                buttonDisabled = true
                submitted = false
            } label: {
                Text("Create Account")
                    .font(.headline)
                    .foregroundColor(.black)
                    .frame(maxWidth: .infinity, minHeight: 50)
                    .background(.white)
                    .cornerRadius(10)
            }
            .disabled(buttonDisabled)
        }
        .alert(alertMessage, isPresented: $showAlert) {
            if showAlert {
                Button("OK", role: .cancel) { showAlert = false }
            }
        }
        .onChange(of: showAlert) { oldValue, newValue in
            if oldValue == true && newValue == false {
                if reEnterField == .email {
                    reEnterField = nil
                    navManager.path.removeLast(3)
                } else if reEnterField == .phoneNumber {
                    reEnterField = nil
                    navManager.path.removeLast(4)
                } else if reEnterField == .fullName {
                    reEnterField = nil
                    navManager.path.removeLast(1)
                } else {
                    return
                }
            }
        }
        .onChange(of: buttonDisabled) {
            if !buttonDisabled { return }
            
            let errorMessagesDictLocal = SignUpFieldsUtils.validateInputs(
                password: password,
                password2: password2
            )
            if let errorMessagesList = SignUpFieldsUtils.parseErrorMessages(errorMessagesDictLocal) {
                errorMessages = errorMessagesList
                buttonDisabled = false
            } else {
                createUser()
            }
        }
        .onChange(of: submitted) {
            if !submitted { return }
            buttonDisabled = false
            navManager.append(.accountCreated)
        }
        .animation(.easeInOut(duration: 0.5), value: errorMessages)
        .padding()
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
                Text("Sign Up")
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
    
    
    
    private func createUser() {
        ServerCommunicator().callMyServer(
            path: "api/user/register/",
            httpMethod: .post,
            params: [
                "password" : password as Any,
                "email" : sessionManager.email as Any,
                "username" : sessionManager.email as Any,
                "full_name" : sessionManager.fullName as Any,
                "phone_number" : sessionManager.phoneNumber as Any
            ],
            responseType: CreateUserRequest.self
        ) { response in
            // extract errorMessages and network error from the Result<T, NetworkError> object
            var errorMessages: CreateUserRequestErrors?
            var networkError: ServerCommunicator.NetworkError?
            switch response {
            case .success(let responseData):
                errorMessages = responseData.error
            case .failure(let error):
                networkError = error
            }
            
            // error if network error
            if let networkError = networkError {
                self.alertMessage = networkError.errorMessage
                self.showAlert = true
                self.buttonDisabled = false
                return
            }
            
            // process response
            if let errorMessages = errorMessages {
                print(errorMessages)
                do {
                    // process errors into a list
                    let errorMessagesDictBackend = try SignUpFieldsUtils.keysStringToSignUpFields(errorMessages)
                    print(errorMessagesDictBackend)
                    if let errorMessagesList = SignUpFieldsUtils.parseErrorMessages(errorMessagesDictBackend) {
                        // if an earlier field is messed up, error and send them back to it
                        if errorMessagesDictBackend[.password] == nil {
                            if let _ = errorMessagesDictBackend[.phoneNumber] {
                                self.sessionManager.phoneNumber = nil
                                self.alertMessage = alertMessagePhoneNumber
                                self.showAlert = true
                                self.reEnterField = .phoneNumber
                            } else if let _ = errorMessagesDictBackend[.email] {
                                self.sessionManager.email = nil
                                self.alertMessage = alertMessageEmail
                                self.showAlert = true
                                self.reEnterField = .email
                            }
                        }
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
            // if no error messages, set error messages to nil
            } else {
                self.errorMessages = Array(repeating: nil, count: SignUpFields.allCases.count) // can just make it nil
                self.buttonDisabled = false
                self.submitted = true
            }
        }
    }
}

struct CreateUserRequest: Codable {
    let success: String?
    let error: CreateUserRequestErrors?
}
struct CreateUserRequestErrors: Codable {
    let fullName: String?
    let email: String?
    let phoneNumber: String?
    let password: String?
}


#Preview {
    SignUpPasswordView()
        .environmentObject(NavigationPathManager())
        .environmentObject(UserSessionManager())
}


