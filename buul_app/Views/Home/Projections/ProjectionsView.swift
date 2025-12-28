//
//  ProjectionsView.swift
//  buul_app
//
//  Created by Nevin Richards on 7/9/25.
//

import SwiftUI

struct ProjectionsView: View {
    @EnvironmentObject var sessionManager: UserSessionManager
    @State private var selectedInvestment: InvestmentButtonPresets = .QQQ
    @State private var avgMonthlyContr: Double = 0.0 // history
    @State private var avgRates: [InvestmentButtonPresets : Double] = defaultAvgRates() // new endpoint
    @State private var portfolioValue: Double = 0.0 // portfolio
    // state for displayed investments, selected investments
    var body: some View {
        HStack (spacing: 1) {
            ProjectionsInvestmentsTabView(
                selectedInvestment: $selectedInvestment
            )
            .background(Color.black.ignoresSafeArea())
            .frame(width: 200)
            .padding(.leading)
            ProjectionsGoalsTabView(
                selectedInvestment: $selectedInvestment,
                avgMonthlyContr: $avgMonthlyContr,
                avgRates: $avgRates,
                portfolioValue: $portfolioValue
            )
            .background(Color.black.ignoresSafeArea())
            .padding(.trailing)
        }
        .onAppear {
            avgMonthlyContr = sessionManager.avgMonthlyContr ?? 0.0
            portfolioValue = sessionManager.graphData?[0].first?.price ?? 0.0
        }
    }
    
    private static func defaultAvgRates() -> [InvestmentButtonPresets : Double] {
        var avgRatesDict: [InvestmentButtonPresets:Double] = [:]
        for investment in InvestmentButtonPresets.allCases {
            avgRatesDict[investment] = 0.0
        }
        return avgRatesDict
    }
}

#Preview {
    ProjectionsView()
}
