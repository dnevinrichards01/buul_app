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
        }
    }
}

#Preview {
    SignUpFieldView(
        instruction: "example instruction",
        placeholder: "value like this",
        inputValue: .constant(""),
        keyboard: UIKeyboardType.phonePad
    )
    .background(.black)
}
