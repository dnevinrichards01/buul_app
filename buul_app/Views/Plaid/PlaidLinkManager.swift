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
    @State var verifyCreatePlaidUserRetries: Int = 3
    
    @Published var linkTokenRequested: Bool = false
    @Published var linkToken: String? = nil
    @State var fetchLinkTokenRetries: Int = 3
    @Published var linkHandler: Handler?
    @Published var linkHandlerCreated: Bool = false
    
    @Published var linkSuccess: Bool = false
    @Published var isPresentingLink: Bool = false
    
    @Published var publicToken: String = ""
    @Published var exchangeRequested: Bool = false
    @Published var exchangeSuccess: Bool = false
    
    @Published var showAlert: Bool = false
    @Published var alertMessage: String = ""
    
    @Published var disableLoadingCircle = false
    
    @Published var updateInstitutionName: String?
    
    func reset() {
        plaidUserRequested = false
        plaidUserCreated = false
        linkTokenRequested = false
        linkToken = nil
        linkHandler = nil
        linkHandlerCreated = false
        linkSuccess = false
        isPresentingLink = false
//        publicToken = ""
//        exchangeRequested = false
//        exchangeSuccess = false
//        sessionManager.linkCompleted = nil
    }
    
    func requestCreatePlaidUser(_ sessionManager: UserSessionManager) async {
        await ServerCommunicator().callMyServer(
            path: "api/plaid/usercreate/",
            httpMethod: .post,
            sessionManager: sessionManager,
            responseType: SuccessErrorResponse.self
        ) { response in
            switch response {
            case .success:
                self.plaidUserRequested = true
            case .failure(let error):
//                if !sessionManager.refreshFailed {
                    self.alertMessage = error.errorMessage
                    self.showAlert = true
//                }
            }
        }
    }
    
    func verifyCreatePlaidUser(_ sessionManager: UserSessionManager, retries: Int = 5) async {
        await ServerCommunicator().callMyServer(
            path: "api/plaid/usercreate/",
            httpMethod: .get,
            sessionManager: sessionManager,
            responseType: SuccessErrorResponse.self
        ) { response in
            switch response {
            case .success(let responseData):
                if responseData.success == nil && responseData.error == nil {
                    if self.verifyCreatePlaidUserRetries > 0 {
                        self.verifyCreatePlaidUserRetries = self.verifyCreatePlaidUserRetries - 1
                        self.plaidUserRequested = false
                        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                            self.plaidUserRequested = true
                        }
                        return
                    } else {
                        self.alertMessage = ServerCommunicator.NetworkError.networkError.errorMessage
                        self.showAlert = true
                    }
                } else if let _ = responseData.error, responseData.success == nil {
                    self.alertMessage = ServerCommunicator.NetworkError.statusCodeError(400).errorMessage
                    self.showAlert = true
                } else {
                    self.plaidUserCreated = true
                }
            case .failure(let error):
                self.alertMessage = error.errorMessage
                self.showAlert = true
            }
        }
    }
    
    func getRequestLinkTokenParams() -> [String : Any]? {
        if let updateInstitutionName = updateInstitutionName {
            return [
                "update": true,
                "institution_name": updateInstitutionName as Any
            ]
        } else {
            return nil
        }
    }
    
    func requestLinkToken(_ sessionManager: UserSessionManager) async {
        await ServerCommunicator().callMyServer(
            path: "api/plaid/linktokencreate/",
            httpMethod: .post,
            params: getRequestLinkTokenParams(),
            sessionManager: sessionManager,
            responseType: SuccessErrorResponse.self
        ) { response in
            switch response {
            case .success:
                self.linkTokenRequested = true
            case .failure(let error):
                self.alertMessage = error.errorMessage
                self.showAlert = true
            }
        }
    }
    
    func fetchLinkToken(_ sessionManager: UserSessionManager, retries: Int = 3) async {
        await ServerCommunicator().callMyServer(
            path: "api/plaid/linktokencreate/",
            httpMethod: .get,
            sessionManager: sessionManager,
            responseType: SuccessErrorResponse.self
        ) { response in
            switch response {
            case .success(let responseData):
                if responseData.success == nil && responseData.error == nil {
                    if retries > 0 {
                        self.fetchLinkTokenRetries = self.fetchLinkTokenRetries - 1
                        self.linkTokenRequested = false
                        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                            self.linkTokenRequested = true
                        }
                        sleep(1)
                        return
                    }
//                    if !sessionManager.refreshFailed {
                        self.alertMessage = ServerCommunicator.NetworkError.networkError.errorMessage
                        self.showAlert = true
//                    }
                } else if let errorMessage = responseData.error, responseData.success == nil {
//                    if !sessionManager.refreshFailed {
                        self.alertMessage = errorMessage
                        self.showAlert = true
//                    }
                } else {
                    self.linkToken = responseData.success
                }
            case .failure(let error):
//                if !sessionManager.refreshFailed {
                    self.alertMessage = error.errorMessage
                    self.showAlert = true
//                }
            }
        }
    }
    
//    func requestExchangePublicToken(_ sessionManager: UserSessionManager?) async {
//        await ServerCommunicator().callMyServer(
//            path: "api/plaid/publictokenexchange/",
//            httpMethod: .post,
//            params: ["public_token" : self.publicToken],
//            sessionManager: sessionManager,
//            responseType: SuccessErrorResponse.self
//        ) { response in
//            switch response {
//            case .success:
//                self.exchangeRequested = true
//            case .failure(let error):
//                self.alertMessage = error.errorMessage
//                self.showAlert = true
//            }
//        }
//    }
    
//    func verifyExchangePublicToken(_ sessionManager: UserSessionManager, retries: Int = 5) async {
//        await ServerCommunicator().callMyServer(
//            path: "api/plaid/itemwebhook/",
//            httpMethod: .get,
//            sessionManager: sessionManager,
//            responseType: SuccessErrorResponse.self
//        ) { response in
//            switch response {
//            case .success(let responseData):
//                if responseData.success == nil && responseData.error == nil {
//                    if retries > 0 {
//                        sleep(1)
//                        self.verifyExchangePublicToken(sessionManager, retries: retries - 1)
//                        return
//                    }
//                    
////                    self.alertMessage = "We were unable to verify if Plaid recieved your submission due to network errors. Retry verification, or restart link connection?" + ServerCommunicator.NetworkError.networkError.errorMessage
////                    self.showAlert = true
//                    self.exchangeSuccess = true
//                } else if let _ = responseData.error, responseData.success == nil {
////                    self.alertMessage = ServerCommunicator.NetworkError.statusCodeError(400).errorMessage
////                    self.showAlert = true
//                    self.exchangeSuccess = true
//                } else {
//                    self.exchangeSuccess = true
//                }
//            case .failure(let error):
////                if !sessionManager.refreshFailed {
//                    self.showAlert = true
//                    self.alertMessage = error.errorMessage
////                }
//                switch error {
//                case .statusCodeError(let status):
//                    if status == 401 {
//                        self.alertMessage = "Your session has expired. To retrieve updated information, please logout then sign in."
//                    }
//                default: break
//                }
//                
//            }
//        }
//    }
//    
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
    
    func createLinkHandler(_ linkToken: String, sessionManager: UserSessionManager) -> Result<Handler, Plaid.CreateError>? {
        var linkTokenConfig = LinkTokenConfiguration(token: linkToken) { success in
            self.linkSuccess = true
//            self.publicToken = success.publicToken
        }
        linkTokenConfig.onExit = { linkExit in // i swapped exit and event --> can't make sandbox error
            Task { @MainActor in
                print(linkExit)
                //            if !sessionManager.refreshFailed {
                //                self.showAlert = false
                //            DispatchQueue.main.async {
                self.disableLoadingCircle = true
                self.reset()
//                self.alertMessage = "Link flow was exited before completion."
//                print(self.showAlert)
//                self.showAlert = true
//                print(self.showAlert)
            }
//            }
//            }
        }
        linkTokenConfig.onEvent = { linkEvent in
//            print("EXIT????: ", linkEvent.eventName.description)
//            if linkEvent.eventName.description == "EXIT" {
//                print("handling exit")
//                print("showAlert", self.showAlert)
////                DispatchQueue.main.async {
//                    self.alertMessage = "Link flow was exited before completion."
//                    self.showAlert = true
////                }
//            }
//            print("link event. \(linkEvent)")
        }
        return Plaid.create(linkTokenConfig)
    }

}

struct SuccessErrorResponse: Codable {
    let success: String?
    let error: String?
}

