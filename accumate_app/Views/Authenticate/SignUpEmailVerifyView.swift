//
//  SwiftUIView.swift
//  accumate_app
//
//  Created by Nevin Richards on 12/12/24.
//

import SwiftUI
import Combine
import Foundation

struct SignUpEmailVerifyView: View {
    @State private var keyboardHeight: CGFloat = 0
    @State private var cancellable: AnyCancellable?
    @State private var otp: String = ""
    @State private var errorMessage: String?
    
    @EnvironmentObject var navManager : NavigationPathManager
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Spacer()
            OTPFieldView(otp: $otp)
            Spacer()
            
            // Continue Button
            VStack() {
                Button {
                    if !validateOTP() {
                        errorMessage = "Code is incorrect or expired"
                    } else {
                        navManager.path.append(NavigationPathViews.signUpFullName)
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
                
                Button {
                    resendCode()
                } label: {
                    Text("Click here to resend code")
                        .foregroundColor(.white)
                        .font(.system(size: 14))
                        .multilineTextAlignment(.center)
                        .frame(maxWidth: .infinity)
                        .bold()
                }
                
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
    
    private func validateOTP() -> Bool {
        return true
    }
    
    private func resendCode() {
        return
    }

    
}



#Preview {
    SignUpEmailVerifyView()
        .environmentObject(NavigationPathManager())
}
