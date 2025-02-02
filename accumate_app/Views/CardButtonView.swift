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
//struct CardButtonView: View {
//    @State var index: Int
//    @State var option: Card
//    
//    private let width = UIScreen.main.bounds.width - 16 * 4
//    
//    var body: some View {
//        HStack {
//            Button {
//                
//            } label: {
//                HStack (spacing: 0) {
//                    HStack (spacing: 0) {
//                        VStack (alignment: .leading) {
//                            Text(option.name)
//                                .multilineTextAlignment(.leading)
//                                .foregroundColor(.black)
//                                .font(.system(size: 22, weight: .bold))
//                                .padding([.bottom], 1)
//                            Text(option.description)
//                                .multilineTextAlignment(.leading)
//                                .foregroundColor(.gray.opacity(0.6))
//                                .font(.system(size: 18, weight: .semibold))
//                        }
//                        .padding()
//                        .frame(width: width *  0.65, alignment: .leading)
//                        
//                        Spacer()
//                        
//                        getOrDefault(get: option.name, defaultVal: Image(systemName: ""), map: cardImageMap)
//                            .resizable()
//                            .scaledToFill()
//                            .frame(width: 50, height: 50)
//                            .clipShape(Circle())
//                            .padding()
//                        
//                    }
//                    .frame(maxWidth: .infinity)
//                    .background (
//                        Color.white
//                            .frame(maxWidth: .infinity)//, maxHeight: .infinity)
//                            .clipShape(RoundedRectangle(cornerRadius: 10))
//                            .overlay(RoundedRectangle(cornerRadius: 10).stroke(.gray.opacity(0.6), lineWidth: 2))
//                    )
//                }
//            }
//            .frame(maxWidth: .infinity)
//        }
//    }
//}
//
//#Preview {
//    CardButtonView(
//        index: 0,
//        option: discoverIt
//    )
//    .background(.black)
//    .frame(maxWidth: .infinity, maxHeight: .infinity)
//    .ignoresSafeArea()
//}
