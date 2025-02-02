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
    
    var body: some View {
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
                        .frame(width: .infinity, alignment: .leading)
                        .multilineTextAlignment(.leading)
                        .lineSpacing(1)
                    Text(String(format: "%.2f", growth) + "%")
                        .font(.subheadline)
                        .fontWeight(.bold)
                        .foregroundColor(growth > 0 ? .green : .red)
                        .lineLimit(nil)
                        .frame(width: .infinity, alignment: .leading)
                        .multilineTextAlignment(.leading)
                        .lineSpacing(1)
                }
                
                Spacer()
            }
            .padding(.leading, 10) // Space between image and text
            
            Spacer() // Push everything left and ensures full width
        }
        .frame(maxWidth: .infinity) // Makes it full-width
        .padding(.vertical, 15) // Adds padding above and below
        .background(.black) // Background color
    }
}


#Preview {
    SignUpETFsButtonView(
        imageName: "Invesco",//"heart.fill",
        title: "temp title",
        subtitle: "temp subtitle",
        growth: 13.5
    )
}
