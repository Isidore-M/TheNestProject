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
    var isGroupChat: Bool? = false
    var groupTitle: String? = nil
    
    // The specific function the ChatRow above is calling:
    func displayName(currentUserID: String) -> String {
        if isGroupChat == true {
            return groupTitle ?? "Project Team"
        }
        let otherId = participants.first(where: { $0 != currentUserID }) ?? ""
        return participantNames[otherId] ?? "Collaborator"
    }
}
