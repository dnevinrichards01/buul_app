//
//  UserSessionManager.swift
//  accumate_app
//
//  Created by Nevin Richards on 2/4/25.
//

import Foundation
import SwiftUI
import LocalAuthentication

class UserSessionManager: ObservableObject {
    
    
//    @Published var brokerage: Brokerages?
    @Published var sharedKeychainReadContext: LAContext
    @Published var linkedBankAccounts: [BankAccounts]?
    @Published var etf: ETF?
    @Published var otp: String?
    @Published var rhMfaMethod: RobinhoodMFAMethod?
    @Published var isLoggedIn: Bool?
    @Published var accessToken: String?
    @Published var refreshToken: String?
    
    // page?
    @AppStorage("accumate.user.phoneNumber") var phoneNumber: String?
    @AppStorage("accumate.user.emailAddress") var emailAddress: String?
    @AppStorage("accumate.user.fullName") var fullName: String?
    @AppStorage("accumate.user.brokerageData") var brokerageData: String?
    @AppStorage("accumate.user.etfData") var etfData: String?
    @AppStorage("accumate.user.link") var linkCompleted: Bool?
    // alter the back buttons on sign up page to let a user go backwards even if they were dropped in there with no navigationpath / history
    
    var brokerage: Brokerages? {
        get {
            guard let data = brokerageData?.data(using: .utf8) else { return nil }
            return try? JSONDecoder().decode(Brokerages.self, from: data)
        }
        set {
            let jsonData = try? JSONEncoder().encode(newValue)
            brokerageData = jsonData?.base64EncodedString()
        }
    }
    
    init() {
        sharedKeychainReadContext = LAContext()
        sharedKeychainReadContext.localizedReason = "Authenticate to access your saved credentials"
        brokerage = loadBrokerage()
        etf = loadEtf()
        isLoggedIn = false
    }
    
    
    func brokerageSet(_ value: Brokerages) -> Bool {
        if let jsonData = try? JSONEncoder().encode(value),
           let jsonString = String(data: jsonData, encoding: .utf8) {
            brokerageData = jsonString
            return true
        }
        return false
    }
    func loadBrokerage() -> Brokerages? {
        guard let jsonData = brokerageData?.data(using: .utf8) else { return nil }
        return try? JSONDecoder().decode(Brokerages.self, from: jsonData)
    }
    
    func etfSet(_ value: ETF) -> Bool {
        if let jsonData = try? JSONEncoder().encode(value),
           let jsonString = String(data: jsonData, encoding: .utf8) {
            etfData = jsonString
            return true
        }
        return false
    }
    func loadEtf() -> ETF? {
        guard let jsonData = etfData?.data(using: .utf8) else { return nil }
        return try? JSONDecoder().decode(ETF.self, from: jsonData)
    }
    
    func refreshTokenGet() async -> String? {
        return await KeychainHelper.shared.getWithBiometrics(
            "accumate.user.refreshToken",
            context: sharedKeychainReadContext
        )
    }
    func refreshTokenSet(_ value: String) async -> Bool {
        return await KeychainHelper.shared.setWithBiometrics(value, forKey: "accumate.user.refreshToken")
    }
    func accessTokenGet() async -> String? {
        return await KeychainHelper.shared.getWithBiometrics(
            "accumate.user.accessToken",
            context: sharedKeychainReadContext
        )
    }
    func accessTokenSet(_ value: String) async -> Bool {
        return await KeychainHelper.shared.setWithBiometrics(value, forKey: "accumate.user.accessToken")
    }
    
    // do this after Login flow too, to redirect ppl to completing sign up process
    func login() async -> NavigationPathViews {
        guard let refreshToken = await refreshTokenGet(), let accessToken = await accessTokenGet() else {
            if let _ = phoneNumber, let _ = emailAddress, let _ = fullName {
                return .signUpETFs
            } else if let _ = phoneNumber, let _ = emailAddress {
                return .signUpFullName
            } else if let _ = phoneNumber {
                return .signUpEmail
            } else {
                return .landing
            }
        }
        
        isLoggedIn = true
        self.accessToken = accessToken
        self.refreshToken = refreshToken
        
        if let _ = brokerage, let _ = etf, let _ = linkCompleted {
            return .home
        } else if let _ = brokerage, let _ = etf {
            return .link
        } else if let _ = etf {
            return .signUpBrokerage
        } else {
            return .signUpETFs
        }
        
    }
}



class KeychainHelper {
    
    static let shared = KeychainHelper()
    
    func get(_ key: String) async -> String? {
        return await withUnsafeContinuation { continuation in
            let query: [String: Any] = [
                kSecClass as String: kSecClassGenericPassword,
                kSecAttrAccount as String: key,
                kSecReturnData as String: true,
                kSecMatchLimit as String: kSecMatchLimitOne
            ]
            var dataTypeRef: AnyObject?
            let status = SecItemCopyMatching(query as CFDictionary, &dataTypeRef)
            
            if status == errSecSuccess, let data = dataTypeRef as? Data {
                continuation.resume(returning: String(data: data, encoding: .utf8))
            } else {
                continuation.resume(returning: nil)
            }
        }
    }

    func getWithBiometrics(_ key: String, context: LAContext) async -> String? {
        return await withUnsafeContinuation { continuation in
            let query: [String: Any] = [
                kSecClass as String: kSecClassGenericPassword,
                kSecAttrAccount as String: key,
                kSecReturnData as String: true,
                kSecMatchLimit as String: kSecMatchLimitOne,
                kSecUseAuthenticationContext as String: context
            ]
            var dataTypeRef: AnyObject?
            let status = SecItemCopyMatching(query as CFDictionary, &dataTypeRef)
            
            if status == errSecSuccess, let data = dataTypeRef as? Data {
                continuation.resume(returning: String(data: data, encoding: .utf8))
            } else {
                continuation.resume(returning: nil)
            }
        }
    }
    
    func setWithBiometrics(_ value: String?, forKey key: String) async -> Bool {
        return await Task(priority: .userInitiated) {
            guard let value = value else {
                return await delete(forKey: key)
            }
            
            let data = Data(value.utf8)
            
            let accessControl = SecAccessControlCreateWithFlags(
                nil,
                kSecAttrAccessibleWhenUnlockedThisDeviceOnly,
                .biometryCurrentSet, // Requires Face ID / Touch ID authentication
                nil
            )
            let query: [String: Any] = [
                kSecClass as String: kSecClassGenericPassword,
                kSecAttrAccount as String: key,
                kSecValueData as String: data,
                kSecAttrAccessControl as String: accessControl as Any
            ]
            if await delete(forKey: key) {
                return false
            }
            let status = SecItemAdd(query as CFDictionary, nil) // Add new item
            if status == errSecSuccess {
                return true
            } else {
                return false
            }
        }.value
    }

    func set(_ value: String?, forKey key: String) async -> Bool {
        return await Task(priority: .userInitiated) {
            guard let value = value else {
                return await delete(forKey: key)
            }
            
            let data = Data(value.utf8)
            
            let query: [String: Any] = [
                kSecClass as String: kSecClassGenericPassword,
                kSecAttrAccount as String: key,
                kSecValueData as String: data,
                kSecAttrAccessible as String: kSecAttrAccessibleWhenUnlockedThisDeviceOnly
            ]
            if await delete(forKey: key) {
                return false
            }
            let status = SecItemAdd(query as CFDictionary, nil) // Add new item
            if status == errSecSuccess {
                return true
            } else {
                return false
            }
        }.value
    }


    func delete(forKey key: String) async -> Bool {
        return await Task(priority: .userInitiated) {
            let query: [String: Any] = [
                kSecClass as String: kSecClassGenericPassword,
                kSecAttrAccount as String: key
            ]
            let status = SecItemDelete(query as CFDictionary)
            if status == errSecSuccess || status == errSecItemNotFound {
                return true
            } else {
                return false
            }
        }.value
    }
}
