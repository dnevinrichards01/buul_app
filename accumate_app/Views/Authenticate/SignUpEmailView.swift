//
//  SwiftUIView.swift
//  accumate_app
//
//  Created by Nevin Richards on 12/12/24.
//

import SwiftUI
import Combine
import Foundation

struct SignUpEmailView: View {
    @State private var keyboardHeight: CGFloat = 0
    @State private var cancellable: AnyCancellable?
    @State private var email: String = ""
    @State private var errorMessage: String?
    
    @EnvironmentObject var navManager : NavigationPathManager
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Spacer()
                .frame(height: 50)
            
            SignUpFieldView(
                instruction: SignUpFields.email.instruction,
                placeholder: SignUpFields.email.placeholder,
                inputValue: $email,
                keyboard: SignUpFields.email.keyboardType,
                errorMessage: errorMessage
            )
            Spacer()
            
            // Continue Button
            VStack() {
                Button {
                    if !validateEmail() {
                        errorMessage = "Enter a valid email address"
                    } else {
                        navManager.append(NavigationPathViews.signUpEmailVerify)
                    }
                    
                } label: {
                    Text("Continue")
                        .font(.headline)
                        .foregroundColor(.black)
                        .frame(maxWidth: .infinity, minHeight: 50)
                        .background(.white)
                        .cornerRadius(10)
                }
                .padding([.top, .bottom], 20)
                
                Text("By signing up, you agree to our Terms and Privacy Policy")
                    .foregroundColor(.gray)
                    .font(.system(size: 12))
                    .multilineTextAlignment(.center)
                    .frame(maxWidth: .infinity)

            }
            .padding(.bottom, keyboardHeight) // Adjust based on keyboard height
            .animation(.easeInOut(duration: 0.3), value: keyboardHeight)
        }
        .padding(30)
        .background(Color.black.ignoresSafeArea())
        .navigationBarBackButtonHidden(true)
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
//            if let countryCode = Locale.current.regionCode {
//                phoneNumber = "+\(countryCodeToPrefix[countryCode] ?? "1")"
//            }
            startKeyboardObserver()
        }
        .onDisappear {
            cancellable?.cancel()
        }
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
    
    func startKeyboardObserver() {
        cancellable = NotificationCenter.default.publisher(for: UIResponder.keyboardWillChangeFrameNotification)
            .compactMap { notification -> CGFloat? in
                if let frame = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect {
                    return frame.height > 0 ? frame.height : 0
                }
                return nil
            }
            .sink { height in
                withAnimation {
                    keyboardHeight = 0
                }
            }
    }
    
    private func validateEmail() -> Bool {
        return true
    }

    
}



#Preview {
    SignUpEmailView()
        .environmentObject(NavigationPathManager())
}
