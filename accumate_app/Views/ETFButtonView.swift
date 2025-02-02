////
////  ETFButtonView.swift
////  accumate_appUITests
////
////  Created by Nevin Richards on 12/14/24.
////
//
//import SwiftUI
//
//
//
//
//struct ETFButtonView: View {
//    @State var index: Int
//    @State var option: ETF
//    
//    var body: some View {
//            Button {
//                
//            } label: {
//                GeometryReader { geometry in
//                    HStack (spacing: 0) {
//                        HStack (spacing: 0) {
//                            HStack {
//                                getOrDefault(get: option.name, defaultVal: Image(systemName: ""), map: ETFLogoMap)
//                                    .resizable()
//                                    .scaledToFill()
//                                    .frame(width: 50, height: 50)
//                                    .clipShape(Circle())
//                                    .padding([.leading, .top, .bottom], 10)
//                                    .padding([.trailing], 5)
//                                VStack (alignment: .leading, spacing: 5) {
//                                    Text(option.name)
//                                        .multilineTextAlignment(.leading)
//                                        .foregroundColor(.black)
//                                        .font(.system(size: 18, weight: .semibold))
//                                    Text("By \(option.provider)")
//                                        .foregroundColor(.gray.opacity(0.6))
//                                        .font(.system(size: 20, weight: .semibold))
//                                }
//                                Spacer()
//                            }
//                            .frame(width: geometry.size.width *  0.65, alignment: .leading)
//                            
//                            Text(option.growth)
//                                .multilineTextAlignment(.leading)
//                                .foregroundColor(.black)
//                                .font(.system(size: 18, weight: .semibold))
//                            .padding()
//                            .frame(width: geometry.size.width * 0.35, alignment: .leading)
//                        }
//                        .frame(maxWidth: .infinity, maxHeight: .infinity)
//                        .background (
//                            Color.white
//                                .frame(maxWidth: .infinity)
//                                .clipShape(RoundedRectangle(cornerRadius: 10))
//                                .overlay(RoundedRectangle(cornerRadius: 10).stroke(.gray.opacity(0.6), lineWidth: 2))
//                        )
//                    }
//                }
//            }
//            .frame(maxWidth: .infinity, maxHeight: 110)
//        
//        
//    }
//}
//
//
//#Preview {
//    ETFButtonView(
//        index: 0,
//        option: voo
//    )
//    .background(.black)
//    .frame(maxWidth: .infinity, maxHeight: .infinity)
//    .ignoresSafeArea()
//}
