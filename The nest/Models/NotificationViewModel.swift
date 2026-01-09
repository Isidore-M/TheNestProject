import SwiftUI
import FirebaseFirestore
import FirebaseAuth

class NotificationViewModel: ObservableObject {
    @Published var notifications: [AppNotification] = []
    @Published var unreadCount: Int = 0
    @Published var isLoading = false
    
    private var db = Firestore.firestore()
    private var listener: ListenerRegistration?

    func fetchNotifications() {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        
        listener = db.collection("notifications")
            .whereField("receiverId", isEqualTo: uid)
            .order(by: "timestamp", descending: true)
            .addSnapshotListener { [weak self] querySnapshot, _ in
                guard let self = self else { return }
                
                let docs = querySnapshot?.documents ?? []
                self.notifications = docs.compactMap { try? $0.data(as: AppNotification.self) }
                
                // Update the red badge count
                DispatchQueue.main.async {
                    self.unreadCount = self.notifications.filter { !($0.isRead ?? false) }.count
                }
            }
    }

    func markAllAsRead() {
        let unreadNotifs = notifications.filter { !($0.isRead ?? false) }
        let batch = db.batch()
        
        for notif in unreadNotifs {
            if let id = notif.id {
                let ref = db.collection("notifications").document(id)
                batch.updateData(["isRead": true], forDocument: ref)
            }
        }
        
        batch.commit { error in
            if let error = error {
                print("DEBUG: Failed to mark read: \(error.localizedDescription)")
            }
        }
    }
}
