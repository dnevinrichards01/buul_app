//
//  NavigationPathViews.swift
//  accumate_app
//
//  Created by Nevin Richards on 12/14/24.
//

import SwiftUI

enum NavigationPathViews: CaseIterable {
    case landing
    case home
    
    case signUpPhone
    case signUpEmail
    case signUpEmailVerify
    case signUpFullName
    case signUpPassword
    case accountCreated
    case signUpETFs
    case signUpBrokerage
    case signUpRobinhoodSecurityInfo
    case signUpRobinhood
    case signUpMfaRobinhood
    case login
    case link
    case passwordRecoveryOTP
    case passwordRecover
    case emailRecover
    case passwordRecoverInitiate
        
    case accountInfo
    case bank
    case help
    case deleteOTP
    case delete
    case changePasswordOTP
    case changePassword
    case changeEmailOTP
    case changeEmail
    case changePhoneOTP
    case changePhone
    case changeNameOTP
    case changeName
    case changeBrokerage
    case robinhoodSecurityInfo
    case connectRobinhood
    case mfaRobinhood
    case changeETFOTP
    case changeETF
    case plaidSettings
}

