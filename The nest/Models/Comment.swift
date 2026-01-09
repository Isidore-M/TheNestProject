//
//  Comment.swift
//  The nest
//

import Foundation
import FirebaseFirestore

struct Comment: Identifiable, Codable {
    @DocumentID var id: String?
    var authorId: String
    var authorName: String
    var authorRole: String
    var text: String
    var timestamp: Date
}
