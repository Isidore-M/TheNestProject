import SwiftUI
import FirebaseFirestore

class FeedViewModel: ObservableObject {
    @Published var posts: [Post] = []
    @Published var isLoading = false
    
    private var db = Firestore.firestore()
    private var listener: ListenerRegistration?

    init() {
        fetchPosts()
    }

    /// Fetches posts from Firestore and listens for real-time updates
    func fetchPosts() {
        isLoading = true
        
        // Clear previous listener if it exists to avoid memory leaks
        listener?.remove()
        
        // Listen to the "posts" collection, ordered by most recent first
        listener = db.collection("posts")
            .order(by: "timestamp", descending: true)
            .addSnapshotListener { [weak self] querySnapshot, error in
                guard let self = self else { return }
                
                DispatchQueue.main.async {
                    self.isLoading = false
                    
                    if let error = error {
                        print("DEBUG: Error fetching posts: \(error.localizedDescription)")
                        return
                    }
                    
                    guard let documents = querySnapshot?.documents else {
                        print("DEBUG: No posts found")
                        return
                    }
                    
                    // Mapping Firestore documents to our Post model
                    // This will now include likesCount and commentsCount
                    self.posts = documents.compactMap { document in
                        do {
                            return try document.data(as: Post.self)
                        } catch {
                            print("DEBUG: Error decoding post \(document.documentID): \(error)")
                            return nil
                        }
                    }
                }
            }
    }

    /// Stops the real-time listener when the ViewModel is no longer needed
    func stopListening() {
        listener?.remove()
    }
    
    deinit {
        stopListening()
    }
}
