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
    @StateObject var sessionManager = UserSessionManager()
    
    init() {
        initToolbarAppearance()
    }
    
    var body: some Scene {
        WindowGroup {
            LandingView()
                .environmentObject(navManager)
                .environmentObject(sessionManager)
        }
    }
    
    func initToolbarAppearance() {
        // Configure appearance for the navigation bar
        let navAppearance = UINavigationBarAppearance()
        navAppearance.configureWithOpaqueBackground()
        navAppearance.backgroundColor = UIColor.black
        // Apply appearance to the navigation bar
        UINavigationBar.appearance().standardAppearance = navAppearance
        UINavigationBar.appearance().scrollEdgeAppearance = navAppearance
        
        let toolbarAppearance = UIToolbarAppearance()
        toolbarAppearance.configureWithOpaqueBackground()
        toolbarAppearance.backgroundColor = .black
        toolbarAppearance.shadowColor = nil
        UIToolbar.appearance().standardAppearance = toolbarAppearance
        UIToolbar.appearance().compactAppearance = toolbarAppearance
        UIToolbar.appearance().scrollEdgeAppearance = toolbarAppearance
    }
}

