//
//  PlaidLinkViewController.swift
//  accumate_app
//
//  Created by Nevin Richards on 1/30/25.
//

import UIKit
import LinkKit

class PlaidLinkViewController: UIViewController {
    @IBOutlet var startLinkButton: UIButton!
    let communicator = ServerCommunicator()
    var linkToken: String?
    var handler: Handler?
    var retries: Int = 3
    
    
    private func createLinkConfiguration(linkToken: String) -> LinkTokenConfiguration {
        var linkTokenConfig = LinkTokenConfiguration(token: linkToken) { success in
            var response: SwapPublicTokenResponse? = nil
            var attempts = self.retries
            while (response == nil || attempts > 0) {
                response = self.exchangePublicTokenForAccessToken(success.publicToken)
                attempts = attempts - 1
            }
        }
        linkTokenConfig.onExit = { linkEvent in
            print("User exited link early. \(linkEvent)")
        }
        linkTokenConfig.onEvent = { linkExit in
            print("Hit an event \(linkExit.eventName)")
        }
        return linkTokenConfig
    }
    
    @IBAction func startLinkWasPressed(_ sender: Any) {
        // Handle the button being clicked
        guard let linkToken = linkToken else {
            // tell user to press it again somehow?
            return
        }
        let config = createLinkConfiguration(linkToken: linkToken)
        let creationResult = Plaid.create(config)
        switch creationResult {
        case .success(let handler):
            self.handler = handler
            handler.open(presentUsing: .viewController(self))
        case .failure(let error):
            // tell user to press it again somehow
            print("Handler creation error\(error)")
        }
    }
    
    private func exchangePublicTokenForAccessToken(_ publicToken: String) -> SwapPublicTokenResponse? {
        do {
            let swapPublicTokenResponse = try self.communicator.callMyServer(
                path: "/plaid/linktokencreate/",
                httpMethod: .post,
                params: ["public_token": publicToken],
                responseType: SwapPublicTokenResponse.self
            )
            self.navigationController?.popViewController(animated: true)
            return swapPublicTokenResponse
        } catch {
            return nil
        }
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

    }
    
    private func fetchLinkToken() {
        // Fetch a link token from our server
        do {
            let fetchLinkTokenResponse = try self.communicator.callMyServer(
                path: "/server/generate_link_token",
                httpMethod: .post,
                params: nil,
                responseType: LinkTokenCreateResponse.self
            )
            self.linkToken = fetchLinkTokenResponse.linkToken
            self.startLinkButton.isEnabled = true
            return
        } catch {
            return
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.startLinkButton.isEnabled = false
        fetchLinkToken()
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
