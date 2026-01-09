import SwiftUI
import FirebaseFirestore
import FirebaseAuth

class ChatListViewModel: ObservableObject {
    @Published var chats: [Chat] = []
    @Published var isLoading = true
    private var db = Firestore.firestore()
    private var listener: ListenerRegistration?

    func fetchChats() {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        
        // Real-time listener for chats where the user is a participant
        listener = db.collection("chats")
            .whereField("participants", arrayContains: uid)
            .order(by: "timestamp", descending: true)
            .addSnapshotListener { querySnapshot, error in
                DispatchQueue.main.async {
                    self.isLoading = false
                    if let error = error {
                        print("DEBUG: Chat Fetch Error: \(error.localizedDescription)")
                        return
                    }
                    
                    self.chats = querySnapshot?.documents.compactMap { document in
                        try? document.data(as: Chat.self)
                    } ?? []
                }
            }
    }
    
    deinit {
        listener?.remove()
    }
}
