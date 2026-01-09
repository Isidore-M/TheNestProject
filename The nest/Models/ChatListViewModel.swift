import SwiftUI
import FirebaseFirestore
import FirebaseAuth

class ChatListViewModel: ObservableObject {
    @Published var chats: [Chat] = []
    private var db = Firestore.firestore()
    private var listener: ListenerRegistration?

    /// Listens for all conversations (1-on-1 and Group) where the user is a participant
    func listenForChats(uid: String) {
        listener?.remove()

        listener = db.collection("chats")
            .whereField("participants", arrayContains: uid)
            .order(by: "timestamp", descending: true)
            .addSnapshotListener { [weak self] snapshot, error in
                if let error = error {
                    print("DEBUG: Chat List Listener Error: \(error.localizedDescription)")
                    return
                }
                
                guard let documents = snapshot?.documents else { return }
                
                self?.chats = documents.compactMap { doc in
                    try? doc.data(as: Chat.self)
                }
            }
    }

    deinit {
        listener?.remove()
    }
}
