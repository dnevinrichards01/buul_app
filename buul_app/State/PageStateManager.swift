//
//  PageStateManager.swift
//  accumate_app
//
//  Created by Nevin Richards on 5/14/25.
//

//import SwiftUI
//
//class PageStateManager: ObservableObject {
//    @Published var var1: String?
//    var var2: String?
//    @AppStorage("buul.user.preAccountId") var _preAccountId: Int?
//    
//    @AppStorage("buul.user.plaidItems") var plaidItemsData: String = "[]"
//    var plaidItems: [String] {
//        get {
//            (try? JSONDecoder().decode([String].self, from: Data(plaidItemsData.utf8))) ?? []
//        }
//        set {
//            if let encoded = try? JSONEncoder().encode(newValue) {
//                plaidItemsData = String(data: encoded, encoding: .utf8) ?? "[]"
//            }
//        }
//    }
//}
//
//enum ErrorState {
//    let error = 
//}
//
//enum PageState {
//    
//}
