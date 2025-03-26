//
//  SignUpBrokerageView.swift
//  accumate_app
//
//  Created by Nevin Richards on 12/14/24.
//

import SwiftUI

struct SelectOptionView: View {
    
    @EnvironmentObject var navManager: NavigationPathManager
    @EnvironmentObject var sessionManager: UserSessionManager
    
    var title: String? // Select Brokerage
    var subtitle: String?
    var signUpField: SignUpFields
    @Binding var alertMessage: String
    @Binding var showAlert: Bool
    @Binding var buttonDisabled: Bool
    @Binding var selectedBrokerage: String
    @Binding var selectedETF: String

    var body: some View {
        VStack {
            VStack (alignment: .leading, spacing: 10) {
                if let title = title {
                    Text(title)
                        .font(.title)
                        .fontWeight(.bold)
                        .foregroundStyle(.white)
                        .fixedSize(horizontal: false, vertical: true)
                }
                if let subtitle = subtitle {
                    Text(subtitle)
                        .font(.headline)
                        .foregroundStyle(.white.opacity(0.8))
                        .multilineTextAlignment(.leading)
                        .fixedSize(horizontal: false, vertical: true)
                }
            }
//            .padding(.bottom, 25)
            
            if signUpField == .brokerage {
                ScrollView {
                    ForEach(Brokerages.allCases, id: \.self) { brokerage in
                        BrokerageButtonView(
                            brokerage: brokerage,
                            buttonDisabled: $buttonDisabled,
                            selectedBrokerage: $selectedBrokerage,
                            alertMessage: $alertMessage,
                            showAlert: $showAlert
                        )
                    }
                    VStack {
                        HStack {
                            Image(systemName: "plus")
                                .resizable()
                                .frame(width: 20, height: 20)
                                .padding(.leading, 30)
                                .foregroundColor(.white)
                            Text("Connect another broker")
                                .font(.title2)
                                .foregroundColor(.white)
                            Spacer()
                        }
                        .frame(height: 80)
                        .disabled(buttonDisabled)
                        .background(.black)
                        Divider()
                            .frame(height: 1.5)
                            .frame(maxWidth: .infinity)
                            .background(.white.opacity(0.6))
                    }
                    .frame(height: 80)
                }
            } else if signUpField == .symbol {
                ScrollView {
                    VStack(spacing: 10) {
                        ForEach(Array(etfsList.enumerated()), id: \.0) { index, etf in
                            SignUpETFsButtonView(
                                imageName: etf.imageName,
                                title: etf.name,
                                subtitle: etf.timePeriod,
                                growth: etf.growth,
                                etf: etf,
                                buttonDisabled: $buttonDisabled,
                                selectedETF: $selectedETF
                            )
                        }
                    }
                    .padding(.top, 10)
                }
                .background(.black)
            } else {
                EmptyView()
            }
            
            Spacer()
        }
        .alert(alertMessage, isPresented: $showAlert) {
            
            if selectedBrokerage != "" && selectedBrokerage != Brokerages.robinhood.rawValue {
                Button("No", role: .cancel) {
                    showAlert = false
                }
                Button("Select", role: .none) {
                    showAlert = false
                    buttonDisabled = true
                }
            } else if sessionManager.refreshFailed {
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
            } else {
                Button("OK", role: .cancel) {
                    showAlert = false
                }
            }
        }
        .onAppear {
            print(selectedETF)
            buttonDisabled = false
        }
        .background(.black)
        .navigationBarBackButtonHidden(true)
        .navigationBarTitleDisplayMode(.inline)
    }
}
