//
//  GeneralNotificationRow.swift
//  The nest
//

import SwiftUI

struct GeneralNotificationRow: View {
    let notification: AppNotification
    @EnvironmentObject var feedVM: FeedViewModel // To pull the post title if needed
    
    var body: some View {
        HStack(spacing: 12) {
            // 1. SENDER AVATAR
            AvatarView(name: notification.senderName, size: 40)
            
            // 2. NOTIFICATION TEXT
            VStack(alignment: .leading, spacing: 2) {
                Group {
                    Text(notification.senderName)
                        .font(.custom("Poppins-Bold", size: 14)) +
                    Text(notification.type == "like" ? " liked your post." : " commented on your post.")
                        .font(.custom("Poppins-Regular", size: 14))
                }
                
                Text(notification.timestamp, style: .relative)
                    .font(.custom("Poppins-Light", size: 11))
                    .foregroundColor(.gray)
            }
            
            Spacer()
            
            // 3. POST PREVIEW BOX
            // This represents a tiny "thumbnail" of the post being interacted with
            if let postId = notification.postId {
                VStack {
                    Image(systemName: notification.type == "like" ? "heart.fill" : "bubble.right.fill")
                        .font(.system(size: 10))
                        .foregroundColor(notification.type == "like" ? .red : .accentColor)
                    
                    Text("View Post")
                        .font(.custom("Poppins-Bold", size: 8))
                        .foregroundColor(.gray)
                }
                .frame(width: 45, height: 45)
                .background(Color.gray.opacity(0.05))
                .cornerRadius(8)
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(Color.gray.opacity(0.1), lineWidth: 1)
                )
            }
        }
        .padding()
        .background(Color.white)
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.02), radius: 5, x: 0, y: 2)
    }
}
