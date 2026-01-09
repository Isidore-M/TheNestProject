import SwiftUI
import FirebaseFirestore
import FirebaseAuth

struct EditProfileView: View {
    @EnvironmentObject var appState: AppState
    @Environment(\.dismiss) var dismiss
    
    // Local state for the form
    @State private var name: String = ""
    @State private var role: String = ""
    @State private var isSaving = false
    @State private var errorMessage = ""
    
    let roles = ["Graphic Designer", "iOS Developer", "Android Developer", "UI|UX Designer", "Web Expert", "Illustrator"]
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 25) {
                // 1. LIVE PREVIEW AVATAR
                VStack(spacing: 10) {
                    AvatarView(name: name.isEmpty ? "U" : name, size: 100)
                    Text("Avatar Preview")
                        .font(.custom("Poppins-Medium", size: 12))
                        .foregroundColor(.secondary)
                }
                .padding(.top, 20)
                
                // 2. FORM FIELDS
                VStack(alignment: .leading, spacing: 20) {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Full Name")
                            .font(.custom("Poppins-Bold", size: 14))
                        TextField("Update your name", text: $name)
                            .padding()
                            .background(Color.gray.opacity(0.1))
                            .cornerRadius(12)
                            .font(.custom("Poppins-Regular", size: 15))
                    }
                    
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Primary Role")
                            .font(.custom("Poppins-Bold", size: 14))
                        
                        Menu {
                            ForEach(roles, id: \.self) { r in
                                Button(r) { self.role = r }
                            }
                        } label: {
                            HStack {
                                Text(role)
                                    .font(.custom("Poppins-Regular", size: 15))
                                    .foregroundColor(.primary)
                                Spacer()
                                Image(systemName: "chevron.down")
                                    .font(.caption)
                            }
                            .padding()
                            .background(Color.gray.opacity(0.1))
                            .cornerRadius(12)
                        }
                    }
                }
                .padding(.horizontal)
                
                if !errorMessage.isEmpty {
                    Text(errorMessage)
                        .font(.custom("Poppins-Medium", size: 12))
                        .foregroundColor(.red)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                }
                
                Spacer()
                
                // 3. MASTER SAVE BUTTON
                Button(action: saveChanges) {
                    if isSaving {
                        ProgressView().tint(.white)
                    } else {
                        Text("Save All Changes")
                            .font(.custom("Poppins-Bold", size: 16))
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(name.isEmpty || role.isEmpty ? Color.gray : Color.accent)
                            .foregroundColor(.white)
                            .cornerRadius(15)
                            .shadow(color: Color.accent.opacity(name.isEmpty ? 0 : 0.3), radius: 10, x: 0, y: 5)
                    }
                }
                .padding()
                .disabled(name.isEmpty || role.isEmpty || isSaving)
            }
            .navigationTitle("Edit Profile")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") { dismiss() }
                        .font(.custom("Poppins-Medium", size: 15))
                }
            }
            .onAppear {
                // Initialize with current data
                self.name = appState.userProfile?["name"] as? String ?? ""
                self.role = appState.userProfile?["role"] as? String ?? "Collaborator"
            }
        }
    }
    
    // --- THE MASTER SYNC LOGIC ---
    func saveChanges() {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        isSaving = true
        
        let db = Firestore.firestore()
        let batch = db.batch()
        let group = DispatchGroup()
        
        // A. Update User Document (Source of Truth)
        let userRef = db.collection("users").document(uid)
        batch.updateData(["name": name, "role": role], forDocument: userRef)
        
        // B. Sync Posts (authorName, authorRole)
        group.enter()
        db.collection("posts").whereField("authorId", isEqualTo: uid).getDocuments { snapshot, _ in
            snapshot?.documents.forEach { doc in
                batch.updateData(["authorName": name, "authorRole": role], forDocument: doc.reference)
            }
            group.leave()
        }
        
        // C. Sync Comments (Using Collection Group to find all comments in sub-collections)
        group.enter()
        db.collectionGroup("comments").whereField("authorId", isEqualTo: uid).getDocuments { snapshot, _ in
            snapshot?.documents.forEach { doc in
                batch.updateData(["authorName": name, "authorRole": role], forDocument: doc.reference)
            }
            group.leave()
        }
        
        // D. Sync Chats (Updating participantNames Map)
        group.enter()
        db.collection("chats").whereField("participants", arrayContains: uid).getDocuments { snapshot, _ in
            snapshot?.documents.forEach { doc in
                batch.updateData(["participantNames.\(uid)": name], forDocument: doc.reference)
            }
            group.leave()
        }
        
        // E. Sync Teams (Updating memberNames Map in projects/teams collection)
        group.enter()
        db.collection("projects").whereField("members", arrayContains: uid).getDocuments { snapshot, _ in
            snapshot?.documents.forEach { doc in
                batch.updateData(["memberNames.\(uid)": name], forDocument: doc.reference)
            }
            group.leave()
        }
        
        // F. Sync Team Invites (Updating senderName if you show it in the UI)
        group.enter()
        db.collection("team_invites").whereField("senderID", isEqualTo: uid).getDocuments { snapshot, _ in
            snapshot?.documents.forEach { doc in
                batch.updateData(["senderName": name], forDocument: doc.reference)
            }
            group.leave()
        }

        // --- EXECUTE FINAL BATCH ---
        group.notify(queue: .main) {
            batch.commit { error in
                DispatchQueue.main.async {
                    self.isSaving = false
                    if let error = error {
                        self.errorMessage = "Sync Error: \(error.localizedDescription)"
                    } else {
                        dismiss()
                    }
                }
            }
        }
    }
}
