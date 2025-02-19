//
//  LoadingCircle.swift
//  accumate_app
//
//  Created by Nevin Richards on 2/10/25.
//

import SwiftUI
import LinkKit

struct LoadingCircle: View {
    @State private var rotationAngle: Double = 0.0
    var body: some View {
        HStack {
            Spacer()
            VStack {
                Spacer()
                ZStack {
                    Circle()
                        .stroke(Color.gray.opacity(0.3), lineWidth: 5)
                        .frame(width: 60)
                    
                    Circle()
                        .trim(from: 0.2, to: 1.0)
                        .stroke(Color.white, lineWidth: 5)
                        .frame(width: 60)
                        .rotationEffect(.degrees(rotationAngle))
                }
                .frame(width: 100, height: 100)
                Spacer()
            }
            Spacer()
        }
        .onAppear {
            withAnimation(Animation.linear(duration: 3).repeatForever(autoreverses: false)) {
                rotationAngle = 360
            }
        }
    }
}

struct PlaidLinkPageBackground: View {
    @EnvironmentObject var navManager: NavigationPathManager
    @EnvironmentObject var sessionManager: UserSessionManager
    @EnvironmentObject var linkManager: PlaidLinkManager
    @Binding var isPresentingLink: Bool
    
    var body: some View {
        ZStack {
            VStack {
                HStack {
                    Text("Connecting to your bank with Plaid")
                        .font(.system(size: 30, weight: .bold))
                        .foregroundColor(.white)
                        .multilineTextAlignment(.center)
                        .padding([.leading, .trailing], 20)
                }
                Spacer()
                VStack {
                    Image("AccumateLogoText")
                        .resizable()
                        .frame(width: 200, height: 70)
                    Image(systemName: "plus")
                        .resizable()
                        .frame(width: 30, height: 30)
                        .foregroundColor(.white)
                    Image("PlaidLinkLogo")
                        .resizable()
                        .frame(width: 200, height: 70)
                }
                Spacer()
                
                Button {
                    linkManager.requestCreatePlaidUser(sessionManager.accessToken)
                } label: {
                    Text("Retry or add accounts from another bank")
                        .font(.subheadline)
                        .foregroundColor(.black)
                        .frame(maxWidth: .infinity, minHeight: 50)
                        .background(.white.opacity(0.8))
                        .cornerRadius(10)
                }
                .disabled(isPresentingLink)
                Button {
                    sessionManager.linkCompleted = true
                    navManager.append(.home)
                } label: {
                    Text("Continue")
                        .font(.headline)
                        .foregroundColor(.black)
                        .frame(maxWidth: .infinity, minHeight: 50)
                        .background(.white)
                        .cornerRadius(10)
                }
                .disabled(isPresentingLink)
            }
            if !isPresentingLink {
                LoadingCircle()
                    .background(.black.opacity(0.65))
            }
        }
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button(action: {
                    linkManager.reset(sessionManager: sessionManager)
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
    
}
