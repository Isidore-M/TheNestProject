//
//  Chat.swift
//  The nest
import Foundation
import FirebaseFirestore
struct Chat: Identifiable, Codable {
    @DocumentID var id: String?
    var participants: [String]
    var participantNames: [String: String]
    var lastMessage: String
    var timestamp: Date
    
    func otherParticipantName(currentUID: String) -> String {
        let otherID = participants.first(where: { $0 != currentUID }) ?? ""
        return participantNames[otherID] ?? "Collaborator"
    }
}
