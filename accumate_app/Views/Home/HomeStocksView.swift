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
    @Binding var graphData: [RecieveStockDataPoint]?
    private var buttons: [String] = ["1D", "1W", "1M", "1Y", "YTD", "5Y", "All"]
    private var defaultData: [[StockDataPoint]] = [
        defaultDays,
        defaultWeeks,
        defaultMonths,
        defaultThreeMonths,
        defaultYTD,
        defaultYears,
        defaultFiveYears,
        defaultAll,
    ]
    @State private var processedGraphData: [[StockDataPoint]]?
    @State private var selectedPeriod: TimePeriods = .day
    @State private var color: Color = .gray
    
    init(graphData: Binding<[RecieveStockDataPoint]?>) {
        self._graphData = graphData
    }
    
    var body: some View {
        let data = processedGraphData ?? defaultData
        VStack {
            switch selectedPeriod {
            case .day:
                StockGraphView(stockData: data[0], color: color).frame(height: 500)
            case .week:
                StockGraphView(stockData: data[1], color: color).frame(height: 500)
            case .month:
                StockGraphView(stockData: data[2], color: color).frame(height: 500)
            case .threeMonths:
                StockGraphView(stockData: data[3], color: color).frame(height: 500)
            case .year:
                StockGraphView(stockData: data[4], color: color).frame(height: 500)
            case .ytd:
                StockGraphView(stockData: data[5], color: color).frame(height: 500)
            case .fiveYears:
                StockGraphView(stockData: data[6], color: color).frame(height: 500)
            case .all:
                StockGraphView(stockData: data[7], color: color).frame(height: 500)
            }
            
            ScrollView (.horizontal) {
                HStack {
                    ForEach(TimePeriods.allCases, id: \.self) { period in
                        Button {
                            selectedPeriod = period
                            color = changeColor(stockData: data[period.index])
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
        .onChange(of: graphData) {
            processedGraphData = processGraphData(graphData: graphData)
        }
        .frame(maxHeight: .infinity)
        .background(Color.black.ignoresSafeArea())
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) { // delay to ensure reset
                color = changeColor(stockData: data[0])
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
    
    
    enum DateParsingError: Error {
        case invalidISODateString
        case dateComputationError
    }
    
    func isoformatToDate(isoDateString: String) throws -> Date {
        let formatter = ISO8601DateFormatter()
        formatter.timeZone = TimeZone(secondsFromGMT: 0)  // explicitly UTC
        guard let date = formatter.date(from: isoDateString) else {
            throw DateParsingError.invalidISODateString
        }
        return date
    }
    
    func processGraphData(graphData: [RecieveStockDataPoint]?) -> [[StockDataPoint]]? {
        guard let graphData = graphData else { return nil }
        
        let now = Date()
        
        let graphDataWithDates: [StockDataPoint]
        do {
            graphDataWithDates = try graphData.map {
                StockDataPoint(date: try isoformatToDate(isoDateString: $0.date), price: $0.price)
            }
        } catch {
            return nil
        }
          
        let day: [StockDataPoint]
        do {
            day = try graphDataWithDates.filter {
                if let cutoff = Calendar.current.date(byAdding: .hour, value: -24, to: Date()) {
                    $0.date >= cutoff
                } else {
                    throw DateParsingError.dateComputationError
                }
            }
        } catch {
            return nil
        }
        
        let week: [StockDataPoint]
        let month: [StockDataPoint]
        let threeMonths: [StockDataPoint]
        let hourlyGrouped: [Date : [StockDataPoint]]
        do {
            hourlyGrouped = try Dictionary(grouping: graphDataWithDates) {
                let dateGroupComponents = Calendar.current.dateComponents([.year, .month, .day, .hour], from: $0.date)
                if let group = Calendar.current.date(from: dateGroupComponents) {
                    return group
                } else {
                    throw DateParsingError.dateComputationError
                }
            }
            
            week = try hourlyGrouped.values.compactMap { $0.max(by: { $0.date < $1.date }) }
                .filter {
                    if let cutoff = calendar.dateInterval(of: .weekOfYear, for: now)?.start {
                        $0.date >= cutoff
                    } else {
                        throw DateParsingError.dateComputationError
                    }
                }
            month = try hourlyGrouped.values.compactMap { $0.max(by: { $0.date < $1.date }) }
                .filter {
                    if let cutoff = Calendar.current.date(byAdding: .month, value: -1, to: Date()) {
                        $0.date >= cutoff
                    } else {
                        throw DateParsingError.dateComputationError
                    }
                }
            threeMonths = try hourlyGrouped.values.compactMap { $0.max(by: { $0.date < $1.date }) }
                .filter {
                    if let cutoff = Calendar.current.date(byAdding: .month, value: -3, to: Date()) {
                        $0.date >= cutoff
                    } else {
                        throw DateParsingError.dateComputationError
                    }
                }
        } catch {
            return nil
        }
        
        let ytd: [StockDataPoint]
        let year: [StockDataPoint]
        let fiveYears: [StockDataPoint]
        let dailyGrouped: [Date : [StockDataPoint]]
        do {
            dailyGrouped = try Dictionary(grouping: graphDataWithDates) {
                let dateGroupComponents = Calendar.current.dateComponents([.year, .month, .day], from: $0.date)
                if let group = Calendar.current.date(from: dateGroupComponents) {
                    return group
                } else {
                    throw DateParsingError.dateComputationError
                }
            }
            
            ytd = try dailyGrouped.values.compactMap { $0.max(by: { $0.date < $1.date }) }
                .filter {
                    if let cutoff = calendar.dateInterval(of: .year, for: now)?.start {
                        $0.date >= cutoff
                    } else {
                        throw DateParsingError.dateComputationError
                    }
                }
            year = try dailyGrouped.values.compactMap { $0.max(by: { $0.date < $1.date }) }
                .filter {
                    if let cutoff = Calendar.current.date(byAdding: .year, value: -1, to: Date()) {
                        $0.date >= cutoff
                    } else {
                        throw DateParsingError.dateComputationError
                    }
                }
            fiveYears = try dailyGrouped.values.compactMap { $0.max(by: { $0.date < $1.date }) }
                .filter {
                    if let cutoff = Calendar.current.date(byAdding: .year, value: -5, to: Date()) {
                        $0.date >= cutoff
                    } else {
                        throw DateParsingError.dateComputationError
                    }
                }
        } catch {
            return nil
        }
        
        
        let all: [StockDataPoint]
        let monthlyGrouped: [Date : [StockDataPoint]]
        do {
            monthlyGrouped = try Dictionary(grouping: graphDataWithDates) {
                let dateGroupComponents = Calendar.current.dateComponents([.year, .month], from: $0.date)
                if let group = Calendar.current.date(from: dateGroupComponents) {
                    return group
                } else {
                    throw DateParsingError.dateComputationError
                }
            }
            
            all = monthlyGrouped.values.compactMap { $0.max(by: { $0.date < $1.date }) }
        } catch {
            return nil
        }

        
        return [day, week, month, threeMonths, ytd, year, fiveYears, all]
    }
}



//let stockData1: [StockDataPoint] = [
//    StockDataPoint(date: Calendar.current.date(byAdding: .day, value: -10, to: Date())!, price: 120.87),
//    StockDataPoint(date: Calendar.current.date(byAdding: .day, value: -9, to: Date())!, price: 122.55),
//    StockDataPoint(date: Calendar.current.date(byAdding: .day, value: -8, to: Date())!, price: 121.30),
//    StockDataPoint(date: Calendar.current.date(byAdding: .day, value: -7, to: Date())!, price: 121.34),
//    StockDataPoint(date: Calendar.current.date(byAdding: .day, value: -6, to: Date())!, price: 121.34),
//    StockDataPoint(date: Calendar.current.date(byAdding: .day, value: -5, to: Date())!, price: 125.74),
//    StockDataPoint(date: Calendar.current.date(byAdding: .day, value: -4, to: Date())!, price: 125.65),
//    StockDataPoint(date: Calendar.current.date(byAdding: .day, value: -3, to: Date())!, price: 135.55),
//    StockDataPoint(date: Calendar.current.date(byAdding: .day, value: -2, to: Date())!, price: 128.26),
//    StockDataPoint(date: Calendar.current.date(byAdding: .day, value: -1, to: Date())!, price: 140.04),
//    StockDataPoint(date: Date(), price: 145.21)
//]
//
//let stockData2: [StockDataPoint] = [
//    StockDataPoint(date: Calendar.current.date(byAdding: .day, value: -6, to: Date())!, price: 100),
//    StockDataPoint(date: Calendar.current.date(byAdding: .day, value: -5, to: Date())!, price: 110),
//    StockDataPoint(date: Calendar.current.date(byAdding: .day, value: -4, to: Date())!, price: 120),
//    StockDataPoint(date: Calendar.current.date(byAdding: .day, value: -3, to: Date())!, price: 130),
//    StockDataPoint(date: Calendar.current.date(byAdding: .day, value: -2, to: Date())!, price: 140),
//    StockDataPoint(date: Calendar.current.date(byAdding: .day, value: -1, to: Date())!, price: 100),
//    StockDataPoint(date: Date(), price: 145)
//]
//
//    private var allData: [[StockDataPoint]] = [
//        stockData1,
//        stockData2,
//        stockData1,
//        stockData2,
//        stockData1,
//        stockData2,
//        stockData1
//    ]

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



        
struct StockDataPoints: Codable {
    let data: [RecieveStockDataPoint]
}

struct RecieveStockDataPoint: Identifiable, Hashable, Codable {
    let id = UUID()
    let date: String
    let price: Double

    enum CodingKeys: String, CodingKey {
        case date, price
    }
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
