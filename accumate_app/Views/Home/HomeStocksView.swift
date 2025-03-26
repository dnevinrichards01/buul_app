//
//  HomeView.swift
//  accumate_app
//
//  Created by Nevin Richards on 12/14/24.
//

import SwiftUI

struct HomeStocksView: View {
    @EnvironmentObject var navManager: NavigationPathManager
    @State private var selected: Int?
//    @Binding var graphData: [RecieveStockDataPoint]
    private var buttons: [String] = ["1D", "1W", "1M", "1Y", "YTD", "5Y", "All"]
    @Binding var processedData: [[StockDataPoint]]
    @State private var selectedPeriod: TimePeriods = .day
    @State private var color: Color = .gray
    
    init(processedData: Binding<[[StockDataPoint]]>) {
        self._processedData = processedData
    }
    
    var body: some View {
        VStack {
            switch selectedPeriod {
            case .day:
                let stockData = processedData[0]
                StockGraphView(
                    stockData: stockData,
                    timePeriod: .day,
                    color: changeColor(stockData: stockData)
                )
                .frame(height: 500)
            case .week:
                let stockData = processedData[1]
                StockGraphView(
                    stockData: stockData,
                    timePeriod: .week,
                    color: changeColor(stockData: stockData)
                )
                .frame(height: 500)
            case .month:
                let stockData = processedData[2]
                StockGraphView(
                    stockData: stockData,
                    timePeriod: .month,
                    color:  changeColor(stockData: stockData)
                )
                .frame(height: 500)
            case .threeMonths:
                let stockData = processedData[3]
                StockGraphView(
                    stockData: stockData,
                    timePeriod: .threeMonths,
                    color:  changeColor(stockData: stockData)
                )
                .frame(height: 500)
            case .ytd:
                let stockData = processedData[4]
                StockGraphView(
                    stockData: stockData,
                    timePeriod: .ytd,
                    color:  changeColor(stockData: stockData)
                )
                .frame(height: 500)
            case .year:
                let stockData = processedData[5]
                StockGraphView(
                    stockData: stockData,
                    timePeriod: .year,
                    color:  changeColor(stockData: stockData)
                )
                .frame(height: 500)
            case .fiveYears:
                let stockData = processedData[6]
                StockGraphView(
                    stockData: stockData,
                    timePeriod: .fiveYears,
                    color: changeColor(stockData: stockData)
                )
                .frame(height: 500)
            case .all:
                let stockData = processedData[7]
                StockGraphView(
                    stockData: stockData,
                    timePeriod: .all,
                    color: changeColor(stockData: stockData)
                )
                .frame(height: 500)
            }
            
            ScrollView (.horizontal) {
                HStack {
                    ForEach(TimePeriods.allCases, id: \.self) { period in
                        Button {
                            selectedPeriod = period
                            let stockData = processedData[period.index]
                            color = changeColor(stockData: stockData)
                        } label: {
                            VStack {
                                Text(period.displayName)
                                    .lineLimit(1)
                                    .foregroundStyle(selectedPeriod == period ? color : .white)
                                Rectangle()
                                    .fill(selectedPeriod == period ? color : .black)
                                    .frame(width: 25, height: 2)
                                    .padding(.top, -8)
                            }
                        }
                        .padding(.horizontal, 10)
                        Spacer()
                    }
                }
            }
            .scrollIndicators(.hidden)
            
            VStack (alignment: .leading, spacing: 10) {
                Divider()
                    .foregroundStyle(.white)
                HStack {
                    Image(systemName: HomeTabs.stocks.imageName)
                        .resizable()
                        .scaledToFit()
                        .foregroundStyle(.white)
                        .frame(width: 20, height: 16)
                    Text("You can view the cumulative sum of your investments made through Accumate here.")
                        .foregroundStyle(.white)
                        .font(.footnote)
                        .padding(.leading, 10)
                        .multilineTextAlignment(.leading)
                }
                .padding(.horizontal, 20)
                Divider()
                    .foregroundStyle(.white)
                HStack {
                    Image(systemName: HomeTabs.cards.imageName)
                        .resizable()
                        .scaledToFit()
                        .foregroundStyle(.white)
                        .frame(width: 20, height: 16)
                    Text("Want to maximize your cashback? Check our card recommendations based on your transactions")
                        .foregroundStyle(.white)
                        .font(.footnote)
                        .padding(.leading, 10)
                        .multilineTextAlignment(.leading)
                }
                .padding(.horizontal, 20)
            }
            .padding(.vertical, 10)
        }
        .onChange(of: processedData) {
//            guard let processedGraphData = processedGraphData else { return }
            self.color = changeColor(stockData: processedData[selectedPeriod.index])
        }
        .frame(maxHeight: .infinity)
        .background(Color.black.ignoresSafeArea())
        .onAppear {
//            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) { // delay to ensure reset
//                color = changeColor(stockData: data[0])
//            }
        }
    }
    
    func changeColor(stockData: [StockDataPoint]) -> Color {
        guard stockData.count > 1 else { return .gray }
        let change = stockData.last!.price - stockData[0].price
        if change > 0 {
            return .green
        } else if change < 0 {
            return .red
        } else {
            return .gray
        }
    }
    
    
    
    
    
    
    
    
    

}



        
struct StockDataPoints: Codable {
    let data: [RecieveStockDataPoint]
}

struct RecieveStockDataPoint: Hashable, Codable {
    let date: String
    let price: Double
}

struct StockDataPoint: Identifiable, Hashable, Codable {
    let id = UUID()
    let date: Date
    let price: Double

    enum CodingKeys: String, CodingKey {
        case date, price
    }
}



enum TimePeriods: CaseIterable {
    case day, week, month, threeMonths, year, ytd, fiveYears, all

    var displayName: String {
        switch self {
        case .day: return "1D"
        case .week: return "1W"
        case .month: return "1M"
        case .threeMonths: return "3M"
        case .year: return "1Y"
        case .ytd: return "YTD"
        case .fiveYears: return "5Y"
        case .all: return "All"
        }
    }
    
    var index: Int {
        switch self {
        case .day: return 0
        case .week: return 1
        case .month: return 2
        case .threeMonths: return 3
        case .year: return 4
        case .ytd: return 5
        case .fiveYears: return 6
        case .all: return 7
        }
    }
}

//
//#Preview {
//    HomeStocksView(graphData: nil)
//        .environmentObject(NavigationPathManager())
//}
