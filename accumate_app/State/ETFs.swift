//
//  ETFs.swift
//  accumate_app
//
//  Created by Nevin Richards on 12/15/24.
//

import SwiftUI


var etfsList: [ETF] = [invesco, voo, voog, ishares]

var invesco: ETF = ETF(
    imageName: "Invesco",
    name: "Invesco QQQ",
    timePeriod: "5 years",
    symbol: "QQQ",
    growth: 138.76
)
var voo: ETF = ETF(
    imageName: "Vanguard",
    name: "VOO (Vanguard S&P 500)",
    timePeriod: "5 years",
    symbol: "VOO",
    growth: 88.64
)
var voog: ETF = ETF(
    imageName: "Vanguard",
    name: "VOOG (Vanguard S&P 500 Growth)",
    timePeriod: "5 years",
    symbol: "VOOG",
    growth: 111.64
)
var ishares: ETF = ETF(
    imageName: "Bitcoin",
    name: "IBIT (iShares Bitcoin Trust)",
    timePeriod: "1 year",
    symbol: "IBIT",
    growth: 113.74
)

struct ETF: Identifiable, Hashable, Codable {
    let id: UUID
    let imageName: String
    let name: String
    let timePeriod: String
    let symbol: String
    let growth: Double
    
    
    init(id: UUID = UUID(), imageName: String, name: String, timePeriod: String, symbol: String, growth: Double) {
        self.id = id
        self.imageName = imageName
        self.name = name
        self.timePeriod = timePeriod
        self.symbol = symbol
        self.growth = growth
    }
}

