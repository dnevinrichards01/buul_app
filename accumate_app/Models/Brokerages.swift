//
//  Brokerages.swift
//  accumate_app
//
//  Created by Nevin Richards on 12/14/24.
//

import SwiftUI

enum Brokerages: CaseIterable {
    case robinhood
    case webull
    //case placeholder
    
    var displayName: String {
        switch self {
        case .robinhood:
            return "Robinhood"
        case .webull:
            return "WeBull"
        }
    }
    
    var imageName: String {
        switch self {
        case .robinhood:
            return "RobinhoodLogo"
        case .webull:
            return "WeBullLogo"
        }
    }
    
    var connectPage: NavigationPathViews {
        switch self {
        case .robinhood:
            return NavigationPathViews.signUpRobinhood
        case .webull:
            return NavigationPathViews.signUpRobinhood
        }
    }
    
}
