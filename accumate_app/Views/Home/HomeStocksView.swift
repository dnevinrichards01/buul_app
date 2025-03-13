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
    private var buttons: [String] = ["1D", "1W", "1M", "1Y", "YTD", "5Y", "All"]
//    private var allData: [[StockDataPoint]] = [
//        defaultDays,
//        defaultWeeks,
//        defaultMonths,
//        defaultThreeMonths,
//        defaultYTD,
//        defaultYears,
//        defaultAll,
//    ]
    private var allData: [[StockDataPoint]] = [
        stockData1,
        stockData2,
        stockData1,
        stockData2,
        stockData1,
        stockData2,
        stockData1
    ]
    
    @State private var selectedPeriod: TimePeriods = .day
    @State private var color: Color = .gray
//    private var currentData = [StockDataPoint(date: Date.now, price: 0.0), StockDataPoint(date: Date.now, price: 0.0)]
    
    var body: some View {
        VStack {
            switch selectedPeriod {
            case .day:
                StockGraphView(stockData: allData[0], color: color).frame(height: 500)
            case .week:
                StockGraphView(stockData: allData[1], color: color).frame(height: 500)
            case .month:
                StockGraphView(stockData: allData[2], color: color).frame(height: 500)
            case .threeMonths:
                StockGraphView(stockData: allData[3], color: color).frame(height: 500)
            case .year:
                StockGraphView(stockData: allData[4], color: color).frame(height: 500)
            case .ytd:
                StockGraphView(stockData: allData[5], color: color).frame(height: 500)
            case .fiveYears:
                StockGraphView(stockData: allData[6], color: color).frame(height: 500)
            case .all:
                StockGraphView(stockData: defaultAll, color: color).frame(height: 500)
            }
            
            ScrollView (.horizontal) {
                HStack {
                    ForEach(TimePeriods.allCases, id: \.self) { period in
                        Button {
                            selectedPeriod = period
                            color = changeColor(stockData: allData[period.index])
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
            
            VStack (alignment: .leading, spacing: 10) {
                Divider()
                    .foregroundStyle(.white)
                HStack {
                    Image(systemName: HomeTabs.stocks.imageName)
                        .resizable()
                        .scaledToFit()
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
        .frame(maxHeight: .infinity)
        .background(Color.black.ignoresSafeArea())
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) { // delay to ensure reset
                color = changeColor(stockData: allData[0])
            }
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


let stockData1: [StockDataPoint] = [
    StockDataPoint(date: Calendar.current.date(byAdding: .day, value: -10, to: Date())!, price: 120.87),
    StockDataPoint(date: Calendar.current.date(byAdding: .day, value: -9, to: Date())!, price: 122.55),
    StockDataPoint(date: Calendar.current.date(byAdding: .day, value: -8, to: Date())!, price: 121.30),
    StockDataPoint(date: Calendar.current.date(byAdding: .day, value: -7, to: Date())!, price: 121.34),
    StockDataPoint(date: Calendar.current.date(byAdding: .day, value: -6, to: Date())!, price: 121.34),
    StockDataPoint(date: Calendar.current.date(byAdding: .day, value: -5, to: Date())!, price: 125.74),
    StockDataPoint(date: Calendar.current.date(byAdding: .day, value: -4, to: Date())!, price: 125.65),
    StockDataPoint(date: Calendar.current.date(byAdding: .day, value: -3, to: Date())!, price: 135.55),
    StockDataPoint(date: Calendar.current.date(byAdding: .day, value: -2, to: Date())!, price: 128.26),
    StockDataPoint(date: Calendar.current.date(byAdding: .day, value: -1, to: Date())!, price: 140.04),
    StockDataPoint(date: Date(), price: 145.21)
]

let stockData2: [StockDataPoint] = [
    StockDataPoint(date: Calendar.current.date(byAdding: .day, value: -6, to: Date())!, price: 100),
    StockDataPoint(date: Calendar.current.date(byAdding: .day, value: -5, to: Date())!, price: 110),
    StockDataPoint(date: Calendar.current.date(byAdding: .day, value: -4, to: Date())!, price: 120),
    StockDataPoint(date: Calendar.current.date(byAdding: .day, value: -3, to: Date())!, price: 130),
    StockDataPoint(date: Calendar.current.date(byAdding: .day, value: -2, to: Date())!, price: 140),
    StockDataPoint(date: Calendar.current.date(byAdding: .day, value: -1, to: Date())!, price: 100),
    StockDataPoint(date: Date(), price: 145)
]

let calendar = Calendar.current

let startOfYear = calendar.date(
    from: DateComponents(
        year: calendar.component(.year, from: Date()),
        month: 1,
        day: 1
    )
)!

let startOfMonth = calendar.date(
    from: DateComponents(
        year: calendar.component(.year, from: Date()),
        month: calendar.component(.month, from: Date()),
        day: 1
    )
)!

let startOfDay = calendar.date(
    from: DateComponents(
        year: calendar.component(.year, from: Date()),
        month: calendar.component(.month, from: Date()),
        day: calendar.component(.month, from: Date())
    )
)!


let defaultDays: [StockDataPoint] = [
    StockDataPoint(date: startOfDay, price: 0),
    StockDataPoint(date: Date(), price: 0)
]

let defaultWeeks: [StockDataPoint] = [
    StockDataPoint(date: Calendar.current.date(byAdding: .day, value: -7, to: Date())!, price: 0),
    StockDataPoint(date: Date(), price: 0)
]
let defaultMonths: [StockDataPoint] = [
    StockDataPoint(date: startOfMonth, price: 0),
    StockDataPoint(date: Date(), price: 0)
]

let defaultThreeMonths: [StockDataPoint] = [
    StockDataPoint(date: Calendar.current.date(byAdding: .month, value: -3, to: Date())!, price: 0),
    StockDataPoint(date: Date(), price: 0)
]

let defaultYears: [StockDataPoint] = [
    StockDataPoint(date: startOfYear, price: 0),
    StockDataPoint(date: Date(), price: 0)
]

let defaultYTD: [StockDataPoint] = defaultYears

let defaultFiveYears: [StockDataPoint] = [
    StockDataPoint(date: Calendar.current.date(byAdding: .year, value: -5, to: Date())!, price: 0),
    StockDataPoint(date: Date(), price: 0)
]
let defaultAll: [StockDataPoint] = defaultYears



        
        
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


#Preview {
    HomeStocksView()
        .environmentObject(NavigationPathManager())
}
