//
//  InvestmentHistoryView.swift
//  buul_app
//
//  Created by Nevin Richards on 7/7/25.
//

import SwiftUI

// maybe separate this into pagination view, and pass in invesmentHistoryView custimizations as args?
struct InvestmentHistoryView: View {
    @EnvironmentObject var navManager: NavigationPathManager
    @EnvironmentObject var sessionManager: UserSessionManager
    @State private var investments: [Int : [UserInvestment]] = [0:[]]
    @State private var buttonDisabled: Bool = false
    @State private var loadingCircle: Bool = false
    @State private var selectedInvestment: UUID?
    @State private var page: Int = 0
    @State private var maxPage: Int = 0
    @State private var investmentIds: Set<UUID> = []
    private var reloadWhenPageChange: Bool = true
    
    var body: some View {
        VStack {
            HStack {
                Spacer()
                Text("Investment History")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundStyle(.white)
                    .multilineTextAlignment(.center)
                    .padding(.top, 30)
                Spacer()
            }
            .padding(.bottom, 30)

            HStack (spacing: 10) {
                Button {
                    buttonDisabled = true
                    Task.detached {
                        await fetchInvestments(page: page)
                    }
                } label: {
                    Image(systemName: "arrow.clockwise")
                        .resizable()
                        .foregroundStyle(.white)
                        .frame(width: 20, height: 20)
                }
                .disabled(buttonDisabled)
                Spacer()
                Button {
                    guard page != 0 else { return }
                    page = 0
                    buttonDisabled = true
                    if reloadWhenPageChange || !investments.keys.contains(0) {
                        Task.detached {
                            await fetchInvestments(page: page)
                        }
                    } else {
                        page = 0
                        buttonDisabled = false
                    }
                } label: {
                    Image(systemName: "chevron.backward.2")
                        .resizable()
                        .foregroundStyle(.white.opacity(page==0 ? 0.65 : 1))
                        .frame(width: 20, height: 20)
                }
                .disabled(page==0 || buttonDisabled)
                Button {
                    guard page != 0 else { return }
                    buttonDisabled = true
                    if reloadWhenPageChange || !investments.keys.contains(page-1) {
                        Task.detached {
                            await fetchInvestments(page: page-1)
                            await MainActor.run {
                                page -= 1
                            }
                        }
                    } else {
                        page -= 1
                        buttonDisabled = false
                    }
                } label: {
                    Image(systemName: "chevron.left")
                        .resizable()
                        .foregroundStyle(.white.opacity(page==0 ? 0.65 : 1))
                        .frame(width: 20, height: 20)
                }
                .disabled(page==0 || buttonDisabled)
                Button {
                    guard page != maxPage else { return }
                    buttonDisabled = true
                    if reloadWhenPageChange || !investments.keys.contains(page+1) {
                        Task.detached {
                            await fetchInvestments(page: page+1)
                            await MainActor.run {
                                page += 1
                            }
                        }
                    } else {
                        page += 1
                        buttonDisabled = false
                    }
                } label: {
                    Image(systemName: "chevron.right")
                        .resizable()
                        .foregroundStyle(.white.opacity(page==maxPage ? 0.65 : 1))
                        .frame(width: 20, height: 20)
                }
                .disabled(page==maxPage || buttonDisabled)
                Button {
                    guard page != maxPage else { return }
                    buttonDisabled = true
                    if reloadWhenPageChange || !investments.keys.contains(maxPage) {
                        Task.detached {
                            await fetchInvestments(page: maxPage)
                        }
                    } else {
                        page = maxPage
                        buttonDisabled = false
                    }
                } label: {
                    Image(systemName: "chevron.forward.2")
                        .resizable()
                        .foregroundStyle(.white.opacity(page==maxPage ? 0.65 : 1))
                        .frame(width: 20, height: 20)
                }
                .disabled(page==maxPage || buttonDisabled)

            }
            .padding(.horizontal, 30)
            .padding(.bottom, 15)

            ZStack {
                if loadingCircle {
                    LoadingCircle()
                        .frame(alignment: .center)
                        .frame(width: 80, height: 80)
                        .offset(y: -60)
                        .zIndex(3)
                    Color.black.opacity(0.8)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .zIndex(2)
                }
                VStack {
                    ScrollView {
                        if investments[page]?.count ?? 0 == 0 {
                            Text("No investments found")
                                .foregroundStyle(.white.opacity(0.65))
                                .frame(maxWidth: .infinity, alignment: .center)
                                .padding()
                        } else {
                            if let pageInvestments = investments[page] {
                                ForEach(pageInvestments.indices, id: \.self) { index in
                                    let investment = pageInvestments[index]
                                    Button {
                                        if selectedInvestment == investment.id {
                                            selectedInvestment = nil
                                        } else {
                                            selectedInvestment = investment.id
                                        }
                                    } label: {
                                        VStack {
                                            HStack {
                                                Text(investment.symbol.padding(toLength: 8, withPad: " ", startingAt: 0))
                                                    .font(.subheadline)
                                                    .foregroundStyle(.white)
                                                Text("$\(String(format: "%.2f", investment.amount))".padding(toLength: 8, withPad: " ", startingAt: 0))
                                                    .font(.subheadline)
                                                    .foregroundStyle(.white)
                                                Text(String(investment.dateString.prefix(12)).padding(toLength: 12, withPad: " ", startingAt: 0))
                                                    .font(.subheadline)
                                                    .foregroundStyle(.white)
                                                Spacer()
                                            }
                                            if selectedInvestment == investment.id {
                                                VStack {
                                                    Text("\("Quantity: ".padding(toLength: 12, withPad: " ", startingAt: 0)) \(String(format: "%.8f", investment.amount))")
                                                        .font(.footnote)
                                                        .foregroundStyle(.white)
                                                        .frame(maxWidth: .infinity, alignment: .leading)
                                                    Text("\("Time: ".padding(toLength: 12, withPad: " ", startingAt: 0)) \(investment.dateString)")
                                                        .font(.footnote)
                                                        .foregroundStyle(.white)
                                                        .frame(maxWidth: .infinity, alignment: .leading)
                                                }
                                                .frame(maxWidth: .infinity, alignment: .leading)
                                                .padding(.top, 2.5)
                                                .padding(.leading, 15)
                                            }
                                        }
                                    }
                                    Divider()
                                        .frame(height: 1)
                                        .background(.white.opacity(0.8))
                                        .padding(.vertical, 5)
                                }
                            }
                        }
                    }
                    .refreshable {
                        Task.detached {
                            await fetchInvestments(page: page)
                        }
                    }
                    Spacer()
                }
                .padding(.horizontal, 30)
                .zIndex(1)
            }
        }
        .background(Color.black.ignoresSafeArea())
        .onAppear {
            self.investments = sessionManager.investmentHistory
            self.investmentIds = Set(self.investments.flatMap { $0.value.map {$0.id}})
            self.maxPage = sessionManager.investmentHistoryMaxPage
            self.buttonDisabled = true
            Task.detached {
                await fetchInvestments(page: page)
            }
        }
        .onChange(of: buttonDisabled) {
            if buttonDisabled {
                loadingCircle = true
            } else {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    loadingCircle = false
                }
            }
        }
        .navigationBarBackButtonHidden(true)
        .navigationBarTitleDisplayMode(.inline)
        .background(Color.black.ignoresSafeArea())
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button {
                    navManager.removeLast(1)
                } label: {
                    Image(systemName: "chevron.left")
                        .foregroundColor(.white)
                        .font(.system(size: 20, weight: .medium))
                        .frame(maxHeight: 30)
                }
            }
        }
    }
    
    private func fetchInvestments(page: Int) async {
        await ServerCommunicator().callMyServer(
            path: "api/user/getuserinvestmentinfo/",
            httpMethod: .post,
            params: [
                "page": page
            ],
            app_version: sessionManager.app_version,
            sessionManager: sessionManager,
            responseType: UserInvestmentResponse.self
        ) { response in
            switch response {
            case .success(let responseData):
                // validation errors
                if let _ = responseData.error, responseData.success == nil {
                    self.buttonDisabled = false
                    // success, set up OTP information
                } else if let successResponse = responseData.success, responseData.error == nil {
                    print("processing")
                    let processedInvestments = self.processInvestments(investments: successResponse.investments)
                    self.page = successResponse.page ?? page
                    self.investments[self.page] = processedInvestments
                    self.sessionManager.investmentHistory[self.page] = processedInvestments
                    self.maxPage = (successResponse.maxPages ?? 1) - 1
                    
                    self.buttonDisabled = false
                    // alert because unexpected response
                } else if let _ = responseData.error, let _ = responseData.success {
                    self.buttonDisabled = false
                    // alert because unexpected response
                } else {
                    self.buttonDisabled = false
                }
            case .failure:
                print("error")
                self.buttonDisabled = false
            }
        }
        return
    }
    
    private func processInvestments(investments: [UserInvestment]) -> [UserInvestment] {
        let result = investments.sorted {
            $0.date > $1.date
        }
        return result
    }
}

struct UserInvestmentResponse: Codable {
    let success: UserInvestmentSuccessResponse?
    let error: String?
}

struct UserInvestmentSuccessResponse: Codable {
    let investments: [UserInvestment]
    let maxPages: Int?
    let page: Int?
}

struct UserInvestment: Codable {
    let symbol: String
    let quantity: Double
    let amount: Double
    let date: Date
    let id: UUID
    
    var dateString: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM d, yyyy h:mm a"
        return formatter.string(from: date)
    }
    
    enum CodingKeys: String, CodingKey {
        case symbol = "_symbol"
        case quantity
        case amount
        case date = "_date"
        case id = "_id"
    }
}


#Preview {
    HomeAccountView()
        .environmentObject(NavigationPathManager())
        .environmentObject(UserSessionManager())
}
