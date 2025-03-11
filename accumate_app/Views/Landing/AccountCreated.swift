//
//  AccountCreated.swift
//  accumate_app
//
//  Created by Nevin Richards on 2/2/25.
//

import SwiftUI

struct AccountCreated: View {
    
    @EnvironmentObject var navManager: NavigationPathManager
    @EnvironmentObject var sessionManager: UserSessionManager
    
    var body: some View {
        VStack {
            VStack {
                Spacer()
                // App Name
                Image("AccumateLogoText")
                    .resizable()
                    .frame(width: 350, height: 115)
//                    .padding(.bottom, -30)
                
                VStack {
                    Text("Congratulations! Your account is now active.")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                        .padding(.bottom, 10)
                        .padding(.trailing, 10)
                        .frame(maxWidth: .infinity, alignment: .leading)
//                        .multilineTextAlignment(.center)
                    
                    Text("We need to collect a little more information before we can start maximizing your cashback")
                        .font(.headline)
                        .foregroundColor(.white.opacity(0.8))
                        .padding(.bottom, 30)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
                .padding(.horizontal, 10)
                Spacer()
            }
            
            
            Spacer()
            
            // Continue Button
            Button {
                navManager.append(.signUpETFs)
            } label: {
                Text("Continue")
                    .font(.headline)
                    .foregroundColor(.black)
                    .frame(maxWidth: .infinity, minHeight: 50)
                    .background(.white)
                    .cornerRadius(10)
            }
            .padding()
        }
        .padding()
        .task {
            // get refresh tokens / log in
            // block the buton maybe?
        }
        .background(.black)
        .navigationBarBackButtonHidden(true)
        .navigationBarTitleDisplayMode(.inline)
    }
    
    
}


#Preview {
    AccountCreated()
        .environmentObject(NavigationPathManager())
        .environmentObject(UserSessionManager())
}
