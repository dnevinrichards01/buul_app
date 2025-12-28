//
//  InvestmentButtonView.swift
//  buul_app
//
//  Created by Nevin Richards on 7/9/25.
//

import SwiftUI

struct InvestmentButtonState: Equatable, Identifiable {
    var id = UUID()
    var name: String?
    var color: Color
    var borderColor: Color
}

enum InvestmentButtonPresets: CaseIterable {
    case cash
    case VOO
    case QQQ
//    case BTC
    
    var color: Color {
        switch self {
        case .cash: return .green
        case .VOO: return .blue
        case .QQQ: return .orange
//        case .BTC: return .purple
        }
    }
    
    var borderColor: Color {
        switch self {
        case .cash: return .yellow
        case .VOO: return .cyan
        case .QQQ: return .yellow
//        case .BTC: return .pink
        }
    }
    
    var displayName: String {
        switch self {
        case .cash: return "Cash"
        case .VOO: return "VOO (S&P500)"
        case .QQQ: return "QQQ"
//        case .BTC: return "BTC"
        }
    }
}

struct InvestmentButtonView: View {
    @Binding var buttonState: InvestmentButtonState
    @Binding var createNewButton: Bool
    @Binding var displayedInvestmentsSet: Set<String>
    @Binding var buttonStates: [InvestmentButtonState]
    @Binding var selectedInvestment: InvestmentButtonPresets
    
    init(
        buttonState: Binding<InvestmentButtonState>,
        createNewButton: Binding<Bool>,
        displayedInvestmentsSet: Binding<Set<String>>,
        selectedInvestment: Binding<InvestmentButtonPresets>,
        buttonStates: Binding<[InvestmentButtonState]>
    ) {
        self._buttonState = buttonState
        self._createNewButton = createNewButton
        self._displayedInvestmentsSet = displayedInvestmentsSet
        self._buttonStates = buttonStates
        self._selectedInvestment = selectedInvestment
    }
    
    var body: some View {
        HStack {
            if let name = buttonState.name {
                Button {
                    if let name = buttonState.name {
                        selectedInvestment = getSelectedInvestmentFromName(name)
                    }
                } label: {
                    HStack {
                        Text(name)
                            .foregroundStyle(.white)
                            .frame(maxWidth: .infinity, alignment: .center)
                            .multilineTextAlignment(.center)

                    }
                    .frame(maxWidth: .infinity, alignment: .center)
                    .contentShape(Rectangle())
                }
            } else {
                Menu {
                    ForEach(InvestmentButtonPresets.allCases, id: \.self) { option in
                        if !displayedInvestmentsSet.contains(option.displayName) {
                            Button {
                                buttonState.name = option.displayName
                                buttonState.color = option.color
                                buttonState.borderColor = option.borderColor
                                displayedInvestmentsSet.insert(option.displayName)
                                if displayedInvestmentsSet.count < InvestmentButtonPresets.allCases.count {
                                    buttonStates.append(
                                        InvestmentButtonState(
                                            name: nil,
                                            color: .gray,
                                            borderColor: .white
                                        )
                                    )
                                }
                            } label: {
                                Text(option.displayName)
                            }
                        }
                    }
                } label: {
                    HStack {
                        Image(systemName: "plus")
                            .foregroundStyle(.white)
                    }
                    .frame(minWidth: 60)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .contentShape(Rectangle())
                }
            }
        }
        .foregroundColor(.white)
        .padding(.horizontal)
        .frame(maxWidth: .infinity)
        .background(buttonState.color)
        .cornerRadius(20)
        .overlay {
            RoundedRectangle(cornerRadius: 20)
                .stroke(
                    selectedInvestment.displayName == buttonState.name ? buttonState.borderColor : buttonState.color,
                    lineWidth: selectedInvestment.displayName == buttonState.name ? 4 : 2
                )
        }
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
    InvestmentButtonView(
        buttonState: .constant(
            InvestmentButtonState(
                name: "VOO",
                color: .blue,
                borderColor: .cyan
            )
        ),
        createNewButton: .constant(false),
        displayedInvestmentsSet: .constant(Set<String>()),
        selectedInvestment: .constant(.VOO),
        buttonStates: .constant([])
    )
}
