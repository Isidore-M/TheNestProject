//
//  Project.swift
//  The nest
//
//  Created by Eezy Mongo on 2026-01-09.
//

import Foundation
import FirebaseFirestore

struct Project: Identifiable, Codable {
    @DocumentID var id: String?
    var title: String
    var description: String
    var authorId: String
    var authorName: String?
    var authorRole: String?
    var timestamp: Date?
    
    // Team Management Fields
    var members: [String]?          // Array of UIDs
    var memberNames: [String: String]? // Dictionary [UID: Name] for Master Sync
    
    // Stats
    var likesCount: Int?
    var commentsCount: Int?
    
    // Helper to get total member count (Author + Collaborators)
    var totalMemberCount: Int {
        return (members?.count ?? 0) + 1
    }
}
