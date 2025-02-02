//
//  LinkView.swift
//  accumate_app
//
//  Created by Nevin Richards on 12/13/24.
//

import SwiftUI

struct LinkView: View {
    @EnvironmentObject var navManager : NavigationPathManager
    @EnvironmentObject var sessionManager: UserSessionManager
    
    @State private var linkCompleted = false
    
    var body: some View {
        GeometryReader { geometry in
            HStack {
                Spacer()
                VStack {
                    HStack {
                        Text("Connecting to your bank with Plaid")
                            .font(.system(size: 30, weight: .bold))
                            .foregroundColor(.white)
                            .multilineTextAlignment(.center)
                            .padding([.leading, .trailing], 20)
                    }
                    Spacer().frame(height: geometry.size.height * 0.25)
                    VStack {
                        Image("AccumateLogoText")
                            .resizable()
                            .frame(width: 200, height: 70)
                        Image(systemName: "plus")
                            .resizable()
                            .frame(width: 30, height: 30)
                            .foregroundColor(.white)
                        Image("PlaidLinkLogo")
                            .resizable()
                            .frame(width: 200, height: 70)
                    }
                    Spacer()
                    Button {
                        sessionManager.isLoggedIn = true
                        navManager.path.append(NavigationPathViews.home)
                    } label: {
                        Text("completed signup (temp)")
                            .font(.headline)
                            .foregroundColor(.black)
                            .frame(maxWidth: .infinity, minHeight: 50)
                            .background(Color(red: 75/255, green: 135/255, blue: 120/255))
                            .cornerRadius(10)
                    }
                    
                }
                .padding()
                Spacer()
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.black)
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden()
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
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
//        .onChange(of: linkCompleted) {
//            navManager.path.append(NavigationPathViews.home)
//        }
    }

}

#Preview {
    LinkView()
        .environmentObject(NavigationPathManager())
}
