//
//  NoSelectionTextField.swift
//  accumate_app
//
//  Created by Nevin Richards on 4/25/25.
//

import SwiftUI

class TapAwareTextField: UITextField {
    var onUserTap: (() -> Void)? = nil

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        onUserTap?()  // <-- run custom tap handler
        super.touchesBegan(touches, with: event)  // <-- still pass touch to system
    }
}

struct NoSelectionTextField: UIViewRepresentable {
    @Binding var text: String
    var placeholder: String
    @Binding var isSecure: Bool
    var maxWidth: CGFloat
    var textType: UITextContentType?
    var keyboardType: UIKeyboardType
    @Binding var focusedFieldCopy: Int?
    @State var focusedField: FocusState<Int?>.Binding
    var totalFields: Int
    var index: Int
    @State private var prefix: String = ""
    @State private var prevLength: Int = 0
    
    init(
        _ placeholder: String,
        text: Binding<String>,
        isSecure: Binding<Bool>,
        maxWidth: CGFloat,
        textType: UITextContentType?,
        keyboardType: UIKeyboardType,
        focusedField: FocusState<Int?>.Binding,
        focusedFieldCopy: Binding<Int?>,
        totalFields: Int,
        index: Int
    ) {
        self.placeholder = placeholder
        self._text = text
        self._isSecure = isSecure
        self.maxWidth = CGFloat(maxWidth)
        self.textType = textType
        self.keyboardType = keyboardType
        self._focusedFieldCopy = focusedFieldCopy
        self.focusedField = focusedField
        self.totalFields = totalFields
        self.index = index
    }

    func makeUIView(context: Context) -> TapAwareTextField {
        let textField = TapAwareTextField()//UITextField()
        textField.delegate = context.coordinator
        textField.onUserTap = {
            context.coordinator.userTapped()
        }
        textField.passwordRules = UITextInputPasswordRules(descriptor: "required: upper; required: lower; required: digit; required: [-@$!.%*?&]; minlength: 8;")
        textField.isSecureTextEntry = [.password, .newPassword].contains(textType)
        textField.tintColor = isSecure ? .white : .white.withAlphaComponent(0.01)
        textField.textColor = isSecure ? .white : .white.withAlphaComponent(0.01)
        textField.placeholder = placeholder
        textField.autocorrectionType = .no
        textField.autocapitalizationType = .none
        textField.spellCheckingType = .no
        textField.textAlignment = .left
        textField.keyboardType = keyboardType
        textField.textContentType = textType ?? .none
        textField.text = text
        textField.inputAccessoryView = makeKeyboardToolbar(context.coordinator)
        return textField
    }
    
    private func makeKeyboardToolbar(_ coordinator: Coordinator) -> UIToolbar {
        let toolbar = UIToolbar()
        toolbar.sizeToFit()

        let previousButton = UIBarButtonItem(
            image: UIImage(systemName: "chevron.left"), style: .plain, target: coordinator,
            action: #selector(Coordinator.previousTapped)
        )
        let nextButton = UIBarButtonItem(
            image: UIImage(systemName: "chevron.right"), style: .plain, target: coordinator,
            action: #selector(Coordinator.nextTapped)
        )
        let spacer = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let doneButton = UIBarButtonItem(
            title: "Done", style: .done, target: coordinator,
            action: #selector(Coordinator.doneTapped)
        )

        if totalFields > 1 {
            toolbar.items = [previousButton, nextButton, spacer, doneButton]
        } else {
            toolbar.items = [spacer, doneButton]
        }
        return toolbar
    }

    func updateUIView(_ uiView: TapAwareTextField, context: Context) {
        uiView.tintColor = isSecure ? .white : .white.withAlphaComponent(0.01)
        uiView.textColor = isSecure ? .white : .white.withAlphaComponent(0.01)
        
        
        if focusedFieldCopy == index && !uiView.isFirstResponder {
            DispatchQueue.main.async {
                uiView.becomeFirstResponder()
                context.coordinator.navigatingFocus = false
                context.coordinator.justBecameFocused = true
            }
        } else if focusedFieldCopy != index && uiView.isFirstResponder {
            if !context.coordinator.navigatingFocus {
                DispatchQueue.main.async {
                    uiView.resignFirstResponder()
                }
            }
        }
        
        if uiView.text != text {
            context.coordinator.manuallySettingText = true
            uiView.text = text
            context.coordinator.manuallySettingText = false
        }
    }
    
    func getStringWidth(_ text: String, secure: Bool) -> CGFloat {
        let visibleFont = UIFont.systemFont(ofSize: secure ? 20 : 17)
        let visibleAttributes = [NSAttributedString.Key.font: visibleFont]
        let visibleWidth = (text as NSString).size(withAttributes: visibleAttributes).width
        return visibleWidth
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    class Coordinator: NSObject, UITextFieldDelegate {
        var parent: NoSelectionTextField
        var manuallySettingText = false
        var userIntendsChange = false
        var navigatingFocus = false
        var justBecameFocused = false

        init(_ parent: NoSelectionTextField) {
            self.parent = parent
        }
        
        @objc func doneTapped() {
            DispatchQueue.main.async {
                self.parent.focusedField.wrappedValue = nil
                self.parent.focusedFieldCopy = nil
                Utils.dismissKeyboard()
            }
        }

        @objc func previousTapped() {
            moveFocus(offset: -1)
        }

        @objc func nextTapped() {
            moveFocus(offset: 1)
        }
        
        private func moveFocus(offset: Int) {
            let newFocusedField = max(0, min(parent.index + offset, parent.totalFields - 1))
            navigatingFocus = true
            DispatchQueue.main.async {
                self.parent.focusedField.wrappedValue = newFocusedField
                self.parent.focusedFieldCopy = newFocusedField
            }
        }

        func textFieldDidChangeSelection(_ textField: UITextField) {
            DispatchQueue.main.async {
                self.parent.text = textField.text ?? ""
            }
        }

        func textFieldDidBeginEditing(_ textField: UITextField) {
            DispatchQueue.main.async {
                self.navigatingFocus = false
                if self.parent.focusedFieldCopy != self.parent.index {
                    self.parent.focusedField.wrappedValue = self.parent.index
                    self.parent.focusedFieldCopy = self.parent.index
                }
            }
        }

        func textFieldShouldEndEditing(_ textField: UITextField) -> Bool {
            return true
        }
        
        func userTapped() {
            navigatingFocus = false
            DispatchQueue.main.async {
                self.parent.focusedField.wrappedValue = self.parent.index
                self.parent.focusedFieldCopy = self.parent.index
            }
        }
    }
}
