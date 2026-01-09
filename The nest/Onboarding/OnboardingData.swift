//
//  OnboardingData.swift.swift
//  The nest
//
//  Created by Eezy Mongo on 2025-10-19.
//
import SwiftUI

struct OnboardingPage: Identifiable {
    let id = UUID()
    let image: String
    let title: String
    let description: String
    let backgroundColor: Color
}

let onboardingPages: [OnboardingPage] = [
    OnboardingPage(
        image: "onboard1", // Ensure asset "onboard1" exists
        title: "Welcome to The Nest",
        description: "Connect, collaborate, and bring your ideas to life. Find people with the skills and passion to join your projects.",
        backgroundColor: Color.purple.opacity(0.1)
    ),
    OnboardingPage(
        image: "onboard2", // Ensure asset "onboard2" exists
        title: "Discover Ideas & Collaborate",
        description: "Browse exciting projects, express interest, and chat with potential collaborators.",
        backgroundColor: Color.blue.opacity(0.1)
    ),
    OnboardingPage(
        image: "onboard3", // Ensure asset "onboard3" exists
        title: "Track & Grow Your Projects",
        description: "Follow your ideas, celebrate progress, and build amazing projects together.",
        backgroundColor: Color.green.opacity(0.1)
    )
]
