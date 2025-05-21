//
//  HomeView.swift
//  accumate_app
//
//  Created by Nevin Richards on 12/14/24.
//

import SwiftUI

@MainActor
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
    
    @State private var graphData: [RecieveStockDataPoint]?
    @State private var defaultData: [[StockDataPoint]]
    @State private var processedData: [[StockDataPoint]]?
    @State private var useDefaultData: Bool = true
    @State private var graphDataRecieved: Bool = false
    
    init() {
        self.date = Self.getGraphParams()
        // maybe have this recalculate onappear so that the default data updates too?
        self.defaultData = Utils.processDefaultGraphData(graphData: Self.calculateDefaultData())
    }
    
    var body: some View {
        VStack {
            Color.black
                .frame(height: 5)
                .edgesIgnoringSafeArea(.top)
            ScrollView {
                switch tabSelected {
                case .stocks:
                    if useDefaultData {
                        HomeStocksView(processedData: $defaultData)
                    } else {
                        HomeStocksView(
                            processedData: Binding<[[StockDataPoint]]>(
                                get: { processedData ?? defaultData },
                                set: { newValue in processedData = newValue }
                            )
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
            
            DispatchQueue.global(qos: .userInitiated).async {
                let processedDataDict = CoreDataStockManager.shared.fetchAllSeries()
                if processedDataDict != [:] {
                    let processedDataList: [[StockDataPoint]] = processedDataDict
                        .sorted(by: { $0.key < $1.key })
                        .map { $0.value }
                    DispatchQueue.main.async {
                        self.processedData = processedDataList
                        useDefaultData = false
                    }
                }
            }
            requestGraphData()
        }
        .onChange(of: retryGetGraphData) {
            guard retryGetGraphData else { return }
            print("retryGetGraphData")
            Task {
                try? await Task.sleep(nanoseconds: 5_000_000_000)
                retryGetGraphData = false
                requestGraphData()
            }
            
        }
        .onChange(of: graphDataRequested) {
            guard graphDataRequested else { return }
            print("graphDataRequested")
            Task {
                try? await Task.sleep(nanoseconds: 5_000_000_000)
                graphDataRequested = false
                getGraphData()
            }
            
        }
        .onChange(of: graphData) {
            print("graphData")
            Task {
                guard let graphData = graphData, graphDataRecieved else { return }
                let processedGraphData = Utils.processGraphData(graphData: graphData, defaultData: defaultData)
                CoreDataStockManager.shared.save(series: processedGraphData)
                print("processed")
                self.useDefaultData = false
                self.processedData = processedGraphData
                print(processedData == defaultData)
//                try? await Task.sleep(nanoseconds: 30_000_000_000)
//                requestGraphData()
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
    
    static func calculateDefaultData() -> [RecieveStockDataPoint] {
        let calendar = Calendar.current
        let now = Date()
        var data: [RecieveStockDataPoint] = []
        
        var currentTime = calendar.dateInterval(of: .minute, for: now)!.end
        while currentTime > calendar.date(byAdding: .day, value: -1, to: now)! {
            data.append(RecieveStockDataPoint(date: currentTime.ISO8601Format(), price: 0))
            currentTime = calendar.date(byAdding: .minute, value: -1, to: currentTime)!
        }

        currentTime = calendar.date(byAdding: .day, value: -1, to: now)!
        while currentTime > calendar.date(byAdding: .month, value: -1, to: now)! {
            data.append(RecieveStockDataPoint(date: currentTime.ISO8601Format(), price: 0))
            currentTime = calendar.date(byAdding: .hour, value: -1, to: currentTime)!
        }
        
        currentTime = calendar.date(byAdding: .month, value: -1, to: now)!
        while currentTime > calendar.date(byAdding: .year, value: -1, to: now)! {
            data.append(RecieveStockDataPoint(date: currentTime.ISO8601Format(), price: 0))
            currentTime = calendar.date(byAdding: .day, value: -1, to: currentTime)!
        }
        
        currentTime = calendar.date(byAdding: .year, value: -1, to: now)!
        while currentTime > calendar.date(byAdding: .year, value: -5, to: now)! {
            data.append(RecieveStockDataPoint(date: currentTime.ISO8601Format(), price: 0))
            currentTime = calendar.date(byAdding: .weekOfYear, value: -1, to: currentTime)!
        }
        
        // to optimize we can calculate exact length of array (but it changes so that's hard), and use indices not reversed()
        return data.reversed()
    }
    
    private static func getGraphParams() -> String {
//        let formatter = DateFormatter()
//        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"

        let fiveYearsAgo = Calendar.current.date(byAdding: .year, value: -5, to: Date())!
//        let date = formatter.string(from: fiveYearsAgo)
        
        let isoFormatter = ISO8601DateFormatter()
        isoFormatter.timeZone = TimeZone(abbreviation: "UTC")
        isoFormatter.formatOptions = [.withInternetDateTime]  // = "yyyy-MM-dd'T'HH:mm:ssZ"

        let isoString = isoFormatter.string(from: fiveYearsAgo)
        return isoString
        
//        return date
    }
    
    private func requestGraphData() {
        ServerCommunicator().callMyServer(
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
            }
        }
    }
    
    private func getGraphData() {
        ServerCommunicator().callMyServer(
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
                self.retryGetGraphData = false
                self.useDefaultData = false
                self.graphDataRecieved = true
                self.graphData = responseData.data
            case .failure(let networkError):
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
