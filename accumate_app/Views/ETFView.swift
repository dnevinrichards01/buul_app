////
////  BrokerageView.swift
////  accumate_app
////
////  Created by Nevin Richards on 12/14/24.
////
//
//import SwiftUI
//
//struct ETFView: View {
//    @State var etfList: [ETF]
//    
//    @EnvironmentObject var navManager: NavigationPathManager
//    
//    var body: some View {
//        GeometryReader { geometry in
//            ScrollView {
//                Text("ETF Return over past 5 years")
//                    .multilineTextAlignment(.leading)
//                    .foregroundColor(.white)
//                    .font(.system(size: 18, weight: .semibold))
//                VStack (spacing: 0) {
//                    ForEach(Array(etfList.etfList.enumerated()), id: \.1) {index, option in
//                        ETFButtonView(index: index, option: option)
//                            .padding(10)
//                    }
//                    Spacer()
//                }
//                .padding(5)
//                .frame(maxWidth: .infinity, minHeight: geometry.size.height, maxHeight: .infinity)
//            }
//            .background(.black)
//            .navigationBarTitleDisplayMode(.inline)
//            .toolbar {
//                ToolbarItem(placement: .navigationBarLeading) {
//                    Button(action: {
//                        navManager.path.removeLast()
//                    }) {
//                        Image(systemName: "chevron.left")
//                            .foregroundColor(.white)
//                            .font(.system(size: 20, weight: .medium))
//                            .frame(maxHeight: 30)
//                    }
//                }
//                ToolbarItem(placement: .principal) {
//                    Text("Select an ETF")
//                        .foregroundColor(.white)
//                        .font(.system(size: 24, weight: .semibold))
//                        .frame(maxHeight: 30)
//                }
//            }
//        }
//    }
//}
//
//
//#Preview {
//                        ETFView(etfList: etfList)
//        .environmentObject(NavigationPathManager())
//}
