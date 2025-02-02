//
//  Brokerages.swift
//  accumate_app
//
//  Created by Nevin Richards on 12/14/24.
//

import SwiftUI

enum Brokerages: CaseIterable {
    case robinhood
    //case placeholder
    
    var name: String {
        switch self {
        case .robinhood:
            return "Robinhood"
        }
    }
    
    var imageName: String {
        switch self {
        case .robinhood:
            return "RobinhoodLogo"
        }
    }
    
    var connectPage: NavigationPathViews {
        switch self {
        case .robinhood:
            return NavigationPathViews.signUpRobinhood
        }
    }
    
}
