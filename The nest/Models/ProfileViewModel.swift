import SwiftUI
import FirebaseFirestore
import FirebaseAuth

class ProfileViewModel: ObservableObject {
    @Published var postsCount: Int = 0
    @Published var collabCount: Int = 0
    @Published var impactScore: Int = 0
    @Published var isLoading = false
    
    private var db = Firestore.firestore()
    
    func fetchStats() {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        isLoading = true
        
        let group = DispatchGroup()
        var currentImpact = 0
        
        // 1. Count User's Posts & Calculate Likes Impact
        group.enter()
        db.collection("posts").whereField("authorId", isEqualTo: uid).getDocuments { snapshot, _ in
            let docs = snapshot?.documents ?? []
            self.postsCount = docs.count
            
            // Each like received adds 5 Impact points
            let totalLikes = docs.compactMap { $0.data()["likesCount"] as? Int }.reduce(0, +)
            currentImpact += (totalLikes * 5)
            group.leave()
        }
        
        // 2. Count Collaborations (Active Chats)
        group.enter()
        db.collection("chats").whereField("participants", arrayContains: uid).getDocuments { snapshot, _ in
            self.collabCount = snapshot?.documents.count ?? 0
            // Each collaboration adds 20 Impact points
            currentImpact += (self.collabCount * 20)
            group.leave()
        }
        
        group.notify(queue: .main) {
            self.impactScore = currentImpact
            self.isLoading = false
        }
    }
}
