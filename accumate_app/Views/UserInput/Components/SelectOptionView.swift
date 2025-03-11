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
            VStack (alignment: .center) {
                if let title = title {
                    Text(title)
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundStyle(.white)
                        .multilineTextAlignment(.center)
                        .fixedSize(horizontal: false, vertical: true)
                        .padding(.bottom, 20)
                }
                if let subtitle = subtitle {
                    Text(subtitle)
                        .font(.headline)
                        .foregroundStyle(.white.opacity(0.8))
                        .multilineTextAlignment(.leading)
                        .fixedSize(horizontal: false, vertical: true)
                }
            }
            .padding(.bottom, 50)
            
            if signUpField == .brokerage {
                ScrollView {
                    ForEach(Brokerages.allCases, id: \.self) { brokerage in
                        switch brokerage {
                        case .robinhood:
                            BrokerageButtonView(
                                brokerage: brokerage,
                                buttonDisabled: $buttonDisabled,
                                selectedBrokerage: $selectedBrokerage
                            )
                            EmptyView()
                        default:
                            Rectangle()
                                .frame(maxWidth: .infinity, maxHeight: .infinity)
                                .foregroundStyle(.black)
                        }
                    }
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
            if showAlert {
                Button("OK", role: .cancel) {
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
//        .alert(sessionManager.refreshFailedMessage, isPresented: $sessionManager.refreshFailed) {
//            Button("OK", role: .cancel) {
//                showAlert = false
////                sessionManager.refreshFailed = false
//            }
//            Button("Log Out", role: .destructive) {
//                showAlert = false
////                Task {
////                    showAlert = false
////                    
////                    sessionManager.refreshFailed = false
////                    _ = await sessionManager.resetComplete()
////                    navManager.reset(views: [.landing])
////                }
//            }
//        }
        .onAppear {
            print(selectedETF)
            buttonDisabled = false
        }
        .background(.black)
        .navigationBarBackButtonHidden(true)
        .navigationBarTitleDisplayMode(.inline)
    }
}
