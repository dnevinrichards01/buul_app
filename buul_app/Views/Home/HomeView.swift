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
    @State private var retryRequestGraphData: Bool = false
    @State private var graphDataRequested: Bool = false
    
    @State private var graphData: [StockDataPoint]?
    @State private var defaultData: [[StockDataPoint]]
    @State private var processedData: [[StockDataPoint]]?
    @State private var useDefaultData: Bool = true
    @State private var graphDataRecieved: Bool = false
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
        self.defaultData = GraphUtils.createDefaultGraphData(
            now: Date(),
            earliestDate: GraphUtils.calendar.date(byAdding: .year, value: -5, to: Date())!
        )
    }
    
    var body: some View {
        ZStack {
            VStack {
                Color.black
                    .frame(height: 5)
                    .edgesIgnoringSafeArea(.top)
                ScrollView {
                    switch tabSelected {
                    case .stocks:
                        if useDefaultData {
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
                        } else {
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
                    case .cards:
                        HomeCardsView()
                    case .account:
                        HomeAccountView()
                    }
                }
                Spacer()
            }
            // instead of this you could have a loading circle etc...
//            if !initialGraphDataRecievedOrError {
//                Color.black
//                    .frame(maxWidth: .infinity, maxHeight: .infinity)
//            }
        }
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
            print("on appear ")
            
            Task.detached(priority: .userInitiated) {
                print("will now fetch")
                var processedDataList: [[StockDataPoint]]? = nil
                if let graphData = await self.sessionManager.graphData {
                    processedDataList = graphData
                } else {
                    let processedDataDict = await CoreDataStockManager.shared.fetchAllSeries()
                    print("fetched")
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
        .onChange(of: retryGetGraphData) {
            guard retryGetGraphData else { return }
            print("retryGetGraphData")
            Task.detached {
                try? await Task.sleep(nanoseconds: 500_000_000)
                await MainActor.run {
                    retryGetGraphData = false
                }
                await requestGraphData()
            }
            
        }
        .onChange(of: graphDataRequested) {
            guard graphDataRequested else { return }
            Task.detached {
                print("graphDataRequested")
                try? await Task.sleep(nanoseconds: 500_000_000)
                await MainActor.run {
                    graphDataRequested = false
                    self.date = Self.getGraphParams()
                }
                await getGraphData()
            }
            
        }
        .onChange(of: graphDataRecieved) {
            guard let graphData = graphData, graphDataRecieved else { return }
            
            Task.detached {
                print("recieved")
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
                CoreDataStockManager.shared.save(series: processedGraphData)
                print("processed")
                await MainActor.run {
                    self.sessionManager.graphData = processedGraphData
                    self.defaultData = defaultData
                    self.graphDataRecieved = false
                    self.initialGraphDataRecievedOrError = true
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
                try? await Task.sleep(nanoseconds: 20_000_000_000)
                await requestGraphData()
            }
        }
        .background(Color.black.ignoresSafeArea())
        .navigationTitle("")
        .navigationBarBackButtonHidden(true)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
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
            sessionManager: sessionManager,
            responseType: StockDataPoints.self
        ) { response in
            print("self.date", self.date)
            switch response {
            case .success(let responseData):
                print("successful getGraphData")
                self.retryGetGraphData = false
                self.useDefaultData = false
                self.graphDataRecieved = true
                self.graphData = responseData.data
            case .failure(let networkError):
                print("failed getGraphData", networkError)
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
                self.retryGetGraphData = true
                self.graphDataRequested = false
                self.retryRequestGraphData = false
                self.initialGraphDataRecievedOrError = true
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
    HomeView()
        .environmentObject(NavigationPathManager())
}
