// Post.swift
import Foundation
import FirebaseFirestore

struct Post: Identifiable, Codable {
    @DocumentID var id: String?
    var title: String
    var description: String
    var authorName: String?
    var authorRole: String?
    var authorId: String?
    var timestamp: Date?
    var likesCount: Int?      // Fixed: Now exists
    var commentsCount: Int?   // Fixed: Now exists
}
