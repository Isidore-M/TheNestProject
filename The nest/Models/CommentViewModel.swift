//
//  CommentViewModel.swift
//  The nest

import Foundation
import SwiftUI
import FirebaseFirestore

class CommentViewModel: ObservableObject {
    @Published var comments: [Comment] = []
    private var db = Firestore.firestore()
    private var listener: ListenerRegistration?
    let postId: String

    init(postId: String) {
        self.postId = postId
    }

    func fetchComments() {
        listener = db.collection("posts").document(postId).collection("comments")
            .order(by: "timestamp", descending: false)
            .addSnapshotListener { querySnapshot, _ in
                self.comments = querySnapshot?.documents.compactMap { try? $0.data(as: Comment.self) } ?? []
            }
    }

    // Add 'authorIdOfPost' as a parameter so we know who to notify
    func postComment(text: String, user: [String: Any], uid: String, authorIdOfPost: String) {
        let name = user["name"] as? String ?? "User"
        let role = user["role"] as? String ?? "Collaborator"
        
        let commentData: [String: Any] = [
            "authorId": uid,
            "authorName": name,
            "authorRole": role,
            "text": text,
            "timestamp": FieldValue.serverTimestamp()
        ]

        // 1. Add the comment
        db.collection("posts").document(postId).collection("comments").addDocument(data: commentData)
        
        // 2. Increment count
        db.collection("posts").document(postId).updateData([
            "commentsCount": FieldValue.increment(Int64(1))
        ])
        
        // 3. Create Notification (if not commenting on your own post)
        if uid != authorIdOfPost {
            let commentNotif: [String: Any] = [
                "type": "comment",
                "senderId": uid,
                "senderName": name,
                "receiverId": authorIdOfPost,
                "postId": postId,
                "timestamp": FieldValue.serverTimestamp(),
                "isRead": false
            ]
            db.collection("notifications").addDocument(data: commentNotif)
        }
    }

    deinit {
        listener?.remove()
    }
}
