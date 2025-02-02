//
//  EmailRecoverView.swift
//  accumate_app
//
//  Created by Nevin Richards on 2/2/25.
//

import SwiftUI

struct EmailRecoverView: View {
    @State private var email: String = ""
    
    @EnvironmentObject var navManager: NavigationPathManager
    
    var body: some View {
        VStack {
            VStack (alignment: .center) {
                Text("Forgot your email?")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundStyle(.white)
                    .multilineTextAlignment(.center)
                    .padding(.bottom, 20)
                Text("We will send you an email if we have an account associated with this email.")
                    .font(.headline)
                    .foregroundStyle(.white.opacity(0.8))
                    .multilineTextAlignment(.leading)
            }
            .frame(maxWidth: .infinity)
            .padding()
            
            SignUpFieldView(
                instruction: SignUpFields.email.instruction,
                placeholder: SignUpFields.email.placeholder,
                inputValue: $email,
                keyboard: SignUpFields.phoneNumber.keyboardType
            )
            .padding()
            
            Spacer()
            
            Button {
                sendEmail()
            } label: {
                Text("Send")
                    .font(.headline)
                    .foregroundColor(.black)
                    .frame(maxWidth: .infinity, minHeight: 50)
                    .background(.white)
                    .cornerRadius(10)
            }
            .padding(20)
            
        }
        .background(.black)
        .navigationBarBackButtonHidden(true)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                Button(action: {
                    navManager.path.removeLast()
                }) {
                    Image(systemName: "chevron.left")
                        .foregroundColor(.white)
                        .font(.system(size: 20, weight: .medium))
                        .frame(maxHeight: 30)
                }
            }
        }
    }
    
    private func sendEmail() {
        return
    }
}

#Preview {
    EmailRecoverView()
        .environmentObject(NavigationPathManager())
}
