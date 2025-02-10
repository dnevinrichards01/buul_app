//
//  PlaidLinkViewController.swift
//  accumate_app
//
//  Created by Nevin Richards on 1/30/25.
//

import UIKit
import LinkKit

@MainActor
class PlaidLinkManager: ObservableObject {
    let communicator = ServerCommunicator()
    var linkToken: String?
    var config: LinkTokenConfiguration?
    var controller: LinkController?
    var retries: Int = 3
    var linkSuccess: Bool = false
    
    func createLinkConfiguration() async {
        guard let linkToken = linkToken else {
            return
        }
        var linkTokenConfig = LinkTokenConfiguration(token: linkToken) { success in
            self.linkSuccess = true
//                var response: SwapPublicTokenResponse? = nil
//                var attempts = self.retries
//                while (response == nil || attempts > 0) {
//                    response = self.exchangePublicTokenForAccessToken(success.publicToken)
//                    attempts = attempts - 1
//                }
        }
        linkTokenConfig.onExit = { linkEvent in
            print("User exited link early. \(linkEvent)")
        }
        linkTokenConfig.onEvent = { linkExit in
            print("Hit an event \(linkExit.eventName)")
        }
        config = linkTokenConfig
    }
    
    func startLinkWasPressed(_ sender: Any) {
        // Handle the button being clicked
//        guard let linkToken = linkToken, let config = config else {
//            // tell user to press it again somehow?
//            return
//        }
//        let createResult = Plaid.create(config)
//        switch createResult {
//        case .failure(let createError):
//            return // some error?
////            print("Link Creation Error: \(createError.localizedDescription)")
//        case .success(let handler):
//            controller = LinkController(handler: handler)
//            
////            handler.open(presentUsing: PresentationMethod.viewController(controller))
//        }
    }
    
    func exchangePublicTokenForAccessToken(_ publicToken: String) async -> SwapPublicTokenResponse? {
//        do {
//            let swapPublicTokenResponse = try self.communicator.callMyServer(
//                path: "/plaid/linktokencreate/",
//                httpMethod: .post,
//                params: ["public_token": publicToken],
//                responseType: SwapPublicTokenResponse.self
//            ) { result in
//                switch result {
//                case .success(let responseData):
//                    print("Success: \(responseData)")
//                case .failure(let error):
//                    print("Request failed with error: \(error)")
//                }
//            }
////            self.navigationController?.popViewController(animated: true)
//            return swapPublicTokenResponse
//        } catch {
//            return nil
//        }
//         { (result: Result<SwapPublicTokenResponse, ServerCommunicator.Error>) in
//            switch result {
//            case .success(let response):
//                if response.success {
//
//                } else {
//                    print ("Got a failed success \(response)")
//                }
//            case .failure(let error):
//                print ("Got an error \(error)")
//            }
//        }
        return nil

    }
    
    func fetchLinkToken() async -> String? {
        // Fetch a link token from our server
//        do {
//            let fetchLinkTokenResponse = try self.communicator.callMyServer(
//                path: "/user/register/",
//                httpMethod: .post,
//                params: nil,
//                responseType: LinkTokenCreateResponse.self
//            )
//            let fetchLinkTokenGetResponse = try self.communicator.callMyServer(
//                path: "/server/generate_link_token",
//                httpMethod: .get,
//                params: nil,
//                responseType: LinkTokenCreateResponse.self//LinkTokenCreateGetResponse.self
//            )
//            self.linkToken = fetchLinkTokenGetResponse.linkToken
////            self.startLinkButton.isEnabled = true
//            return nil
//        } catch {
//            return "Server error. Return to this page to try again or contact Accumate"
//        }
        return nil
    }
    
    private func createPlaidUser() {
        
        return
    }
}
