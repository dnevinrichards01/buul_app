//
//  ChangeEmailView.swift
//  accumate_app
//
//  Created by Nevin Richards on 2/1/25.
//

import SwiftUI

struct ChangeAccountInfoView: View {
    @State private var username: String = ""
    @State private var password: String = ""
    @State private var password2: String = ""
    @State private var fullName: String = ""
    @State private var phoneNumber: String = ""
    @State private var email: String = ""
    @State private var errorMessages: [String?]? = nil
    @State private var showAlert: Bool = false
    @FocusState private var focusedField: Int?
    
    var title: String
    
    
    
    @EnvironmentObject var navManager: NavigationPathManager
    @EnvironmentObject var sessionManager: UserSessionManager
    
    var signUpFields: [SignUpFields]
    
    private var fieldBindings: [SignUpFields: Binding<String>] {
        [
            .password: $password,
            .password2: $password2,
            .fullName: $fullName,
            .phoneNumber: $phoneNumber,
            .email: $email,
        ]
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text(title)
                .font(.largeTitle)
                .fontWeight(.bold)
                .foregroundStyle(.white)
                .multilineTextAlignment(.center)
                .padding(.bottom, 20)
            
            ForEach(SignUpFields.allCases.indices, id: \.self) { index in
                let signUpField = SignUpFields.allCases[index]
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
            
            VStack() {
                Button {
                    let errorMessagesDict = SignUpFieldsUtils.validateInputs(
                        signUpFields: signUpFields,
                        password: password,
                        password2: password2,
                        fullName: fullName,
                        phoneNumber: phoneNumber,
                        email: email
                    )
                    var errorMessagesList: [String?] = []
                    var isError = false
                    for index in SignUpFields.allCases.indices {
                        let signUpField = SignUpFields.allCases[index]
                        if let errorMessage = errorMessagesDict[signUpField] {
                            if errorMessage != nil {
                                isError = true
                            }
                            errorMessagesList.append(errorMessage)
                        } else {
                            errorMessagesList.append(nil)
                        }
                    }
                    
                    withAnimation(.easeInOut(duration: 0.5)) {
                        errorMessages = errorMessagesList
                    }
                    if !isError {
                        showAlert = true
                        navManager.append(NavigationPathViews.home)
                    }
                } label: {
                    Text("Submit")
                        .font(.headline)
                        .foregroundColor(.black)
                        .frame(maxWidth: .infinity, minHeight: 50)
                        .background(.white)
                        .cornerRadius(10)
                }
                .padding([.top, .bottom], 20)
                .alert("Your information has been updated", isPresented: $showAlert) {
                    Button("OK", role: .cancel) { showAlert = false}
                }
                .onChange(of: showAlert) { oldValue, newValue in
                    if oldValue == true && newValue == false {
                        navManager.reset()
                    }
                }
            }
        }
        .padding(30)
        .background(Color.black.ignoresSafeArea())
        .navigationBarBackButtonHidden(true)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button(action: {
                    navManager.path.removeLast(2)
                }) {
                    Image(systemName: "chevron.left")
                        .foregroundColor(.white)
                        .font(.system(size: 20, weight: .medium))
                        .frame(maxHeight: 30)
                }
            }
            ToolbarItemGroup(placement: .keyboard) {
                if signUpFields.count > 1 {
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
                }
                Spacer()
                Button("Done") {
                    dismissKeyboard()
                }
                .foregroundColor(.blue) // Customize the button appearance
            }
        }
    }
    
    private func dismissKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
    
    private func validateEmail() -> String? {
        return nil
    }
    
    private func validatePassword() -> String? {
        return nil
    }
    
    private func validatePassword2() -> String? {
        if password == password2 {
            return nil
        }
        return "Enter your new password exactly as above"
    }
    
    private func validateUsername() -> String? {
        return nil
    }
    
    private func validateFullname() -> String? {
        return nil
    }
    
    private func validatePhoneNumber() -> String? {
        return nil
    }

    
}


#Preview {
    ChangeAccountInfoView(title: "Reset Password", signUpFields: [.password, .password2])
        .environmentObject(NavigationPathManager())
        .environmentObject(UserSessionManager())
}
