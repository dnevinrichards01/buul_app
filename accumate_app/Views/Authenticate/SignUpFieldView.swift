//
//  SignUpFieldView.swift
//  accumate_app
//
//  Created by Nevin Richards on 12/13/24.
//

import SwiftUI

struct CustomTextField: View {
    @Binding var inputValue: String
    var placeholder: String
    var keyboard : UIKeyboardType
    
    var body: some View {
        ZStack(alignment: .leading) {
            if inputValue.isEmpty {
                Text(placeholder)
                    .foregroundColor(.white.opacity(0.6))
                    .padding(.leading, 8)
            }

            TextField("", text: $inputValue)
                .foregroundColor(.white.opacity(0.8))
                .accentColor(.white.opacity(0.8))
                .padding(8)
                .keyboardType(keyboard)
        }
        .background(.black)
        .cornerRadius(8)
        .overlay(
            RoundedRectangle(cornerRadius: 10)
                .stroke(.gray.opacity(0.4), lineWidth: 2)
        )
    }
}

struct SignUpFieldView: View {
    var instruction : String
    var placeholder : String
    @Binding var inputValue : String
    var keyboard : UIKeyboardType
    var errorMessage : String?
    var displayErrorMessage : Bool = true
    var signUpField: SignUpFields
    
    @EnvironmentObject var navManager: NavigationPathManager
    @EnvironmentObject var sessionManager: UserSessionManager
    
    var body: some View {
        VStack(alignment: .leading, spacing: 5) {
            Text(instruction)
                .foregroundColor(.white.opacity(0.9))
                .font(.system(size: 18))
                .background(.black)
                .cornerRadius(10)
            CustomTextField(
                inputValue: $inputValue,
                placeholder: placeholder,
                keyboard: keyboard
            )
            
            if displayErrorMessage {
                if let error = errorMessage {
                    Text(error)
                        .foregroundColor(.red)
                        .font(.system(size: 18))
                        .background(.black)
                        .cornerRadius(10)
                        .padding(.bottom, 10)
                        .fixedSize(horizontal: false, vertical: true)
                } else {
                    Spacer()
                        .frame(height: 20)
                }
            }
        }
        .onChange(of: inputValue) {
            if signUpField == .phoneNumber {
                inputValue = SignUpFieldsUtils.formatPhoneNumber(inputValue)
            }
        }
        .onAppear {
            if signUpField == .phoneNumber {
                if let _phoneNumber = sessionManager.phoneNumber {
                    inputValue = !sessionManager.isLoggedIn ? _phoneNumber : "+1"
                } else {
                    inputValue = "+1"
                }
            }
        }
    }
    
    
}

#Preview {
    SignUpFieldView(
        instruction: "example instruction",
        placeholder: "value like this",
        inputValue: .constant(""),
        keyboard: UIKeyboardType.phonePad,
        errorMessage: nil,
        signUpField: .password
    )
    .environmentObject(UserSessionManager())
    .environmentObject(NavigationPathManager())
    .background(.black)
}
