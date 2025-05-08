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
    var description: String
    var compositionImages: [String]
    var link: String
    @State private var isToggled: Bool = false
    var targetDemographic: String
    var pros: [String]
    var cons: [String]
    
    var body: some View {
        VStack {
            Button {
                isToggled.toggle()
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
            .padding(.top, 15)
            .padding(.bottom, isToggled ? 0 : 15)
            .frame(maxWidth: .infinity)
            .disabled(buttonDisabled)
            .id(etf.id)
            .background(.black)
            
            VStack {
                VStack (alignment: .leading) {
                    
                    Text("Best for: \(targetDemographic)")
                        .font(.headline)
                        .foregroundColor(.white.opacity(1.0))
                        .lineLimit(nil)
                        .minimumScaleFactor(1)
                        .layoutPriority(1)
                        .multilineTextAlignment(.leading)
                        .fixedSize(horizontal: false, vertical: true)
                        .lineSpacing(1)
                        .padding(.vertical, 5)
                    
                    Text(description)
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
                        if let url = URL(string: link) {
                            UIApplication.shared.open(url)
                        }
                    } label: {
                        Text("Visit this webpage to learn more.")
                            .font(.subheadline)
                            .foregroundColor(.blue)
                            .lineLimit(nil)
                            .minimumScaleFactor(1)
                            .layoutPriority(1)
                            .multilineTextAlignment(.leading)
                            .fixedSize(horizontal: false, vertical: true)
                            .lineSpacing(1)
                    }
                    
                    VStack {
                        ForEach(pros.indices, id: \.self) { index in
                            BulletPoint(
                                imageSystemName: "checkmark.circle.fill",
                                imageColor: .green,
                                text: pros[index]
                            )
                            .frame(maxWidth: .infinity, alignment: .leading)
                        }
                        ForEach(cons.indices, id: \.self) { index in
                            BulletPoint(
                                imageSystemName: "info.circle",
                                imageColor: .gray,
                                text: cons[index]
                            )
                            .frame(maxWidth: .infinity, alignment: .leading)
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    
                    TabView {
                        ForEach(compositionImages.indices, id: \.self) { index in
                            let image = compositionImages[index]
                            Image(image)
                                .resizable()
                                .frame(width: 300, height: 360)
                                .tag(index)
                        }
                    }
                    .tabViewStyle(.page)
                    .indexViewStyle(.page(backgroundDisplayMode: .always))
                    .frame(width: compositionImages.count > 0 ? 300 : 0, height: compositionImages.count > 0 ? 400 : 0, alignment: .center)
                    
                    Button {
                        buttonDisabled = true
                        selectedETF = etf.symbol
                    } label: {
                        HStack {
                            Text("Select")
                                .font(.subheadline)
                                .foregroundColor(.white)
                                .lineLimit(nil)
                                .minimumScaleFactor(1)
                                .layoutPriority(1)
                                .multilineTextAlignment(.leading)
                                .fixedSize(horizontal: false, vertical: true)
                                .lineSpacing(1)
                            Color.black
                                .frame(maxWidth: .infinity)
                            Image(systemName: "chevron.right")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 20, height: 20)
                                .foregroundStyle(.white.opacity(0.8))
                        }
                        .padding()
                    }
                    .contentShape(Rectangle())
                    .buttonStyle(DimOnPressButtonStyle())
                    
                    
                    .frame(alignment: .center)
                    .disabled(buttonDisabled)
                    .id(etf.id)
                }
                .padding(.horizontal, 16)
                .frame(maxWidth: .infinity)
                .background(.black)
                .opacity(isToggled ? 1 : 0)
                .frame(height: isToggled ? nil : 0)
                
                Divider()
                    .frame(height: 1.5)
                    .frame(maxWidth: .infinity)
                    .background(.white.opacity(0.6))
            }
            
//            .clipped()
             // animates fade
            
        }
//        .animation(.easeInOut(duration: 1.0), value: isToggled)
        
        
        
//        Divider()
//            .frame(height: 2)
//            .background(.white.opacity(0.8))
    }
}

struct BulletPoint: View {
    var imageSystemName: String
    var imageColor: Color
    var text: String
    
    var body: some View {
        HStack {
            Image(systemName: imageSystemName)
                .foregroundColor(imageColor)
                .frame(width: 25, height: 25)
            Text(text)
                .font(.subheadline)
                .foregroundColor(.white.opacity(0.8))
                .lineLimit(nil)
                .minimumScaleFactor(1)
                .layoutPriority(1)
                .multilineTextAlignment(.leading)
                .fixedSize(horizontal: false, vertical: true)
                .lineSpacing(1)
                .padding(.top, 5)
            
        }
    }
}


struct DimOnPressButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .opacity(configuration.isPressed ? 0.5 : 1)
            .overlay(
                RoundedRectangle(cornerRadius: 10)
                    .stroke(configuration.isPressed ? .white.opacity(0.4) : .white.opacity(0.8), lineWidth: 1)
            )
            .animation(.easeInOut(duration: 0.15), value: configuration.isPressed)
    }
}
