//
//  HomeView.swift
//  accumate_app
//
//  Created by Nevin Richards on 12/14/24.
//

import SwiftUI

struct HomeView: View {
    @EnvironmentObject var navManager: NavigationPathManager
    @EnvironmentObject var sessionManager: UserSessionManager
    @State private var tabSelected: HomeTabs = .stocks
//    private var currentData = [StockDataPoint(date: Date.now, price: 0.0), StockDataPoint(date: Date.now, price: 0.0)]
    
    var body: some View {
        VStack {
            Color.black
                .frame(height: 5)
                .edgesIgnoringSafeArea(.top)
            ScrollView {
                switch tabSelected {
                case .stocks:
                    HomeStocksView()
                case .cards:
                    HomeCardsView()
                case .account:
                    HomeAccountView()
                }
            }
            Spacer()
        }
        .background(Color.black.ignoresSafeArea())
        .navigationTitle("")
        .navigationBarBackButtonHidden(true)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            //            ToolbarItem(placement: .topBarTrailing) {
            //                Image(systemName: "line.3.horizontal")
            //                    .resizable()
            //                    .frame(width: 27, height: 20)
            //                    .foregroundColor(.white)
            //                    .padding()
            //            }
            ToolbarItemGroup(placement: .bottomBar) {
                HStack {
                    Spacer()
                    ForEach(HomeTabs.allCases, id: \.self) { tab in
                        Button {
                            tabSelected = tab
                        } label: {
                            Image(systemName: tab.imageName)
                                .resizable()
                                .scaledToFit()
                                .foregroundStyle(tabSelected == tab ? .white : .gray)
                                .frame(width: tab == .account ? 25 : 35, height: 25)
                        }
                        .padding(.horizontal, 25)
                        
                    }
                    Spacer()
                }
                .padding(.leading, -20)
            }
        }
    }
            
            
}

        
enum HomeTabs: CaseIterable {
    case stocks, cards, account

    var imageName: String {
        switch self {
        case .stocks: return "chart.line.uptrend.xyaxis"
        case .cards: return "creditcard"
        case .account: return "person.crop.circle"
        }
    }
    
}

#Preview {
    HomeStocksView()
        .environmentObject(NavigationPathManager())
}
