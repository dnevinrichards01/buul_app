//
//  BrokerageButtonView.swift
//  accumate_app
//
//  Created by Nevin Richards on 3/7/25.
//

import SwiftUI

struct BrokerageButtonView: View {
    var brokerage: Brokerages
    @Binding var buttonDisabled: Bool
    @Binding var selectedBrokerage: String
    
    var body: some View {
        Button {
            buttonDisabled = true
            selectedBrokerage = brokerage.displayName.lowercased()
        } label: {
            HStack {
                Image(brokerage.imageName)
                    .resizable()
                    .frame(width: 60, height: 60)
                    .clipShape(Circle())
                    .padding(.leading, 10)
                Text(brokerage.displayName)
                    .font(.headline)
                    .foregroundStyle(.white)
                    .padding(.leading, 10)
                Spacer()
            }
            .padding(.vertical, 10)
            .disabled(buttonDisabled)
            .background(.black)
        }
        Divider()
            .frame(height: 1.5)
            .frame(maxWidth: .infinity)
            .background(.white.opacity(0.6))
    }
}
