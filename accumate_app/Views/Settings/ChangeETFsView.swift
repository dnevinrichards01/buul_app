//
//  ChangeETFsView.swift
//  accumate_app
//
//  Created by Nevin Richards on 2/2/25.
//

import SwiftUI

struct ChangeETFsView: View {
    let etfs: [ETF] = etfsList
    @State private var selectedETF: ETF?
    @State private var showAlert = false
    
    @EnvironmentObject var navManager: NavigationPathManager
    @EnvironmentObject var sessionManager: UserSessionManager

    var body: some View {
        VStack {
            // Header Text
            Text("Select an Investment")
                .font(.largeTitle)
                .fontWeight(.bold)
                .padding(.top, 20)
                .padding(.bottom, 5)
                .foregroundStyle(.white)
            Text("We will invest your cashback monthly. You can change your choice later.")
                .font(.subheadline)
                .padding(.horizontal, 40)
                .foregroundStyle(.white)

            // Scrollable Button List
            ScrollView {
                VStack(spacing: 10) {
                    ForEach(Array(etfs.enumerated()), id: \.0) { index, etf in
                        Divider()
                            .frame(height: 2)
                            .background(.white.opacity(0.8))
                        Button(action: {
                            selectedETF = etf
                        }) {
                            SignUpETFsButtonView(
                                imageName: etf.imageName,
                                title: etf.name,
                                subtitle: etf.timePeriod,
                                growth: etf.growth
                            )
                        }
                        .padding(.horizontal, 16) // Space on sides
                        .id(etf.id)
                    }
                    Divider()
                        .frame(height: 2)
                        .background(.white.opacity(0.8))
                }
                .padding(.top, 10)
            }
            .background(.black)
        }
        .onChange(of: selectedETF) {
            showAlert = true
            navManager.path.append(NavigationPathViews.home)
        }
        .alert("Your investment choice has been updated", isPresented: $showAlert) {
            Button("OK", role: .cancel) {}
        }
        .padding(.bottom, 10)
        .background(.black)
        .navigationBarBackButtonHidden(true)
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
        }
    }
}

#Preview {
    ChangeETFsView()
        .environmentObject(NavigationPathManager())
        .environmentObject(UserSessionManager())
}
