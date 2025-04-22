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
    var textType: UITextContentType? 
    var isNewPassword: Bool
    var isUserName: Bool
    @State private var blinkCursor: Bool = false
    @State var focusedField: FocusState<Int?>.Binding
    var index: Int
    
    init(inputValue: Binding<String>, placeholder: String, keyboard: UIKeyboardType, isSecure: Binding<Bool>,
         textType: UITextContentType? = .none, isNewPassword: Bool = false, isUserName: Bool = false,
         focusedField: FocusState<Int?>.Binding, index: Int) {
        self._inputValue = inputValue
        self.placeholder = placeholder
        self.keyboard = keyboard
        self._isSecure = isSecure
        self.censoredInputValue = Utils.censor(inputValue.wrappedValue)
        self.textType = textType
        self.isNewPassword = isNewPassword
        self.isUserName = isUserName
        self.focusedField = focusedField
        self.index = index
    }
    
    var body: some View {
        ZStack(alignment: .leading) {
            if inputValue.isEmpty {
                Text(placeholder)
                    .foregroundColor(.white.opacity(0.6))
                    .padding(.leading, 8)
            }
            ZStack {
                Group {
                    TextField("", text: $inputValue)
                        .foregroundColor(isSecure ? .clear : .white.opacity(0.8))
                        .accentColor(isSecure ? .clear : .white.opacity(0.8))
                        .padding(8)
                        .keyboardType(keyboard)
                        .autocorrectionDisabled(true)
                        .textInputAutocapitalization(.never)
                        .textContentType(textType)
                        .focused(focusedField, equals: index)
                    if isSecure {
                        HStack (spacing: 0) {
                            Text(String(repeating: "•", count: inputValue.count))
                                .font(.system(.body, design: .monospaced))
                                .frame(alignment: .leading)
                                .foregroundColor(.white.opacity(0.8))
                                .padding(8)
//                            if actuallyFocused {
//                                Rectangle()
//                                    .fill(Color.white.opacity(blinkCursor ? 1 : 0))
//                                    .frame(width: 1.5, height: 20)
//                                    .offset(x: -8)
//                                    .onAppear {
//                                        blinkCursor.toggle()
//                                        withAnimation(.easeInOut(duration: 0.6).repeatForever(autoreverses: true)) {
//                                            blinkCursor.toggle()
//                                        }
//                                    }
//                            }
                            Spacer()
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                    }
                }
            }
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
    var isNewPassword: Bool
    var isUserName: Bool
    @State private var isSecure: Bool
    
    @State var focusedField: FocusState<Int?>.Binding
    var index: Int
    
    @EnvironmentObject var navManager: NavigationPathManager
    @EnvironmentObject var sessionManager: UserSessionManager
    
    init(instruction: String, placeholder: String, inputValue: Binding<String>, keyboard: UIKeyboardType, errorMessage: String?,
         signUpField: SignUpFields, isNewPassword: Bool = false, isUserName: Bool = true, focusedField: FocusState<Int?>.Binding,
         index: Int) {
        self.instruction = instruction
        self.placeholder = placeholder
        self._inputValue = inputValue
        self.keyboard = keyboard
        self.errorMessage = errorMessage
        self.signUpField = signUpField
        self.isSecure = signUpField == .password || signUpField == .password2
        self.isNewPassword = isNewPassword
        self.isUserName = isUserName
        
        self.focusedField = focusedField
        self.index = index
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
                        isSecure: $isSecure,
                        textType: getTextTypeFromFieldType(),
                        isNewPassword: isNewPassword,
                        focusedField: focusedField,
                        index: index
                    )
                    if signUpField == .password || signUpField == .password2 {
                        Button {
                            isSecure.toggle()
                        } label: {
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
    
    private func getTextTypeFromFieldType() -> UITextContentType? {
        switch signUpField {
        case .email:
            return .username
        case .password:
            return isNewPassword ? .newPassword : .password
        case .password2:
            return .none
        case .phoneNumber:
            return .telephoneNumber
        case .verificationEmail:
            return .emailAddress
        case .verificationPhoneNumber:
            return .telephoneNumber
//        case .code:
//            return .oneTimeCode
        default:
            return .none
        }
        
    }
}

//#Preview {
//    SignUpFieldView(
//        instruction: "example instruction",
//        placeholder: "value like this",
//        inputValue: .constant(""),
//        keyboard: UIKeyboardType.phonePad,
//        errorMessage: nil,
//        signUpField: .password,
//        index: 0,
//        focusedField: .Binding
//    )
//    .environmentObject(UserSessionManager())
//    .environmentObject(NavigationPathManager())
//    .background(.black)
//}
