//
//  ProjectionsGoalsTabView.swift
//  buul_app
//
//  Created by Nevin Richards on 7/9/25.
//

import SwiftUI

// maybe change plus to just a button below the stack, and we can add as many empty goals as we'd like...
struct ProjectionsInvestmentsTabView: View {
    @State private var buttonStates: [InvestmentButtonState] = [
        InvestmentButtonState(
            name: InvestmentButtonPresets.VOO.displayName,
            color: InvestmentButtonPresets.VOO.color,
            borderColor: InvestmentButtonPresets.VOO.borderColor
        ),
        InvestmentButtonState(
            name: InvestmentButtonPresets.QQQ.displayName,
            color: InvestmentButtonPresets.QQQ.color,
            borderColor: InvestmentButtonPresets.QQQ.borderColor
        ),
        InvestmentButtonState(
            name: InvestmentButtonPresets.cash.displayName,
            color: InvestmentButtonPresets.cash.color,
            borderColor: InvestmentButtonPresets.cash.borderColor
        )
    ]
    @State private var createNewButton: Bool = false
    @State private var displayedInvestmentsSet: Set<String> = [
        InvestmentButtonPresets.VOO.displayName,
        InvestmentButtonPresets.QQQ.displayName,
        InvestmentButtonPresets.cash.displayName,
    ]
    @Binding var selectedInvestment: InvestmentButtonPresets
    private var defaultInvestments: [String?] = [
        InvestmentButtonPresets.VOO.displayName,
        InvestmentButtonPresets.QQQ.displayName,
        InvestmentButtonPresets.cash.displayName,
        nil
    ]
    
    init(selectedInvestment: Binding<InvestmentButtonPresets>) {
        self._selectedInvestment = selectedInvestment
    }
    
    var body: some View {
        VStack {
            List {
                ForEach(buttonStates) { button in
                    if let index = buttonStates.firstIndex(of: button) {
                        if !defaultInvestments.contains(button.name) {
                            HStack {
                                InvestmentButtonView(
                                    buttonState: $buttonStates[index],
                                    createNewButton: $createNewButton,
                                    displayedInvestmentsSet: $displayedInvestmentsSet,
                                    selectedInvestment: $selectedInvestment,
                                    buttonStates: $buttonStates
                                )
                            }
                            .listRowBackground(Color.black)
                            .swipeActions(edge: .leading, allowsFullSwipe: false) {
                                Button(role: .destructive, action: {
                                    if selectedInvestment == getSelectedInvestmentFromName(buttonStates[index].name ?? "") {
                                        selectedInvestment = .VOO
                                    }
                                    displayedInvestmentsSet.remove(buttonStates[index].name ?? "")
                                    buttonStates.remove(at: index)
                                    if displayedInvestmentsSet.count == InvestmentButtonPresets.allCases.count - 1 {
                                        buttonStates.append(
                                            InvestmentButtonState(
                                                name: nil,
                                                color: .gray,
                                                borderColor: .white
                                            )
                                        )
                                    }
                                }) {
                                    Label("Delete", systemImage: "trash")
                                }
                                .tint(.red)
                            }
                        } else {
                            HStack {
                                InvestmentButtonView(
                                    buttonState: $buttonStates[index],
                                    createNewButton: $createNewButton,
                                    displayedInvestmentsSet: $displayedInvestmentsSet,
                                    selectedInvestment: $selectedInvestment,
                                    buttonStates: $buttonStates
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
        .onAppear {
            if displayedInvestmentsSet.count < InvestmentButtonPresets.allCases.count {
                buttonStates.append(
                    InvestmentButtonState(
                        name: nil,
                        color: .gray,
                        borderColor: .white
                    )
                )
            }
        }
    }
    
    private func move(from source: IndexSet, to destination: Int) {
        buttonStates.move(fromOffsets: source, toOffset: destination)
    }
    
    private func getSelectedInvestmentFromName(_ name: String) -> InvestmentButtonPresets {
        for inv in InvestmentButtonPresets.allCases {
            if inv.displayName == name {
                return inv
            }
        }
        return .VOO
    }
}

#Preview {
    ProjectionsInvestmentsTabView(
        selectedInvestment: .constant(.VOO)
    )
}
