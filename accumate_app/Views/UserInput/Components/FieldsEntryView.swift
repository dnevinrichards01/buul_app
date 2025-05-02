//
//  FieldsEntryView.swift
//  accumate_app
//
//  Created by Nevin Richards on 3/6/25.
//

import SwiftUI

struct FieldsEntryView: View {
    
    @EnvironmentObject var navManager: NavigationPathManager
    @EnvironmentObject var sessionManager: UserSessionManager
    
    var title: String?
    var subtitle: String?
    var signUpFields: [SignUpFields]
    var fieldBindings: [SignUpFields : Binding<String>]
    var suggestLogIn: Bool = false
    var isLogin: Bool = false
    var isSignUp: Bool
    @Binding var buttonText: String
    var isUserName: Bool
    @Binding var alertMessage: String
    @Binding var showAlert: Bool
    @Binding var errorMessages: [String?]?
    @Binding var buttonDisabled: Bool
    @State var focusedField: FocusState<Int?>.Binding
    @State var focusedFieldCopy: Int?
    @Binding var hideFields: [SignUpFields]
    @State private var email: String = ""
    var isNewPassword: Bool = false
    var isSecureBindings: [SignUpFields : Binding<Bool>]
    
    init(
        title: String? = nil,
        subtitle: String? = nil,
        signUpFields: [SignUpFields],
        fieldBindings: [SignUpFields : Binding<String>],
        suggestLogIn: Bool = false,
        isLogin: Bool = false,
        isSignUp: Bool,
        buttonText: Binding<String>,
        isUserName: Bool = false,
        alertMessage: Binding<String>,
        showAlert: Binding<Bool>,
        errorMessages: Binding<[String?]?>,
        buttonDisabled: Binding<Bool>,
        focusedField: FocusState<Int?>.Binding,
        isNewPassword: Bool = false,
        isSecureBindings: [SignUpFields : Binding<Bool>],
        hideFields: Binding<[SignUpFields]> = .constant([])
    ) {
        self.title = title
        self.subtitle = subtitle
        self.signUpFields = signUpFields
        self.fieldBindings = fieldBindings
        self.suggestLogIn = suggestLogIn
        self.isLogin = isLogin
        self.isSignUp = isSignUp
        self._buttonText = buttonText
        self.isUserName = isUserName
        self._alertMessage = alertMessage
        self._showAlert = showAlert
        self._errorMessages = errorMessages
        self._buttonDisabled = buttonDisabled
        self.focusedField = focusedField
        self.isNewPassword = isNewPassword
        self.isSecureBindings = isSecureBindings
        self._hideFields = hideFields
    }
    
    
    var body: some View {
        ZStack {
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
                
                if suggestLogIn {
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
                    if let binding = fieldBindings[signUpField], let isSecure = isSecureBindings[signUpField], signUpFields.contains(signUpField), !hideFields.contains(signUpField) {
                        SignUpFieldView(
                            instruction: getLabel(signUpField),
                            placeholder: signUpField.placeholder,
                            inputValue: binding,
                            keyboard: signUpField.keyboardType,
                            errorMessage: errorMessages?[index],
                            signUpField: signUpField,
                            isNewPassword: isNewPassword,
                            isUserName: isUserName,
                            focusedField: focusedField,
                            focusedFieldCopy: $focusedFieldCopy,
                            index: index,
                            totalFields: signUpFields.count,
                            isSecure: isSecure
                        )
                    }
                }
                .animation(.easeInOut(duration: 0.25), value: hideFields)
                
                if isLogin {
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
                }
                
                Spacer()
                
                Button {
                    buttonDisabled = true
                } label: {
                    Text(buttonText)
                        .font(.headline)
                        .foregroundColor(.black)
                        .frame(maxWidth: .infinity, minHeight: 50)
                        .background(.white)
                        .cornerRadius(10)
                }
                .disabled(buttonDisabled)
                .padding(20)
                
            }
            if signUpFields.contains(.password) && !signUpFields.contains(.email) && !signUpFields.contains(.verificationEmail) {
                
            }
        }
        .onAppear() {
            email = sessionManager.email ?? ""
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
        .onAppear {
            buttonDisabled = false
        }
        .animation(.easeInOut(duration: 0.5), value: errorMessages)
        .background(Color.black.ignoresSafeArea())
        .navigationBarBackButtonHidden(true)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItemGroup(placement: .keyboard) {
                Button {
                    if let _focusedField = focusedFieldCopy {
                        focusedFieldCopy = max(_focusedField - 1, 0)
                        focusedField.wrappedValue = focusedFieldCopy
                    }
                } label: {
                    Image(systemName: "chevron.left")
                        .foregroundColor(.blue)
                }
                Button {
                    if let _focusedField = focusedFieldCopy {
                        focusedFieldCopy = min(_focusedField + 1, signUpFields.count - 1)
                        focusedField.wrappedValue = focusedFieldCopy
                    }
                } label: {
                    Image(systemName: "chevron.right")
                        .foregroundColor(.blue)
                }
                Spacer()
                Button("Done") {
                    Utils.dismissKeyboard()
                }
                .foregroundColor(.blue)
            }
        }
    }
    
    private func selectInstructionType(_ signUpField: SignUpFields) -> String {
        var instruction: String
        if isSignUp {
            instruction = signUpField.instruction
        } else if isLogin {
            instruction = signUpField.loginInstruction
        } else {
            instruction = signUpField.resetInstruction
        }
        return instruction
    }
    
    private func getLabel(_ signUpField: SignUpFields) -> String {
        var instruction: String
        if isNewPassword && signUpField == .email {
            instruction = "Your previously selected email is your username"
        } else {
            instruction = selectInstructionType(signUpField)
        }
        return instruction
    }
}
