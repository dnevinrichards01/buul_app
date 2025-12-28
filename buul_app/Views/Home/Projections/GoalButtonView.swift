//
//  GoalButtonView.swift
//  buul_app
//
//  Created by Nevin Richards on 7/9/25.
//

import SwiftUI

struct GoalButtonView: View {
    @EnvironmentObject var sessionManager: UserSessionManager
    @Binding var buttonState: GoalButtonState
    @Binding var buttonCreated: Bool
    @Binding var selectedInvestment: InvestmentButtonPresets
    @Binding var avgRates: [InvestmentButtonPresets:Double]
    @Binding var avgMonthlyContr: Double
    @Binding var portfolioValue: Double
    var onDelete: (() -> Void)? = nil
    
    @State private var expanded: Bool = false
    private var imageOptions: [String] = ["Icon", "Flag", "Car"]
    private var images: [String:String] = [
        "Icon": "chevron.down",
        "Flag": "flag",
        "Car": "car"
    ]
    
    init(
        buttonState: Binding<GoalButtonState>,
        buttonCreated: Binding<Bool>,
        selectedInvestment: Binding<InvestmentButtonPresets>,
        avgRates: Binding<[InvestmentButtonPresets:Double]>,
        avgMonthlyContr: Binding<Double>,
        portfolioValue: Binding<Double>,
        onDelete: (() -> Void)?
    ) {
        self._buttonState = buttonState
        self._buttonCreated = buttonCreated
        self._selectedInvestment = selectedInvestment
        self._avgMonthlyContr = avgMonthlyContr
        self._avgRates = avgRates
        self._portfolioValue = portfolioValue
        self.onDelete = onDelete
    }
    
    var body: some View {
        VStack (spacing: 10) {
            Button {
                expanded.toggle()
            } label: {
                HStack {
                    if !buttonCreated {
                        Image(systemName: "plus")
                            .font(.title3)
                            .foregroundColor(.white)
                            .background(.clear)
                    } else {
                        Image(systemName: buttonState.image == "Icon" ? "" : images[buttonState.image] ?? "flag")
                            .font(.title3)
                            .foregroundColor(.white)
                            .background(.clear)
                        Text("\(buttonState.name) \(formatAmount(buttonState.amount ?? 0.0)) \(formatDate(buttonState.date ?? .now))")
                            .font(.headline)
                            .foregroundColor(.white)
                            .background(.clear)
                        Image(systemName: "chevron.down")
                            .font(.headline)
                            .foregroundColor(.white)
                            .background(.clear)
                            .rotationEffect(.degrees(expanded ? 180 : 0))
                    }
                }
                .frame(maxWidth: .infinity)
                .animation(.none, value: expanded)
            }
            if expanded {
                VStack (spacing: 5) {
                    Text("Edit Goal:")
                        .font(.headline)
                        .foregroundColor(.white)
                        .background(.clear)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    VStack (alignment: .leading, spacing: 10) {
                        Menu {
                            ForEach(imageOptions, id: \.self) { option in
                                Button {
                                    buttonState.image = option
                                } label: {
                                    HStack {
                                        Text(option)
                                        Spacer()
                                        Image(systemName: images[option] ?? "flag")
                                    }
                                }
                            }
                        } label: {
                            HStack {
                                Text(buttonState.image)
                                Spacer()
                                Image(systemName: images[buttonState.image] ?? "flag")
                            }
                            .frame(minWidth: 60) // gives area
                            .frame(maxWidth: .infinity) // will take up area
                            .contentShape(Rectangle()) // defines tappable area
                        }
                        .foregroundColor(.white)
                        .padding(.horizontal)
                        .frame(maxWidth: .infinity)
                        .background(!buttonCreated ? selectedInvestment.borderColor : .blue)//.textBoxColor)
                        .cornerRadius(20)
                        TextField("Name", text: $buttonState.name)
                            .padding(.leading, 13)
                            .padding(.trailing, 5)
                            .font(.subheadline)
                            .foregroundColor(.white)
                            .background(!buttonCreated ? selectedInvestment.borderColor : .cyan)//.textBoxColor)
                            .cornerRadius(20)
                        TextField("Amount (USD)", value: $buttonState.amount, formatter: getNumberFormatter())
                            .padding(.leading, 13)
                            .padding(.trailing, 5)
                            .font(.subheadline)
                            .foregroundColor(.white)
                            .background(!buttonCreated ? selectedInvestment.borderColor : .cyan)//buttonState.textBoxColor)
                            .cornerRadius(20)
                            .keyboardType(.decimalPad)
                    }
                    .padding(.leading, 15)
                }
            }
        }
        .padding()
        .background(selectedInvestment.color.cornerRadius(20))//!buttonCreated ? selectedInvestment.color.cornerRadius(20) : Color.blue.cornerRadius(20))//buttonState.color.cornerRadius(20))
        .overlay(
            RoundedRectangle(cornerRadius: 20)
                .stroke(!buttonCreated ? selectedInvestment.borderColor : .cyan, lineWidth: 4)
        )
        .onChange(of: expanded) {
            if !expanded {
                if buttonState.amount != nil || buttonState.image != "Icon" || buttonState.name != "" {
                    buttonCreated = true
                    buttonState.date = Utils.getGoalDate(
                        amount: buttonState.amount ?? 0.0,
                        contribution: avgMonthlyContr,
                        annualRate: avgRates[selectedInvestment] ?? 0.0,
                        currentPortfolioValue: portfolioValue,
                        graphData: sessionManager.graphData
                    )
                } else {
                    withAnimation {
                        onDelete?()
                    }
                }
            }
        }
    }

    private func getNumberFormatter() -> NumberFormatter {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        return formatter
    }
    
    private func formatAmount(_ amount: Double) -> String {
        if amount < 1000 {
            return String(format: "$%d", Int(round(amount)))
//            return String(format: "$%.2f%", amount)
        } else if amount < 1000000 {
            let thousands = amount / 1000
//            return String(format: "$%.2f%K", thousands)
            return String(format: "$%d%K", Int(round(thousands)))
        } else {
            let millions = amount / 1000000
            return String(format: "$%.1f%M", millions)
        }
    }
    
    private func formatDate(_ date: Date) -> String {
        if date >= Date.distantFuture {
            return "in 4+ millenia"
        }
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM, yyyy"
        return "by \(formatter.string(from: date))"
    }
}

#Preview {
    GoalButtonView(
        buttonState: .constant(
            GoalButtonState(
                name: "",
                image: "Icon",
                amount: nil,
                date: .now,
                color: .blue,
                borderColor: .cyan,
                textBoxColor: .teal
            )
        ),
        buttonCreated: .constant(false),
        selectedInvestment: .constant(.VOO),
        avgRates: .constant([:]),
        avgMonthlyContr: .constant(0.0),
        portfolioValue: .constant(0.0),
        onDelete: {}
    )
}
