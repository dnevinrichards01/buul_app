//
//  RobinhoodFieldsEntryView.swift
//  accumate_app
//
//  Created by Nevin Richards on 3/7/25.
//

import SwiftUI

struct RobinhoodFieldsEntryView: View {
    
    @EnvironmentObject var navManager: NavigationPathManager
    @EnvironmentObject var sessionManager: UserSessionManager
    
    var title: String?
    var subtitle: String?
    var signUpFields: [SignUpFields]
    var fieldBindings: [SignUpFields : Binding<String>]
    var suggestLogIn: Bool
    var isLogin: Bool
    var isSignUp: Bool
    @Binding var alertMessage: String
    @Binding var showAlert: Bool
    @Binding var errorMessages: [String?]?
    @Binding var buttonDisabled: Bool
    @FocusState var focusedField: Int?
    @Binding var timedOut: Bool
    
    init(title: String?, subtitle: String?, signUpFields: [SignUpFields], fieldBindings: [SignUpFields : Binding<String>],
         suggestLogIn: Bool = false, isLogin: Bool = false, isSignUp: Bool = false, alertMessage: Binding<String>,
         showAlert: Binding<Bool>, errorMessages: Binding<[String?]?>, buttonDisabled: Binding<Bool>, timedOut: Binding<Bool>) {
        self.title = title
        self.subtitle = subtitle
        self.signUpFields = signUpFields
        self.fieldBindings = fieldBindings
        self.suggestLogIn = suggestLogIn
        self.isLogin = isLogin
        self.isSignUp = isSignUp
        self._alertMessage = alertMessage
        self._showAlert = showAlert
        self._errorMessages = errorMessages
        self._buttonDisabled = buttonDisabled
        self._timedOut = timedOut
    }
    
    var body: some View {
        VStack {
            VStack (alignment: .center) {
                Image("RobinhoodLeafLogo")
                    .resizable()
                    .frame(width: 150, height: 150)
            }
            .frame(maxWidth: .infinity)
            .padding()
            
            ForEach(0..<signUpFields.count, id: \.self) { index in
                let signUpField = signUpFields[index]
               
                if let binding = fieldBindings[signUpField], signUpFields.contains(signUpField) {
                    SignUpFieldView(
                        instruction: selectInstructionType(signUpField),
                        placeholder: signUpField.placeholder,
                        inputValue: binding,
                        keyboard: signUpField.keyboardType,
                        errorMessage: errorMessages?[index],
                        signUpField: signUpField,
                        focusedField: $focusedField,
                        index: index
                    )
                    .focused($focusedField, equals: index)
                }
            }
            
            Spacer()
            
            VStack {
                Button {
                    buttonDisabled = true
                } label: {
                    Text("Connect")
                        .font(.headline)
                        .foregroundColor(.black)
                        .frame(maxWidth: .infinity, minHeight: 50)
                        .background(.white)
                        .cornerRadius(10)
                }
                .disabled(buttonDisabled)
                .padding(.bottom, 20)
                
                Button {
                    if let url = URL(string: "https://join.robinhood.com/teymurr") {
                        UIApplication.shared.open(url)
                    }
                } label: {
                    Text("Sign up for Robinhood")
                        .font(.headline)
                        .foregroundColor(.white.opacity(0.8))
                        .frame(maxWidth: .infinity, minHeight: 50)
                        .background(.black)
                        .cornerRadius(10)
                        .overlay(
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(.gray.opacity(0.4), lineWidth: 2)
                        )
                }
                
                HStack {
                    Image(systemName: "lock.shield")
                        .foregroundStyle(.gray)
                    Text("Buul uses bank level security to connect to your brokerage")
                        .font(.footnote)
                        .foregroundStyle(.gray)
                        .padding(.leading, 10)
                }
                .padding()
            }
            
        }
        .alert(alertMessage, isPresented: $showAlert) {
            if timedOut {
                Button("No", role: .cancel) {
                    showAlert = false
                    timedOut = false
                }
                Button("Yes", role: .cancel) {
                    showAlert = false
                }
            } else {
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
//        .alert(sessionManager.refreshFailedMessage, isPresented: $sessionManager.refreshFailed) {
//            Button("OK", role: .cancel) {
//                showAlert = false
//                sessionManager.refreshFailed = false
//            }
//            Button("Log Out", role: .destructive) {
//                Task {
//                    showAlert = false
//                    
//                    sessionManager.refreshFailed = false
//                    _ = await sessionManager.resetComplete()
//                    navManager.reset(views: [.landing])
//                }
//            }
//        }
        .padding()
        .animation(.easeInOut(duration: 0.5), value: errorMessages)
        .background(.black)
        .navigationBarBackButtonHidden(true)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItemGroup(placement: .keyboard) {
                Button {
                    if let _focusedField = focusedField {
                        focusedField = max(_focusedField - 1, 0)
                        print(focusedField)
                    }
                } label: {
                    Image(systemName: "chevron.left")
                        .foregroundColor(.blue)
                }
                Button {
                    if let _focusedField = focusedField {
                        focusedField = min(_focusedField + 1, signUpFields.count - 1)
                        print(focusedField)
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
}
