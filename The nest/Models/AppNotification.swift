//
//  AppNotification.swift
//  The nest

import Foundation
import FirebaseFirestore

struct AppNotification: Identifiable, Codable {
    @DocumentID var id: String?
    var type: String // "collaboration_request" or "like"
    var senderId: String
    var senderName: String
    var senderRole: String?
    var receiverId: String
    var postId: String?
    var timestamp: Date
    var isRead: Bool? = false // <--- New property
}
