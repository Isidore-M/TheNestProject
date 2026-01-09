//
//  OnboardingIndicator.swift
//  The nest
//
//  Created by Eezy Mongo on 2025-10-19.
//

import SwiftUI

struct OnboardingIndicator: View {
    var currentPage: Int
    var totalPages: Int
    
    var body: some View {
        HStack(spacing: 8) {
            ForEach(0..<totalPages, id: \.self) { index in
                Capsule()
                    .fill(index == currentPage ? Color.purple : Color.gray.opacity(0.3))
                    .frame(width: index == currentPage ? 30 : 10, height: 6)
                    .animation(.easeInOut, value: currentPage)
            }
        }
        .padding(.bottom, 30)
    }
}
