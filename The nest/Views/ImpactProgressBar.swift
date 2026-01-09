//
//  ImpactProgressBar.swift
//  The nest


import Foundation
import SwiftUI

struct ImpactProgressBar: View {
    let score: Int
    let milestone: Int = 500 // Points needed for next level
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Image(systemName: "leaf.fill")
                    .foregroundColor(.green)
                Text("Nest Contribution")
                    .font(.custom("Poppins-Bold", size: 13))
                Spacer()
                Text("\(score) / \(milestone) XP")
                    .font(.custom("Poppins-Medium", size: 12))
                    .foregroundColor(.secondary)
            }
            
            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    Capsule()
                        .fill(Color.gray.opacity(0.1))
                        .frame(height: 10)
                    
                    Capsule()
                        // Gradient from your Accent to Green
                        .fill(LinearGradient(colors: [.accent, .green], startPoint: .leading, endPoint: .trailing))
                        .frame(width: geo.size.width * CGFloat(min(Double(score) / Double(milestone), 1.0)), height: 10)
                }
            }
            .frame(height: 10)
            
            Text("You are in the top 10% of active Ants this week!")
                .font(.custom("Poppins-Italic", size: 11))
                .foregroundColor(.gray)
        }
        .padding()
        .background(Color.white)
        .cornerRadius(15)
        .padding(.horizontal)
    }
}
