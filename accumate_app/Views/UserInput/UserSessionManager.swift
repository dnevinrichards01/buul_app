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

//@MainActor
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
    @AppStorage("accumate.user.isLoggedIn") var isLoggedIn: Bool = false
    @AppStorage("accumate.user.phoneNumber") var phoneNumber: String?
    @AppStorage("accumate.user.email") var email: String?
    @AppStorage("accumate.user.unverifiedEmail") var unverifiedEmail: String?
    @AppStorage("accumate.user.fullName") var fullName: String?
    @AppStorage("accumate.user.brokerageName") var brokerageName: String?
    @AppStorage("accumate.user.etfSymbol") var etfSymbol: String?
    @AppStorage("accumate.user.brokerageCompleted") var brokerageCompleted: Bool = false
    @AppStorage("accumate.user.link") var linkCompleted: Bool = false
    // alter the back buttons on sign up page to let a user go backwards even if they were dropped in there with no navigationpath / history
    
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
        return KeychainHelper.shared.get("accumate.user.refreshToken")
    }
    func refreshTokenSet(_ value: String?) async -> Bool {
        return await KeychainHelper.shared.set(value, forKey: "accumate.user.refreshToken")
    }
    func accessTokenGet() -> String? {
        return KeychainHelper.shared.get("accumate.user.accessToken")
    }
    func accessTokenSet(_ value: String?) async -> Bool {
        return await KeychainHelper.shared.set(value, forKey: "accumate.user.accessToken")
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



class KeychainHelper {
    
    static let shared = KeychainHelper()
    
    
    func get(_ key: String) -> String? {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: key,
            kSecReturnData as String: true,
            kSecMatchLimit as String: kSecMatchLimitOne
        ]
        var dataTypeRef: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &dataTypeRef)
        
        if status == errSecSuccess, let data = dataTypeRef as? Data {
            return String(data: data, encoding: .utf8)
        } else {
            return nil
        }
    }

    func getWithBiometrics(_ key: String, context: LAContext) -> String? {
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
            return String(data: data, encoding: .utf8)
        } else {
            return nil
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


class CoreDataStockManager {
    static let shared = CoreDataStockManager()

    let container: NSPersistentContainer

    private init() {
        container = NSPersistentContainer(name: "CoreStockDataPoint") // your .xcdatamodeld name
        container.loadPersistentStores { _, error in
            if let error = error {
                fatalError("Core Data failed: \(error.localizedDescription)")
            }
        }
        container.viewContext.mergePolicy = NSMergePolicy.mergeByPropertyObjectTrump
    }

    var context: NSManagedObjectContext {
        container.viewContext
    }

    func save(series: [[StockDataPoint]]) {
        print("core data save")

        for i in series.indices {
            let dataPoints = series[i]
            let stockSeries = CoreStockSeries(context: context)
            stockSeries.id = UUID()
            stockSeries.i = Int16(i)

            for point in dataPoints {
                let stockPoint = CoreStockDataPoint(context: context)
                stockPoint.date = point.date
                stockPoint.price = point.price
                stockPoint.series = stockSeries // link the point to the series
            }
        }

        do {
            try context.save()
        } catch {
            print("Failed to save: \(error)")
        }
    }

    // MARK: - Load from Core Data
    func fetchAllSeries() -> [Int : [StockDataPoint]] {
        let request: NSFetchRequest<CoreStockSeries> = CoreStockSeries.fetchRequest()
        do {
            let seriesList = try context.fetch(request)
            return seriesList.reduce(into: [:]) { dict, series in
                let points: [CoreStockDataPoint] = Array(series.dataPoints as? Set<CoreStockDataPoint> ?? [])
                let stockPoints: [StockDataPoint] = points
                    .sorted { $0.date ?? Date() < $1.date ?? Date()}
                    .compactMap { (point: CoreStockDataPoint) in
                        guard let date = point.date else { return nil }
                        return StockDataPoint(date: date, price: point.price)
                    }
                dict[Int(series.i)] = stockPoints
            }
        } catch {
            print("Failed to fetch series: \(error)")
            return [:]
        }
    }

    // MARK: - Optional: Clear All
    func clearAll() {
        let request: NSFetchRequest<NSFetchRequestResult> = CoreStockSeries.fetchRequest()
        let delete = NSBatchDeleteRequest(fetchRequest: request)

        do {
            try context.execute(delete)
            try context.save()
            print("All series and data points cleared.")
        } catch {
            print("Failed to clear: \(error)")
        }
    }
}
