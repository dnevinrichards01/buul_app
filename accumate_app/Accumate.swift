//
//  accumate_appApp.swift
//  accumate_app
//
//  Created by Nevin Richards on 12/2/24.
//

import SwiftUI

@main
struct Accumate: App {
    @StateObject var navManager = NavigationPathManager()
    
    var body: some Scene {
        WindowGroup {
            LandingView()
                .environmentObject(navManager)
        }
        
    }
}

