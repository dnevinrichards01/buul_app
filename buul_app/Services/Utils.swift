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
    
    static func getBrokerage(sessionManager: UserSessionManager, brokerageString: String? = nil) async -> Brokerages? {
        let brokerageName: String?
        if let brokerageString = brokerageString {
            brokerageName = brokerageString
        } else {
            brokerageName = await sessionManager.brokerageName
        }
        
        for brokerage in Brokerages.allCases {
            if brokerage.rawValue == brokerageName {
                return brokerage
            }
        }
        return nil
    }
    
    @MainActor
    static func getBrokerageMainActor(sessionManager: UserSessionManager, brokerageString: String? = nil) -> Brokerages? {
        let brokerageName: String?
        if let brokerageString = brokerageString {
            brokerageName = brokerageString
        } else {
            brokerageName = sessionManager.brokerageName
        }
        
        for brokerage in Brokerages.allCases {
            if brokerage.rawValue == brokerageName {
                return brokerage
            }
        }
        return nil
    }
    
    static func searchGraphDataForValue(value: Double, graphData: [[StockDataPoint]]?) -> Date? {
        guard let graphData = graphData else { return nil }
        var previous: Date? = nil
        for point in graphData.lazy.flatMap({ $0.reversed() }) {
            if point.price < value {
                return previous
            }
            previous = point.date
        }
        return Date()
    }
    
    static func getGoalDate(
        amount: Double,
        contribution: Double,
        annualRate: Double,
        currentPortfolioValue: Double,
        graphData: [[StockDataPoint]]?
    ) -> Date {
        if amount == 0 || currentPortfolioValue > amount {
            return searchGraphDataForValue(value: amount, graphData: graphData) ?? Date()
        }
        
        let monthlyRate = pow(1 + annualRate, 1 / 12.0) - 1
        if monthlyRate == 0 && contribution == 0 {
            return Date.distantFuture
        } else if  monthlyRate < 0 || contribution < 0 {
            return Date.distantFuture
        }
        
        let numerator = contribution + amount * monthlyRate
        let denominator = contribution + currentPortfolioValue * monthlyRate

        guard numerator > 0, denominator > 0 else {
            return Date.distantFuture
        }

        let n = log(numerator / denominator) / log(1 + monthlyRate)
        let months = Int(ceil(n))

        return Calendar.current.date(byAdding: .month, value: months, to: Date()) ?? Date()
        
    }
    
    static func censor(_ input: String) -> String {
        if input.count == 0 {
            return input
        }
        return String(repeating: "•", count: input.count)
    }
    
    static func extractCode(from url: URL) -> String? {
        guard let components = URLComponents(url: url, resolvingAgainstBaseURL: false),
              let code = components.queryItems?.first(where: { $0.name == "code" })?.value else {
            return nil
        }
        return code
    }
}

