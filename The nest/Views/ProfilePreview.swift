import SwiftUI
import FirebaseFirestore

struct ProfilePreview: View {
    let userID: String
    @EnvironmentObject var appState: AppState
    @StateObject private var teamManager = TeamManager()
    
    @State private var userProfile: [String: Any]?
    @State private var myTeams: [(id: String, name: String)] = []
    @State private var isSending = false
    @Environment(\.dismiss) var dismiss

    var body: some View {
        NavigationStack {
            VStack(spacing: 25) {
                // 1. PROFILE HEADER
                if let profile = userProfile {
                    VStack(spacing: 15) {
                        AvatarView(name: profile["name"] as? String ?? "U", size: 80)
                        
                        VStack(spacing: 5) {
                            Text(profile["name"] as? String ?? "User")
                                .font(.custom("Poppins-Bold", size: 20))
                            Text(profile["role"] as? String ?? "Collaborator")
                                .font(.custom("Poppins-Medium", size: 14))
                                .foregroundColor(.accentColor)
                        }
                    }
                    .padding(.top)
                } else {
                    ProgressView().padding()
                }

                Divider()

                // 2. TEAM SELECTION MENU
                VStack(alignment: .leading, spacing: 10) {
                    Text("Quick Actions")
                        .font(.custom("Poppins-Bold", size: 14))
                        .foregroundColor(.secondary)

                    if myTeams.isEmpty {
                        Text("You don't manage any teams yet.")
                            .font(.custom("Poppins-Italic", size: 13))
                            .foregroundColor(.gray)
                    } else {
                        Menu {
                            ForEach(myTeams, id: \.id) { team in
                                Button(team.name) {
                                    sendInvite(toTeam: team)
                                }
                            }
                        } label: {
                            HStack {
                                Label(isSending ? "Sending..." : "Add to a Team", systemImage: "person.badge.plus")
                                Spacer()
                                Image(systemName: "chevron.right")
                            }
                            .fontWeight(.semibold)
                            .padding()
                            .background(isSending ? Color.gray.opacity(0.2) : Color.accentColor.opacity(0.1))
                            .foregroundColor(isSending ? .gray : .accentColor)
                            .cornerRadius(12)
                        }
                        .disabled(isSending)
                    }
                }

                Spacer()
            }
            .padding()
            .navigationTitle("Collaborator Info")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Close") { dismiss() }
                }
            }
            .task {
                await fetchTargetUser()
                do {
                    myTeams = try await teamManager.fetchAdminTeams()
                } catch {
                    print("Error: \(error.localizedDescription)")
                }
            }
        }
    }

    private func fetchTargetUser() async {
        let db = Firestore.firestore()
        let doc = try? await db.collection("users").document(userID).getDocument()
        self.userProfile = doc?.data()
    }

    private func sendInvite(toTeam team: (id: String, name: String)) {
        guard let myName = appState.userProfile?["name"] as? String else { return }
        isSending = true
        Task {
            do {
                // This uses your TeamManager logic to add user to dictionary and array
                try await teamManager.acceptTeamInvite(
                    teamID: team.id,
                    userID: userID,
                    userName: userProfile?["name"] as? String ?? "New Member",
                    inviteID: "manual_add" // Placeholder
                )
                isSending = false
                dismiss()
            } catch {
                isSending = false
            }
        }
    }
}
