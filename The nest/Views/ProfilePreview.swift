import SwiftUI
import FirebaseFirestore

struct ProfilePreview: View {
    let userID: String
    @StateObject private var teamManager = TeamManager()
    @State private var myTeams: [(id: String, name: String)] = []
    @State private var isSending = false
    @Environment(\.dismiss) var dismiss

    var body: some View {
        NavigationStack {
            VStack(spacing: 25) {
                // ... (Profile Header from previous step)
                
                if myTeams.isEmpty {
                    Text("You don't manage any teams yet.")
                        .font(.caption)
                        .foregroundColor(.secondary)
                } else {
                    Menu {
                        ForEach(myTeams, id: \.id) { team in
                            Button(team.name) {
                                sendInvite(toTeam: team)
                            }
                        }
                    } label: {
                        Label(isSending ? "Sending..." : "Add to a Team", systemImage: "person.badge.plus")
                            .fontWeight(.semibold)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(isSending ? Color.gray : Color("AccentColor"))
                            .foregroundColor(.white)
                            .cornerRadius(15)
                    }
                    .disabled(isSending)
                }
                
                Spacer()
            }
            .padding()
            .task {
                // Fetch the user's teams when the view appears
                do {
                    myTeams = try await teamManager.fetchAdminTeams()
                } catch {
                    print("Error fetching teams: \(error.localizedDescription)")
                }
            }
        }
    }

    private func sendInvite(toTeam team: (id: String, name: String)) {
        isSending = true
        Task {
            do {
                try await teamManager.sendTeamInvite(to: userID, teamID: team.id, teamName: team.name)
                isSending = false
                dismiss() // Close the profile preview after success
            } catch {
                print("Failed to send invite: \(error)")
                isSending = false
            }
        }
    }
}
