//
//  SignUpField.swift
//  accumate_app
//
//  Created by Nevin Richards on 12/13/24.
//

import SwiftUI

// Enum to represent input fields
enum SignUpField: CaseIterable {
    
    case username
    case password
    case firstName
    case lastName
    case phoneNumber
    case email
    
    var instruction: String {
        switch self {
        case .username:
            return "Enter a user name"
        case .password:
            return "Enter a password"
        case .firstName:
            return "Enter your first name"
        case .lastName:
            return "Enter your last name"
        case .phoneNumber:
            return "Enter your phone number"
        case .email:
            return "Enter your email"
        
        }
    }
    
    var placeholder: String {
        switch self {
        case .username:
            return "username"
        case .password:
            return "password"
        case .firstName:
            return "First name"
        case .lastName:
            return "Last name"
        case .phoneNumber:
            return "(555) 123-4567"
        case .email:
            return "you@example.com"
        }
    }
    
    var keyboardType: UIKeyboardType {
        switch self {
        case .username:
            return .default
        case .password:
            return .default
        case .firstName:
            return .default
        case .lastName:
            return .default
        case .phoneNumber:
            return .phonePad
        case .email:
            return .emailAddress
        
        }
    }
}
