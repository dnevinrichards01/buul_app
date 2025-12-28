//
//  ProjectionsGoalsTabView.swift
//  buul_app
//
//  Created by Nevin Richards on 7/9/25.
//

import SwiftUI

// maybe change plus to just a button below the stack, and we can add as many empty goals as we'd like...
struct ProjectionsGoalsTabView: View {
    @EnvironmentObject var sessionManager: UserSessionManager
    @State private var buttonStates: [GoalButtonState] = [
        GoalButtonState(
            name: "",
            image: "Icon",
            amount: nil,
            date: nil,
            color: .blue,
            borderColor: .cyan,
            textBoxColor: .teal
        )
    ]
    @State private var buttonsCreated: [Bool] = [false]
    @Binding var selectedInvestment: InvestmentButtonPresets
    @Binding var avgMonthlyContr: Double
    @Binding var avgRates: [InvestmentButtonPresets:Double]
    @Binding var portfolioValue: Double
    
    var body: some View {
        VStack {
            List {
                ForEach(buttonStates) { button in
                    if let index = buttonStates.firstIndex(of: button) {
                        if buttonsCreated[index] {
                            HStack {
                                GoalButtonView(
                                    buttonState: $buttonStates[index],
                                    buttonCreated: $buttonsCreated[index],
                                    selectedInvestment: $selectedInvestment,
                                    avgRates: $avgRates,
                                    avgMonthlyContr: $avgMonthlyContr,
                                    portfolioValue: $portfolioValue,
                                    onDelete: { self.buttonsCreated[index] = false }
                                )
                            }
                            .listRowBackground(Color.black)
                            .swipeActions(edge: .leading, allowsFullSwipe: false) {
                                Button(role: .destructive, action: {
                                    buttonsCreated[index] = false
                                }) {
                                    Label("Delete", systemImage: "trash")
                                }
                                .tint(.red)
                            }
                        } else {
                            HStack {
                                GoalButtonView(
                                    buttonState: $buttonStates[index],
                                    buttonCreated: $buttonsCreated[index],
                                    selectedInvestment: $selectedInvestment,
                                    avgRates: $avgRates,
                                    avgMonthlyContr: $avgMonthlyContr,
                                    portfolioValue: $portfolioValue,
                                    onDelete: { self.buttonsCreated[index] = false }
                                )
                            }
                            .listRowBackground(Color.black)
                        }
                    }
                }
                .onMove(perform: move)
                .background(Color.black.ignoresSafeArea())
                
            }
            .listStyle(PlainListStyle())
            .background(Color.black.ignoresSafeArea())
        }
        .background(Color.black.ignoresSafeArea())
        .onChange(of: buttonsCreated) {
            let numNotCreated = buttonsCreated.map({$0 ? 0 : 1}).reduce(0, +)
            if numNotCreated == 0 || buttonsCreated.count == 0 {
                withAnimation {
                    buttonStates.append(
                        GoalButtonState(
                            name: "",
                            image: "Icon",
                            amount: nil,
                            date: nil,
                            color: .blue,
                            borderColor: .cyan,
                            textBoxColor: .teal
                        )
                    )
                    buttonsCreated.append(false)
                }
            } else if numNotCreated > 1 {
                if let index = buttonsCreated.firstIndex(where: {$0 == false}) {
                    buttonStates.remove(at: index)
                    buttonsCreated.remove(at: index)
                }
            }
        }
        .onChange(of: selectedInvestment) {
            getAllGoalDates()
        }
        .onAppear {
            getAllGoalDates()
        }
    }
    
    private func getAllGoalDates() {
        for i in buttonStates.indices {
            buttonStates[i].date = Utils.getGoalDate(
                amount: buttonStates[i].amount ?? 0.0,
                contribution: avgMonthlyContr,
                annualRate: avgRates[selectedInvestment] ?? 0.0,
                currentPortfolioValue: portfolioValue,
                graphData: sessionManager.graphData
            )
        }
    }
    
    private func move(from source: IndexSet, to destination: Int) {
        buttonStates.move(fromOffsets: source, toOffset: destination)
        buttonsCreated.move(fromOffsets: source, toOffset: destination)
    }
}

struct GoalButtonState: Equatable, Identifiable {
    var id = UUID()
    var name: String
    var image: String
    var amount: Double?
    var date: Date?
    var color: Color
    var borderColor: Color
    var textBoxColor: Color
}

#Preview {
    ProjectionsGoalsTabView(
        selectedInvestment: .constant(.VOO),
        avgMonthlyContr: .constant(0.0),
        avgRates: .constant([.VOO:0.0]),
        portfolioValue: .constant(0.0)
    )
}
