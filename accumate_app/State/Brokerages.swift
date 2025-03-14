//
//  Brokerages.swift
//  accumate_app
//
//  Created by Nevin Richards on 12/14/24.
//

import SwiftUI

enum Brokerages: String, CaseIterable {
    case robinhood
    case webull
    case charlesSchwab
    case fidelity
    
    var displayName: String {
        switch self {
        case .robinhood:
            return "Robinhood"
        case .webull:
            return "WeBull"
        case .charlesSchwab:
            return "Charles Schwab"
        case .fidelity:
            return "Fidelity"
        }
    }
    
    var imageName: String {
        switch self {
        case .robinhood:
            return "RobinhoodLogo"
        case .webull:
            return "WeBullLogo"
        case .charlesSchwab:
            return "CharlesSchwabLogo"
        case .fidelity:
            return "FidelityLogo"
        }
    }
    
    var secondaryImageName: String {
        switch self {
        case .robinhood:
            return "RobinhoodLeafLogo"
        case .webull:
            return "WeBullSmallLogo"
        case .charlesSchwab:
            return "CharlesSchwabLogo"
        case .fidelity:
            return "FidelitySmallLogo"
        }
    }
    
    var imageDim: [Double] {
        switch self {
        case .robinhood:
            return [180, 58.86]
        case .webull:
            return [180, 50]
        case .charlesSchwab:
            return [180, 60]
        case .fidelity:
            return [180, 70.2]
        }
    }
    
    var secondaryImageDim: [Double] {
        switch self {
        case .robinhood:
            return [80, 80, 0]
        case .webull:
            return [70, 50, 0]
        case .charlesSchwab:
            return [180, 70.2, 0]
        case .fidelity:
            return [60, 60, 10]
        }
    }
    
    var signUpSecurityInfo: NavigationPathViews {
        switch self {
        case .robinhood:
            return .signUpRobinhoodSecurityInfo
        case .webull:
            return .signUpRobinhoodSecurityInfo
        case .charlesSchwab:
            return .signUpRobinhoodSecurityInfo
        case .fidelity:
            return .signUpRobinhoodSecurityInfo
        }
    }
    
    var changeSecurityInfo: NavigationPathViews {
        switch self {
        case .robinhood:
            return .robinhoodSecurityInfo
        case .webull:
            return .robinhoodSecurityInfo
        case .charlesSchwab:
            return .robinhoodSecurityInfo
        case .fidelity:
            return .robinhoodSecurityInfo
        }
    }
    
    var signUpConnect: NavigationPathViews {
        switch self {
        case .robinhood:
            return .signUpRobinhood
        case .webull:
            return .signUpConnectBrokerageLater
        case .charlesSchwab:
            return .signUpConnectBrokerageLater
        case .fidelity:
            return .signUpConnectBrokerageLater
        }
    }
    
    var changeConnect: NavigationPathViews {
        switch self {
        case .robinhood:
            return .connectRobinhood
        case .webull:
            return .connectBrokerageLater
        case .charlesSchwab:
            return .connectBrokerageLater
        case .fidelity:
            return .connectBrokerageLater
        }
    }

}
