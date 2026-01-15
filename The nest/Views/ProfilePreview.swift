import SwiftUI
import FirebaseFirestore

struct ProfilePreview: View {
    let userID: String
    let notificationID: String
    let projectID: String
    
    @EnvironmentObject var appState: AppState
    @StateObject private var teamManager = TeamManager()
    
    // State to trigger the new selection modal
    @State private var showingTeamSheet = false
    
    @State private var userProfile: [String: Any]?
    @State private var isProcessing = false
    @State private var errorMessage = ""
    @Environment(\.dismiss) var dismiss

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                ScrollView {
                    VStack(spacing: 25) {
                        if let profile = userProfile {
                            // --- 1. IDENTITY ---
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
                            
                            // --- 2. BIO SECTION ---
                            if let bio = profile["bio"] as? String, !bio.isEmpty {
                                profileSection(title: "About", content: bio)
                            }

                            // --- 3. INTERESTS SECTION ---
                            if let interests = profile["interests"] as? String, !interests.isEmpty {
                                profileSection(title: "Interests & Focus", content: interests, isAccent: true)
                            }
                            
                            // --- 4. CONTACT & LINKS ---
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

                // --- 5. BOTTOM ACTIONS ---
                VStack(spacing: 12) {
                    if !errorMessage.isEmpty {
                        Text(errorMessage)
                            .font(.caption)
                            .foregroundColor(.red)
                            .padding(.bottom, 4)
                    }

                    // CHANGED: Now opens the TeamSelectionSheet instead of an alert
                    Button(action: { showingTeamSheet = true }) {
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
                        .background(isProcessing ? Color.gray : Color.accentColor)
                        .foregroundColor(.white)
                        .cornerRadius(15)
                    }
                    .disabled(isProcessing || userProfile == nil)

                    Button(action: rejectMember) {
                        Text("Reject Request")
                            .font(.custom("Poppins-Bold", size: 14))
                            .foregroundColor(.red)
                    }
                    .disabled(isProcessing)
                }
                .padding(20)
                .background(Color.white)
                .shadow(color: .black.opacity(0.05), radius: 10, y: -5)
            }
            .navigationTitle("Profile Details")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Close") { dismiss() }
                }
            }
            // NEW: Modal sheet for project selection
            .sheet(isPresented: $showingTeamSheet) {
                TeamSelectionSheet(
                    targetUserID: userID,
                    targetUserName: userProfile?["name"] as? String ?? "User",
                    notificationID: notificationID
                )
                .environmentObject(appState)
            }
            .task { await fetchTargetUser() }
        }
    }

    @ViewBuilder
    func profileSection(title: String, content: String, isAccent: Bool = false) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.custom("Poppins-Bold", size: 14))
                .foregroundColor(.secondary)
                .textCase(.uppercase)
            Text(content)
                .font(.custom("Poppins-Medium", size: 15))
                .foregroundColor(isAccent ? .accentColor : .primary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(isAccent ? Color.accentColor.opacity(0.05) : Color.gray.opacity(0.05))
        .cornerRadius(15)
    }

    private func fetchTargetUser() async {
        let db = Firestore.firestore()
        if let doc = try? await db.collection("users").document(userID).getDocument() {
            self.userProfile = doc.data()
        }
    }

    private func rejectMember() {
        isProcessing = true
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
