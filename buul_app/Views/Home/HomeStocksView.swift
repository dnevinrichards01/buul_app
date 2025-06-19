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
    @Binding var processedData: [[StockDataPoint]]
    @State private var selectedPeriod: TimePeriods?
    
    @Binding var oneDayColor: Color
    @Binding var oneWeekColor: Color
    @Binding var oneMonthColor: Color
    @Binding var threeMonthsColor: Color
    @Binding var oneYearColor: Color
    @Binding var ytdColor: Color
    @Binding var allColor: Color
    @State private var selectedButtonColor: Color?
    
    init(
        processedData: Binding<[[StockDataPoint]]>,
        oneDayColor: Binding<Color>,
        oneWeekColor: Binding<Color>,
        oneMonthColor: Binding<Color>,
        threeMonthsColor: Binding<Color>,
        oneYearColor: Binding<Color>,
        ytdColor: Binding<Color>,
        allColor: Binding<Color>
    ) {
        self._processedData = processedData
        self._oneDayColor = oneDayColor
        self._oneWeekColor = oneWeekColor
        self._oneMonthColor = oneMonthColor
        self._threeMonthsColor = threeMonthsColor
        self._oneYearColor = oneYearColor
        self._ytdColor = ytdColor
        self._allColor = allColor
    }
    
    var body: some View {
        VStack {
            switch selectedPeriod {
            case .day:
                let stockData = processedData[0]
                StockGraphView(
                    stockData: stockData,
                    mostRecentValue: processedData[0].last!.price,
                    timePeriod: .oneDay,
                    color: getColorFromPeriod(period: .day)
                )
                .frame(height: 500)
            case .none:
                let stockData = processedData[0]
                StockGraphView(
                    stockData: stockData,
                    mostRecentValue: processedData[0].last!.price,
                    timePeriod: .oneDay,
                    color: getColorFromPeriod(period: .day)
                )
                .frame(height: 500)
            case .week:
                let stockData = processedData[1]
                StockGraphView(
                    stockData: stockData,
                    mostRecentValue: processedData[0].last!.price,
                    timePeriod: .oneWeek,
                    color: getColorFromPeriod(period: .week)
                )
                .frame(height: 500)
            case .month:
                let stockData = processedData[2]
                StockGraphView(
                    stockData: stockData,
                    mostRecentValue: processedData[0].last!.price,
                    timePeriod: .oneMonth,
                    color: getColorFromPeriod(period: .month)
                )
                .frame(height: 500)
            case .threeMonths:
                let stockData = processedData[3]
                StockGraphView(
                    stockData: stockData,
                    mostRecentValue: processedData[0].last!.price,
                    timePeriod: .threeMonths,
                    color: getColorFromPeriod(period: .threeMonths)
                )
                .frame(height: 500)
            case .year:
                let stockData = processedData[4]
                StockGraphView(
                    stockData: stockData,
                    mostRecentValue: processedData[0].last!.price,
                    timePeriod: .oneYear,
                    color: getColorFromPeriod(period: .year)
                )
                .frame(height: 500)
            case .ytd:
                let stockData = processedData[5]
                StockGraphView(
                    stockData: stockData,
                    mostRecentValue: processedData[0].last!.price,
                    timePeriod: .ytd,
                    color: getColorFromPeriod(period: .ytd)
                )
                .frame(height: 500)
            case .all:
                let stockData = processedData[7]
                StockGraphView(
                    stockData: stockData,
                    mostRecentValue: processedData[0].last!.price,
                    timePeriod: .all,
                    color: getColorFromPeriod(period: .all)
                )
                .frame(height: 500)
            }
            
            ScrollView (.horizontal) {
                HStack {
                    ForEach(TimePeriods.allCases, id: \.self) { period in
                        Button {
                            selectedPeriod = period
                            selectedButtonColor =  getColorFromPeriod(period: selectedPeriod ?? .day).wrappedValue
                        } label: {
                            VStack {
                                Text(period.displayName)
                                    .lineLimit(1)
                                    .foregroundStyle(selectedPeriod == period ? (selectedButtonColor ?? .white) : .white)
                                Rectangle()
                                    .fill(selectedPeriod == period ? (selectedButtonColor ?? .black) : .black)
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
                    Text("You can view the cumulative sum of your investments made through Buul here.")
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
        .onAppear {
            selectedPeriod = .day
        }
        .onChange(of: selectedPeriod) {
            if let selectedPeriod = selectedPeriod {
                selectedButtonColor = getColorFromPeriod(period: selectedPeriod).wrappedValue
            }
        }
        .onChange(of: processedData) {
            if let selectedPeriod = selectedPeriod {
                selectedButtonColor = getColorFromPeriod(period: selectedPeriod).wrappedValue
            }
        }
        .frame(maxHeight: .infinity)
        .background(Color.black.ignoresSafeArea())
    }
    
    func getColorFromPeriod(period: TimePeriods) -> Binding<Color> {
        switch period {
        case .day: return $oneDayColor
        case .week: return $oneWeekColor
        case .month: return $oneMonthColor
        case .threeMonths: return $threeMonthsColor
        case .year: return $oneYearColor
        case .ytd: return $ytdColor
        case .all: return $allColor
        }
    }
}
        
struct StockDataPoints: Codable {
    let data: [StockDataPoint]
}

struct StockDataPoint: Identifiable, Hashable, Codable {
    let id = UUID()
    let date: Date
    var price: Double

    enum CodingKeys: String, CodingKey {
        case date, price
    }
}

enum TimePeriods: CaseIterable {
    case day, week, month, threeMonths, year, ytd, all

    var displayName: String {
        switch self {
        case .day: return "1D"
        case .week: return "1W"
        case .month: return "1M"
        case .threeMonths: return "3M"
        case .year: return "1Y"
        case .ytd: return "YTD"
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
        case .all: return 6
        }
    }
}
