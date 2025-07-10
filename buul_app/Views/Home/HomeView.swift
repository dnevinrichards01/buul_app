//
//  HomeView.swift
//  accumate_app
//
//  Created by Nevin Richards on 12/14/24.
//

import SwiftUI

//@MainActor
struct HomeView: View {
    @EnvironmentObject var navManager: NavigationPathManager
    @EnvironmentObject var sessionManager: UserSessionManager
    @State private var tabSelected: HomeTabs = .stocks
    @State private var date: String
    @State private var alertMessage: String = ""
    @State private var showAlert: Bool = false
    @State private var retryGetGraphData: Bool = false
    @State private var getGraphDataRetries: Int = 5
    @State private var retryRequestGraphData: Bool = false
    @State private var graphDataRequested: Bool = false
    
    @State private var graphData: [StockDataPoint]?
    @State private var defaultData: [[StockDataPoint]]
    @State private var processedData: [[StockDataPoint]]?
    @State private var useDefaultData: Bool = true
    @State private var initialGraphDataRecievedOrError: Bool = false
    
    @State private var oneDayColor: Color = .gray
    @State private var oneWeekColor: Color = .gray
    @State private var oneMonthColor: Color = .gray
    @State private var threeMonthsColor: Color = .gray
    @State private var oneYearColor: Color = .gray
    @State private var ytdColor: Color = .gray
    @State private var allColor: Color = .gray
    
    init() {
        self.date = Self.getGraphParams()
        let now = Date()
        self.defaultData = GraphUtils.createDefaultGraphData(
            now: now,
            earliestDate: GraphUtils.calendar.date(byAdding: .year, value: -5, to: now)!
        )
    }
    
    var body: some View {
        ZStack {
            VStack {
                Color.black
                    .frame(height: 5)
                    .edgesIgnoringSafeArea(.top)
                switch tabSelected {
                case .stocks:
                    if useDefaultData {
                        ScrollView {
                            HomeStocksView(
                                processedData: $defaultData,
                                oneDayColor: $oneDayColor,
                                oneWeekColor: $oneWeekColor,
                                oneMonthColor: $oneMonthColor,
                                threeMonthsColor: $threeMonthsColor,
                                oneYearColor: $oneYearColor,
                                ytdColor: $ytdColor,
                                allColor: $allColor
                            )
                        }
                    } else {
                        ScrollView {
                            HomeStocksView(
                                processedData: Binding<[[StockDataPoint]]>(
                                    get: { processedData ?? defaultData },
                                    set: { newValue in processedData = newValue }
                                ),
                                oneDayColor: $oneDayColor,
                                oneWeekColor: $oneWeekColor,
                                oneMonthColor: $oneMonthColor,
                                threeMonthsColor: $threeMonthsColor,
                                oneYearColor: $oneYearColor,
                                ytdColor: $ytdColor,
                                allColor: $allColor
                            )
                        }
                    }
                case .cards:
                    ScrollView {
                        HomeCardsView()
                    }
                case .account:
                    ScrollView {
                        HomeAccountView()
                    }
                case .projections:
                    ProjectionsView()
                        .background(Color.black.ignoresSafeArea())
                }
                Spacer()
            }
            if !initialGraphDataRecievedOrError {
                HomeLoadingScreen()
                    .transition(.opacity)
                    .zIndex(1)
            }
        }
        .animation(.easeInOut(duration: 0.4), value: initialGraphDataRecievedOrError)
        .alert(alertMessage, isPresented: $showAlert) {
            if sessionManager.refreshFailed {
                Button("OK", role: .cancel) {
                    showAlert = false
                }
                Button("Log Out", role: .destructive) {
                    Task {
                        showAlert = false
                        
                        sessionManager.refreshFailed = false
                        _ = await sessionManager.resetComplete()
                        navManager.reset(views: [.landing])
                    }
                }
            }
        }
        .onAppear() {
            retryGetGraphData = false
            retryRequestGraphData = false
            graphDataRequested = false
            useDefaultData = true
//            print("on appear ")
            
            Task.detached(priority: .userInitiated) {
//                print("will now fetch")
                var processedDataList: [[StockDataPoint]]? = nil
                if let graphData = await self.sessionManager.graphData {
                    processedDataList = graphData
                } else {
                    let processedDataDict = await CoreDataStockManager.shared.fetchAllSeries()
//                    print("fetched")
                    if processedDataDict != [:] {
                        processedDataList = processedDataDict
                            .sorted(by: { $0.key < $1.key })
                            .map { $0.value }
                    }
                }
                
                if let processedDataList = processedDataList {
                    let colors = GraphUtils.getColors(graphData: processedDataList)
                    await MainActor.run {
                        self.processedData = processedDataList
                        self.useDefaultData = false
                        self.oneDayColor = colors[0]
                        self.oneWeekColor = colors[1]
                        self.oneMonthColor = colors[2]
                        self.threeMonthsColor = colors[3]
                        self.oneYearColor = colors[4]
                        self.ytdColor = colors[5]
                        self.allColor = colors[7]
                    }
                }
                
                await requestGraphData()
            }
        }
        .onChange(of: retryRequestGraphData) {
            guard retryRequestGraphData else { return }
//            print("retryRequestGraphData")
            Task.detached {
                try? await Task.sleep(nanoseconds: 2_000_000_000)
                await MainActor.run {
                    retryRequestGraphData = false
                }
                await requestGraphData()
            }
        }
        .onChange(of: retryGetGraphData) {
            guard retryGetGraphData else { return }
//            print("retryGetGraphData")
            Task.detached {
                try? await Task.sleep(nanoseconds: 500_000_000)
                await MainActor.run {
                    retryGetGraphData = false
                }
                await getGraphData()
            }
            
        }
        .onChange(of: graphDataRequested) {
            guard graphDataRequested else { return }
            Task.detached {
//                print("graphDataRequested")
                try? await Task.sleep(nanoseconds: 500_000_000)
                await MainActor.run {
                    graphDataRequested = false
                    self.date = Self.getGraphParams()
                }
                await getGraphData()
            }
            
        }
        .onChange(of: graphData) {
            guard let graphData = graphData else { return }
            
            Task.detached {
//                print("recieved")
                let now: Date = Date()
                let defaultData = GraphUtils.createDefaultGraphData(
                    now: now,
                    earliestDate: GraphUtils.calendar.date(byAdding: .year, value: -5, to: now)!
                )
                let processedGraphData = GraphUtils.processGraphData(
                    graphData: graphData,
                    now: now
                )
                let colors = GraphUtils.getColors(graphData: processedGraphData)
//                print("processed")
                await MainActor.run {
                    self.sessionManager.graphData = processedGraphData
                    self.defaultData = defaultData
                    self.useDefaultData = false
                    self.processedData = processedGraphData
                    self.oneDayColor = colors[0]
                    self.oneWeekColor = colors[1]
                    self.oneMonthColor = colors[2]
                    self.threeMonthsColor = colors[3]
                    self.oneYearColor = colors[4]
                    self.ytdColor = colors[5]
                    self.allColor = colors[7]
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                    self.initialGraphDataRecievedOrError = true
                }
                DispatchQueue.global(qos: .utility).asyncAfter(deadline: .now() + 0.2) {
                    CoreDataStockManager.shared.save(series: processedGraphData)
                }
                
                let seconds = await secondsUntilNextMinute()
                let nanoseconds = UInt64(seconds * 1_000_000_000)
                try? await Task.sleep(nanoseconds: nanoseconds)
                await requestGraphData()
            }
        }
        .background(Color.black.ignoresSafeArea())
        .navigationTitle("")
        .navigationBarBackButtonHidden(true)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            if initialGraphDataRecievedOrError {
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
    
    func secondsUntilNextMinute() -> TimeInterval {
        let now = Date()
        let calendar = Calendar.current

        if let nextMinute = calendar.nextDate(after: now, matching: DateComponents(second: 0), matchingPolicy: .strict, direction: .forward) {
            return nextMinute.timeIntervalSince(now) + 5
        } else {
            return 20
        }
    }
    
    private static func getCustomDate() -> Date {
        let utcCalendar = Calendar(identifier: .gregorian)
        let utcTimeZone = TimeZone(secondsFromGMT: 0)!

        var components = DateComponents()
        components.year = 2025
        components.month = 1
        components.day = 1
        components.hour = 8
        components.minute = 30
        components.timeZone = utcTimeZone

        let utcDate = utcCalendar.date(from: components)!
        return utcDate
    }

    
    private static func getGraphParams() -> String {
        let fiveYearsAgo = Calendar.current.date(byAdding: .year, value: -5, to: Date())!
        let isoFormatter = ISO8601DateFormatter()
        isoFormatter.timeZone = TimeZone(abbreviation: "UTC")
        isoFormatter.formatOptions = [.withInternetDateTime]  // = "yyyy-MM-dd'T'HH:mm:ssZ"
        let isoString = isoFormatter.string(from: fiveYearsAgo)
        return isoString
    }
    
    
    
    private func requestGraphData() async {
        await ServerCommunicator().callMyServer(
            path: "api/user/getstockgraphdata/",
            httpMethod: .put,
            app_version: sessionManager.app_version,
            sessionManager: sessionManager,
            responseType: SuccessErrorResponse.self
        ) { response in
            switch response {
            case .success(let responseData):
                if responseData.error == nil, let _ = responseData.success {
                    self.retryRequestGraphData = false
                    self.graphDataRequested = true
                } else {
                    self.initialGraphDataRecievedOrError = true
                    self.retryRequestGraphData = true
                    self.graphDataRequested = false
                }
            case .failure(let networkError):
                switch networkError {
                case .statusCodeError(let status):
                    if status == 401 {
                        self.alertMessage = "Your session has expired. To retrieve updated information, please logout then sign in."
                        self.retryRequestGraphData = false
                        self.graphDataRequested = false
                        self.showAlert = true
                        return
                    }
                default: break
                }
                self.retryRequestGraphData = true
                self.graphDataRequested = false
                self.initialGraphDataRecievedOrError = true

            }
        }
    }
    
    private func getGraphData() async {
        await ServerCommunicator().callMyServer(
            path: "api/user/getstockgraphdata/",
            httpMethod: .post,
            params: [
                "start_date" : self.date as Any
            ],
            app_version: sessionManager.app_version,
            sessionManager: sessionManager,
            responseType: StockDataPoints.self
        ) { response in
//            print("self.date", self.date)
            switch response {
            case .success(let responseData):
//                print("successful getGraphData")
                self.retryGetGraphData = false
                self.useDefaultData = false
                self.graphData = responseData.data
            case .failure(let networkError):
//                print("failed getGraphData", networkError)
                switch networkError {
                case .decodingError:
                    self.retryGetGraphData = false
                    self.graphDataRequested = true
                    self.retryRequestGraphData = true
                case .statusCodeError(let status):
                    if status == 401 {
                        self.alertMessage = "Your session has expired. To retrieve updated information, please logout then sign in."
                        self.retryRequestGraphData = false
                        self.graphDataRequested = false
                        self.retryGetGraphData = false
                        self.showAlert = true
                        return
                    }
                default: break
                }
                if self.getGraphDataRetries > 0 {
                    self.getGraphDataRetries -= 1
                    self.retryGetGraphData = true
                    self.graphDataRequested = false
                    self.retryRequestGraphData = false
                } else {
                    self.getGraphDataRetries = 5
                    self.retryGetGraphData = false
                    self.graphDataRequested = false
                    self.retryRequestGraphData = true
                    self.initialGraphDataRecievedOrError = true
                }
            }
        }
    }
}



enum HomeTabs: CaseIterable {
    case stocks, cards, account, projections

    var imageName: String {
        switch self {
        case .stocks: return "chart.line.uptrend.xyaxis"
        case .cards: return "creditcard"
        case .account: return "person.crop.circle"
        case .projections: return "calendar"
        }
    }
    
}

#Preview {
    HomeView()
        .environmentObject(NavigationPathManager())
}
