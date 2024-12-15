//
//  BrokerageView.swift
//  accumate_app
//
//  Created by Nevin Richards on 12/14/24.
//

import SwiftUI

struct ETFView: View {
    @EnvironmentObject var navManager: NavigationPathManager
    
    var body: some View {
        GeometryReader { geometry in
            ScrollView {
                VStack (spacing: 0) {
                    let options = Array(ETFProviders.allCases)
                    ForEach(Array(options.enumerated()), id: \.0) {index, option in
                        ETFButtonView(index: index, option: option)
                    }
                    Spacer()
                }
                .padding(5)
                .frame(maxWidth: .infinity, minHeight: geometry.size.height, maxHeight: .infinity)
            }
            .background(.black)
            .navigationBarTitleDisplayMode(.inline)
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
                ToolbarItem(placement: .principal) {
                    Text("Select an ETF")
                        .foregroundColor(.white)
                        .font(.system(size: 24, weight: .semibold))
                        .frame(maxHeight: 30)
                }
            }
        }
    }
}


#Preview {
    ETFView()
        .environmentObject(NavigationPathManager())
}
