//
//  CollaborationNotificationCard.swift
//  The nest
import SwiftUI
import Foundation
import FirebaseFirestore

struct CollaborationNotificationCard: View {
    let notification: AppNotification
    @EnvironmentObject var appState: AppState
    @State private var isConnecting = false
    @State private var showProfile = false

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 12) {
                AvatarView(name: notification.senderName, size: 45)
                VStack(alignment: .leading, spacing: 2) {
                    Text("**\(notification.senderName)**").font(.custom("Poppins-Bold", size: 15))
                    Text("wants to collaborate on your project.").font(.custom("Poppins-Regular", size: 13)).foregroundColor(.secondary)
                }
            }
            
            HStack(spacing: 10) {
                Button("See Profile") { showProfile.toggle() }
                    .font(.custom("Poppins-Bold", size: 12)).frame(maxWidth: .infinity).padding(10)
                    .background(Color.gray.opacity(0.1)).cornerRadius(8)
                
                Button(action: handleConnect) {
                    if isConnecting { ProgressView() }
                    else { Text("Connect").font(.custom("Poppins-Bold", size: 12)).foregroundColor(.white) }
                }
                .frame(maxWidth: .infinity).padding(10)
                .background(Color.accentColor).cornerRadius(8)
            }
        }
        .padding().background(Color.white).cornerRadius(12).shadow(radius: 5)
        .sheet(isPresented: $showProfile) { ProfilePreview(userID: notification.senderId).environmentObject(appState) }
    }

    private func handleConnect() {
        guard let myId = appState.currentUser?.uid, let myName = appState.userProfile?["name"] as? String else { return }
        isConnecting = true
        let db = Firestore.firestore()
        
        Task {
            do {
                let chatId = myId < notification.senderId ? "\(myId)_\(notification.senderId)" : "\(notification.senderId)_\(myId)"
                let batch = db.batch()
                
                // 1. Update Team Dictionary (Master Sync Format)
                if let postId = notification.postId {
                    batch.updateData(["memberNames.\(notification.senderId)": notification.senderName, "members": FieldValue.arrayUnion([notification.senderId])], forDocument: db.collection("projects").document(postId))
                }
                
                // 2. Create Chat
                batch.setData([
                    "participants": [myId, notification.senderId],
                    "participantNames": [myId: myName, notification.senderId: notification.senderName],
                    "lastMessage": "Connected!",
                    "timestamp": FieldValue.serverTimestamp()
                ], forDocument: db.collection("chats").document(chatId), merge: true)
                
                try await batch.commit()
                isConnecting = false
            } catch {
                isConnecting = false
            }
        }
    }
}
