//
//  SwiftUIView.swift
//  accumate_app
//
//  Created by Nevin Richards on 12/12/24.
//

import SwiftUI
import Combine
import Foundation

struct SignUpFullNameView: View {
    @State private var keyboardHeight: CGFloat = 0
    @State private var cancellable: AnyCancellable?
    @State private var fullName: String = ""
    @State private var errorMessage: String?
    
    @EnvironmentObject var navManager : NavigationPathManager
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Spacer()
                .frame(height: 50)
            
            SignUpFieldView(
                instruction: SignUpFields.fullName.instruction,
                placeholder: SignUpFields.fullName.placeholder,
                inputValue: $fullName,
                keyboard: SignUpFields.fullName.keyboardType,
                errorMessage: errorMessage
            )
            Spacer()
            
            // Continue Button
            VStack() {
                Button {
                    if !validateFullName() {
                        errorMessage = "Avoid numbers and special characters like punctuation"
                    } else {
                        navManager.append(NavigationPathViews.signUpETFs)
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
    
    private func validateFullName() -> Bool {
        return true
    }

    
}



#Preview {
    SignUpFullNameView()
        .environmentObject(NavigationPathManager())
}
