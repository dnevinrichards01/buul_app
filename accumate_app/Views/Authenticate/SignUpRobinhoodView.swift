//
//  RobinhoodView.swift
//  accumate_app
//
//  Created by Nevin Richards on 12/14/24.
//

import SwiftUI

struct SignUpRobinhoodView: View {
    @State private var username: String = ""
    @State private var password: String = ""
    @State private var password2: String = ""
    
    var isSignUp: Bool = true
    
    private var fieldBindings: [RobinhoodFields: Binding<String>] {
        [
            .username: $username,
            .password: $password
        ]
    }
    
    @FocusState private var focusedField: Int?
    @State private var showAlert: Bool = false
    
    @EnvironmentObject var navManager: NavigationPathManager
    @EnvironmentObject var sessionManager: UserSessionManager
    
    var body: some View {
        VStack {
            Image("RobinhoodLogo")
                .resizable()
                .frame(width: 150, height: 150)
            ForEach(RobinhoodFields.allCases.indices, id: \.self) { index in
                let option = RobinhoodFields.allCases[index]
                if let binding = fieldBindings[option] {
                    SignUpFieldView(
                        instruction: option.instruction,
                        placeholder: option.placeholder,
                        inputValue: binding,
                        keyboard: option.keyboardType,
                        displayErrorMessage: false
                    )
                    .focused($focusedField, equals: index)
                    .id(index)
                }
                Spacer().frame(height: 20)
            }
            
            Spacer()
            
            Button {
                let mfaMethod: RobinhoodMFAMethod = .app//signInToRobinhood()
                sessionManager.rhMfaMethod = mfaMethod
                if mfaMethod == .none {
                    if isSignUp {
                        navManager.append(NavigationPathViews.plaidInfo)
                    } else {
                        showAlert = true
                    }
                } else {
                    if isSignUp {
                        navManager.append(NavigationPathViews.signUpMfaRobinhood)
                    } else {
                        navManager.append(NavigationPathViews.mfaRobinhood)
                    }
                }
            } label: {
                Text("Connect")
                    .font(.headline)
                    .foregroundColor(.black)
                    .frame(maxWidth: .infinity, minHeight: 50)
                    .background(Color(red: 75/255, green: 135/255, blue: 120/255))
                    .cornerRadius(10)
            }
            .padding(.top, 0)
            .alert("Your brokerage information has been updated", isPresented: $showAlert) {
                Button("OK", role: .cancel) {showAlert = false }
            }
            .onChange(of: showAlert) { oldValue, newValue in
                if oldValue == true && newValue == false {
                    navManager.path.removeLast(3)
                }
            }
            
            Button {
                
            } label: {
                Text("Sign up for Robinhood")
                    .font(.headline)
                    .foregroundColor(.white.opacity(0.8))
                    .frame(maxWidth: .infinity, minHeight: 50)
                    .background(.black)
                    .cornerRadius(10)
                    .overlay(
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(.gray.opacity(0.4), lineWidth: 2)
                    )
            }
            .padding(.top, 10)
            
            
            HStack {
                Image(systemName: "lock.shield")
                    .foregroundStyle(.gray)
                Text("Accumate uses bank level security to connect to your brokerage")
                    .font(.footnote)
                    .foregroundStyle(.gray)
                    .padding(.leading, 10)
            }
            .padding(.horizontal, 20)
            .padding(.top, 10)
        }
        .padding()
        .background(Color.black.ignoresSafeArea())
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden()
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
                Text("Connect to Robinhood")
                    .foregroundColor(.white)
                    .font(.system(size: 24, weight: .semibold))
                    .frame(maxHeight: 30)
            }
        }
    }
    
    private func dismissKeyboard() {
        focusedField = nil
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
    
    private func signInToRobinhood() -> RobinhoodMFAMethod {
        return .none
    }
}

enum RobinhoodMFAMethod: CaseIterable {
    case sms
    case deviceApprovals
    case app
    case none
}

#Preview {
    SignUpRobinhoodView()
        .environmentObject(NavigationPathManager())
        .environmentObject(UserSessionManager())
}
