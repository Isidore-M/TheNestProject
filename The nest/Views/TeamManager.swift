import Foundation
import FirebaseFirestore
import FirebaseAuth

class TeamManager: ObservableObject {
    // Defines 'db' at the class level so all functions can access it
    private let db = Firestore.firestore()
    
    // MARK: - Core Logic
    
    /// Adds a member to an existing project and removes the notification alert.
    func acceptMemberToTeam(projectID: String, userID: String, userName: String, notificationID: String) async throws {
        let batch = db.batch()
        let projectRef = db.collection("projects").document(projectID)
        
        // Master Sync using your specific field names: members and memberNames
        batch.updateData([
            "members": FieldValue.arrayUnion([userID]),
            "memberNames.\(userID)": userName
        ], forDocument: projectRef)
        
        // Clear the notification if it exists and is not a preview
        if !notificationID.isEmpty && notificationID != "view_only" {
            let notifRef = db.collection("notifications").document(notificationID)
            batch.deleteDocument(notifRef)
        }
        
        try await batch.commit()
    }
    
    /// Creates a new project document in Firestore using your ProjectTeam structure.
    func createNewProject(title: String) async throws -> String {
        guard let myUID = Auth.auth().currentUser?.uid else {
            throw NSError(domain: "Auth", code: 401, userInfo: [NSLocalizedDescriptionKey: "User not logged in"])
        }
        
        // Get the current user's name from our helper
        let creatorName = appStateUserName()
        
        let newProjectData: [String: Any] = [
            "title": title,
            "description": "New collaborative project",
            "authorId": myUID,
            "authorName": creatorName,
            "members": [myUID],
            "memberNames": [myUID: creatorName],
            "timestamp": FieldValue.serverTimestamp(),
            "likesCount": 0,
            "commentsCount": 0
        ]
        
        let docRef = try await db.collection("projects").addDocument(data: newProjectData)
        return docRef.documentID
    }
    
    /// Fetches projects where the current user is the author.
    func fetchAdminTeams() async throws -> [ProjectTeam] {
        guard let myUID = Auth.auth().currentUser?.uid else { return [] }
        
        let snapshot = try await db.collection("projects")
            .whereField("authorId", isEqualTo: myUID)
            .getDocuments()
        
        return snapshot.documents.compactMap { doc in
            try? doc.data(as: ProjectTeam.self)
        }
    }
    
    // MARK: - Helpers (Now correctly scoped inside the class)
    
    /// Retrieves the current user's display name or a default fallback.
    private func appStateUserName() -> String {
        return Auth.auth().currentUser?.displayName ?? "Project Leader"
    }
    
    /// Removes a collaborator from the team members list and the name mapping.
    func removeMemberFromTeam(projectID: String, userID: String) async throws {
        let projectRef = db.collection("projects").document(projectID)
        
        // Dot notation is used to delete the specific key from the memberNames map
        try await projectRef.updateData([
            "members": FieldValue.arrayRemove([userID]),
            "memberNames.\(userID)": FieldValue.delete()
        ])
    }
} // End of class
