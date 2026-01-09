//
//  TeamListRow.swift
//  The nest

import Foundation
import SwiftUI

struct TeamListRow: View {
    // FIXED: Changed variable name to 'team' and type to 'ProjectTeam'
    let team: ProjectTeam
    
    var body: some View {
        NavigationLink(destination: ProjectDetailsView(team: team)) {
            HStack(spacing: 15) {
                ZStack {
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color.accentColor.opacity(0.1))
                        .frame(width: 50, height: 50)
                    Image(systemName: "briefcase.fill")
                        .foregroundColor(.accentColor)
                }
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(team.title)
                        .font(.custom("Poppins-Bold", size: 16))
                        .foregroundColor(.primary)
                    
                    Text("\(team.totalMemberCount) Members")
                        .font(.custom("Poppins-Regular", size: 12))
                        .foregroundColor(.secondary)
                }
            }
            .padding(.vertical, 4)
        }
    }
}
