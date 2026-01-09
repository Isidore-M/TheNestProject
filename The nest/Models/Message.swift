//
//  Message.swift
//  The nest

import Foundation
import FirebaseFirestore

struct Message: Identifiable, Codable {
    @DocumentID var id: String?
    var senderId: String
    var text: String
    var timestamp: Date
    
    // ADD THIS HELPER FUNCTION
    func isFromCurrentUser(uid: String) -> Bool {
        return senderId == uid
    }
}
