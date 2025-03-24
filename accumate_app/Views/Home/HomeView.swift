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
    @State private var date: String?
    @State private var alertMessage: String = ""
    @State private var showAlert: Bool = false
    @State private var retryGetGraphData: Bool = false
    @State private var retryRequestGraphData: Bool = false
    @State private var graphDataRequested: Bool = false
    @State private var graphData: [RecieveStockDataPoint]?
    
    
    init() {
        self.date = getGraphParams()
    }
    
    var body: some View {
        VStack {
            Color.black
                .frame(height: 5)
                .edgesIgnoringSafeArea(.top)
            ScrollView {
                switch tabSelected {
                case .stocks:
                    HomeStocksView(graphData: $graphData)
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
//        @State private var retryGetGraphData: Bool = false
//        @State private var retryRequestGraphData: Bool = false
//        @State private var graphDataRequested: Bool = false
//        @State private var graphData: [RecieveStockDataPoint]?
        .onAppear() {
            print("on appear ")
            retryGetGraphData = false
            retryRequestGraphData = false
            graphDataRequested = false
            requestGraphData()
        }
        .onChange(of: retryGetGraphData) {
            guard retryGetGraphData else { return }
            print("retryGetGraphData")
            requestGraphData()
        }
        .onChange(of: graphDataRequested) {
            guard graphDataRequested else { return }
            print("graphDataRequested")
            getGraphData()
        }
        .onChange(of: graphData) {
            print("graphData")
            Task {
                try? await Task.sleep(nanoseconds: 30_000_000_000)
                requestGraphData()
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
    
    private func getGraphParams() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        let date = formatter.string(from: Date())
        self.date = date
        return date
    }
    
    private func requestGraphData() {
        ServerCommunicator().callMyServer(
            path: "api/user/getstockgraphdata/",
            httpMethod: .put,
            params: [
                "start_date" : getGraphParams() as Any
            ],
            sessionManager: sessionManager,
            responseType: SuccessErrorResponse.self
        ) { response in
            switch response {
            case .success(let responseData):
                if let _ = responseData.error, let _ = responseData.success {
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
            switch response {
            case .success(let responseData):
                self.retryGetGraphData = false
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
