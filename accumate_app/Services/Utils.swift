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
    
    static func getOTPEndpoint(_ OTPField: OTPFields, _ authenticate: Bool) -> String {
        if OTPField == .password && !authenticate {
            return "api/user/resetpassword/"
        } else if OTPField == .email || OTPField == .phoneNumber && !authenticate {
            return "api/user/emailphonesignupvalidation/"
        } else {
            return "api/user/requestverificationcode/"
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
}
