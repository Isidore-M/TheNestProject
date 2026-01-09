//
//  ProjectTeam.swift
//  The nest
//
import Foundation
import FirebaseFirestore

struct ProjectTeam: Identifiable, Codable {
    @DocumentID var id: String?
    var title: String?
    var members: [String]?
    // CHANGED: From String? to [String: String]?
    var memberNames: [String: String]?
    var goal: String?
}
