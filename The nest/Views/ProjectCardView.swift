import SwiftUI

struct ProjectCardView: View {
    let team: ProjectTeam
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                // --- ICON BRANDING ---
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
                    
                    // Safety: Member Count logic
                    Text("\(team.members?.count ?? 0) members")
                        .font(.custom("Poppins-Regular", size: 13))
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                // Status Indicator
                HStack(spacing: 4) {
                    Circle()
                        .fill(Color.green)
                        .frame(width: 6, height: 6)
                    Text("Active")
                        .font(.custom("Poppins-Medium", size: 10))
                        .foregroundColor(.green)
                }
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(Color.green.opacity(0.1))
                .cornerRadius(20)
            }
            
            Divider()
                .opacity(0.5)
            
            // --- DYNAMIC MEMBER NAMES ---
            // We now take the Values from the Dictionary and join them with a comma
            VStack(alignment: .leading, spacing: 4) {
                Text("Contributors:")
                    .font(.custom("Poppins-Bold", size: 11))
                    .foregroundColor(.gray)
                    .textCase(.uppercase)
                
                if let namesDict = team.memberNames, !namesDict.isEmpty {
                    Text(namesDict.values.sorted().joined(separator: ", "))
                        .font(.custom("Poppins-Medium", size: 13))
                        .foregroundColor(.black.opacity(0.8))
                        .lineLimit(2)
                } else {
                    Text("No contributors listed yet")
                        .font(.custom("Poppins-Italic", size: 13))
                        .foregroundColor(.gray)
                }
            }
        }
        .padding(16)
        .background(Color.white)
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.04), radius: 10, x: 0, y: 4)
    }
}
