import SwiftUI
import FirebaseFirestore

struct ProfilePreview: View {
    let userID: String
    let notificationID: String // The ID of the alert to delete/update
    let projectID: String      // The specific project the user wants to join
    
    @EnvironmentObject var appState: AppState
    @StateObject private var teamManager = TeamManager()
    
    @State private var userProfile: [String: Any]?
    @State private var isProcessing = false
    @Environment(\.dismiss) var dismiss

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
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
                                        .foregroundColor(.accent)
                                }
                            }
                            .padding(.top, 20)
                            
                            // --- 2. CONTACT & LINKS ---
                            VStack(spacing: 16) {
                                ProfileInfoRow(
                                    icon: "envelope.fill",
                                    label: "Email Address",
                                    value: profile["email"] as? String ?? "No email provided",
                                    isLink: false
                                )
                                
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
                        } else {
                            ProgressView("Fetching details...").padding(.top, 100)
                        }
                    }
                    .padding(20)
                }

                // --- 3. BOTTOM ACTIONS ---
                // We place these at the bottom so they are always visible
                VStack(spacing: 12) {
                    // ACCEPT BUTTON
                    Button(action: acceptMember) {
                        HStack {
                            if isProcessing {
                                ProgressView().tint(.white)
                            } else {
                                Label("Add to Project Team", systemImage: "person.badge.plus")
                                    .font(.custom("Poppins-Bold", size: 16))
                            }
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(isProcessing ? Color.gray : Color.accent)
                        .foregroundColor(.white)
                        .cornerRadius(15)
                        .shadow(color: Color.accent.opacity(0.3), radius: 10, x: 0, y: 5)
                    }
                    .disabled(isProcessing || userProfile == nil)

                    // REJECT BUTTON
                    Button(action: rejectMember) {
                        Text("Reject Request")
                            .font(.custom("Poppins-Bold", size: 14))
                            .foregroundColor(.red)
                            .padding(.vertical, 8)
                    }
                    .disabled(isProcessing)
                }
                .padding(20)
                .background(Color.white)
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
            }
        }
    }

    // MARK: - Logic Helpers

    private func fetchTargetUser() async {
        let db = Firestore.firestore()
        let doc = try? await db.collection("users").document(userID).getDocument()
        if let data = doc?.data() {
            self.userProfile = data
        }
    }

    private func acceptMember() {
        guard let name = userProfile?["name"] as? String else { return }
        isProcessing = true
        
        Task {
            do {
                // 1. Adds member to project members array AND memberNames dictionary
                // 2. Deletes the notification
                try await teamManager.acceptTeamInvite(
                    teamID: projectID,
                    userID: userID,
                    userName: name,
                    inviteID: notificationID
                )
                isProcessing = false
                dismiss() // Success
            } catch {
                print("DEBUG: Error accepting: \(error.localizedDescription)")
                isProcessing = false
            }
        }
    }

    private func rejectMember() {
        isProcessing = true
        // Simply delete the notification to "reject" the request
        Firestore.firestore().collection("notifications").document(notificationID).delete { _ in
            isProcessing = false
            dismiss()
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
                Circle().fill(Color.accent.opacity(0.1)).frame(width: 36, height: 36)
                Image(systemName: icon).foregroundColor(.accent).font(.system(size: 14))
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
                        .foregroundColor(.accent)
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
