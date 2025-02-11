//
//  UserSessionManager.swift
//  accumate_app
//
//  Created by Nevin Richards on 2/4/25.
//

import Foundation
import SwiftUI
import LocalAuthentication

@MainActor
class UserSessionManager: ObservableObject {
    //    @Published var brokerage: Brokerages?
    @Published var sharedKeychainReadContext: LAContext = LAContext()
    @Published var otp: String?
    @Published var rhMfaMethod: RobinhoodMFAMethod?
    @Published var accessToken: String?
    @Published var refreshToken: String?
    @Published var password: String?
    @Published var password2: String?
    
    // page?
    @AppStorage("accumate.user.isLoggedIn") var isLoggedIn: Bool = false
    @AppStorage("accumate.user.phoneNumber") var phoneNumber: String?
    @AppStorage("accumate.user.email") var email: String?
    @AppStorage("accumate.user.unverifiedEmail") var unverifiedEmail: String?
    @AppStorage("accumate.user.fullName") var fullName: String?
    @AppStorage("accumate.user.brokerageName") var brokerageName: String?
    @AppStorage("accumate.user.etfSymbol") var etfSymbol: String?
    @AppStorage("accumate.user.brokerageCompleted") var brokerageCompleted: String?
    @AppStorage("accumate.user.link") var linkCompleted: Bool?
    // alter the back buttons on sign up page to let a user go backwards even if they were dropped in there with no navigationpath / history
    
    init() {
        sharedKeychainReadContext.localizedReason = "Authenticate to access your saved credentials"
    }
    
    func reset() async -> Bool {
        let accessDeleted = await accessTokenSet(nil)
        let refreshDeleted = await refreshTokenSet(nil)
        if accessDeleted && refreshDeleted {
            phoneNumber = nil
            email = nil
            unverifiedEmail = nil
            fullName = nil
            brokerageName = nil
            linkCompleted = nil
            etfSymbol = nil
            otp = nil
            rhMfaMethod = nil
            isLoggedIn = false
            accessToken = nil
            refreshToken = nil
            password = nil
            password2 = nil
            return true
        }
        return false
    }
    
    
    // login
    
    func refreshTokenGet() async -> String? {
        return await KeychainHelper.shared.getWithBiometrics(
            "accumate.user.refreshToken",
            context: sharedKeychainReadContext
        )
    }
    func refreshTokenSet(_ value: String?) async -> Bool {
        return await KeychainHelper.shared.setWithBiometrics(
            value,
            forKey: "accumate.user.refreshToken",
            context: sharedKeychainReadContext
        )
    }
    func accessTokenGet() async -> String? {
        return await KeychainHelper.shared.getWithBiometrics(
            "accumate.user.accessToken",
            context: sharedKeychainReadContext
        )
    }
    func accessTokenSet(_ value: String?) async -> Bool {
        return await KeychainHelper.shared.setWithBiometrics(
            value,
            forKey: "accumate.user.accessToken",
            context: sharedKeychainReadContext
        )
    }
    
    
    
    func refreshTokens() async -> Bool {
        if refreshToken == nil || accessToken == nil {
            return false
        }
        // refresh
        let newRefreshToken = "refresh"
        let newAccessToken = "access"
        refreshToken = newRefreshToken
        accessToken = newAccessToken
        let refreshTokenSaved = await refreshTokenSet(newRefreshToken)
        let accessTokenSaved = await accessTokenSet(newAccessToken)
        return refreshTokenSaved && accessTokenSaved
    }
    
    
    
    
    
    
    
    func loadSavedTokens() async {
        if self.accessToken == nil || self.refreshToken == nil {
            guard let refreshToken = await refreshTokenGet(), let accessToken = await accessTokenGet() else {
                isLoggedIn = false
                return
            }
            isLoggedIn = true
            self.accessToken = accessToken
            self.refreshToken = refreshToken
        }
    }
    
    
    // login / sign up navigation path helpers
    
    func signUpFlowPlacement() -> NavigationPathViews? {
//        print(phoneNumber, email, fullName, etfSymbol, brokerageName, isLoggedIn)
        if isLoggedIn == true {
            if let _ = phoneNumber, let _ = email, let _ = fullName, let _ = etfSymbol, let _ = brokerageName, let _ = brokerageCompleted, let _ = linkCompleted {
                return .home
            } else if let _ = phoneNumber, let _ = email, let _ = fullName, let _ = etfSymbol, let _ = brokerageName, let _ = brokerageCompleted {
                return .link
            } else if let _ = phoneNumber, let _ = email, let _ = fullName, let _ = etfSymbol, let _ = brokerageName {
                return .signUpRobinhoodSecurityInfo
            } else if let _ = phoneNumber, let _ = email, let _ = fullName, let _ = etfSymbol {
                return .signUpBrokerage
            } else if let _ = phoneNumber, let _ = email, let _ = fullName {
                return .signUpETFs
            } else {
                return nil
            }
        } else {
            if let _ = phoneNumber, let _ = email, let _ = fullName {
                return .signUpPassword
            } else if let _ = phoneNumber, let _ = email {
                return .signUpFullName
            } else if let _ = phoneNumber {
                return .signUpEmail
            } else {
                return .landing
            }
        }
    }
    
    func signUpFlowPlacementPaths(_ destinationPage: NavigationPathViews?) -> [NavigationPathViews] {
        let sharedPath: [NavigationPathViews] = [.accountCreated, .signUpETFs, .signUpBrokerage, .signUpRobinhoodSecurityInfo, .signUpRobinhood, .signUpMfaRobinhood, .link, .home]
        let signUpBasePath: [NavigationPathViews] = [.landing, .signUpPhone, .signUpEmail, .signUpEmailVerify, .signUpFullName, .signUpPassword]
        
//        print(destinationPage)
        
        if destinationPage == .signUpPhone {
            return Array(signUpBasePath[0..<2])
        } else if destinationPage == .signUpEmail {
            return Array(signUpBasePath[0..<3])
        } else if destinationPage == .signUpFullName {
            return Array(signUpBasePath[0..<5])
        } else if destinationPage == .signUpPassword {
            return signUpBasePath
        } else if destinationPage == .signUpETFs {
            return Array(sharedPath[0..<1])
        } else if destinationPage == .signUpBrokerage {
            return Array(sharedPath[0..<3])
        } else if destinationPage == .signUpRobinhoodSecurityInfo {
            return Array(sharedPath[0..<4])
        } else if destinationPage == .link {
            return Array(sharedPath[0..<7])
        } else if destinationPage == .home {
            return [.home]
        } else if destinationPage == .landing {
            return [.landing]
        } else {
            return [.landing]
        }
    }
    
    func updateSignUpFieldsState(password: String? = nil, password2: String? = nil,
                                 fullName: String? = nil, phoneNumber: String? = nil, email: String? = nil) {
        for signUpField in SignUpFields.allCases {
            switch signUpField {
            case .password:
                if let password = password {
                    self.password = password
                }
            case .password2:
                if let password2 = password2 {
                    self.password2 = password2
                }
            case .fullName:
                if let fullName = fullName {
                    self.fullName = fullName
                }
            case .phoneNumber:
                if let phoneNumber = phoneNumber {
                    self.phoneNumber = phoneNumber
                }
            case .email:
                if let email = email {
                    self.email = email
                }
            }
        }
    }
    
    
    
    // robinhood
    
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
    
    func setWithBiometrics(_ value: String?, forKey key: String, context: LAContext) async -> Bool {
        return await Task(priority: .userInitiated) {
            guard let value = value else {
                return delete(forKey: key)
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
                kSecAttrAccessControl as String: accessControl as Any,
                kSecUseAuthenticationContext as String: context
            ]
            if !delete(forKey: key) {
                return false
            }
            let status = SecItemAdd(query as CFDictionary, nil) // Add new item
            return status == errSecSuccess
        }.value
    }

    func set(_ value: String?, forKey key: String) async -> Bool {
        return await Task(priority: .userInitiated) {
            guard let value = value else {
                return delete(forKey: key)
            }
            
            let data = Data(value.utf8)
            
            let query: [String: Any] = [
                kSecClass as String: kSecClassGenericPassword,
                kSecAttrAccount as String: key,
                kSecValueData as String: data,
                kSecAttrAccessible as String: kSecAttrAccessibleWhenUnlockedThisDeviceOnly
            ]
            if !delete(forKey: key) {
                return false
            }
            let status = SecItemAdd(query as CFDictionary, nil) // Add new item
            return status == errSecSuccess
        }.value
    }


    func delete(forKey key: String) -> Bool {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: key
        ]
        let status = SecItemDelete(query as CFDictionary)
        return  status == errSecSuccess || status == errSecItemNotFound
    }
}
