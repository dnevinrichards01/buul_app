//
//  Utils.swift
//  accumate_app
//
//  Created by Nevin Richards on 2/5/25.
//

import SwiftUI

class Utils {
    
    static func dismissKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
    
    static func nilOrEmptyString(_ str: String?) -> Bool {
        return str == nil || str == ""
    }
    
    static func compactMapKeys<T: Hashable>(dictionary: [String: String?], transform: (String) -> T?) -> [T: String?] {
        var newDict: [T: String?] = [:]
        for (key, value) in dictionary {
            if let newKey = transform(key) {
                newDict[newKey] = value
            }
        }
        return newDict
    }
    
    static func camelCaseToSnakeCase(_ input: String) -> String {
        let pattern = "([a-z0-9])([A-Z])" // Matches lowercase/number followed by uppercase
        let regex = try! NSRegularExpression(pattern: pattern, options: [])
        let range = NSRange(location: 0, length: input.utf16.count)
        let snakeCase = regex.stringByReplacingMatches(in: input, options: [], range: range, withTemplate: "$1_$2")
        return snakeCase.lowercased()
    }
    
    static func camelCaseToSpaces(_ input: String) -> String {
        let pattern = "([a-z0-9])([A-Z])" // Matches lowercase/number followed by uppercase
        let regex = try! NSRegularExpression(pattern: pattern, options: [])
        let range = NSRange(location: 0, length: input.utf16.count)
        let snakeCase = regex.stringByReplacingMatches(in: input, options: [], range: range, withTemplate: "$1 $2")
        return snakeCase.lowercased()
    }
    
    static func snakeCaseToCamelCase(_ input: String) -> String {
        let words = input.split(separator: "_")
        let firstWord = words.first?.lowercased() ?? ""
        let capitalizedWords = words.dropFirst().map { $0.capitalized }
        return ([firstWord] + capitalizedWords).joined()
    }
    
    static func getOTPEndpoint(_ signUpField: SignUpFields, _ authenticate: Bool) -> String {
        if !authenticate && signUpField == .password {
            return "api/user/resetpassword/"
        } else if !authenticate && (signUpField == .email || signUpField == .phoneNumber) {
            return "api/user/emailphonesignupvalidation/"
        } else {
            return "api/user/requestverificationcode/"
        }
    }
    
    static func getSignUpFieldsValidateEndpoint(_ signUpField: SignUpFields) -> String {
        if [.brokerage, .symbol].contains(signUpField) {
            return "api/user/setbrokerageinvestment/"
        } else  {
            return "api/user/namepasswordvalidation/"
        }
    }
    
    static func truncateTo6Digits(text: String) -> String {
        let digitsOnly = text.filter { $0.isNumber }
        if digitsOnly.count <= 6 {
            return digitsOnly
        } else {
            return String(digitsOnly.prefix(6))
        }
    }
    
    static func getIndex(text: String, index: Int) -> String {
        if let indexObject = text.index(text.startIndex, offsetBy: index, limitedBy: text.endIndex),
           text.count - 1 >= index {
            return String(text[indexObject])
        }
        return ""
    }
    
    static func getBrokerage(sessionManager: UserSessionManager, brokerageString: String? = nil) -> Brokerages? {
        let brokerageName: String? = brokerageString ?? sessionManager.brokerageName
        for brokerage in Brokerages.allCases {
            print(brokerage.rawValue, brokerageName)
            if brokerage.rawValue == brokerageName {
                return brokerage
            }
        }
        return nil
    }
}
