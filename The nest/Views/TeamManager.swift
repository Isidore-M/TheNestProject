//
//  TeamManager.swift
//  The nest

import Foundation
import FirebaseFirestore
import FirebaseAuth

class TeamManager: ObservableObject {
    private let db = Firestore.firestore()
    
    /// Sends a team invitation to a specific user
    func sendTeamInvite(to targetUserID: String, teamID: String, teamName: String) async throws {
        guard let currentUserID = Auth.auth().currentUser?.uid else {
            throw NSError(domain: "AuthError", code: 401, userInfo: [NSLocalizedDescriptionKey: "User not logged in"])
        }
        
        let inviteData: [String: Any] = [
            "teamID": teamID,
            "teamName": teamName,
            "senderID": currentUserID,
            "receiverID": targetUserID,
            "status": "pending",
            "timestamp": FieldValue.serverTimestamp()
        ]
        
        // Add to 'team_invites' collection
        try await db.collection("team_invites").addDocument(data: inviteData)
    }
    
    /// Fetches all teams where the current user is an admin
    func fetchAdminTeams() async throws -> [(id: String, name: String)] {
        guard let uid = Auth.auth().currentUser?.uid else { return [] }
        
        let snapshot = try await db.collection("teams")
            .whereField("adminID", isEqualTo: uid)
            .getDocuments()
        
        return snapshot.documents.map { doc in
            let name = doc.get("name") as? String ?? "Unknown Team"
            return (id: doc.documentID, name: name)
        }
    }
    
    /// Adds a user to a project and updates the member dictionary
    func acceptTeamInvite(teamID: String, userID: String, userName: String, inviteID: String) async throws {
        let batch = db.batch()
        
        // 1. Reference to the Project/Team document
        let projectRef = db.collection("projects").document(teamID)
        
        // 2. Update members array and the memberNames dictionary (using dot notation)
        batch.updateData([
            "members": FieldValue.arrayUnion([userID]),
            "memberNames.\(userID)": userName
        ], forDocument: projectRef)
        
        // 3. Mark the invite as "accepted" or delete it
        let inviteRef = db.collection("team_invites").document(inviteID)
        batch.updateData(["status": "accepted"], forDocument: inviteRef)
        
        // Execute
        try await batch.commit()
    }
}
