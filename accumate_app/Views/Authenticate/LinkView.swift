//
//  LinkView.swift
//  accumate_app
//
//  Created by Nevin Richards on 12/13/24.
//

import SwiftUI
import LinkKit

struct LinkView: View {
    @EnvironmentObject var navManager : NavigationPathManager
    @EnvironmentObject var sessionManager: UserSessionManager
    
    @State private var linkCompleted = false
    @State private var isPresentingLink = false
    @State private var rotationAngle: Double = 0.0
    
    @StateObject var linkManager = PlaidLinkManager()
    
    var body: some View {
        VStack (alignment: .center) {
            Spacer()
            
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
//                            Button {
//                                triggerLinkFlow()
//                            } label: {
//                                Text("completed signup (temp)")
//                                    .font(.headline)
//                                    .foregroundColor(.black)
//                                    .frame(maxWidth: .infinity, minHeight: 50)
//                                    .background(.white)
//                                    .cornerRadius(10)
//                            }
                }
                if !isPresentingLink && !linkCompleted {
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
                    .background(.black.opacity(0.65))
                }
                
            }
                
//            Button {
//                triggerLinkFlow()
//            } label: {
//                Text("completed signup (temp)")
//                    .font(.headline)
//                    .foregroundColor(.black)
//                    .frame(maxWidth: .infinity, minHeight: 50)
//                    .background(.white)
//                    .cornerRadius(10)
//            }
                
            
            .padding()
            Spacer()
        }
        .fullScreenCover(
            isPresented: $isPresentingLink,
            onDismiss: { isPresentingLink = false },
            content: {
                if let controller = linkManager.controller {
                    controller.ignoresSafeArea(.all)
                } else {
                    Text("Error: LinkController not initialized")
                }
            }
        )
        .onAppear {
            withAnimation(Animation.linear(duration: 3).repeatForever(autoreverses: false)) {
                rotationAngle = 360
            }
        }
        .task {
            await linkManager.fetchLinkToken()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.black)
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden()
        .toolbar {
//            ToolbarItem(placement: .navigationBarLeading) {
//                Button(action: {
//                    navManager.path.removeLast()
//                }) {
//                    Image(systemName: "chevron.left")
//                        .foregroundColor(.white)
//                        .font(.system(size: 20, weight: .medium))
//                        .frame(maxHeight: 30)
//                }
//            }
        }
        .onChange(of: linkCompleted) {
            sessionManager.linkCompleted = linkCompleted
            navManager.append(NavigationPathViews.home)
        }
    }
    
    func triggerLinkFlow() {
        isPresentingLink = true
//        linkCompleted = true
        return
    }

}

#Preview {
    LinkView()
        .environmentObject(NavigationPathManager())
}
