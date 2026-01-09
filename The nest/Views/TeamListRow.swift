//
//  TeamListRow.swift
//  The nest


import Foundation
import SwiftUI

struct TeamListRow: View {
    let team: ProjectTeam
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                // Icon Branding
                Circle()
                    .fill(Color.purple.opacity(0.1))
                    .frame(width: 40, height: 40)
                    .overlay(
                        Image(systemName: "square.stack.3d.up")
                            .foregroundColor(.purple)
                            .font(.caption)
                    )
                
                VStack(alignment: .leading) {
                    // Safety: Unwrap title with fallback
                    Text(team.title ?? "Untitled Project")
                        .font(.custom("Poppins-Bold", size: 16))
                        .foregroundColor(.black)
                    
                    // Safety: Handle optional members list
                    Text("\(team.members?.count ?? 0) members")
                        .font(.custom("Poppins-Regular", size: 13))
                        .foregroundColor(.secondary)
                }
                Spacer()
                
                Text("Active")
                    .font(.custom("Poppins-Regular", size: 10))
                    .foregroundColor(.green)
            }
            
            // Safety: Unwrap memberNames
            Text(team.memberNames ?? "Team setup in progress...")
                .font(.custom("Poppins-Medium", size: 12))
                .foregroundColor(.black.opacity(0.7))
        }
        .padding()
        .background(Color.white)
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.03), radius: 8, x: 0, y: 4)
    }
}
