//
//  ProjectDetailsView.swift
//  The nest
//
//  Created by Eezy Mongo on 2026-01-09.
//

import Foundation
import SwiftUI
import FirebaseFirestore

import SwiftUI
import FirebaseFirestore

struct ProjectDetailsView: View {
    let team: ProjectTeam
    @EnvironmentObject var appState: AppState
    @State private var selectedMemberID: String? = nil
    @State private var isRemoving = false
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 25) {
                
                // --- 1. PROJECT HEADER ---
                VStack(alignment: .leading, spacing: 10) {
                    Text(team.title)
                        .font(.custom("Poppins-Bold", size: 28))
                        .lineLimit(2)
                    
                    Text(team.description)
                        .font(.custom("Poppins-Regular", size: 15))
                        .foregroundColor(.secondary)
                }
                .padding(.horizontal)
                .padding(.top)

                // --- 2. GROUP CHAT ACTION ---
                NavigationLink(destination: ChatRoomView(chat: createGroupChatObject()).environmentObject(appState)) {
                    HStack {
                        Image(systemName: "bubble.left.and.bubble.right.fill")
                        Text("Enter Group Chat")
                            .font(.custom("Poppins-Bold", size: 15))
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.accentColor)
                    .foregroundColor(.white)
                    .cornerRadius(15)
                    .shadow(color: Color.accentColor.opacity(0.3), radius: 10, x: 0, y: 5)
                }
                .padding(.horizontal)

                Divider().padding(.horizontal)

                // --- 3. THE TEAM SECTION ---
                VStack(alignment: .leading, spacing: 20) {
                    Text("The Colony")
                        .font(.custom("Poppins-Bold", size: 18))
                        .padding(.horizontal)

                    // A. PROJECT LEADER
                    VStack(alignment: .leading, spacing: 12) {
                        Text("PROJECT LEADER")
                            .font(.custom("Poppins-Bold", size: 11))
                            .foregroundColor(.accentColor)
                            .padding(.horizontal)
                        
                        MemberRow(
                            uid: team.authorId,
                            name: team.authorName ?? "Leader",
                            role: team.authorRole ?? "Founder",
                            isLeader: true,
                            canManage: false // Cannot remove the leader
                        )
                        .onTapGesture { selectedMemberID = team.authorId }
                    }

                    // B. COLLABORATORS
                    VStack(alignment: .leading, spacing: 12) {
                        Text("COLLABORATORS")
                            .font(.custom("Poppins-Bold", size: 11))
                            .foregroundColor(.secondary)
                            .padding(.horizontal)
                        
                        if let memberNames = team.memberNames, !memberNames.isEmpty {
                            ForEach(memberNames.sorted(by: { $0.value < $1.value }), id: \.key) { uid, name in
                                let isMeLeader = team.authorId == appState.currentUser?.uid
                                
                                MemberRow(
                                    uid: uid,
                                    name: name,
                                    role: "Collaborator",
                                    isLeader: false,
                                    canManage: isMeLeader, // Only leader can see remove button
                                    onRemove: { removeMember(uid: uid) }
                                )
                                .onTapGesture { selectedMemberID = uid }
                            }
                        } else {
                            Text("No collaborators joined yet.")
                                .font(.custom("Poppins-Italic", size: 13))
                                .foregroundColor(.gray)
                                .padding(.horizontal)
                        }
                    }
                }
            }
            .padding(.bottom, 30)
        }
        .navigationTitle("Team Details")
        .navigationBarTitleDisplayMode(.inline)
        .sheet(item: Binding(
            get: { selectedMemberID.map { IdentifiableMember(id: $0) } },
            set: { selectedMemberID = $0?.id }
        )) { member in
            ProfilePreview(
                userID: member.id,
                notificationID: "view_only",
                projectID: team.id ?? ""
            ).environmentObject(appState)
        }
    }

    // MARK: - Logic
    
    private func createGroupChatObject() -> Chat {
        var allParticipants = team.members ?? []
        allParticipants.append(team.authorId)
        
        var allNames = team.memberNames ?? [:]
        allNames[team.authorId] = team.authorName ?? "Leader"
        
        return Chat(
            id: "group_\(team.id ?? UUID().uuidString)",
            participants: allParticipants,
            participantNames: allNames,
            lastMessage: "Welcome to the group chat!",
            timestamp: Date(),
            isGroupChat: true,
            groupTitle: team.title
        )
    }
    
    private func removeMember(uid: String) {
        guard let projectID = team.id else { return }
        let db = Firestore.firestore()
        
        // Atomically remove from array and dictionary
        db.collection("projects").document(projectID).updateData([
            "members": FieldValue.arrayRemove([uid]),
            "memberNames.\(uid)": FieldValue.delete()
        ])
    }
}

// MARK: - Updated MemberRow

struct MemberRow: View {
    let uid: String
    let name: String
    let role: String
    let isLeader: Bool
    let canManage: Bool
    var onRemove: (() -> Void)? = nil
    
    var body: some View {
        HStack(spacing: 15) {
            AvatarView(name: name, size: 45)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(name)
                    .font(.custom("Poppins-Bold", size: 15))
                Text(role)
                    .font(.custom("Poppins-Medium", size: 12))
                    .foregroundColor(.gray)
            }
            
            Spacer()
            
            if canManage && !isLeader {
                Button(action: { onRemove?() }) {
                    Image(systemName: "person.badge.minus")
                        .foregroundColor(.red)
                        .font(.system(size: 18))
                }
            } else {
                Image(systemName: "chevron.right")
                    .font(.system(size: 12, weight: .bold))
                    .foregroundColor(.gray.opacity(0.5))
            }
        }
        .padding()
        .background(Color.white)
        .cornerRadius(15)
        .padding(.horizontal)
        .shadow(color: Color.black.opacity(0.03), radius: 5, x: 0, y: 2)
    }
}
// MARK: - Helper Components
//
//struct MemberRow: View {
//    let uid: String
//    let name: String
//    let role: String
//    
//    var body: some View {
//        HStack(spacing: 15) {
//            AvatarView(name: name, size: 45)
//            
//            VStack(alignment: .leading, spacing: 2) {
//                Text(name)
//                    .font(.custom("Poppins-Bold", size: 15))
//                Text(role)
//                    .font(.custom("Poppins-Medium", size: 12))
//                    .foregroundColor(.gray)
//            }
//            
//            Spacer()
//            
//            Image(systemName: "chevron.right")
//                .font(.system(size: 12, weight: .bold))
//                .foregroundColor(.gray.opacity(0.5))
//        }
//        .padding()
//        .background(Color.white)
//        .cornerRadius(15)
//        .padding(.horizontal)
//        .shadow(color: Color.black.opacity(0.03), radius: 5, x: 0, y: 2)
//    }
//}

// Helper to make String IDs compatible with .sheet(item:)
struct IdentifiableMember: Identifiable {
    let id: String
}
