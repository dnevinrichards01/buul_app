//
//  CreateGoalView.swift
//  buul_app
//
//  Created by Nevin Richards on 7/9/25.
//

import SwiftUI

// maybe change plus to just a button below the stack, and we can add as many empty goals as we'd like...
struct CreateGoalView: View {
    @State private var buttonStates: [GoalButtonState] = [
        GoalButtonState(
            name: "",
            image: "plus",
            amount: nil,
            date: nil,
            color: .blue,
            borderColor: .cyan,
            textBoxColor: .teal
        )
    ]
    @State private var buttonsCreated: [Bool] = [false]
    
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
                                    buttonIndex: index,
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
                                    buttonIndex: index,
                                    onDelete: { self.buttonsCreated[index] = false }
                                )
                            }
                            .listRowBackground(Color.black)
                        }
                    }
                }
                .background(Color.black.ignoresSafeArea())
//                .onMove(perform: move)
            }
            .listStyle(PlainListStyle())
            .background(Color.black.ignoresSafeArea())
//            .listStyle(PlainListStyle())
        }
        .padding()
        .background(Color.black.ignoresSafeArea())
        .onChange(of: buttonsCreated) {
            let numNotCreated = buttonsCreated.map({$0 ? 0 : 1}).reduce(0, +)
            if numNotCreated == 0 || buttonsCreated.count == 0 {
                withAnimation {
                    buttonStates.append(
                        GoalButtonState(
                            name: "",
                            image: "plus",
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
    }
    
    private func move(from source: IndexSet, to destination: Int) {
        buttonStates.move(fromOffsets: source, toOffset: destination)
        buttonsCreated.move(fromOffsets: source, toOffset: destination) // Make sure both arrays stay in sync
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

//struct InvestmentButtonState: Equatable, Identifiable {
//    var id = UUID()
//    var name: String
//    var borderColor: Color
//    var textBoxColor: Color
//}

#Preview {
    CreateGoalView()
}
