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
        
        // Ensure the collection name is "notifications" (all lowercase)
        listener = db.collection("notifications")
            .whereField("receiverId", isEqualTo: uid) // This is the filter
            .order(by: "timestamp", descending: true)
            .addSnapshotListener { [weak self] querySnapshot, error in
                if let error = error {
                    print("DEBUG: Notification listener error: \(error.localizedDescription)")
                    return
                }
                
                let docs = querySnapshot?.documents ?? []
                self?.notifications = docs.compactMap { try? $0.data(as: AppNotification.self) }
                
                DispatchQueue.main.async {
                    self?.unreadCount = self?.notifications.filter { !($0.isRead ?? false) }.count ?? 0
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
    

    func deleteNotification(notificationID: String) {
        let db = Firestore.firestore()
        
        // 1. Remove from Firestore
        db.collection("notifications").document(notificationID).delete { error in
            if let error = error {
                print("DEBUG: Failed to delete notification: \(error.localizedDescription)")
            } else {
                // 2. Local update (optional as the snapshot listener will handle it,
                // but doing it manually makes the UI feel faster)
                DispatchQueue.main.async {
                    self.notifications.removeAll { $0.id == notificationID }
                }
            }
        }
    }
}
