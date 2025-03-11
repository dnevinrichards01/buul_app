//
//  SignUpField.swift
//  accumate_app
//
//  Created by Nevin Richards on 12/13/24.
//

import SwiftUI

// Enum to represent input fields
enum SignUpFields: String, CaseIterable {
    case email
    case password
    case password2
    case fullName
    case phoneNumber
    case verificationEmail
    case verificationPhoneNumber
    case symbol
    case brokerage
    case deleteAccount
    case field
    case code
    
    
    var instruction: String {
        switch self {
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
        default:
            return "Error: This field should not be displayed"
        }
    }
    
    var loginInstruction: String {
        switch self {
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
        default:
            return "Error: This field should not be displayed"
        }
    }
        
    var resetInstruction: String {
        switch self {
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
        case .verificationPhoneNumber:
            return "Enter the phone number for your account"
        case .verificationEmail:
            return "Enter the email for your account"
        default:
            return "Error: This field should not be displayed"
        }
    }
    
    var placeholder: String {
        switch self {
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
        case .verificationPhoneNumber:
            return "(555) 123-4567"
        case .verificationEmail:
            return "you@example.com"
        default:
            return "Error: This field should not be displayed"
        }
    }
    
    var keyboardType: UIKeyboardType {
        switch self {
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
        case .verificationPhoneNumber:
            return .phonePad
        case .verificationEmail:
            return .emailAddress
        default:
            return .default
        }
    }
}
