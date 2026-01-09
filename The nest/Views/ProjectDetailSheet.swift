//
//  ProjectDetailSheet.swift
//  The nest

import Foundation
import SwiftUI

struct ProjectDetailSheet: View {
    @Environment(\.dismiss) var dismiss
    let team: Team
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    // 1. Project Header (Matching The Nest's purple branding)
                    HStack(spacing: 16) {
                        ZStack {
                            RoundedRectangle(cornerRadius: 12)
                                .fill(Color.purple.opacity(0.1))
                                .frame(width: 64, height: 64)
                            Image(systemName: "square.stack.3d.up.fill")
                                .foregroundColor(.purple)
                                .font(.title)
                        }
                        
                        VStack(alignment: .leading, spacing: 4) {
                            Text(team.title)
                                .font(.custom("Poppins-Bold", size: 22))
                            Text("Active Collaboration")
                                .font(.custom("Poppins-Medium", size: 14))
                                .foregroundColor(.purple)
                        }
                    }
                    
                    // 2. Project Goal (Context for the team)
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Project Goal")
                            .font(.custom("Poppins-Bold", size: 16))
                        Text("Building a seamless bridge between local artisans and global markets through high-performance mobile design.")
                            .font(.custom("Poppins-Regular", size: 14))
                            .foregroundColor(.secondary)
                            .lineSpacing(4)
                    }
                    
                    Divider()
                    
                    // 3. Team Members List
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Contributors")
                            .font(.custom("Poppins-Bold", size: 16))
                        
                        ForEach(0..<3) { index in
                            ContributorRow(
                                name: index == 0 ? "Kalum Wilson" : "Meghan Good",
                                role: index == 0 ? "Lead Designer" : "iOS Developer"
                            )
                        }
                    }
                    
                    // 4. Branding Footer
                    VStack {
                        Spacer(minLength: 40)
                        Text("the nest All right reserved 2025")
                            .font(.custom("Poppins-Regular", size: 10))
                            .foregroundColor(.gray.opacity(0.6))
                    }
                    .frame(maxWidth: .infinity)
                }
                .padding()
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") { dismiss() }
                        .font(.custom("Poppins-Bold", size: 16))
                        .foregroundColor(.purple)
                }
            }
        }
    }
}

struct ContributorRow: View {
    let name: String
    let role: String
    
    var body: some View {
        HStack(spacing: 12) {
            Circle()
                .fill(Color.gray.opacity(0.1))
                .frame(width: 40, height: 40)
                .overlay(Text(name.prefix(1)).font(.custom("Poppins-Bold", size: 14)))
            
            VStack(alignment: .leading) {
                Text(name)
                    .font(.custom("Poppins-Bold", size: 15))
                Text(role)
                    .font(.custom("Poppins-Regular", size: 12))
                    .foregroundColor(.secondary)
            }
            Spacer()
            Image(systemName: "chevron.right")
                .font(.caption)
                .foregroundColor(.gray)
        }
    }
}
