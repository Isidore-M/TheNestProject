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
}
