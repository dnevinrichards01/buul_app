//
//  NavPathModel.swift
//  accumate_app
//
//  Created by Nevin Richards on 12/12/24.
//
import SwiftUI

@MainActor
class NavigationPathManager: ObservableObject {
    
    @Published var path: NavigationPath = NavigationPath()
    private var pathArray: [NavigationPathViews] = []
    
    func append(_ view: NavigationPathViews) {
        pathArray.append(view)
        path.append(view)
    }

    
    func reset(views: [NavigationPathViews] = []) {
        pathArray = views
        path = NavigationPath(views)
    }
    
    func extend(_ views: [NavigationPathViews]) {
        pathArray.append(contentsOf: views)
        path = NavigationPath(pathArray)

    }
}






