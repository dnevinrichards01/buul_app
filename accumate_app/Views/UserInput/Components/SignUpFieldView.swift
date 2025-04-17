//
//  SignUpFieldView.swift
//  accumate_app
//
//  Created by Nevin Richards on 12/13/24.
//

import SwiftUI

//struct CustomSecureField: View {
//    @Binding var inputValue: String
//    var placeholder: String
//    var keyboard : UIKeyboardType
//    @State private var censoredInputValue: String
//    
//    init(inputValue: Binding<String>, placeholder: String, keyboard: UIKeyboardType) {
//        self._inputValue = inputValue
//        self.placeholder = placeholder
//        self.keyboard = keyboard
//        self.censoredInputValue = inputValue.wrappedValue
//    }
//    
//    var body: some View {
//        ZStack {
//            TextField("", text: $inputValue)
//                .foregroundColor(.white.opacity(0.8))
//                .accentColor(.white.opacity(0.8))
//                .padding(8)
//                .keyboardType(keyboard)
//            //            .textContentType(.oneTimeCode)
//                .onChange(of: inputValue) {
//                    censoredInputValue = censor(inputValue)
//                    inputValue =
//                }
//        }
//    }
//    
//    private func censor(_ input: String) -> String {
//        if input.count == 0 {
//            return ""
//        }
//        return String(repeating: "•", count: input.count)
//    }
//}

struct CustomTextField: View {
    @Binding var inputValue: String
    var placeholder: String
    var keyboard : UIKeyboardType
    @Binding var isSecure: Bool
    @State private var censoredInputValue: String
//    @FocusState private var isFocused: Bool = true
    
    init(inputValue: Binding<String>, placeholder: String, keyboard: UIKeyboardType, isSecure: Binding<Bool>) {
        self._inputValue = inputValue
        self.placeholder = placeholder
        self.keyboard = keyboard
        self._isSecure = isSecure
        self.censoredInputValue = Utils.censor(inputValue.wrappedValue)
    }
    
    var body: some View {
        ZStack(alignment: .leading) {
            if inputValue.isEmpty {
                Text(placeholder)
                    .foregroundColor(.white.opacity(0.6))
                    .padding(.leading, 8)
            }
            ZStack {
                TextField("", text: $inputValue)
                    .foregroundColor(isSecure ? .clear : .white.opacity(0.8))
                    .accentColor(isSecure ? .clear : .white.opacity(0.8))
                    .padding(8)
                    .keyboardType(keyboard)
                    .autocorrectionDisabled(true)
                    .textInputAutocapitalization(.never)
                if isSecure {
                    Text(censoredInputValue)
                        .foregroundColor(.white.opacity(0.8))
                        .accentColor(.white.opacity(0.8))
                        .padding(8)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .allowsHitTesting(false)
                }
            }
        }
        .onChange(of: inputValue) {
            censoredInputValue = Utils.censor(inputValue)
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
    
    @State private var isSecure: Bool
    
    @EnvironmentObject var navManager: NavigationPathManager
    @EnvironmentObject var sessionManager: UserSessionManager
    
    init(instruction: String, placeholder: String, inputValue: Binding<String>, keyboard: UIKeyboardType, errorMessage: String?,
         signUpField: SignUpFields) {
        self.instruction = instruction
        self.placeholder = placeholder
        self._inputValue = inputValue
        self.keyboard = keyboard
        self.errorMessage = errorMessage
        self.signUpField = signUpField
        self.isSecure = signUpField == .password || signUpField == .password2
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 5) {
            
            VStack (alignment: .leading) {
                Text(instruction)
                    .foregroundColor(.white.opacity(0.9))
                    .font(.system(size: 18))
                    .background(.black)
                    .cornerRadius(10)
                HStack {
                    CustomTextField(
                        inputValue: $inputValue,
                        placeholder: placeholder,
                        keyboard: keyboard,
                        isSecure: $isSecure
                    )
                    if signUpField == .password || signUpField == .password2 {
                        Button(action: {
                            isSecure.toggle()
                        }) {
                            Image(systemName: isSecure ? "eye.slash" : "eye")
                                .foregroundColor(.gray)
                        }
                    }
                }
            }
            
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
