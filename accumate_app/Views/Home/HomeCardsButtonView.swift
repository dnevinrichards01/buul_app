//
//  SwiftUIView.swift
//  accumate_app
//
//  Created by Nevin Richards on 12/12/24.
//

import SwiftUI

struct HomeCardsButtonView: View {
    var imageName: String
    var title: String
    var subtitle: String
    var isToggled: Bool
    var url: String
    var category: String
    var categoryPercentage: Double
    
    var body: some View {
        
        ZStack (alignment: .topLeading) {
            VStack {
                Divider()
                    .frame(height: 2)
                    .background(.white.opacity(0.8))
                
                HStack (alignment: .top) {
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
                            .lineLimit(nil)
                            .minimumScaleFactor(1)
                            .layoutPriority(1)
                            .fixedSize(horizontal: false, vertical: true)
                            .frame(alignment: .leading)
                            .multilineTextAlignment(.leading)
                            .lineSpacing(-15)
                        
                        Text(subtitle)
                            .font(.subheadline)
                            .foregroundColor(.white.opacity(0.8))
                            .lineLimit(nil)
                            .minimumScaleFactor(1)
                            .layoutPriority(1)
                            .fixedSize(horizontal: false, vertical: true)
                            .frame(alignment: .leading)
                            .multilineTextAlignment(.leading)
                            .lineSpacing(1)
                    }
                    
                    
                    .padding(.leading, 10) // Space between image and text
                    
                    Spacer() // Push everything left and ensures full width
                }
                .padding(.top, 10)
                
                if isToggled {
                    VStack (alignment: .leading) {
//                        Text("We recommended this card because your spending is high in \(category) at \(formatAsDecimal(categoryPercentage))% of spending. \n\nYou can learn more and sign up here:")
                        Text("We recommend this card if your spending is high in \(category). \n\nYou can learn more and sign up here:")
                            .font(.subheadline)
                            .foregroundColor(.white.opacity(0.8))
                            .lineLimit(nil)
                            .minimumScaleFactor(1)
                            .layoutPriority(1)
                            .multilineTextAlignment(.leading)
                            .fixedSize(horizontal: false, vertical: true)
                            .lineSpacing(1)
                            .padding(.top, 5)
                        
                        Button {
                            if let url = URL(string: url) {
                                UIApplication.shared.open(url)
                            }
                        } label: {
                            Text(title)
                                .font(.subheadline)
                                .foregroundColor(.blue)
                                .lineLimit(nil)
                                .minimumScaleFactor(1)
                                .layoutPriority(1)
                                .multilineTextAlignment(.leading)
                                .fixedSize(horizontal: false, vertical: true)
                                .lineSpacing(1)
                        }
                        .frame(alignment: .center)
                    }
                    .padding(.top, 5)
                }
            }
//            Divider()
//                .frame(height: 2)
//                .background(.white.opacity(0.8))
        }
        .padding(.vertical, 15)
        .background(Color.black.ignoresSafeArea())
        
        
    }
    
    func formatAsDecimal(_ value: Double) -> String {
        let formatter = NumberFormatter()
//        formatter.numberStyle = .currency
//        formatter.currencySymbol = "$"
        formatter.maximumFractionDigits = 2
        return formatter.string(from: NSNumber(value: value)) ?? "0.00"
    }
}




#Preview {
    HomeCardsButtonView(
        imageName: "CashPlusVisa",
        title: "temp title",
        subtitle: "temp subtitle",
        isToggled: true,
        url: "www.google.com",
        category: "dining",
        categoryPercentage: 22.54
    )
}
