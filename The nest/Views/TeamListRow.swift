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
                            .font(.system(size: 14, weight: .bold))
                    )
                
                VStack(alignment: .leading, spacing: 2) {
                    // Safety: Project Title
                    Text(team.title ?? "Untitled Project")
                        .font(.custom("Poppins-Bold", size: 16))
                        .foregroundColor(.black)
                    
                    // Safety: Member Count
                    Text("\(team.members?.count ?? 0) members")
                        .font(.custom("Poppins-Regular", size: 13))
                        .foregroundColor(.secondary)
                }
                Spacer()
                
                Text("Active")
                    .font(.custom("Poppins-Medium", size: 10))
                    .foregroundColor(.green)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color.green.opacity(0.1))
                    .cornerRadius(20)
            }
            
            // --- FIXED SECTION ---
            // We now take the values from the dictionary [ID: Name] and join them
            if let namesDict = team.memberNames, !namesDict.isEmpty {
                Text(namesDict.values.sorted().joined(separator: ", "))
                    .font(.custom("Poppins-Medium", size: 12))
                    .foregroundColor(.black.opacity(0.7))
                    .lineLimit(1)
            } else {
                Text("Team setup in progress...")
                    .font(.custom("Poppins-Italic", size: 12))
                    .foregroundColor(.gray.opacity(0.7))
            }
        }
        .padding()
        .background(Color.white)
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.03), radius: 8, x: 0, y: 4)
    }
}
