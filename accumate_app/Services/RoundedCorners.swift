//
//  RoundedCorners.swift
//  accumate_app
//
//  Created by Nevin Richards on 12/14/24.
//
//  will use to clip shape of buttons on ETF page

import SwiftUI


struct RoundedCorners: Shape {
    var corners: UIRectCorner
    var radius: CGFloat

    func path(in rect: CGRect) -> Path { // SwiftUI calls path automatically when view heirarchy is updated / on re-renders
        let path = UIBezierPath(
            roundedRect: rect,
            byRoundingCorners: corners,
            cornerRadii: CGSize(width: radius, height: radius)
        )
        return Path(path.cgPath) // to make this UIKit object compatible with SwiftUI
    }
}
