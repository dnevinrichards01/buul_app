//
//  NavPathModel.swift
//  accumate_app
//
//  Created by Nevin Richards on 12/12/24.
//
import SwiftUI

class NavigationPathManager: ObservableObject {
    @Published var path: NavigationPath = NavigationPath()
    func resetNavigation() {
        path = NavigationPath()
    }
}

class UserSessionManager: ObservableObject {
    @Published var isLoggedIn: Bool = false
    @Published var brokerage: Brokerages?
    @Published var linkedBankAccounts: [BankAccounts]?
    @Published var etf: ETF?
    @Published var phoneNumber: String? // user defaults or app storage
    @Published var fullName: String? // user defaults or app storage
    @Published var emailAddress: String? // user defaults or app storage
    @Published var accessToken: String? // keychain
    @Published var refreshToken: String? // keychain
    @Published var username: String? // keychain
    // also store password in keychain. add keychain / autofill support to remember uname/pword
    // face ID can come later
    
}




