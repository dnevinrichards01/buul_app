//
//  PlaidInstructionsView.swift
//  accumate_app
//
//  Created by Nevin Richards on 5/2/25.
//

import SwiftUI

struct RedeemCashbackInstructionsView: View {
    @EnvironmentObject var navManager: NavigationPathManager
    
    var nextPage: NavigationPathViews
    var isSignUp: Bool
    var goBackNPagesOnCompletion: Int = 0
    var autoRedeemInstructions: [String : String] = [
        "Bank of America" : "https://info.bankofamerica.com/en/digital-banking/how-to/online-banking-rewards-demo",
        "Capital One": "https://www.capitalone.com/help-center/credit-cards/manage-your-rewards/",
        "Discover": "https://www.discover.com/credit-cards/cash-back/redeem-cashback.html",
        "Wells Fargo": "https://www.wellsfargo.com/rewards/"
    ]
    
    var body: some View {
        VStack {
            VStack (spacing: 10) {
                Text("Congratulations on completing your onboarding!")
                    .font(.system(size: 30, weight: .bold))
                    .foregroundColor(.white)
                    .multilineTextAlignment(.leading)
                    .lineLimit(nil)
                    .minimumScaleFactor(1)
                    .layoutPriority(1)
                    .fixedSize(horizontal: false, vertical: true)
                    .padding()
                    .frame(maxWidth: .infinity, alignment: .leading)
                
                VStack(alignment: .leading, spacing: 8) {
                    Text("Your cashback will get invested when it is:")
                        .font(.headline)
                        .foregroundColor(.white)
                        .multilineTextAlignment(.leading)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    HStack (alignment: .top) {
                        Text("•")
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(alignment: .leading)
                            .frame(width: 20)
                        Text("Deposited into your checking account")
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity, alignment: .leading)
                        Spacer()
                    }
//                    .padding(.leading, 5)
                    .padding(.top, 10)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    
                    HStack (alignment: .top) {
                        Text("•")
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(alignment: .leading)
                            .frame(width: 20)
                        Text("Applied as statement credit")
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity, alignment: .leading)
                        Spacer()
                    }
                    .padding(.top, 10)
//                    .padding(.leading, 5)
                    .frame(maxWidth: .infinity, alignment: .leading)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding()
                
                VStack(alignment: .leading, spacing: 8) {
                    Text("We highly recommend enabling auto-redemption. This ensures your rewards are seemlessly collected and invested without any extra steps.")
                        .font(.title3)
                        .foregroundColor(.green)
                        .multilineTextAlignment(.leading)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .lineLimit(nil)
                        .minimumScaleFactor(1)
                        .layoutPriority(1)
                        .fixedSize(horizontal: false, vertical: true)
                        
                    
//                    ForEach(Array(autoRedeemInstructions), id: \.0) { key, val in
//                        Button {
//                            if let url = URL(string: val) {
//                                UIApplication.shared.open(url)
//                            }
//                        } label: {
//                            HStack (spacing: 0) {
//                                Text("• ")
//                                    .font(.headline)
//                                    .foregroundColor(.white)
//                                Text(key)
//                                    .font(.headline)
//                                    .foregroundColor(.blue)
//                                    .underline(color: .blue)
//                                    .lineLimit(nil)
//                                    .minimumScaleFactor(1)
//                                    .layoutPriority(1)
//                                    .fixedSize(horizontal: false, vertical: true)
//                                    .frame(maxWidth: .infinity, alignment: .leading)
//                            }
//                            .padding(.leading, 40)
//                            .frame(maxWidth: .infinity, alignment: .leading)
//                        }
//                        .padding(.top, 10)
//                        .frame(maxWidth: .infinity, alignment: .leading)
//                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding()
                
                VStack(alignment: .leading, spacing: 8) {
                    Text("Need help setting it up? Contact us any time!")
                        .font(.headline)
                        .italic()
                        .foregroundColor(.white)
                        .multilineTextAlignment(.leading)
                        .frame(maxWidth: .infinity, alignment: .leading)
//                    Text("notifications@bu-ul.com")
//                        .font(.headline)
//                        .italic()
//                        .foregroundColor(.blue)
//                        .frame(maxWidth: .infinity, alignment: .leading)
//                        .contextMenu {
//                            Button(action: {
//                                UIPasteboard.general.string = "notifications@bu-ul.com"
//                            }) {
//                                Label("Copy Email", systemImage: "doc.on.doc")
//                            }
//                        }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding()
                
                
                Spacer()
                
                Button {
                    if goBackNPagesOnCompletion > 0 {
                        navManager.removeLast(1)
                    } else {
                        navManager.append(nextPage)
                    }
                } label: {
                    Text("Continue")
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
//                        navManager.path.removeLast()
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
    RedeemCashbackInstructionsView(
        nextPage: .home,
        isSignUp: true
    )
    .environmentObject(NavigationPathManager())
}



