//
//  CollaborationNotificationCard.swift
//  The nest

import SwiftUI
import FirebaseFirestore

struct CollaborationNotificationCard: View {
    let notification: AppNotification
    @EnvironmentObject var appState: AppState
    
    @State private var showProfile = false
    @State private var navigateToChat = false // This controls the navigation

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // --- USER INFO ---
            HStack(spacing: 12) {
                AvatarView(name: notification.senderName, size: 45)
                VStack(alignment: .leading, spacing: 2) {
                    Text("**\(notification.senderName)**").font(.custom("Poppins-Bold", size: 15))
                    Text(notification.senderRole ?? "Collaborator")
                        .font(.custom("Poppins-Medium", size: 12))
                        .foregroundColor(.accent)
                    Text("wants to collaborate on your project.").font(.custom("Poppins-Regular", size: 13)).foregroundColor(.secondary)
                }
            }
            
            // --- ACTION BUTTONS ---
            HStack(spacing: 10) {
                // BUTTON 1: VIEW PROFILE
                Button(action: { showProfile.toggle() }) {
                    Text("View Profile")
                        .font(.custom("Poppins-Bold", size: 12))
                        .frame(maxWidth: .infinity)
                        .padding(10)
                        .background(Color.gray.opacity(0.1))
                        .foregroundColor(.black)
                        .cornerRadius(8)
                }
                .buttonStyle(PlainButtonStyle()) // Prevents the List from highlighting the whole card

                // BUTTON 2: CONNECT (The Logic Trigger)
                Button(action: {
                    handleConnect()
                }) {
                    Text("Connect")
                        .font(.custom("Poppins-Bold", size: 12))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(10)
                        .background(Color.accent)
                        .cornerRadius(8)
                }
                .buttonStyle(PlainButtonStyle()) // Prevents gesture conflicts
            }
        }
        .padding()
        .background(Color.white)
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.05), radius: 5)
        
        // --- HIDDEN NAVIGATION DESTINATION ---
        // This is the "Road" that is only traveled when navigateToChat is true
        .navigationDestination(isPresented: $navigateToChat) {
            ChatRoomView(chat: buildChatObject())
                .environmentObject(appState)
        }
        
        // --- PROFILE SHEET ---
        .sheet(isPresented: $showProfile) {
            ProfilePreview(
                userID: notification.senderId,
                notificationID: notification.id ?? "",
                projectID: notification.postId ?? ""
            ).environmentObject(appState)
        }
    }

    // MARK: - Logic

    private func handleConnect() {
        // 1. Perform database sync (Master Sync)
        syncToDatabase()
        
        // 2. Trigger navigation
        navigateToChat = true
    }

    private func syncToDatabase() {
        guard let myId = appState.currentUser?.uid,
              let myName = appState.userProfile?["name"] as? String else { return }
        
        let db = Firestore.firestore()
        let batch = db.batch()
        
        if let postId = notification.postId {
            let projectRef = db.collection("projects").document(postId)
            batch.updateData([
                "memberNames.\(notification.senderId)": notification.senderName,
                "members": FieldValue.arrayUnion([notification.senderId])
            ], forDocument: projectRef)
        }
        
        if let notifId = notification.id {
            batch.deleteDocument(db.collection("notifications").document(notifId))
        }
        
        batch.commit()
    }

    private func buildChatObject() -> Chat {
        let myId = appState.currentUser?.uid ?? ""
        let myName = appState.userProfile?["name"] as? String ?? "Me"
        let otherId = notification.senderId
        let otherName = notification.senderName
        let chatId = myId < otherId ? "\(myId)_\(otherId)" : "\(otherId)_\(myId)"
        
        return Chat(
            id: chatId,
            participants: [myId, otherId],
            participantNames: [myId: myName, otherId: otherName],
            lastMessage: "Connected!",
            timestamp: Date()
        )
    }
}
