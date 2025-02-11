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
    @StateObject private var linkManager: PlaidLinkManager = PlaidLinkManager()
    
    
    var body: some View {
        PlaidLinkPageBackground(isPresentingLink: $linkManager.isPresentingLink)
            .padding()
            .fullScreenCover(
                isPresented: $linkManager.isPresentingLink,
                onDismiss: { linkManager.isPresentingLink = false },
                content: {
                    if let linkController = linkManager.linkController {
                        linkController
                            .ignoresSafeArea(.all)
                    } else {
                        Text("Error: LinkController not initialized")
                    }
                }
            )
            .alert(linkManager.alertMessage, isPresented: $linkManager.showAlert) {
                if linkManager.showAlert {
                    Button("OK", role: .cancel) { linkManager.showAlert = false }
                }
            }
            .onChange(of: linkManager.showAlert) { oldValue, newValue in
                if oldValue && !newValue {
                    linkManager.reset(sessionManager: sessionManager)
                }
            }
            .onAppear {
                print("user create request")
                linkManager.requestCreatePlaidUser(sessionManager.accessToken)
            }
            .onChange(of: linkManager.plaidUserRequested) {
                Task {
                    if !linkManager.plaidUserRequested { return }
                    print("user create verify")
                    try? await Task.sleep(nanoseconds: 1_500_000_000)
                    linkManager.verifyCreatePlaidUser(sessionManager.accessToken)
                }
            }
            .onChange(of: linkManager.plaidUserCreated) {
                Task {
                    if !linkManager.plaidUserCreated { return }
                    print("token request begin")
                    linkManager.requestLinkToken(sessionManager.accessToken)
                    print("token request complete")
                }
            }
            .onChange(of: linkManager.linkTokenRequested) {
                Task {
                    if !linkManager.linkTokenRequested { return }
                    print("token fetch begin")
                    try? await Task.sleep(nanoseconds: 1_500_000_000)
                    linkManager.fetchLinkToken(sessionManager.accessToken)
                    print("token fetch complete")
                }
            }
            .onChange(of: linkManager.linkToken) {
                guard let linkToken = linkManager.linkToken else { return }
                print("handler")
                let createResult = linkManager.createLinkHandler(linkToken)
                switch createResult {
                case .failure(let createError):
                    print("Link Creation Error: \(createError.localizedDescription)")
                case .success(let handler):
                    linkManager.linkController = LinkController(handler: handler)
                    linkManager.linkControllerCreated = true
                case .none:
                    print("none")
                    //                also failure
                }
            }
            .onChange(of: linkManager.linkControllerCreated) {
                print("link flow")
                if !linkManager.linkControllerCreated { return }
                linkManager.isPresentingLink = true
            }
            .onChange(of: linkManager.linkSuccess) {
                if !linkManager.linkSuccess { return }
                print("link success and request exchange")
                linkManager.isPresentingLink = false
                linkManager.requestExchangePublicToken(sessionManager.accessToken)
            }
            .onChange(of: linkManager.exchangeRequested) {
                Task {
                    if !linkManager.exchangeRequested { return }
                    print("exchange verify")
                    try? await Task.sleep(nanoseconds: 1_500_000_000)
                    linkManager.verifyExchangePublicToken(sessionManager.accessToken)
                }
            }
            .onChange(of: linkManager.exchangeSuccess) {
                if !linkManager.exchangeSuccess { return }
                print("flow completed")
                sessionManager.linkCompleted = true
                navManager.append(.home)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color.black)
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarBackButtonHidden()
    }
}


#Preview {
    LinkView()
        .environmentObject(NavigationPathManager())
        .environmentObject(UserSessionManager())
        .environmentObject(PlaidLinkManager())
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
