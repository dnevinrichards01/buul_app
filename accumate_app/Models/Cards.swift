//
//  Cards.swift
//  accumate_app
//
//  Created by Nevin Richards on 12/15/24.
//

import SwiftUI

//struct Cards {
//    var cardsList: [Card]
//}

var cardsList = [cashPlusVisa, bofaCustomizedCash, citiCustomCash, discoverIt, chaseFreedomFlex]

var cashPlusVisa = Card(
    name: "U.S. Bank Cash+ Visa Signature",// Card",
    description: "Home utilities 5%,\nTV, internet and streaming 5%",
    imageName: "CashPlusVisa",
    url: "https://www.google.com",
    category: "dining",
    categoryPercentage: 22.54
)
var bofaCustomizedCash = Card(
    name: "Bank of America Customized Cash Rewards",// Credit Card",
    description: "Shopping 3%",
    imageName: "BofaCustomizedCash",
    url: "https://www.google.com",
    category: "dining",
    categoryPercentage: 22.54
)
var citiCustomCash = Card(
    name: "Citi Custom Cash",// Card",
    description: "Dining 5%",
    imageName: "CitiCustomCash",
    url: "https://www.google.com",
    category: "dining",
    categoryPercentage: 22.54
)
var discoverIt = Card(
    name: "Discover It",// Credit Card",
    description: "Rotating Categories 5%\n3 Months Gas (5%)\n3 Months Groceries (5%)\n3 Months Restaurants (5%)",
    imageName: "DiscoverIt",
    url: "https://www.google.com",
    category: "dining",
    categoryPercentage: 22.54
)
var chaseFreedomFlex = Card(
    name: "Chase Freedom Flex",// Credit Card",
    description: "Rotating Categories 5%\n3 Months Gas (5%)\n3 Months Groceries (5%)\n3 Months Restaurants (5%)",
    imageName: "ChaseFreedomFlex",
    url: "https://www.google.com",
    category: "dining",
    categoryPercentage: 22.54
)


struct Card: Identifiable, Hashable {
    let id: UUID = UUID()
    let name: String
    let description: String
    let imageName: String
    let url: String
    let category: String
    let categoryPercentage: Double
}
//
//var cardImageMap: [String: Image] {
//    [
//        "U.S. Bank Cash + Visa Signature" : Image("RobinhoodLogo"),
//        "Bank of America Customized Cash Rewards" : Image("RobinhoodLogo"),
//        "Citi Custom Cash" : Image("RobinhoodLogo"),
//        "Discover It" : Image("RobinhoodLogo"),
//        "Chase Freedom Flex" : Image("AccumateLogo")
//    ]
//}


