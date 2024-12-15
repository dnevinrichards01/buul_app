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
    
    var logo: Image {
        switch self {
        case .robinhood:
            return Image("RobinhoodLogo")
        }
    }
    
    var connectPage: NavigationPathViews {
        switch self {
        case .robinhood:
            return NavigationPathViews.robinhood
        }
    }
    
}
