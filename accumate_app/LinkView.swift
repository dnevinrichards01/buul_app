//
//  LinkView.swift
//  accumate_app
//
//  Created by Nevin Richards on 12/13/24.
//

import SwiftUI

struct LinkView: View {
    @EnvironmentObject var navManager : NavigationPathManager
    
    @State private var linkCompleted = false
    
    var body: some View {
        GeometryReader { geometry in
            VStack {
                HStack {
                    Text("Connecting to your bank with Plaid")
                        .font(.system(size: 24, weight: .bold))
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
                
            }
            .padding()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.black) // Background fills the frame
    }

}

#Preview {
    LinkView()
}
