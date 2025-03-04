//
//  SignUpBrokerageView.swift
//  accumate_app
//
//  Created by Nevin Richards on 12/14/24.
//

import SwiftUI

struct SignUpBrokerageView: View {
    @EnvironmentObject var navManager: NavigationPathManager
    @EnvironmentObject var sessionManager: UserSessionManager
    @State private var selectedBrokerage: Brokerages?
    @State private var submitted: Bool = false
    @State private var toggleRefresh: Bool = false
    @State private var showAlert: Bool = false
    @State private var alertMessage: String = ""
    @State private var buttonDisabled: Bool = false
    
    var isSignUp: Bool = true

    var body: some View {
        VStack {
            HStack {
                Spacer()
                Text("Select Brokerage")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundStyle(.white)
                    .multilineTextAlignment(.center)
                    .padding(.top, 30)
                Spacer()
            }
            .padding(.bottom, 50)
            
            ForEach(Brokerages.allCases, id: \.self) { brokerage in
                switch brokerage {
                case .robinhood:
                    Button {
                        buttonDisabled = true
                        selectedBrokerage = brokerage
                    } label: {
                        HStack {
                            Image(brokerage.imageName)
                                .resizable()
                                .frame(width: 60, height: 60)
                                .clipShape(Circle())
                                .padding(.leading, 10)
                            Text(brokerage.displayName)
                                .font(.headline)
                                .foregroundStyle(.white)
                                .padding(.leading, 10)
                            Spacer()
                        }
                        .padding(.vertical, 10)
                        .disabled(buttonDisabled)
                        .background(.black)
                    }
                    Divider()
                        .frame(height: 1.5)
                        .frame(maxWidth: .infinity)
                        .background(.white.opacity(0.6))
                default:
                    Rectangle()
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .foregroundStyle(.black)
                }
            }
            Spacer()
        }
        .onAppear {
            submitted = false
            selectedBrokerage = nil
        }
        .background(.black)
        .alert(alertMessage, isPresented: $showAlert) {
            if showAlert {
                Button("OK", role: .cancel) { showAlert = false }
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden()
        .onChange(of: selectedBrokerage) {
            if let selectedBrokerage = selectedBrokerage {
                sessionManager.brokerageName = selectedBrokerage.displayName
                setBrokerageInvestment()
            }
        }
        .onChange(of: submitted) {
            guard let brokerage = selectedBrokerage, submitted else { return }
            self.selectedBrokerage = nil
            sessionManager.brokerageName = brokerage.displayName
            print(brokerage)
            switch brokerage {
            case .robinhood:
                // save robinhood
                if isSignUp {
                    print(isSignUp)
                    navManager.append(.signUpRobinhoodSecurityInfo)
                } else {
                    print(isSignUp)
                    navManager.append(.robinhoodSecurityInfo)
                }
            default:
                break
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
    
    private func setBrokerageInvestment() {
        ServerCommunicator().callMyServer(
            path: "api/user/setbrokerageinvestment/",
            httpMethod: .post,
            params: [
                "brokerage" : sessionManager.brokerageName?.lowercased() as Any,
                "symbol" : sessionManager.etfSymbol as Any
            ],
            sessionManager: sessionManager,
            responseType: SuccessErrorResponse.self
        ) { response in
            switch response {
            case .success:
                print("success", response)
                self.buttonDisabled = false
                self.submitted = true
            case .failure(let error):
                print("failure", response)
                self.selectedBrokerage = nil
                self.alertMessage = error.errorMessage
                self.showAlert = true
                self.buttonDisabled = false
                return
            }
        }
    }
}

#Preview {
    SignUpBrokerageView()
        .environmentObject(NavigationPathManager())
        .environmentObject(UserSessionManager())
}
