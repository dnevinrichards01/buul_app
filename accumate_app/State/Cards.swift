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
    description: "Home utilities 5%,\nTV, internet and streaming 5%,\n$200 signup bonus",
    imageName: "CashPlusVisa",
    url: "https://www.usbank.com/credit-cards/offers/cash-plus-visa-signature-credit-card.html?sourcecode=86937&ecid=PS_50670&ds_e=GOOGLE&ds_c=BB+Cash%2B_US+Bank+Cash%2B+CC_Brand-Tier+1_Prospect_ALL_ALL_NAT+11376&ds_a=BB+Cash%2B_US+Bank+Cash%2B+CC_Brand-Tier+1_Prospect_ALL_ALL_NAT&ds_k=us+bank+cash+%2B&ds_kids=330073517438&i=1&gclsrc=aw.ds&gad_source=1&gbraid=0AAAAADpM1fyuWM6M6um8oI2EziR_raLpv&gclid=Cj0KCQiA-5a9BhCBARIsACwMkJ5RH4CSjeOolcKVBwwi7J0c6wl1kw9PAMidyFZGfRJtYVPc86yM3H4aAidHEALw_wcB",
    category: "home utilities, internet, and streaming",
    categoryPercentage: 0.0
)
var bofaCustomizedCash = Card(
    name: "Bank of America Customized Cash Rewards",// Credit Card",
    description: "Online Shopping 3%,\nGroceries 2%,\n$200 signup bonus",
    imageName: "BofaCustomizedCash",
    url: "https://promo.bankofamerica.com/ccsearchlp10/compare-cards-3/?cm_mmc=Cons-CC-_-Google-PS-_-bank_of_america_customized_cash_rewards-_-Brand_Cash&code=TC0306&cq_src=google_ads&cq_med=Credit_Card&cq_cmp=20837226170&cq_term=bank%20of%20america%20customized%20cash%20rewards&cq_net=g&cq_plt=gp&gclsrc=aw.ds&gad_source=1&gbraid=0AAAAAD-5Cc1GggRu8QYeEEWPNkmJdI3Cg&gclid=Cj0KCQiA-5a9BhCBARIsACwMkJ7bbRNu6Fch2MJUvOmiM4eA5T_9sCnNS2moU5GJLaj2-drdEKeqZgsaAmLwEALw_wcB",
    category: "shopping",
    categoryPercentage: 0.0
)
var citiCustomCash = Card(
    name: "Citi Custom Cash",// Card",
    description: "Dining 5%,\n$200 signup bonus",
    imageName: "CitiCustomCash",
    url: "https://www.citi.com/usc/LPACA/Citi/Cards/CustomCash/ps/index.html?cmp=knc%7Cacquire%7C2006%7CCARDS%7CGoogle%7CBR&gclsrc=aw.ds&gbraid=0AAAAADaf8I-th33nRyjepg47TvNiFn3YJ&gclid=Cj0KCQiA-5a9BhCBARIsACwMkJ7baIF76sY_uDXiJ4MxOXPWlGPwCHukT5y_btdc3icZzfCBNrARcp4aAlJNEALw_wcB&ProspectID=PHrJmtmnwKqTB9nDS6EnUw4ozDzOLzuZ",
    category: "dining",
    categoryPercentage: 0.0
)
var discoverIt = Card(
    name: "Discover It",// Credit Card",
    description: "Rotating Categories\nQ1 Dining 5%,\nQ2 Groceries 5%,\nQ3 Gas 5%,\nQ4 Amazon 5%,\n$100 signup bonus",
    imageName: "DiscoverIt",
    url: "https://refer.discover.com/s/teymurrishani?advocate.partner_share_id=2836556850", //affiliate
    category: "dining, groceries, gas, and Amazon",
    categoryPercentage: 0.0
)
var chaseFreedomFlex = Card(
    name: "Chase Freedom Flex",// Credit Card",
    description: "Rotating Categories\nQ1 Gas 5%,\nQ2 Dining 5%,\nQ3 Amazon 5%,\nQ4 Groceries 5%,\n$200 signup bonus",
    imageName: "ChaseFreedomFlex",
    url: "https://creditcards.chase.com/a1/freedom/CFDFlex0125?CELL=6D4C&jp_cmp=cc/Freedom+Flex_Brand_Exact_Freedom+Flex_SEM_US_NA_Standard_+Test+(1.29.25)/sea/947525282588/Chase+-+Freedom+Flex&gclsrc=aw.ds&gad_source=1&gbraid=0AAAAAD3FB7gA6eR18oYq5iTucD95T3b5_&gclid=Cj0KCQiA-5a9BhCBARIsACwMkJ573jxwi18Kck7Rl3SVBjg8cfVoRplDgeFR_P668gQC3byvOKcadpgaAuCZEALw_wcB",
    category: "dining, groceries, gas, and Amazon",
    categoryPercentage: 0.0
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

