import Foundation
import SwiftUI

struct CommentSheetView: View {
    let post: Post
    @StateObject var viewModel: CommentViewModel
    @EnvironmentObject var appState: AppState
    @State private var commentText = ""

    init(post: Post) {
        self.post = post
        // Initialize the ViewModel with the specific Post ID
        _viewModel = StateObject(wrappedValue: CommentViewModel(postId: post.id ?? ""))
    }

    var body: some View {
        VStack(spacing: 0) {
            // --- HANDLEBAR ---
            Capsule()
                .fill(Color.gray.opacity(0.3))
                .frame(width: 40, height: 5)
                .padding(.top, 10)
            
            Text("Comments")
                .font(.custom("Poppins-Bold", size: 18))
                .padding(.vertical, 15)
            
            Divider()

            // --- COMMENTS LIST ---
            ScrollView {
                if viewModel.comments.isEmpty {
                    VStack(spacing: 15) {
                        Image(systemName: "bubble.left.and.exclamationmark.bubble.right")
                            .font(.system(size: 40))
                            .foregroundColor(.gray.opacity(0.4))
                        Text("No comments yet. Be the first to chime in!")
                            .font(.custom("Poppins-Medium", size: 14))
                            .foregroundColor(.gray)
                    }
                    .padding(.top, 50)
                } else {
                    LazyVStack(alignment: .leading, spacing: 20) {
                        ForEach(viewModel.comments) { comment in
                            CommentRow(comment: comment)
                                .environmentObject(appState) // Pass appState for live name updates
                        }
                    }
                    .padding()
                }
            }

            // --- INPUT FIELD ---
            VStack(spacing: 0) {
                Divider()
                HStack(spacing: 12) {
                    AvatarView(name: appState.userProfile?["name"] as? String ?? "U", size: 35)
                    
                    TextField("Add a comment...", text: $commentText)
                        .font(.custom("Poppins-Regular", size: 14))
                        .padding(10)
                        .background(Color.gray.opacity(0.1))
                        .cornerRadius(20)
                    
                    Button(action: submitComment) {
                        Image(systemName: "paperplane.fill")
                            .foregroundColor(commentText.isEmpty ? .gray : .accentColor)
                    }
                    .disabled(commentText.isEmpty)
                }
                .padding()
                .background(Color.white)
            }
        }
        .onAppear { viewModel.fetchComments() }
    }

    // --- FIXED FUNCTION ---
    func submitComment() {
        guard let myUID = appState.currentUser?.uid else { return }
        
        // We now pass the post's author ID so the ViewModel can send a notification
        viewModel.postComment(
            text: commentText,
            user: appState.userProfile ?? [:],
            uid: myUID,
            authorIdOfPost: post.authorId ?? "" // This was the missing argument
        )
        
        commentText = "" // Clear input
    }
}
// MARK: - UPDATED Comment Row Component
struct CommentRow: View {
    let comment: Comment
    @EnvironmentObject var appState: AppState // Added to access live data
    
    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            // LOGIC: Check if this comment belongs to the current user
            let isMe = comment.authorId == appState.currentUser?.uid
            let displayName = isMe ? (appState.userProfile?["name"] as? String ?? comment.authorName) : comment.authorName
            let displayRole = isMe ? (appState.userProfile?["role"] as? String ?? comment.authorRole) : comment.authorRole
            
            AvatarView(name: displayName, size: 35)
            
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text(displayName)
                        .font(.custom("Poppins-Bold", size: 14))
                    Text("•")
                        .foregroundColor(.gray)
                    Text(displayRole)
                        .font(.custom("Poppins-Medium", size: 11))
                        .foregroundColor(.accentColor)
                }
                
                Text(comment.text)
                    .font(.custom("Poppins-Regular", size: 14))
                    .foregroundColor(.primary)
            }
        }
    }
}
