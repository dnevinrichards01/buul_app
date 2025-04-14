//
//  PlaidInfo.swift
//  accumate_app
//
//  Created by Nevin Richards on 2/14/25.
//

import SwiftUI

struct PlaidInfo: View {
    @EnvironmentObject var navManager: NavigationPathManager
    
    var nextPage: NavigationPathViews
    var isSignUp: Bool
    
    var body: some View {
        VStack {
            VStack (spacing: 10) {
                HStack {
                    Text("Connect your bank account with Plaid")
                        .font(.system(size: 30, weight: .bold))
                        .foregroundColor(.white)
                        .multilineTextAlignment(.center)
                }
                .padding(.top, 50)
                HStack {
                    Image("BuulLogoText")
                        .resizable()
                        .frame(width: 130, height: 55)
                        .padding(.bottom, 10)
                    Image(systemName: "plus")
                        .resizable()
                        .frame(width: 15, height: 15)
                        .foregroundColor(.white)
                        .padding(.leading, 10)
                    Image("PlaidLinkLogo")
                        .resizable()
                        .frame(width: 150, height: 53.5)
                }
                .padding(.bottom, 30)
                
                VStack(alignment: .center, spacing: 20) {
                    FeatureItem(iconName: "building.columns", title: "Select Bank Accounts", description: "Select accounts you want us to monitor for redeemed cashback or withdraw from to deposit into your brokerage.")
                    FeatureItem(iconName: "tray.full", title: "Your Data", description: "We will view your balance to prevent overdrawing, and your transaction history to identify redeemed cashback.")
                    FeatureItem(iconName: "shield.fill", title: "Revocable", description: "Your data is only stored or accessed as needed with end-to-end encryption.")
                    FeatureItem(iconName: "xmark.seal.fill", title: "Security", description: "You will be able to revoke our access through settings, deleting your account, or contacting Buul")
                }
                
                Spacer()
                
                Button {
                    navManager.append(nextPage)
                } label: {
                    Text("Connect")
                        .font(.headline)
                        .foregroundColor(.black)
                        .frame(maxWidth: .infinity, minHeight: 50)
                        .background(.white)
                        .cornerRadius(10)
                }
                .padding()
            }
            .padding(.top, 50)
            
        }
        .padding()
        .navigationBarBackButtonHidden()
        .background(.black)
        .ignoresSafeArea()
        .toolbar {
            if !isSignUp {
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
}

#Preview {
    PlaidInfo(
        nextPage: .home,
        isSignUp: true
    )
    .environmentObject(NavigationPathManager())
}


