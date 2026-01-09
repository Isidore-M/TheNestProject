import SwiftUI
import FirebaseFirestore

struct PostCard: View {
    let post: Post
    @EnvironmentObject var appState: AppState
    
    // UI States
    @State private var isLiked = false
    @State private var isCollaborating = false
    @State private var showComments = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 15) {
            
            // --- HEADER: Author Info ---
            HStack(spacing: 12) {
                let isMe = post.authorId == appState.currentUser?.uid
                let displayName = isMe ? (appState.userProfile?["name"] as? String ?? post.authorName ?? "U") : (post.authorName ?? "U")
                let displayRole = isMe ? (appState.userProfile?["role"] as? String ?? post.authorRole ?? "Ant") : (post.authorRole ?? "Collaborator")
                
                AvatarView(name: displayName, size: 42)
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(displayName)
                        .font(.custom("Poppins-Bold", size: 15))
                    
                    Text(displayRole)
                        .font(.custom("Poppins-Medium", size: 12))
                        .foregroundColor(.accentColor)
                }
                Spacer()
            }
            
            // --- CONTENT ---
            VStack(alignment: .leading, spacing: 8) {
                Text(post.title)
                    .font(.custom("Poppins-Bold", size: 18))
                
                Text(post.description)
                    .font(.custom("Poppins-Regular", size: 14))
                    .foregroundColor(.secondary)
                    .lineLimit(3)
            }
            
            // --- INTERACTION BAR ---
            HStack(spacing: 25) {
                // Like Button
                Button(action: toggleLike) {
                    HStack(spacing: 6) {
                        Image(systemName: isLiked ? "heart.fill" : "heart")
                            .foregroundColor(isLiked ? .red : .gray)
                        Text("\(post.likesCount ?? 0)")
                            .font(.custom("Poppins-Medium", size: 13))
                            .foregroundColor(.gray)
                    }
                }
                
                // Comment Button
                Button(action: { showComments.toggle() }) {
                    HStack(spacing: 6) {
                        Image(systemName: "message")
                            .foregroundColor(.gray)
                        Text("\(post.commentsCount ?? 0)")
                            .font(.custom("Poppins-Medium", size: 13))
                            .foregroundColor(.gray)
                    }
                }
                
                Spacer()
                
                // RESTORED: Collaborate Button
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
        .sheet(isPresented: $showComments) {
            CommentSheetView(post: post).environmentObject(appState)
        }
    }
    
    private func toggleLike() {
        guard let postId = post.id else { return }
        isLiked.toggle()
        Firestore.firestore().collection("posts").document(postId).updateData([
            "likesCount": FieldValue.increment(isLiked ? Int64(1) : Int64(-1))
        ])
    }
    
    private func sendCollaborationRequest() {
        guard !isCollaborating else { return }
        withAnimation { isCollaborating = true }
        
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
        
        db.collection("notifications").addDocument(data: notificationData)
    }
}
