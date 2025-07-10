//
//  GoalButtonView.swift
//  buul_app
//
//  Created by Nevin Richards on 7/9/25.
//

import SwiftUI

struct GoalButtonView: View {
    @Binding var buttonState: GoalButtonState
    @Binding var buttonCreated: Bool
    var buttonIndex: Int
    var onDelete: (() -> Void)? = nil
    
    @State private var expanded: Bool = false
    private var imageOptions: [String] = ["flag", "car"]
    private var images: [String:String] = [
        "flag": "flag",
        "car": "car"
    ]
    
    init(
        buttonState: Binding<GoalButtonState>,
        buttonCreated: Binding<Bool>,
        buttonIndex: Int,
        onDelete: (() -> Void)?
    ) {
        self._buttonState = buttonState
        self._buttonCreated = buttonCreated
        self.buttonIndex = buttonIndex
        self.onDelete = onDelete
    }
    
    var body: some View {
        VStack (spacing: 10) {
            Button {
                expanded.toggle()
            } label: {
                HStack {
                    if buttonState.amount == nil && buttonState.image == "plus" && buttonState.name == "" {
                        Image(systemName: "plus")
                            .font(.title3)
                            .foregroundColor(.white)
                            .background(.clear)
                    } else {
                        Image(systemName: buttonState.image)
                            .font(.title3)
                            .foregroundColor(.white)
                            .background(.clear)
                        Text(buttonState.name)
                            .font(.headline)
                            .foregroundColor(.white)
                            .background(.clear)
                        Text(formatAmount(buttonState.amount ?? 0.0))
                            .font(.headline)
                            .foregroundColor(.white)
                            .background(.clear)
                        Text("by \(formatDate(buttonState.date ?? .now))")
                            .font(.headline)
                            .foregroundColor(.white)
                            .background(.clear)
                        Spacer()
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
                        HStack {
                            Text("Icon: ")
                                .font(.headline)
                                .foregroundColor(.white)
                                .background(.clear)
                                .frame(width: 80, alignment: .leading)
                            Picker("Select an option", selection: $buttonState.image) {
                                ForEach(imageOptions, id: \.self) { option in
                                    HStack {
                                        Text(option)
                                            .foregroundColor(.white)
                                        Image(systemName: images[option] ?? "flag")
                                            .resizable()
                                            .frame(width: 15, height: 15)
                                            .foregroundColor(.white)
                                    }
//                                    .frame(minWidth: .infinity, alignment: .leading)
                                    .foregroundStyle(.white)
                                }
                            }
                            .foregroundColor(.white)
                            .pickerStyle(MenuPickerStyle())
                            .background(buttonState.textBoxColor)
                            .cornerRadius(20)
                        }
                        HStack {
                            Text("Name: ")
                                .font(.headline)
                                .foregroundColor(.white)
                                .background(.clear)
                                .frame(width: 80, alignment: .leading)
                            TextField("", text: $buttonState.name)
                                .padding(.leading, 13)
                                .padding(.trailing, 5)
                                .font(.subheadline)
                                .foregroundColor(.white)
                                .background(buttonState.textBoxColor)
                                .cornerRadius(20)
                        }
                        HStack {
                            Text("Amount: ")
                                .font(.headline)
                                .foregroundColor(.white)
                                .background(.clear)
                                .frame(width: 80, alignment: .leading)
                            TextField("", value: $buttonState.amount, formatter: getNumberFormatter())
                                .padding(.leading, 13)
                                .padding(.trailing, 5)
                                .font(.subheadline)
                                .foregroundColor(.white)
                                .background(buttonState.textBoxColor)
                                .cornerRadius(20)
                                .keyboardType(.decimalPad)
                        }
                    }
                    .padding(.leading, 15)
                }
                .transition(.asymmetric(insertion: .move(edge: .bottom), removal: .identity))
                .animation(.easeInOut(duration: 0.3), value: expanded)
            }
        }
        .padding()
        .animation(.easeInOut(duration: 0.5), value: expanded)
        .cornerRadius(20)
        .background(buttonState.color.cornerRadius(20))
        .overlay(
            RoundedRectangle(cornerRadius: 20)
                .stroke(buttonState.borderColor, lineWidth: 4)
        )
        .onChange(of: expanded) {
            if !expanded {
                if buttonState.amount != nil || buttonState.image != "plus" || buttonState.name != "" {
//                    withAnimation {
//                        onCreate?()
//                    }
                    buttonCreated = true
                } else {
                    withAnimation {
                        onDelete?()
                    }
                    
                }
            }
//            print("buttonCreated", buttonCreated, index)
        }
    }

    private func getNumberFormatter() -> NumberFormatter {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        return formatter
    }
    
    private func formatAmount(_ amount: Double) -> String {
        if amount < 1000 {
            return String(format: "$%.2f%", amount)
        } else if amount < 1000000 {
            let thousands = amount / 1000
            return String(format: "$%.2f%K", thousands)
        } else {
            let millions = amount / 1000000
            return String(format: "$%.2f%M", millions)
        }
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM, yyyy"
        return formatter.string(from: date)
    }
}

#Preview {
    GoalButtonView(
        buttonState: .constant(
            GoalButtonState(
                name: "",
                image: "plus",
                amount: nil,
                date: .now,
                color: .blue,
                borderColor: .cyan,
                textBoxColor: .teal
            )
        ),
        buttonCreated: .constant(false),
        buttonIndex: 0,
        onDelete: {}
    )
}
