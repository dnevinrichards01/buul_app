//
//  NetworkingTesting.swift
//  accumate_app
//
//  Created by Nevin Richards on 2/7/25.
//

import SwiftUI

struct NetworkingTesting: View {
    @State private var text: String = "Hello, World!"
    var body: some View {
        Text(text)
//            .task {
//                let comm = ServerCommunicator(baseURL: "https://sandbox.plaid.com/")
//                comm.callMyServer(path: <#T##String#>, httpMethod: <#T##HTTPMethod#>, responseType: <#T##T#>)
//            }
    }
    
}

#Preview {
    NetworkingTesting()
}
