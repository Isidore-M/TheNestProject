//
//  TeamSelectionSheet.swift
//  The nest
//
//  Created by Eezy Mongo on 2026-01-14.
//

import Foundation
import SwiftUI

struct TeamSelectionSheet: View {
    let targetUserID: String
    let targetUserName: String
    let notificationID: String
    
    @StateObject private var teamManager = TeamManager()
    @State private var projects: [ProjectTeam] = []
    @State private var newProjectTitle = ""
    @State private var isLoading = true
    
    @Environment(\.dismiss) var dismiss

    var body: some View {
        NavigationStack {
            VStack {
                if isLoading {
                    ProgressView("Loading your projects...")
                } else {
                    List {
                        if projects.isEmpty {
                            Section {
                                Text("You haven't created any projects yet. Create one below to add \(targetUserName).")
                                    .font(.system(size: 14))
                                    .foregroundColor(.secondary)
                            }
                        } else {
                            Section("Your Active Projects") {
                                ForEach(projects) { project in
                                    Button {
                                        addToProject(id: project.id ?? "")
                                    } label: {
                                        HStack {
                                            Text(project.title)
                                                .font(.custom("Poppins-Medium", size: 16))
                                            Spacer()
                                            Image(systemName: "plus.circle.fill")
                                                .foregroundColor(.accentColor)
                                        }
                                    }
                                }
                            }
                        }
                        
                        Section("Create New Project") {
                            TextField("Project Title", text: $newProjectTitle)
                                .font(.custom("Poppins-Regular", size: 15))
                            
                            Button(action: createAndAdd) {
                                Text("Create & Add Collaborator")
                                    .font(.custom("Poppins-Bold", size: 15))
                            }
                            .disabled(newProjectTitle.isEmpty)
                        }
                    }
                }
            }
            .navigationTitle("Select Project")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
            }
            .task {
                projects = (try? await teamManager.fetchAdminTeams()) ?? []
                isLoading = false
            }
        }
    }

    private func addToProject(id: String) {
        Task {
            try? await teamManager.acceptMemberToTeam(
                projectID: id,
                userID: targetUserID,
                userName: targetUserName,
                notificationID: notificationID
            )
            dismiss()
        }
    }

    private func createAndAdd() {
        Task {
            if let newID = try? await teamManager.createNewProject(title: newProjectTitle) {
                try? await teamManager.acceptMemberToTeam(
                    projectID: newID,
                    userID: targetUserID,
                    userName: targetUserName,
                    notificationID: notificationID
                )
                dismiss()
            }
        }
    }
}
