//
//  KeychainHelper.swift
//  accumate_app
//
//  Created by Nevin Richards on 5/14/25.
//

import Foundation
import SwiftUI
import LocalAuthentication
import CoreData



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
