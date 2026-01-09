//
//  UIHelpers.swift
//  The nest
//
//  Created by Eezy Mongo on 2026-01-09.
//

import Foundation
import SwiftUI

// Helper for the deep rounded corners on the white onboarding card
struct CustomCorners: Shape {
    var corners: UIRectCorner
    var radius: CGFloat
    
    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(roundedRect: rect, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
        return Path(path.cgPath)
    }
}

// A simple wrapper to display the illustrations in the onboarding TabView
struct OnboardingIllustration: View {
    let imageName: String
    
    var body: some View {
        Image(imageName)
            .resizable()
            .scaledToFit()
            .padding(40)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}
