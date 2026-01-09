import SwiftUI
import FirebaseFirestore

struct PostCard: View {
    let post: Post
    @EnvironmentObject var appState: AppState
    
    // UI States for immediate feedback
    @State private var isLiked = false
    @State private var isCollaborating = false
    @State private var showComments = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 15) {
            
            // --- HEADER: Author Info ---
            HStack(spacing: 12) {
                // LOGIC: If this is the current user's post, use their live profile data.
                // Otherwise, use the data snapshot stored on the post.
                let isMe = post.authorId == appState.currentUser?.uid
                let displayName = isMe ? (appState.userProfile?["name"] as? String ?? post.authorName ?? "User") : (post.authorName ?? "User")
                let displayRole = isMe ? (appState.userProfile?["role"] as? String ?? post.authorRole ?? "Collaborator") : (post.authorRole ?? "Collaborator")
                
                // Uses custom Masked Ant Mascot
                AvatarView(name: displayName, size: 42)
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(displayName)
                        .font(.custom("Poppins-Bold", size: 15))
                    
                    Text(displayRole)
                        .font(.custom("Poppins-Medium", size: 12))
                        .foregroundColor(.accentColor)
                }
                
                Spacer()
                
                // Time stamp
                if let date = post.timestamp {
                    Text(date, style: .date)
                        .font(.custom("Poppins-Light", size: 10))
                        .foregroundColor(.gray)
                }
            }
            
            // --- CONTENT: Project Details ---
            VStack(alignment: .leading, spacing: 8) {
                Text(post.title)
                    .font(.custom("Poppins-Bold", size: 18))
                    .foregroundColor(.primary)
                
                Text(post.description)
                    .font(.custom("Poppins-Regular", size: 14))
                    .foregroundColor(.secondary)
                    .lineLimit(3)
                    .fixedSize(horizontal: false, vertical: true)
            }
            
            // --- INTERACTION BAR ---
            HStack(spacing: 25) {
                // 1. LIKE BUTTON
                Button(action: {
                    withAnimation(.spring()) { isLiked.toggle() }
                    // Future: Add Firebase Like Logic here
                }) {
                    HStack(spacing: 6) {
                        Image(systemName: isLiked ? "heart.fill" : "heart")
                            .font(.system(size: 18))
                            .foregroundColor(isLiked ? .red : .gray)
                        
                        Text("\((post.likesCount ?? 0) + (isLiked ? 1 : 0))")
                            .font(.custom("Poppins-Medium", size: 13))
                            .foregroundColor(.gray)
                    }
                }
                
                // 2. COMMENT BUTTON
                Button(action: { showComments.toggle() }) {
                    HStack(spacing: 6) {
                        Image(systemName: "message")
                            .font(.system(size: 18))
                            .foregroundColor(.gray)
                        
                        Text("\(post.commentsCount ?? 0)")
                            .font(.custom("Poppins-Medium", size: 13))
                            .foregroundColor(.gray)
                    }
                }
                
                Spacer()
                
                // 3. COLLABORATE BUTTON
                // Don't show the button on your own posts
                if post.authorId != appState.currentUser?.uid {
                    Button(action: sendCollaborationRequest) {
                        Text(isCollaborating ? "Requested" : "Collaborate")
                            .font(.custom("Poppins-Bold", size: 13))
                            .padding(.horizontal, 18)
                            .padding(.vertical, 8)
                            .background(isCollaborating ? Color.green : Color.accentColor)
                            .foregroundColor(.white)
                            .cornerRadius(25)
                    }
                }
            }
        }
        .padding(18)
        .background(Color.white)
        .cornerRadius(20)
        .shadow(color: Color.black.opacity(0.06), radius: 10, x: 0, y: 5)
        
        // --- COMMENT SHEET TRIGGER ---
        .sheet(isPresented: $showComments) {
            CommentSheetView(post: post)
                .environmentObject(appState)
                .presentationDetents([.medium, .large])
                .presentationDragIndicator(.visible)
        }
    }
    
    // MARK: - Logic Functions
    
    private func sendCollaborationRequest() {
        guard !isCollaborating else { return }
        
        // Immediate UI feedback
        withAnimation(.easeInOut) {
            isCollaborating = true
        }
        
        let db = Firestore.firestore()
        let myId = appState.currentUser?.uid ?? ""
        let myName = appState.userProfile?["name"] as? String ?? "New User"
        let myRole = appState.userProfile?["role"] as? String ?? "Collaborator"
        
        let notificationData: [String: Any] = [
            "type": "collaboration_request",
            "senderId": myId,
            "senderName": myName,
            "senderRole": myRole,
            "receiverId": post.authorId ?? "",
            "postId": post.id ?? "",
            "timestamp": FieldValue.serverTimestamp(),
            "isRead": false
        ]
        
        db.collection("notifications").addDocument(data: notificationData) { error in
            if let error = error {
                print("DEBUG: Error sending request: \(error.localizedDescription)")
                isCollaborating = false
            }
        }
    }
}
