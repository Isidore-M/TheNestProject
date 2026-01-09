//
//  TeamManager.swift
//  The nest


import Foundation
import FirebaseFirestore
import FirebaseAuth

class TeamManager: ObservableObject {
    private let db = Firestore.firestore()
    
    /// The "Master Sync" function to officially add a member to a project.
    /// Renamed to match the call in your ProfilePreview logic.
    func acceptMemberToTeam(projectID: String, userID: String, userName: String, notificationID: String) async throws {
        let batch = db.batch()
        
        // 1. Reference the Project document
        let projectRef = db.collection("projects").document(projectID)
        
        // 2. Perform Master Sync:
        // 'members' array allows for high-performance membership queries.
        // 'memberNames' map allows for zero-latency name display in the Team List.
        batch.updateData([
            "members": FieldValue.arrayUnion([userID]),
            "memberNames.\(userID)": userName
        ], forDocument: projectRef)
        
        // 3. Clear the Notification
        // Only deletes if it's a real notification (not a 'view_only' preview)
        if !notificationID.isEmpty && notificationID != "view_only" {
            let notifRef = db.collection("notifications").document(notificationID)
            batch.deleteDocument(notifRef)
        }
        
        // 4. Atomic Commit
        try await batch.commit()
        
        print("DEBUG: TeamManager successfully added \(userName) to project \(projectID)")
    }
    
    /// Allows the Project Leader to remove a member from the team.
    func removeMemberFromTeam(projectID: String, userID: String) async throws {
        let projectRef = db.collection("projects").document(projectID)
        
        // We use dot notation to delete the specific key from the map
        try await projectRef.updateData([
            "members": FieldValue.arrayRemove([userID]),
            "memberNames.\(userID)": FieldValue.delete()
        ])
        
        print("DEBUG: TeamManager removed user \(userID) from project \(projectID)")
    }
    
    /// Fetches projects where the current user is the leader.
    /// Updated to return the full ProjectTeam objects for better compatibility.
    func fetchAdminTeams() async throws -> [ProjectTeam] {
        guard let myUID = Auth.auth().currentUser?.uid else { return [] }
        
        let snapshot = try await db.collection("projects")
            .whereField("authorId", isEqualTo: myUID)
            .getDocuments()
        
        return snapshot.documents.compactMap { doc in
            try? doc.data(as: ProjectTeam.self)
        }
    }
}
