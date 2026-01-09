//
//  User.swift
//  The nest
//

import Foundation

struct User: Identifiable, Codable {
    var id: String // Firebase UID
    var firstName: String
    var lastName: String
    var email: String
    
    // Collaborative Profile Fields
    var bio: String
    var primaryRole: String?
    var skills: [String]
    var interests: [String]
    var portfolioLink: String?
    
    // Engagement Metrics
    var teamsCount: Int
    var membersCount: Int
}
