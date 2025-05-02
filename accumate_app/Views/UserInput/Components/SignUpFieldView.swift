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
    @Binding var isSecure: Bool
    @State private var censoredInputValue: String
    var textType: UITextContentType?
    var isNewPassword: Bool
    var isUserName: Bool
    var maxWidth: CGFloat
    var totalFields: Int
    var index: Int
    var isInteractive: Bool
    private var truncatedInputValue: String {
        truncateText(inputValue)
    }
    
    @State private var blinkCursor: Bool = false
    @Binding var focusedFieldCopy: Int?
    @State var focusedField: FocusState<Int?>.Binding
    @State var actuallyFocused = false
    @State private var isCurrentIndex: Bool = false
    @State var uncensoredText: String = ""
    
    init(
        inputValue: Binding<String>,
        placeholder: String,
        keyboard: UIKeyboardType,
        isSecure: Binding<Bool>,
        textType: UITextContentType? = .none,
        isNewPassword: Bool = false,
        isUserName: Bool = false,
        focusedField: FocusState<Int?>.Binding,
        focusedFieldCopy: Binding<Int?>,
        index: Int,
        totalFields: Int,
        isInteractive: Bool = true
    ) {
        self._inputValue = inputValue
        self.placeholder = placeholder
        self.keyboard = keyboard
        self._isSecure = isSecure
        self.censoredInputValue = Utils.censor(inputValue.wrappedValue)
        self.textType = textType
        self.isNewPassword = isNewPassword
        self.isUserName = isUserName
        self.focusedField = focusedField
        self._focusedFieldCopy = focusedFieldCopy
        self.maxWidth = UIScreen.main.bounds.width - ([.password,.newPassword].contains(textType) ? 80 : 50)
        self.index = index
        self.totalFields = totalFields
        self.isInteractive = isInteractive
        
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
                    ZStack {
                        if [.password,.newPassword].contains(textType) {
                            NoSelectionTextField(
                                placeholder,
                                text: $inputValue,
                                isSecure: $isSecure,
                                maxWidth: maxWidth,
                                textType: textType,
                                keyboardType: keyboard,
                                focusedField: focusedField,
                                focusedFieldCopy: $focusedFieldCopy,
                                totalFields: totalFields,
                                index: index
                            )
                            .frame(width: maxWidth, height: 40)
                            .padding(.horizontal, 8)
                        } else {
                            TextField(placeholder, text: $inputValue)
                                .textContentType(textType)
                                .keyboardType(keyboard)
                                .foregroundColor(.white.opacity(0.8))
                                .tint(.white.opacity(0.8))
                                .frame(height: 40)
                                .frame(maxWidth: .infinity)
                                .cornerRadius(10)
                                .autocorrectionDisabled()
                                .textInputAutocapitalization(.never)
                                .padding(.horizontal, 8)
                                .simultaneousGesture(
                                    TapGesture().onEnded {
                                        focusedFieldCopy = index
                                    }
                                )
                                .focused(focusedField, equals: index)
                        }
                    }
                    if !isSecure {
                        HStack (spacing: 0) {
                            Text(truncatedInputValue)
                                .background(.black)
                                .foregroundColor(.white.opacity(0.8))
                                .lineLimit(1)
                                .padding(.horizontal, 8)
                                .frame(height: 40)
                                .allowsHitTesting(false)
                            
                            if focusedFieldCopy == index {
                                Rectangle()
                                    .fill(Color.white.opacity(blinkCursor ? 1 : 0))
                                    .frame(width: 2, height: 22)
                                    .offset(x: -7)
                                    .onAppear {
                                        blinkCursor.toggle()
                                        withAnimation(.easeInOut(duration: 0.5).repeatForever(autoreverses: true)) {
                                            blinkCursor.toggle()
                                        }
                                    }
                            }
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
    
    func truncateText(_ text: String) -> String {
        var _text = text
        while getStringWidth(_text) > maxWidth {
            _text = String(_text.dropFirst())
        }
        return _text
    }
    
    func getStringWidth(_ text: String) -> CGFloat {
        let font = UIFont.systemFont(ofSize: 17)
        let attributes = [NSAttributedString.Key.font: font]
        let width = (text as NSString).size(withAttributes: attributes).width
        return width
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
    @Binding var isSecure: Bool
    @Binding var focusedFieldCopy: Int?
    @State var focusedField: FocusState<Int?>.Binding
    var index: Int
    var totalFields: Int
    var isInteractive: Bool
    
    @EnvironmentObject var navManager: NavigationPathManager
    @EnvironmentObject var sessionManager: UserSessionManager
    
    init(instruction: String, placeholder: String, inputValue: Binding<String>, keyboard: UIKeyboardType, errorMessage: String?,
         signUpField: SignUpFields, isNewPassword: Bool = false, isUserName: Bool = true, focusedField: FocusState<Int?>.Binding,
         focusedFieldCopy: Binding<Int?>, index: Int, totalFields: Int, isInteractive: Bool = true,
         isSecure: Binding<Bool> = .constant(true)) {
        self.instruction = instruction
        self.placeholder = placeholder
        self._inputValue = inputValue
        self.keyboard = keyboard
        self.errorMessage = errorMessage
        self.signUpField = signUpField
        self.isNewPassword = isNewPassword
        self.isUserName = isUserName
        self.focusedField = focusedField
        self._focusedFieldCopy = focusedFieldCopy
        self.index = index
        self.totalFields = totalFields
        self.isInteractive = isInteractive
        self._isSecure = isSecure
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 5) {
            
            VStack (alignment: .leading) {
                Text(instruction)
                    .foregroundColor(.white.opacity(0.9))
                    .font(.system(size: 18))
                    .background(.black)
                    .cornerRadius(10)
                    .fixedSize(horizontal: false, vertical: true)
                HStack {
                    CustomTextField(
                        inputValue: $inputValue,
                        placeholder: placeholder,
                        keyboard: keyboard,
                        isSecure: $isSecure,
                        textType: getTextTypeFromFieldType(),
                        isNewPassword: isNewPassword,
                        focusedField: focusedField,
                        focusedFieldCopy: $focusedFieldCopy,
                        index: index,
                        totalFields: totalFields,
                        isInteractive: isInteractive
                    )
                    if signUpField == .password || signUpField == .password2 {
                        Button {
                            isSecure.toggle()
                        } label: {
                            Image(systemName: isSecure ? "eye.slash" : "eye")
                                .foregroundColor(.gray)
                                .frame(width: 40, height: 40)
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
            // maybe make copy of input value and pass it in
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
            return isUserName ? .username : .emailAddress
        case .password:
            return isNewPassword ? .newPassword : .password
        case .password2:
            return .password
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
