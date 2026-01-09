//
//  CollaborationNotificationCard.swift
//  The nest
import SwiftUI
import Foundation


struct CollaborationNotificationCard: View {
    let notification: AppNotification
    @EnvironmentObject var appState: AppState

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 12) {
                AvatarView(name: notification.senderName, size: 45)
                
                VStack(alignment: .leading, spacing: 2) {
                    Text("**\(notification.senderName)**")
                        .font(.custom("Poppins-Bold", size: 15))
                    
                    // DISPLAYING THE ROLE
                    Text(notification.senderRole ?? "Collaborator")
                        .font(.custom("Poppins-Medium", size: 12))
                        .foregroundColor(.accentColor)
                    
                    Text("wants to collaborate on your project.")
                        .font(.custom("Poppins-Regular", size: 13))
                        .foregroundColor(.secondary)
                }
            }
            
            HStack(spacing: 10) {
                NavigationLink(destination: Text("Profile View")) {
                    Text("See Profile").font(.custom("Poppins-Bold", size: 12))
                        .frame(maxWidth: .infinity).padding(8)
                        .background(Color.gray.opacity(0.1)).cornerRadius(8)
                }
                
                NavigationLink(destination: ChatRoomView(chat: createChat()).environmentObject(appState)) {
                    Text("Connect").font(.custom("Poppins-Bold", size: 12))
                        .frame(maxWidth: .infinity).padding(8)
                        .background(Color.accentColor).foregroundColor(.white).cornerRadius(8)
                }
            }
        }
        .padding()
        .background(Color.white)
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.05), radius: 5)
    }

    func createChat() -> Chat {
        let myId = appState.currentUser?.uid ?? ""
        let myName = appState.userProfile?["name"] as? String ?? "Me"
        
        return Chat(
            id: "\(myId)_\(notification.senderId)",
            participants: [myId, notification.senderId],
            participantNames: [myId: myName, notification.senderId: notification.senderName],
            lastMessage: "Request Accepted!",
            timestamp: Date()
        )
    }
}
