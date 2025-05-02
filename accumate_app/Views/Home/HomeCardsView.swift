//
//  SwiftUIView.swift
//  accumate_app
//
//  Created by Nevin Richards on 12/12/24.
//

import SwiftUI

struct HomeCardsView: View {
    @State private var cards: [Card] = cardsList
    @State private var selectedCard: Card?
    
    @EnvironmentObject var navManager : NavigationPathManager

    var body: some View {
        VStack {
            // Header Text
            Text("Cards to Maximize Cashback")
                .font(.title)
                .fontWeight(.bold)
                .multilineTextAlignment(.leading)
                .padding(.top, 20)
                .padding(.horizontal, 20)
                .foregroundStyle(.white)

            // Scrollable Button List
            ScrollView {
                Text("We update this page with the best cards for each of your highest spending categories. Click them for more information and to sign up!")
                    .foregroundStyle(.white)
                    .font(.footnote)
                    .padding(.horizontal, 20)
                    .multilineTextAlignment(.leading)
                
                VStack(spacing: 10) {
                    ForEach(cards, id: \.self) { card in
                        Button {
                            if selectedCard == card {
                                selectedCard = nil
                            } else {
                                selectedCard = card
                            }
                        } label: {
                            HomeCardsButtonView(
                                imageName: card.imageName,
                                title: card.name,
                                subtitle: card.description,
                                isToggled: selectedCard == card,
                                url: card.url,
                                category: card.category,
                                categoryPercentage: card.categoryPercentage
                            )
                        }
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .padding(.horizontal, 16)
                        .animation(.easeInOut(duration: 0.4), value: selectedCard)
                    }
                }
                .padding(.top, 10)
                .animation(.easeInOut(duration: 0.4), value: cards)
                .onAppear {
//                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
//                        getSpendingCategories()
//                    }
                }
            }
            .background(.black)
        }
        .padding(.bottom, 10)
        .background(Color.black.ignoresSafeArea())
    }
    
    func getSpendingCategories() {
        self.cards = self.cards.reversed()
    }
}




#Preview {
    HomeCardsView()
        .environmentObject(NavigationPathManager())
}
