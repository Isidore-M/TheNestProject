//
//  TeamManager.swift
//  The nest


import Foundation
import FirebaseFirestore
import FirebaseAuth

class TeamManager: ObservableObject {
    private let db = Firestore.firestore()
    
    /// The "Master Sync" function to accept a new collaborator
    func acceptTeamInvite(teamID: String, userID: String, userName: String, inviteID: String) async throws {
        let batch = db.batch()
        
        // 1. Reference the Project/Team document
        // Make sure your collection name is "projects" in Firebase
        let projectRef = db.collection("projects").document(teamID)
        
        // 2. Update members (Array) and memberNames (Dictionary)
        // We use dot notation "memberNames.id" to avoid overwriting other names
        batch.updateData([
            "members": FieldValue.arrayUnion([userID]),
            "memberNames.\(userID)": userName
        ], forDocument: projectRef)
        
        // 3. Delete the Notification
        // This clears the alert from the user's Notification Center
        let notifRef = db.collection("notifications").document(inviteID)
        batch.deleteDocument(notifRef)
        
        // 4. Commit all changes at once
        try await batch.commit()
        
        print("DEBUG: Successfully added \(userName) to project \(teamID)")
    }
    
    /// Fetches projects where the current user is the administrator
    func fetchAdminTeams() async throws -> [(id: String, name: String)] {
        guard let myUID = Auth.auth().currentUser?.uid else { return [] }
        
        // Query projects where authorId is the current user
        let snapshot = try await db.collection("projects")
            .whereField("authorId", isEqualTo: myUID)
            .getDocuments()
        
        return snapshot.documents.compactMap { doc in
            let data = doc.data()
            let title = data["title"] as? String ?? "Untitled Project"
            return (id: doc.documentID, name: title)
        }
    }
}
