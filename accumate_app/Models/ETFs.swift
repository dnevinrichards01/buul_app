//
//  ETFs.swift
//  accumate_app
//
//  Created by Nevin Richards on 12/15/24.
//

import SwiftUI

enum ETFProviders: CaseIterable {
    case invesco
    case vanguard
    case ishares
    
    var text: String {
        switch self {
        case .invesco: return "Invesco"
        case .vanguard: return "Vanguard"
        case .ishares: return "iShares"
        }
    }
    
    var logo: Image {
        switch self {
        case .invesco: return Image("RobinhoodLogo")
        case .vanguard: return Image("RobinhoodLogo")
        case .ishares: return Image("RobinhoodLogo")
        }
    }
    
    var etfs: [ETF] {
        switch self {
        case .invesco:
            return [ETF(text: "iShares Bitcoin Trust ETF", growth: "101.73%")]
        case .vanguard:
            return [
                ETF(text: "VOO (Vanguard S&P 500 ETF)", growth: "89.99%"),
                ETF(text: "VOOG (Vanguard S&P 500 Growth)", growth: "110.98%")
            ]
        case .ishares:
            return [ETF(text: "Invesco QQQ", growth: "159.59%")]
        }
    }
}

struct ETF: Codable, Hashable {
    let text: String
    let growth: String
}


