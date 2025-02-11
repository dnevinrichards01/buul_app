//
//  PlaidLinkManager.swift
//  accumate_app
//
//  Created by Nevin Richards on 2/10/25.
//

import SwiftUI
import LinkKit

@MainActor
class PlaidLinkManager: ObservableObject {
    @Published var plaidUserRequested: Bool = false
    @Published var plaidUserCreated: Bool = false
    
    @Published var linkTokenRequested: Bool = false
    @Published var linkToken: String? = nil
    @Published var linkController: LinkController?
    @Published var linkControllerCreated: Bool = false
    
    @Published var linkSuccess: Bool = false
    @Published var isPresentingLink: Bool = false
    
    @Published var publicToken: String = ""
    @Published var exchangeRequested: Bool = false
    @Published var exchangeSuccess: Bool = false
    
    @Published var showAlert: Bool = false
    @Published var alertMessage: String = ""
    
    func reset(sessionManager: UserSessionManager) {
        plaidUserRequested = false
        plaidUserCreated = false
        linkTokenRequested = false
        linkToken = nil
        linkController = nil
        linkControllerCreated = false
        linkSuccess = false
        isPresentingLink = false
        publicToken = ""
        exchangeRequested = false
        exchangeSuccess = false
        sessionManager.linkCompleted = nil
        
        requestCreatePlaidUser(sessionManager.accessToken)
    }
    
    func requestCreatePlaidUser(_ accessToken: String?) {
        ServerCommunicator().callMyServer(
            path: "api/plaid/usercreate/",
            httpMethod: .post,
            accessToken: accessToken,
            responseType: SuccessErrorResponse.self
        ) { response in
            switch response {
            case .success:
                self.plaidUserRequested = true
            case .failure(let error):
                self.alertMessage = error.errorMessage
                self.showAlert = true
            }
        }
    }
    
    func verifyCreatePlaidUser(_ accessToken: String?) {
        ServerCommunicator().callMyServer(
            path: "api/plaid/usercreate/",
            httpMethod: .get,
            accessToken: accessToken,
            responseType: SuccessErrorResponse.self
        ) { response in
            switch response {
            case .success(let responseData):
                if responseData.success == nil && responseData.error == nil {
                    self.alertMessage = "user create not yet ready"
                    self.showAlert = true
                } else if responseData.success == nil {
                    self.alertMessage = "Server error: "
                    self.showAlert = true
                } else {
                    self.plaidUserRequested = true
                }
                self.plaidUserCreated = true
            case .failure(let error):
                self.alertMessage = error.errorMessage
                self.showAlert = true
            }
        }
    }
    
    func requestLinkToken(_ accessToken: String?) {
        ServerCommunicator().callMyServer(
            path: "api/plaid/linktokencreate/",
            httpMethod: .post,
            accessToken: accessToken,
            responseType: SuccessErrorResponse.self
        ) { response in
            print("request closure")
            switch response {
            case .success:
                self.linkTokenRequested = true
            case .failure(let error):
                self.alertMessage = error.errorMessage
                self.showAlert = true
            }
        }
    }
    
    func fetchLinkToken(_ accessToken: String?) {
        ServerCommunicator().callMyServer(
            path: "api/plaid/linktokencreate/",
            httpMethod: .get,
            accessToken: accessToken,
            responseType: SuccessErrorResponse.self
        ) { response in
            print("fetch closure")
            switch response {
            case .success(let responseData):
                if responseData.success == nil && responseData.error == nil {
                    self.alertMessage = "token create not yet ready"
                    self.showAlert = true
                } else if responseData.success == nil {
                    self.alertMessage = "success is nil but not failure with a success code?"
                    self.showAlert = true
                } else {
                    self.linkToken = responseData.success
                }
            case .failure(let error):
                self.alertMessage = error.errorMessage
                self.showAlert = true
            }
        }
    }
    
    func requestExchangePublicToken(_ accessToken: String?) {
        ServerCommunicator().callMyServer(
            path: "api/plaid/publictokenexchange/",
            httpMethod: .post,
            params: ["public_token" : self.publicToken],
            accessToken: accessToken,
            responseType: SuccessErrorResponse.self
        ) { response in
            switch response {
            case .success:
                self.exchangeRequested = true
            case .failure(let error):
                self.alertMessage = error.errorMessage
                self.showAlert = true
            }
        }
    }
    
    func verifyExchangePublicToken(_ accessToken: String?) {
        ServerCommunicator().callMyServer(
            path: "api/plaid/publictokenexchange/",
            httpMethod: .get,
            accessToken: accessToken,
            responseType: SuccessErrorResponse.self
        ) { response in
            switch response {
            case .success(let responseData):
                if responseData.success == nil && responseData.error == nil {
                    self.alertMessage = "exchange public token not yet ready"
                    self.showAlert = true
                } else if responseData.success == nil {
                    self.alertMessage = "success is nil but not failure with a success code?"
                    self.showAlert = true
                } else {
                    self.linkToken = responseData.success
                }
                self.exchangeSuccess = true
            case .failure(let error):
                self.alertMessage = error.errorMessage
                self.showAlert = true
            }
        }
    }
    
//    func delayedFunction(
//        _ webRequest: @escaping () async -> Any?,
//        nanoSeconds: UInt64,
//        oldVal: Any,
//        newVal: Binding<Any>,
//        retries: Int = 3
//    ) async -> Any? {
//
//        var attemptsLeft = retries
//
//        while newVal.wrappedValue as? Equatable == oldVal as? Equatable && attemptsLeft > 0 {
//            let result = await webRequest() // Await the async request
//            try? await Task.sleep(nanoseconds: nanoSeconds) // Sleep for given delay
//            attemptsLeft -= 1
//        }
//
//        return attemptsLeft > 0 ? newVal.wrappedValue : nil
//    }
    
    func createLinkHandler(_ linkToken: String) -> Result<Handler, Plaid.CreateError>? {
        var linkTokenConfig = LinkTokenConfiguration(token: linkToken) { success in
            self.linkSuccess = true
            self.publicToken = success.publicToken
        }
        linkTokenConfig.onExit = { linkEvent in
            print("User exited link early. \(linkEvent)")
        }
        linkTokenConfig.onEvent = { linkExit in
            print("Hit an event \(linkExit.eventName)")
        }
        return Plaid.create(linkTokenConfig)
    }

}

struct SuccessErrorResponse: Codable {
    let success: String?
    let error: String?
}

