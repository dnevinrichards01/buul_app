//
//  UserSessionManager.swift
//  accumate_app
//
//  Created by Nevin Richards on 2/4/25.
//

import Foundation
import SwiftUI
import LocalAuthentication
import CoreData

@MainActor
class UserSessionManager: ObservableObject {
    @Published var otp: String?
    @Published var accessToken: String?
    @Published var refreshToken: String?
    @Published var password: String?
    @Published var password2: String?
    
    @Published var refreshFailed: Bool = false
    @Published var refreshFailedMessage: String = ""
    
    var sharedKeychainReadContext: LAContext = LAContext()
    
    var verificationEmail: String?
    var verificationPhoneNumber: String?
    var stringToVerify: String?
    var boolToVerify: Bool?
    
    var brokerageEmail: String?
    var brokeragePassword: String?
    var robinhoodMFAType: RobinhoodMFAMethod?
    
    // page?
    @AppStorage("buul.user.preAccountId") var _preAccountId: Int?
    @AppStorage("buul.user.isLoggedIn") var isLoggedIn: Bool = false
    @AppStorage("buul.user.phoneNumber") var phoneNumber: String?
    @AppStorage("buul.user.email") var email: String?
    @AppStorage("buul.user.unverifiedEmail") var unverifiedEmail: String?
    @AppStorage("buul.user.fullName") var fullName: String?
    @AppStorage("buul.user.brokerageName") var brokerageName: String?
    @AppStorage("buul.user.etfSymbol") var etfSymbol: String?
    @AppStorage("buul.user.brokerageCompleted") var brokerageCompleted: Bool = false
    @AppStorage("buul.user.link") var linkCompleted: Bool = false
    
    var preAccountId: Int? {
        get {
            if _preAccountId == nil {
                let newPreAccountId: Int =  Int.random(in: 10_000_000...99_999_999)
                _preAccountId = newPreAccountId
                return _preAccountId
            } else {
                return _preAccountId
            }
        }
        set {
            _preAccountId = newValue
        }
    }
    
    @AppStorage("buul.user.plaidItems") var plaidItemsData: String = "[]"
    var plaidItems: [String] {
        get {
            (try? JSONDecoder().decode([String].self, from: Data(plaidItemsData.utf8))) ?? []
        }
        set {
            if let encoded = try? JSONEncoder().encode(newValue) {
                plaidItemsData = String(data: encoded, encoding: .utf8) ?? "[]"
            }
        }
    }
    
    @AppStorage("buul.user.cardRecommendationsData") var cardRecommendationsData: String?
    var cardRecommendations: SpendingCategoriesResponseSuccess? {
        get {
            if let jsonString = cardRecommendationsData,
               let data = jsonString.data(using: .utf8) {
                return try? JSONDecoder().decode(SpendingCategoriesResponseSuccess.self, from: data)
            } else {
                return nil
            }
        }
        set {
            if let data = try? JSONEncoder().encode(newValue) {
                cardRecommendationsData = String(data: data, encoding: .utf8)
            }
        }
    }
    
    init() {
        sharedKeychainReadContext.localizedReason = "Authenticate to access your saved credentials"
    }
    
    func reset() -> Bool {
        phoneNumber = nil
        email = nil
        unverifiedEmail = nil
        fullName = nil
        brokerageName = nil
        linkCompleted = false
        etfSymbol = nil
        otp = nil
        isLoggedIn = false
        accessToken = nil
        refreshToken = nil
        password = nil
        password2 = nil
        verificationEmail = nil
        verificationPhoneNumber = nil
        stringToVerify = nil
        boolToVerify = nil
        brokerageEmail = nil
        brokeragePassword = nil
        brokerageCompleted = false
        robinhoodMFAType = nil
        preAccountId = nil
        plaidItems = []
        CoreDataStockManager.shared.clearAll()
        return true
    }
    
    @MainActor
    func resetComplete() async -> Bool {
        let accessDeleted = await accessTokenSet(nil)
        let refreshDeleted = await refreshTokenSet(nil)
        if accessDeleted && refreshDeleted {
            phoneNumber = nil
            email = nil
            unverifiedEmail = nil
            fullName = nil
            brokerageName = nil
            linkCompleted = false
            etfSymbol = nil
            otp = nil
            isLoggedIn = false
            accessToken = nil
            refreshToken = nil
            password = nil
            password2 = nil
            verificationEmail = nil
            verificationPhoneNumber = nil
            stringToVerify = nil
            boolToVerify = nil
            brokerageEmail = nil
            brokeragePassword = nil
            robinhoodMFAType = nil
            preAccountId = nil
            plaidItems = []
            CoreDataStockManager.shared.clearAll()
            return true
        }
        return false
    }
    
    
    
//    @MainActor
    func authenticateUser(completion: @escaping (Result<Bool, AuthenticationError>) -> Void) {
        let context = LAContext()
//        context.invalidate() 
        var error: NSError?
        
        if context.canEvaluatePolicy(.deviceOwnerAuthentication, error: &error) {
            context.evaluatePolicy(.deviceOwnerAuthentication, localizedReason: "Authenticate to access your saved credentials") { success, authenticationError in
                if success {
                    print("success")
                    completion(.success(true))
                } else {
                    completion(.failure(.failedAuthentication))
                }
            }
        } else {
            if let laError = error as? LAError {
                switch laError.code {
                case .biometryNotAvailable:
                    completion(.failure(.biometryNotAvailable))
                case .biometryNotEnrolled:
                    completion(.failure(.biometryNotEnrolled))
                case .passcodeNotSet:
                    completion(.failure(.passcodeNotSet))
                default:
                    completion(.failure(.unknownError))
                }
            } else {
                completion(.failure(.unknownError))
            }
        }
    }
    
    
    enum AuthenticationError: Error {
        case biometryNotAvailable
        case biometryNotEnrolled
        case passcodeNotSet
        case failedAuthentication
        case userCancelled
        case biometryLockout
        case unknownError
    }
        
    func refreshTokenGet() -> String? {
        return KeychainHelper.shared.get("buul.user.refreshToken")
    }
    func refreshTokenSet(_ value: String?) async -> Bool {
        return await KeychainHelper.shared.set(value, forKey: "buul.user.refreshToken")
    }
    func accessTokenGet() -> String? {
        return KeychainHelper.shared.get("buul.user.accessToken")
    }
    func accessTokenSet(_ value: String?) async -> Bool {
        return await KeychainHelper.shared.set(value, forKey: "buul.user.accessToken")
    }
    
    func loadSavedTokens() -> Bool {
        if self.accessToken != nil && self.refreshToken != nil {
            return true
        } else {
            guard let refreshToken = refreshTokenGet(), let accessToken = accessTokenGet() else {
                return false
            }
            self.accessToken = accessToken
            self.refreshToken = refreshToken
            return true
        }
    }
    
    
    // login / sign up navigation path helpers
    func signUpFlowPlacement() -> NavigationPathViews? {
//        print(phoneNumber, email, fullName, etfSymbol, brokerageName, isLoggedIn)
        if isLoggedIn == true {
            if let _ = phoneNumber, let _ = email, let _ = fullName, let _ = etfSymbol, let _ = brokerageName, brokerageCompleted, linkCompleted {
                return .home
            } else if let _ = phoneNumber, let _ = email, let _ = fullName, let _ = etfSymbol, let _ = brokerageName, brokerageCompleted {
                return .plaidInfo
            } else if let _ = phoneNumber, let _ = email, let _ = fullName, let _ = etfSymbol, let _ = brokerageName {
                return .signUpRobinhoodSecurityInfo
            } else if let _ = phoneNumber, let _ = email, let _ = fullName, let _ = etfSymbol {
                return .signUpBrokerage
            } else if let _ = phoneNumber, let _ = email, let _ = fullName {
                return .signUpETFs
            } else {
                return .landing
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
        let sharedPath: [NavigationPathViews] = [.accountCreated, .signUpETFs, .signUpBrokerage, .signUpRobinhoodSecurityInfo, .signUpRobinhood, .signUpMfaRobinhood, .plaidInfo, .link, .home]
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
        } else if destinationPage == .plaidInfo {
            return Array(sharedPath[0..<7])
        } else if destinationPage == .home {
            return [.home]
        } else if destinationPage == .landing {
            return [.landing]
        } else {
            return [.landing]
        }
    }
    
    // robinhood
    
}



