//
//  ETFs.swift
//  accumate_app
//
//  Created by Nevin Richards on 12/15/24.
//

import SwiftUI


var etfsList: [ETF] = [invesco, voo, voog, ishares] //[invesco, voo, voog, ishares]

var invesco: ETF = ETF(
    imageName: "Invesco",
    name: "Invesco QQQ",
    timePeriod: "5 years",
    symbol: "QQQ",
    growth: 138.76,
    description: "QQQ tracks a modified market cap weighted index of 100 NASDAQ-listed stocks.",
    compositionImages: ["QQQSectors", "QQQTop10"],
    link: "https://www.invesco.com/qqq-etf/en/about.html",
    targetDemographic: "Tech believers with higher risk tolerance",
    pros: [
        "Focus on tech giants (Nvidia, Amazon, etc.)",
        "Strong growth during market booms"
    ],
    cons: [
        "More volatile",
        "Overexposed to tech industry swings"
    ]
)
var voo: ETF = ETF(
    imageName: "Vanguard",
    name: "VOO (Vanguard S&P 500)",
    timePeriod: "5 years",
    symbol: "VOO",
    growth: 88.64,
    description: "VOO tracks stocks in the S&P 500 Index, representing 500 of the largest U.S. companies",
    compositionImages: ["VOOSectors", "VOOTop10"],
    link: "https://investor.vanguard.com/investment-products/etfs/profile/voo",
    targetDemographic: "Long-term, stable growth",
    pros: [
        "Broad U.S. market exposure (Apple, Microsoft, etc.)",
        "Diversified, stable, and historically strong performer",
        "Great for long-term growth with lower volatility"
    ],
    cons: [
        "Less upside in boom years compared to tech-heavy ETFs or crypto",
        "Still exposed to U.S. market downturns",
    ]
)
var voog: ETF = ETF(
    imageName: "Vanguard",
    name: "VOOG (Vanguard S&P 500 Growth)",
    timePeriod: "5 years",
    symbol: "VOOG",
    growth: 111.64,
    description: "VOOG tracks stocks in the S&P 500 Growth Index, representing  500 of the largest U.S. companies",
    compositionImages: ["VOOGSectors", "VOOGTop10"],
    link: "https://investor.vanguard.com/investment-products/etfs/profile/voog",
    targetDemographic: "Long-term, stable growth with focus on growth",
    pros: [
        "Broad U.S. market exposure (Apple, Microsoft, etc.) approaching VOO",
        "Diversified, stable, and historically strong performer",
        "Potential for higher growth than VOO"
    ],
    cons: [
        "Less upside in boom years compared to tech-heavy ETFs or crypto",
        "Still exposed to U.S. market downturns",
    ]
)
var ishares: ETF = ETF(
    imageName: "Bitcoin",
    name: "Bitcoin",
    timePeriod: "1 year",
    symbol: "BTC",
    growth: 113.74,
    description: "Bitcoin (BTC), launched in 2009, is a cryptocurrency powered by the Bitcoin network—a peer-to-peer network for verifying transactions.",
    compositionImages: [],
    link: "https://bitcoin.org/en/",
    targetDemographic: "Users seeking high-risk, high-reward plays",
    pros: [
        "Potential for massive upside",
        "Hedge against inflation"
    ],
    cons: [
        "Can crash quickly"
    ]
)

struct ETF: Identifiable, Hashable, Codable {
    let id: UUID
    let imageName: String
    let name: String
    let timePeriod: String
    let symbol: String
    let growth: Double
    let description: String
    let compositionImages: [String]
    let targetDemographic: String
    let link: String
    let pros: [String]
    let cons: [String]
    
    
    init(
        id: UUID = UUID(), imageName: String, name: String, timePeriod: String, symbol: String, growth: Double,
        description: String, compositionImages: [String] = [], link: String, targetDemographic: String, pros: [String],
        cons: [String]
    ) {
        self.id = id
        self.imageName = imageName
        self.name = name
        self.timePeriod = timePeriod
        self.symbol = symbol
        self.growth = growth
        self.description = description
        self.compositionImages = compositionImages
        self.link = link
        self.targetDemographic = targetDemographic
        self.pros = pros
        self.cons = cons
    }
}

