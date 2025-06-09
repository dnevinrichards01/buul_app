//
//  SettingsBankInfoView.swift
//  accumate_app
//
//  Created by Nevin Richards on 1/31/25.
//

import SwiftUI

struct SettingsBankInfoView: View {
    @EnvironmentObject var navManager: NavigationPathManager
    @EnvironmentObject var sessionManager: UserSessionManager
    @State private var selectedBankingSetting: BankingSettings?

    var body: some View {
        VStack {
            HStack {
                Spacer()
                Text("Banking Settings")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundStyle(.white)
                    .multilineTextAlignment(.center)
                    .padding(.top, 30)
                Spacer()
            }
            .padding(.bottom, 50)
            
            ForEach(BankingSettings.allCases, id: \.self) { bankingSetting in
                Button {
                    selectedBankingSetting = bankingSetting
                } label: {
                    HStack {
                        VStack (alignment: .leading) {
                            Text(bankingSetting.label)
                                .font(.headline)
                                .foregroundStyle(.white)
                                .multilineTextAlignment(.leading)
                                
                            Text(bankingSetting != .accounts ? getValue(bankingSetting: bankingSetting) : "")
                                .font(.subheadline)
                                .foregroundStyle(.white.opacity(0.8))
                                .multilineTextAlignment(.leading)
                        }
                        .padding(.leading, 10)
                        Spacer()
                        Image(systemName: "chevron.right")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 20, height: 20)
                            .foregroundStyle(.white.opacity(0.8))
                            .padding(.trailing, 20)
                    }
                    .padding(.vertical, 10)
                }
                Divider()
                    .frame(height: 1.5)
                    .frame(maxWidth: .infinity)
                    .background(.white.opacity(0.6))
            }
            Spacer()
        }
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden()
        .background(Color.black.ignoresSafeArea())
        .onAppear() {
            selectedBankingSetting = nil
        }
        .onChange(of: selectedBankingSetting) {
            if let selectedBankingSetting = selectedBankingSetting {
                switch selectedBankingSetting {
                case .accounts:
                    navManager.append(NavigationPathViews.plaidSettings)
                case .changeBrokerage:
                    navManager.append(NavigationPathViews.changeBrokerage)
                case .changeInvestment:
                    navManager.append(NavigationPathViews.changeETF)
                }
            }
        }
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                Button(action: {
                    navManager.path.removeLast()
                }) {
                    Image(systemName: "chevron.left")
                        .foregroundColor(.white)
                        .font(.system(size: 20, weight: .medium))
                        .frame(maxHeight: 30)
                }
            }
        }
    }
    
    func getValue(bankingSetting: BankingSettings) -> String {
        switch bankingSetting {
        case .changeBrokerage:
            return Utils.getBrokerageMainActor(sessionManager: sessionManager)?.displayName ?? sessionManager.brokerageName ?? "Could not load or find brokerage"
        case .changeInvestment:
            return sessionManager.etfSymbol ?? "Could not load or find ETF"
        case .accounts:
            return "Could not load or find accounts"
        }
    }
    
}

enum BankingSettings: CaseIterable {
    case accounts
    case changeBrokerage
    case changeInvestment

    var label: String {
        switch self {
        case .accounts: return "Linked bank accounts and cards"
        case .changeBrokerage: return "Change your brokerage"
        case .changeInvestment: return "Change your monthly investment"
        }
    }
}

#Preview {
    SettingsBankInfoView()
        .environmentObject(NavigationPathManager())
        .environmentObject(UserSessionManager())
}
