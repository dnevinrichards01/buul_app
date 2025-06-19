//
//  SwiftUIView.swift
//  accumate_app
//
//  Created by Nevin Richards on 12/12/24.
//

import SwiftUI

struct HomeCardsView: View {
    @State private var cards: [Card] = cardsList
    @State private var cardsData: [Card : CGFloat]?
    @State private var selectedCard: Card?
    @State private var totalSpendingAmount: CGFloat?
    @State private var startDate: Date?
    @State private var endDate: Date?
    @State private var showAlert: Bool = false
    @State private var alertMessage: String = ""
    
    @EnvironmentObject var navManager : NavigationPathManager
    @EnvironmentObject var sessionManager : UserSessionManager

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
            }
            .background(.black)
        }
        .padding(.bottom, 10)
        .background(Color.black.ignoresSafeArea())
        .onAppear {
            if let cardData = sessionManager.cardRecommendations {
                processSpendingCategories(cardData)
            }
            Task.detached {
                await getSpendingCategories()
            }
        }
        .alert(alertMessage, isPresented: $showAlert) {
            Button("OK", role: .cancel) {
                Task {
                    showAlert = false
                }
            }
            if sessionManager.refreshFailed {
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
    }
    
    private func processSpendingCategories(_ categoriesResponse: SpendingCategoriesResponseSuccess) {
        let formatter = ISO8601DateFormatter()
        let startDate = formatter.date(from: categoriesResponse.startDate)
        let endDate = formatter.date(from: categoriesResponse.endDate)
        guard let _ = startDate, let _ = endDate else { return }
        self.startDate = startDate
        self.endDate = endDate
        
        let categoriesDict: [String : CGFloat] = [
            "entertainment": categoriesResponse.entertainment,
            "foodAndDrink": categoriesResponse.foodAndDrink,
            "homeImprovement": categoriesResponse.homeImprovement,
            "personalCare": categoriesResponse.personalCare,
            "transportation": categoriesResponse.transportation,
            "travel": categoriesResponse.travel,
            "rentAndUtilities": categoriesResponse.rentAndUtilities,
        ]
//        let sortedCategoriesDescending = categoriesDict.keys.sorted { categoriesDict[$0]! > categoriesDict[$1]! }
        
//        self.cards = []
        let cardsRanking: [Card : CGFloat] = [
            cashPlusVisa: categoriesDict["rentAndUtilities"] ?? 0,
            bofaCustomizedCash: categoriesDict["food_and_drink"] ?? 0,
            citiCustomCash: categoriesDict["travel"] ?? 0,
            chaseFreedomFlex: categoriesDict["personalCare"] ?? 0
        ]
        let sortedCardsDescending = cardsRanking.keys.sorted { cardsRanking[$0]! > cardsRanking[$1]! }
        self.cards = sortedCardsDescending
        
//        utilities, cashPlusVisa
//        shopping / groceries, bofaCustomizedCash
//        dining, citiCustomCash
//        shopping, dining, groceries, discoverIt and chaseFreedomFlex
        self.totalSpendingAmount = categoriesResponse.totalAmount
    }
    
    
    
    private func getSpendingCategories() async {
        await ServerCommunicator().callMyServer(
            path: "api/user/getspendingrecommendations/",
            httpMethod: .get,
            app_version: sessionManager.app_version,
            sessionManager: sessionManager,
            responseType: SpendingCategoriesResponse.self
        ) { response in
            switch response {
            case .success(let responseData):
                if let _ = responseData.error, responseData.success == nil {
//                    self.alertMessage = ServerCommunicator.NetworkError.decodingError.errorMessage
//                    self.showAlert = true
                } else if let categoriesData = responseData.success, responseData.error == nil {
                    processSpendingCategories(categoriesData)
                    self.sessionManager.cardRecommendations = categoriesData
                } else if let _ = responseData.error, let _ = responseData.success {
//                    self.alertMessage = "We could not retrieve your linked accounts. Swipe up to retry." + ServerCommunicator.NetworkError.decodingError.errorMessage
//                    self.showAlert = true
                } else {
//                    self.alertMessage = "We could not retrieve your linked accounts. Swipe up to retry." + ServerCommunicator.NetworkError.decodingError.errorMessage
//                    self.showAlert = true
                }
            case .failure(let networkError):
                self.alertMessage = networkError.errorMessage
                switch networkError {
                case .statusCodeError(let status):
                    if status == 401 {
                        self.alertMessage = "Your session has expired. To retrieve updated information, please logout then sign in."
                        self.showAlert = true
                    } else {//if status == 400 {
                        self.showAlert = false
                    }
                default: break
                }
            }
        }
    }
}

struct SpendingCategoriesResponse: Codable {
    let success: SpendingCategoriesResponseSuccess?
    let error: String?
}

struct SpendingCategoriesResponseSuccess: Codable {
    let entertainment: CGFloat
    let foodAndDrink: CGFloat
    let homeImprovement: CGFloat
    let personalCare: CGFloat
    let transportation: CGFloat
    let travel: CGFloat
    let rentAndUtilities: CGFloat
    let startDate: String
    let endDate: String
    let totalAmount: CGFloat
    
}

#Preview {
    HomeCardsView()
        .environmentObject(NavigationPathManager())
}
