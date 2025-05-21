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
    @Binding var alertMessage: String
    @Binding var showAlert: Bool
    
    var body: some View {
        Button {
            if brokerage != .robinhood {
                showAlert = true
                alertMessage = "We can save this selection as your brokerage, but we are not yet able to connect with it. Do you want to select it anyways?"
                selectedBrokerage = brokerage.rawValue
            } else {
                buttonDisabled = true
                selectedBrokerage = brokerage.rawValue
            }
        } label: {
            HStack {
                Image(brokerage.imageName)
                    .resizable()
                    .frame(width: brokerage.imageDim[0], height: brokerage.imageDim[1])
                    .padding(.leading, 30)
                Spacer()
            }
            .frame(height: 80)
            .disabled(buttonDisabled)
            .background(.black)
        }
        Divider()
            .frame(height: 1.5)
            .frame(maxWidth: .infinity)
            .background(.white.opacity(0.6))
    }
}
