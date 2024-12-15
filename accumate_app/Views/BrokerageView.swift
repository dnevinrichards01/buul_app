//
//  BrokerageView.swift
//  accumate_app
//
//  Created by Nevin Richards on 12/14/24.
//

import SwiftUI

struct BrokerageView: View {
    @EnvironmentObject var navManager: NavigationPathManager
    
    var body: some View {
        GeometryReader { geometry in
            ScrollView {
                VStack {
                    ForEach(Brokerages.allCases.indices, id: \.self) { index in
                        let option = Brokerages.allCases[index]
                        ZStack {
                            Button {
                                navManager.path.append(option.connectPage)
                            } label: {
                                HStack(spacing: 8) {
                                    option.logo
                                        .resizable()
                                        .scaledToFill()
                                        .frame(width: 50, height: 50)
                                        .clipShape(Circle())
                                        .padding(10)
                                        
                                    Text(option.name)
                                        .foregroundColor(.black)
                                        .font(.system(size: 24, weight: .semibold))
                                    Spacer()
                                    Image(systemName: "chevron.right")
                                        .resizable()
                                        .frame(width: 18, height: 18)
                                        .foregroundColor(.black)
                                        .padding()
                                }
                            }
                            .background (
                                Color.white
                                    .cornerRadius(10)
                            )
                        }
                    }
                    Spacer()
                }
                .padding()
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
                    Text("Select your brokerage")
                        .foregroundColor(.white)
                        .font(.system(size: 24, weight: .semibold))
                        .frame(maxHeight: 30)
                }
            }
        }
    }
}

#Preview {
    BrokerageView()
        .environmentObject(NavigationPathManager())
}
