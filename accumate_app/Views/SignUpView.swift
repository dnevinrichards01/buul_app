//
//  SwiftUIView.swift
//  accumate_app
//
//  Created by Nevin Richards on 12/12/24.
//

import SwiftUI

struct SignUpView: View {
    @State private var username: String = ""
    @State private var password: String = ""
    @State private var password2: String = ""
    @State private var phoneNumber: String = ""
    @State private var verificationCode: String = ""
    @State private var email: String = ""
    @State private var firstName: String = ""
    @State private var lastName: String = ""
    
    @FocusState private var focusedField: Int?
    
    private var fieldBindings: [SignUpFields: Binding<String>] {
        [
            .username: $username,
            .password: $password,
            .password2: $password2,
            .firstName: $firstName,
            .lastName: $lastName,
            .phoneNumber: $phoneNumber,
            .email: $email,
        ]
    }
    
    @EnvironmentObject var navManager : NavigationPathManager
    
    var body: some View {
        ScrollViewReader { scrollProxy in
            GeometryReader { geometry in
                ScrollView {
                    VStack(alignment: .leading, spacing: 0) {
                        HStack {
                            Spacer()
                            Text("Already a member?")
                                .foregroundColor(.white.opacity(0.9))
                                .font(.system(size: 12))
                                .background(.black)
                                .cornerRadius(10)
                            Button {
                                navManager.path.append(NavigationPathViews.login)
                            } label: {
                                Text("Sign In")
                                    .foregroundColor(.blue)
                                    .font(.system(size: 12))
                                    .background(.black)
                                    .cornerRadius(10)
                            }
                        }
                        
                        Spacer()
                            .frame(height: 30)
                        
                        ForEach(SignUpFields.allCases.indices, id: \.self) { index in
                            let option = SignUpFields.allCases[index]
                            if let binding = fieldBindings[option] {
                                SignUpFieldView(
                                    instruction: option.instruction,
                                    placeholder: option.placeholder,
                                    inputValue: binding,
                                    keyboard: option.keyboardType
                                )
                                .focused($focusedField, equals: index)
                                .id(index)
                            }
                            Spacer().frame(height: 20)
                        }
                        
                        // Continue Button
                        Button {
                            navManager.path.append(NavigationPathViews.link)
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
                        
                        if focusedField != nil {
                            Color.clear
                                .frame(height: geometry.size.height * 0.8)
                        }
                    }
                    .padding()
                    .frame(minHeight: geometry.size.height)
                }
                .onChange(of: focusedField) { oldValue, newValue in
                    if let newValue = newValue {
                        scrollToField(id: newValue, scrollProxy: scrollProxy)
                    }
                }
                //.ignoresSafeArea(.keyboard)
                .background(Color.black.ignoresSafeArea())
                .navigationBarBackButtonHidden(true)
                .navigationBarTitleDisplayMode(.inline)
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
                        Button {
                            if let focusedField = focusedField {
                                scrollToField(
                                    id: max(focusedField - 1, 0),
                                    scrollProxy: scrollProxy
                                )
                            }
                        } label: {
                            Image(systemName: "chevron.left")
                                .foregroundColor(.blue)
                        }
                        Button {
                            if let focusedField = focusedField {
                                scrollToField(
                                    id: min(focusedField + 1, fieldBindings.count - 1),
                                    scrollProxy: scrollProxy
                                )
                            }
                        } label: {
                            Image(systemName: "chevron.right")
                                .foregroundColor(.blue)
                        }
                        Spacer()
                        Button("Done") {
                            dismissKeyboard()
                        }
                        .foregroundColor(.blue) // Customize the button appearance
                    }
                }
            }
        }
    }
    
    private func dismissKeyboard() {
        focusedField = nil
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
    
    private func scrollToField(id: Int, scrollProxy: ScrollViewProxy) {
        focusedField = id
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
            withAnimation(.spring(response: 0.5, dampingFraction: 0.7, blendDuration: 0.2)) {
                scrollProxy.scrollTo(id, anchor: .center)
            }
        }
    }
}



#Preview {
    SignUpView()
        .environmentObject(NavigationPathManager())
}
