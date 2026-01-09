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
            ScrollView {
                VStack(spacing: 30) {
                    
                    // --- 1. HEADER: IDENTITY ---
                    if let profile = userProfile {
                        VStack(spacing: 15) {
                            AvatarView(name: profile["name"] as? String ?? "U", size: 100)
                                .shadow(color: .black.opacity(0.05), radius: 10, y: 5)
                            
                            VStack(spacing: 4) {
                                Text(profile["name"] as? String ?? "Anonymous User")
                                    .font(.custom("Poppins-Bold", size: 24))
                                
                                Text(profile["role"] as? String ?? "Collaborator")
                                    .font(.custom("Poppins-Medium", size: 16))
                                    .foregroundColor(.accentColor)
                            }
                        }
                        .padding(.top, 20)
                        
                        // --- 2. CONTACT & LINKS SECTION ---
                        VStack(spacing: 16) {
                            // Email Row
                            ProfileInfoRow(
                                icon: "envelope.fill",
                                label: "Email Address",
                                value: profile["email"] as? String ?? "No email provided",
                                isLink: false
                            )
                            
                            // Portfolio Link Row
                            if let link = profile["portfolioLink"] as? String, !link.isEmpty {
                                ProfileInfoRow(
                                    icon: "link",
                                    label: "Portfolio / Website",
                                    value: link,
                                    isLink: true
                                )
                            }
                        }
                        .padding()
                        .background(Color.gray.opacity(0.05))
                        .cornerRadius(20)
                        
                        Divider().padding(.vertical, 10)

                        // --- 3. TEAM MANAGEMENT ---
                        VStack(alignment: .leading, spacing: 15) {
                            Text("Recruitment")
                                .font(.custom("Poppins-Bold", size: 16))
                                .foregroundColor(.secondary)
                            
                            if myTeams.isEmpty {
                                Text("You don't manage any active teams.")
                                    .font(.custom("Poppins-Italic", size: 14))
                                    .foregroundColor(.gray)
                                    .frame(maxWidth: .infinity, alignment: .center)
                                    .padding()
                            } else {
                                Menu {
                                    ForEach(myTeams, id: \.id) { team in
                                        Button(team.name) {
                                            sendInvite(toTeam: team)
                                        }
                                    }
                                } label: {
                                    HStack {
                                        Label(isSending ? "Processing..." : "Add to a Project Team", systemImage: "person.badge.plus")
                                            .font(.custom("Poppins-Bold", size: 15))
                                        Spacer()
                                        Image(systemName: "chevron.right")
                                    }
                                    .padding()
                                    .background(isSending ? Color.gray.opacity(0.2) : Color.accentColor)
                                    .foregroundColor(.white)
                                    .cornerRadius(15)
                                    .shadow(color: Color.accentColor.opacity(0.3), radius: 10, x: 0, y: 5)
                                }
                                .disabled(isSending)
                            }
                        }
                    } else {
                        // Loading State
                        VStack {
                            ProgressView()
                            Text("Fetching profile...")
                                .font(.custom("Poppins-Medium", size: 14))
                                .foregroundColor(.gray)
                        }
                        .padding(.top, 100)
                    }
                }
                .padding(20)
            }
            .navigationTitle("Profile Details")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Close") { dismiss() }
                        .font(.custom("Poppins-Medium", size: 15))
                }
            }
            .task {
                await fetchTargetUser()
                try? myTeams = await teamManager.fetchAdminTeams()
            }
        }
    }

    // MARK: - Logic
    
    private func fetchTargetUser() async {
        let db = Firestore.firestore()
        let doc = try? await db.collection("users").document(userID).getDocument()
        if let data = doc?.data() {
            self.userProfile = data
        }
    }

    private func sendInvite(toTeam team: (id: String, name: String)) {
        isSending = true
        Task {
            do {
                // Uses the TeamManager logic to add to Dictionary and Array
                try await teamManager.acceptTeamInvite(
                    teamID: team.id,
                    userID: userID,
                    userName: userProfile?["name"] as? String ?? "New Member",
                    inviteID: "admin_add_\(UUID().uuidString)"
                )
                isSending = false
                dismiss() // Close on success
            } catch {
                print("DEBUG: Error adding to team: \(error.localizedDescription)")
                isSending = false
            }
        }
    }
}

// MARK: - Helper UI Component

struct ProfileInfoRow: View {
    let icon: String
    let label: String
    let value: String
    let isLink: Bool
    
    var body: some View {
        HStack(spacing: 15) {
            ZStack {
                Circle().fill(Color.accentColor.opacity(0.1)).frame(width: 36, height: 36)
                Image(systemName: icon).foregroundColor(.accentColor).font(.system(size: 14))
            }
            
            VStack(alignment: .leading, spacing: 2) {
                Text(label)
                    .font(.custom("Poppins-Medium", size: 11))
                    .foregroundColor(.secondary)
                    .textCase(.uppercase)
                
                Text(value)
                    .font(.custom("Poppins-Bold", size: 14))
                    .foregroundColor(.primary)
                    .lineLimit(1)
            }
            
            Spacer()
            
            if isLink, let url = URL(string: value.contains("http") ? value : "https://\(value)") {
                Link(destination: url) {
                    Image(systemName: "arrow.up.right.circle.fill")
                        .font(.title3)
                        .foregroundColor(.accentColor)
                }
            } else {
                Button(action: { UIPasteboard.general.string = value }) {
                    Image(systemName: "doc.on.doc")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                }
            }
        }
    }
}
