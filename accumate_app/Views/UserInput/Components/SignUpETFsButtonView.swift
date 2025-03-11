//
//  SwiftUIView.swift
//  accumate_app
//
//  Created by Nevin Richards on 12/12/24.
//

import SwiftUI

struct SignUpETFsButtonView: View {
    var imageName: String
    var title: String
    var subtitle: String
    var growth: Double
    var etf: ETF
    @Binding var buttonDisabled: Bool
    @Binding var selectedETF: String
    
    var body: some View {
        Divider()
            .frame(height: 2)
            .background(.white.opacity(0.8))
        
        Button {
            buttonDisabled = true
            selectedETF = etf.symbol
        } label: {
            HStack {
                // Left Image
                Image(imageName)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 120, height: 80)
                    .padding(.leading, 5)
                    .padding(.trailing, 10)
                
                // Right Text Stack
                VStack(alignment: .leading) {
                    Text(title)
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundStyle(.white)
                        .padding(.top, 7)
                        .frame(alignment: .leading)
                        .multilineTextAlignment(.leading)
                        .lineSpacing(-15)
                    
                    HStack() {
                        Text(subtitle + ":")
                            .font(.subheadline)
                            .foregroundColor(.white.opacity(0.8))
                            .lineLimit(nil)
                            .multilineTextAlignment(.leading)
                            .lineSpacing(1)
                        Text(String(format: "%.2f", growth) + "%")
                            .font(.subheadline)
                            .fontWeight(.bold)
                            .foregroundColor(growth > 0 ? .green : .red)
                            .lineLimit(nil)
                            .multilineTextAlignment(.leading)
                            .lineSpacing(1)
                    }
                    
                    Spacer()
                }
                .padding(.leading, 10) // Space between image and text
                
                Spacer() // Push everything left and ensures full width
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 15)
        .frame(maxWidth: .infinity)
        .disabled(buttonDisabled)
        .id(etf.id)
        .background(.black) // Background color
        
//        Divider()
//            .frame(height: 2)
//            .background(.white.opacity(0.8))
    }
}
