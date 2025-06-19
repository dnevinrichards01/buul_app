//
//  HomeLoadingScreen.swift
//  buul_app
//
//  Created by Nevin Richards on 6/12/25.
//

import SwiftUI

struct HomeLoadingScreen: View {
    @State private var dotCount = 0
    private let maxDots = 3
    private let timer = Timer.publish(every: 0.4, on: .main, in: .common).autoconnect()
    
    var body: some View {
        VStack {
            HStack(spacing: 10) {
                Spacer()
                Text("Loading your investments")
                    .font(.title2)
                    .fontWeight(.medium)
                    .foregroundColor(.white)
                Text(String(repeating: ".", count: dotCount))
                    .font(.largeTitle)
                    .fontWeight(.medium)
                    .foregroundColor(.white)
                    .frame(width: 40, alignment: .leading)
                    .animation(.easeInOut, value: dotCount)
                    .padding(.bottom, 10)
                Spacer()
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.black.ignoresSafeArea())
        .onReceive(timer) { _ in
            dotCount = (dotCount + 1) % (maxDots + 1)
        }
    }
}
#Preview {
    HomeLoadingScreen()
}
