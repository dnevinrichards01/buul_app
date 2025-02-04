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
    @Published var otp: String? // don't store
    @Published var rhMfaMethod: RobinhoodMFAMethod? // don't store
    // also store password in keychain but don't load it into UserSessionManager
    // face ID can come later
    
}




