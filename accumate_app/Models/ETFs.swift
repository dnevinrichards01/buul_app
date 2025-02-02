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
    growth: 138.76
)
var voo: ETF = ETF(
    imageName: "Vanguard",
    name: "VOO (Vanguard S&P 500)",
    timePeriod: "5 years",
    growth: 88.64
)
var voog: ETF = ETF(
    imageName: "Vanguard",
    name: "VOOG (Vanguard S&P 500 Growth)",
    timePeriod: "5 years",
    growth: 111.64
)
var ishares: ETF = ETF(
    imageName: "Bitcoin",
    name: "IBIT (iShares Bitcoin Trust)",
    timePeriod: "1 year",
    growth: 113.74
)

struct ETF: Identifiable, Hashable {
    let id: UUID = UUID()
    let imageName: String
    let name: String
    let timePeriod: String
    let growth: Double
}
