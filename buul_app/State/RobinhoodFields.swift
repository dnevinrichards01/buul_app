//
//  SignUpField.swift
//  accumate_app
//
//  Created by Nevin Richards on 12/13/24.
//

import SwiftUI

// Enum to represent input fields
enum RobinhoodFields: CaseIterable {
    
    case username
    case password
    case password2
    
    var instruction: String {
        switch self {
        case .username:
            return "Enter your Robinhood user name"
        case .password:
            return "Enter your Robinhood password"
        case .password2:
            return "Retype your Robinhood password"
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
        }
    }
}
