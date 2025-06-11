//
//  LinkView.swift
//  accumate_app
//
//  Created by Nevin Richards on 12/13/24.
//

import SwiftUI
import LinkKit

struct LinkViewUpdate: View {
    @EnvironmentObject var linkManager: PlaidLinkManager
    var goBackNPagesToRedoEntries: Int
    var goBackNPagesIfCompleted: Int
    var nextPage: NavigationPathViews?
    var isSignUp: Bool
    
    var body: some View {
        LinkViewBase(
            goBackNPagesToRedoEntries: goBackNPagesToRedoEntries,
            goBackNPagesIfCompleted: goBackNPagesIfCompleted,
            nextPage: nextPage,
            isSignUp: isSignUp,
            linkManager: linkManager
        )
    }
}

struct LinkView: View {
    @StateObject var linkManager: PlaidLinkManager = PlaidLinkManager()
    var goBackNPagesToRedoEntries: Int
    var goBackNPagesIfCompleted: Int
    var nextPage: NavigationPathViews?
    var isSignUp: Bool
    
    var body: some View {
        LinkViewBase(
            goBackNPagesToRedoEntries: goBackNPagesToRedoEntries,
            goBackNPagesIfCompleted: goBackNPagesIfCompleted,
            nextPage: nextPage,
            isSignUp: isSignUp,
            linkManager: linkManager
        )
    }
}

struct LinkViewBase: View {
    @EnvironmentObject var navManager : NavigationPathManager
    @EnvironmentObject var sessionManager: UserSessionManager
    
    
    var goBackNPagesToRedoEntries: Int
    var goBackNPagesIfCompleted: Int
    @State var nextPage: NavigationPathViews?
    var isSignUp: Bool
    @ObservedObject var linkManager: PlaidLinkManager
    
    var body: some View {
        PlaidLinkPageBackground(
            isPresentingLink: $linkManager.isPresentingLink,
            disableLoadingCircle: $linkManager.disableLoadingCircle,
            nextPage: $nextPage,
            goBackNPagesIfCompleted: goBackNPagesIfCompleted,
            isSignUp: isSignUp,
            linkManager: linkManager
        )
        .padding()
        .fullScreenCover(
            isPresented: $linkManager.isPresentingLink,
            onDismiss: {
                DispatchQueue.main.async {
                    linkManager.isPresentingLink = false
                }
            },
            content: {
                if let handler = linkManager.linkHandler {
                    PlaidViewControllerWrapper(handler: handler)
                }
            }
        )
        .onOpenURL { url in
            if let _ = Utils.extractCode(from: url) {
                //oauthCode = code
                // Call server to exchange code, update UI, etc.
            }
        }
        .alert(linkManager.alertMessage, isPresented: $linkManager.showAlert) {
            Button("OK", role: .cancel) {
                linkManager.showAlert = false
                linkManager.reset()
                linkManager.disableLoadingCircle = true
            }
            if sessionManager.refreshFailed {
                Button("Log Out", role: .destructive) {
                    Task {
                        linkManager.showAlert = false
                        linkManager.reset()
                        linkManager.disableLoadingCircle = true
                        
                        sessionManager.refreshFailed = false
                        _ = await sessionManager.resetComplete()
                        navManager.reset(views: [.landing])
                    }
                }
            }
        }
        .onAppear {
            Task.detached {
                await linkManager.requestCreatePlaidUser(sessionManager)
            }
        }
        .onChange(of: linkManager.plaidUserRequested) {
            guard linkManager.plaidUserRequested else { return }
            Task.detached {
                await linkManager.verifyCreatePlaidUser(sessionManager)
            }
        }
        .onChange(of: linkManager.plaidUserCreated) {
            guard linkManager.plaidUserCreated else { return }
            Task.detached {
                await linkManager.requestLinkToken(sessionManager)
            }
        }
        .onChange(of: linkManager.linkTokenRequested) {
            guard linkManager.linkTokenRequested else { return }
            Task.detached {
                await linkManager.fetchLinkToken(sessionManager)
            }
        }
        .onChange(of: linkManager.linkToken) {
            guard let linkToken = linkManager.linkToken else { return }
            let createResult = linkManager.createLinkHandler(linkToken, sessionManager: sessionManager)
            
            switch createResult {
            case .failure:
//                if !sessionManager.refreshFailed {
                    linkManager.alertMessage = "An error occured while preparing to connect to Plaid Link. Press ok to retry."
                    linkManager.showAlert = true
//                }
            case .success(let handler):
                linkManager.linkHandler = handler
                linkManager.linkHandlerCreated = true
            case .none:
//                if !sessionManager.refreshFailed {
                    linkManager.alertMessage = "An error occured while preparing to connect to Plaid Link. Press ok to retry."
                    linkManager.showAlert = true
//                }
            }
        }
        .onChange(of: linkManager.linkHandlerCreated) {
            if !linkManager.linkHandlerCreated { return }
            linkManager.isPresentingLink = true
        }
        .onChange(of: linkManager.linkSuccess) {
            if !linkManager.linkSuccess { return }
            linkManager.isPresentingLink = false
            sessionManager.linkCompleted = true
            linkManager.disableLoadingCircle = true
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.black)
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden()
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                if !isSignUp {
                    Button(action: {
                        linkManager.reset()
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
}


#Preview {
    LinkView(
        goBackNPagesToRedoEntries: 0,
        goBackNPagesIfCompleted: 0,
        nextPage: .home,
        isSignUp: false
    )
    .environmentObject(NavigationPathManager())
    .environmentObject(UserSessionManager())
    .environmentObject(PlaidLinkManager())
}
