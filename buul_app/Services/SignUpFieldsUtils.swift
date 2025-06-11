//
//  SignUpFieldsUtils.swift
//  accumate_app
//
//  Created by Nevin Richards on 2/6/25.
//

import SwiftUI



class SignUpFieldsUtils {
    
    static func validateInputs(
        signUpFields: [SignUpFields], password: String? = nil, password2: String? = nil,
        fullName: String? = nil, phoneNumber: String? = nil, email: String? = nil,
        verificationPhoneNumber: String? = nil, verificationEmail: String? = nil
    ) -> [SignUpFields : String?] {
        var errorMessagesDict: [SignUpFields : String?] = [:]
        for signUpField in signUpFields {
            var errorMessage: String? = nil
            switch signUpField {
            case .password:
                if let password = password {
                    errorMessage = validatePassword(password)
                }
            case .password2:
                if let password2 = password2 {
                    errorMessage = validatePassword2(password, password2)
                }
            case .fullName:
                if let fullName = fullName {
                    errorMessage = validateFullname(fullName)
                }
            case .phoneNumber:
                if let phoneNumber = phoneNumber {
                    errorMessage = validatePhoneNumber(phoneNumber)
                }
            case .email:
                if let email = email {
                    errorMessage = validateEmail(email)
                }
            case .verificationPhoneNumber:
                if let verificationPhoneNumber = verificationPhoneNumber {
                    errorMessage = validatePhoneNumber(verificationPhoneNumber)
                }
            case .verificationEmail:
                if let verificationEmail = verificationEmail {
                    errorMessage = validateEmail(verificationEmail)
                }
            default:
                continue
            }
            errorMessagesDict[signUpField] = errorMessage
        }
        return errorMessagesDict
    }
    
    static func keysStringToSignUpFields(_ errorMessages: any Codable) throws -> [SignUpFields : String?] {
        do {
            let jsonData = try JSONEncoder().encode(errorMessages)
            if let dictionary = try? JSONSerialization.jsonObject(with: jsonData, options: []) as? [String: String?] {
                let mappedDict: [SignUpFields: String?] = Utils.compactMapKeys(dictionary: dictionary) {
                    SignUpFields(rawValue: $0)
                }
                return mappedDict
            }
            throw ServerCommunicator.NetworkError.decodingError
        } catch {
            throw ServerCommunicator.NetworkError.decodingError
        }
    }
    
    static func parseErrorMessages(_ signUpFields: [SignUpFields],_ errorMessagesDict: [SignUpFields : String?]) -> [String?]? {
        var errorMessagesList: [String?] = []
        var isError = false
        for signUpField in signUpFields {
            if let errorMessage = errorMessagesDict[signUpField] {
                if errorMessage != nil {
                    isError = true
                }
                errorMessagesList.append(errorMessage)
            } else {
                errorMessagesList.append(nil)
            }
        }
        if isError {
            return errorMessagesList
        } else {
            return nil
        }
    }
    
    static func validateEmail(_ email: String?) -> String? {
        if email == "" || email == nil { return "Please enter an email" }
        return nil
    }
    
    static func validatePassword(_ password: String?) -> String? {
        if password == "" || password == nil { return "Please enter a password" }
        return nil
    }
    
    static func validatePassword2(_ password: String?, _ password2: String?) -> String? {
        if password != password2 { return "Passwords do not match" }
        return nil
    }
    
    static func validateFullname(_ fullName: String?) -> String? {
        if fullName == "" || fullName == nil { return "Please enter your full name" }
        return nil
    }
    
    static func phoneNumberIsNil(_ phoneNumber: String?) -> Bool {
        return Utils.nilOrEmptyString(phoneNumber) || phoneNumber == "+" || phoneNumber == "+1"
    }
    
    static func validatePhoneNumber(_ phoneNumber: String?) -> String? {
        if phoneNumberIsNil(phoneNumber) {
            return "Please enter your phone number"
        }
        if phoneNumber != formatPhoneNumber(phoneNumber!) {
            return "Please include the country and area codes"
        }
        return nil
    }
    
    static func formatPhoneNumber(_ phoneNumber: String) -> String {
        var filtered = phoneNumber.filter { "+0123456789".contains($0) }

        if !filtered.hasPrefix("+") {
            filtered = "+" + filtered
        }

        if filtered.count > 15 {
            filtered = String(filtered.prefix(15))
        }

        return filtered
    }
    
    
    static func validateOTP(_ otp: String) -> String? {
        let filtered = otp.filter { "0123456789".contains($0) }
        if filtered != otp || otp.count != 6 {
            return "Code must be 6 digits"
        }
        return nil
    }
    
    static func sendEmailOTP(_ otp: String) async -> String? {
        if otp == "" { return "Please enter a 6 digit code" }
        return nil
    }
    
    static func sendETF(_ symbol: String) async -> String? {
        if symbol == "" { return "Your selection was not recorded. Contact Buul" }
        
        if symbolToEtf(symbol) == nil {
            return "\(symbol) does not match one of the options. Contact Buul."
        }
        
        // send it and return its error
        return nil
    }
    
    static func symbolToEtf(_ symbol: String?) -> ETF? {
        guard let symbol = symbol else {
            return nil
        }
        for etf in etfsList {
            if symbol == etf.symbol {
                return etf
            }
        }
        return nil
    }
    
    static func nameToBrokerage(_ brokerageName: String?) -> Brokerages? {
        if let brokerageName = brokerageName {
            for brokerage in Brokerages.allCases {
                if brokerage.displayName == brokerageName {
                    return brokerage
                }
            }
        }
        return nil
    }
    
    static func sendBrokerage(_ brokerageName: String) async -> String? {
        if brokerageName == "" { return "Your selection was not recorded. Contact Buul" }
        
        var match = false
        for brokerage in Brokerages.allCases {
            if brokerage.displayName == brokerageName {
                match = true
                break
            }
        }
        if !match {
            return "\(brokerageName) does not match one of the options. Contact Buul."
        }
        
        // send it and return its error
        return nil
    }
    
}

