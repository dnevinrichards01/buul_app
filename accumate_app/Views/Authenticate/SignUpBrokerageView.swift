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
                Button {
                    selectedBrokerage = brokerage
                } label: {
                    HStack {
                        Image(brokerage.imageName)
                            .resizable()
                            .frame(width: 60, height: 60)
                            .clipShape(Circle())
                            .padding(.leading, 10)
                        Text(brokerage.name)
                            .font(.headline)
                            .foregroundStyle(.white)
                            .padding(.leading, 10)
                        Spacer()
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
        .background(.black)
        .onAppear() {
            selectedBrokerage = nil
        }
        .onChange(of: selectedBrokerage) {
            if let selectedBrokerage = selectedBrokerage {
                switch selectedBrokerage {
                case .robinhood:
                    // save robinhood
                    if isSignUp {
                        navManager.path.append(NavigationPathViews.signUpRobinhoodSecurityInfo)
                    } else {
                        navManager.path.append(NavigationPathViews.robinhoodSecurityInfo)
                    }
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
}

#Preview {
    SignUpBrokerageView()
        .environmentObject(NavigationPathManager())
        .environmentObject(UserSessionManager())
}
