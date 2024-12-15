//
//  ETFButtonView.swift
//  accumate_appUITests
//
//  Created by Nevin Richards on 12/14/24.
//

import SwiftUI




struct ETFButtonView: View {
    @State var index: Int
    @State var option: ETFProviders
    var totalLength = ETFProviders.allCases.count
    
    var body: some View {
        let shape =
            RoundedCorners(
                corners: cornersToRound(
                    index: index,
                    totalLength: totalLength
                ),
                radius: 20
            )
        ZStack {
            Button {
                
            } label: {
                GeometryReader { geometry in
                    HStack {
                        option.logo
                            .resizable()
                            .scaledToFill()
                            .frame(width: 50, height: 50)
                            .clipShape(Circle())
                            .padding([.leading, .top, .bottom], 10)
                            .padding([.trailing], 5)
                        Text(option.text)
                            .foregroundColor(.black)
                            .font(.system(size: 20, weight: .semibold))
                        Spacer()
                    }
                    .frame(maxWidth: geometry.size.width / 2, maxHeight: .infinity)
                    
                    Rectangle()
                        .frame(width: 2)
                        .foregroundColor(Color.gray.opacity(0.6))
                        .position(x: geometry.size.width * 0.45, y: geometry.size.height / 2)
                    
                    ETFButtonColumn(option: option)
                        .frame(maxWidth: geometry.size.width / 2, maxHeight: .infinity)
                        .offset(x: geometry.size.width * 0.45, y: 0)
                    
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background (
                    Color.white
                        .frame(maxWidth: .infinity)//, maxHeight: .infinity)
                        .clipShape(shape)
                        .overlay(shape
                            .stroke(.gray.opacity(0.6), lineWidth: 2)
                        )
                )
            }
        }
        .frame(maxWidth: .infinity, maxHeight: CGFloat(option.etfs.count) * 105)
    }
    
    private func cornersToRound(index: Int, totalLength: Int ) -> UIRectCorner {
        if index == 0 {
            return [.topLeft, .topRight]
        } else if index == totalLength - 1 {
            return [.bottomLeft, .bottomRight]
        } else {
            return []
        }
    }
}

struct ETFButtonColumn: View {
    var option: ETFProviders
    var body: some View {
        HStack {
            VStack (alignment: .leading, spacing: 15) {
                ForEach(option.etfs, id: \.self) { etf in
                    VStack (alignment: .leading) {
                        Text(etf.text)
                            .multilineTextAlignment(.leading)
                            .foregroundColor(.black)
                            .font(.system(size: 18, weight: .semibold))
                        Text(etf.growth)
                            .multilineTextAlignment(.leading)
                            .foregroundColor(.gray.opacity(0.6))
                            .font(.system(size: 18, weight: .semibold))
                    }
                }
            }
            .padding()
            Spacer()
        }
    }
}

#Preview {
    ETFButtonView(
        index: 0,
        option: ETFProviders.vanguard
    )
    .background(.black)
    .frame(maxWidth: .infinity, maxHeight: .infinity)
    .ignoresSafeArea()
}
