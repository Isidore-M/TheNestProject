//
//  Team.swift
//  The nest

import Foundation

struct Team: Identifiable {
    let id = UUID()
    let title: String
    let members: String
    let date: String
    let memberNames: String
}
