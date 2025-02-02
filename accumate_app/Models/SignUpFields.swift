//
//  SignUpField.swift
//  accumate_app
//
//  Created by Nevin Richards on 12/13/24.
//

import SwiftUI

// Enum to represent input fields
enum SignUpFields: CaseIterable {
    
    case username
    case password
    case password2
    case fullName
    case phoneNumber
    case email
    
    var instruction: String {
        switch self {
        case .username:
            return "Enter a user name"
        case .password:
            return "Enter a password"
        case .password2:
            return "Retype your password"
        case .fullName:
            return "Enter your full name"
        case .phoneNumber:
            return "Enter your phone number"
        case .email:
            return "Enter your email"
        }
    }
    
    var loginInstruction: String {
        switch self {
        case .username:
            return "Enter your user name"
        case .password:
            return "Enter your password"
        case .password2:
            return "Retype your password"
        case .fullName:
            return "Enter your full name"
        case .phoneNumber:
            return "Enter your phone number"
        case .email:
            return "Enter your email"
        }
    }
        
    var resetInstruction: String {
        switch self {
        case .username:
            return "Enter your new user name"
        case .password:
            return "Enter your new password"
        case .password2:
            return "Retype your new password"
        case .fullName:
            return "Enter your corrected full name"
        case .phoneNumber:
            return "Enter your new phone number"
        case .email:
            return "Enter your new email"
        }
    }
    
    var placeholder: String {
        switch self {
        case .username:
            return "username"
        case .password:
            return "password"
        case .password2:
            return "password"
        case .fullName:
            return ""
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
        case .password2:
            return .default
        case .fullName:
            return .default
        case .phoneNumber:
            return .phonePad
        case .email:
            return .emailAddress
        }
    }
}
