import SwiftUI
import FirebaseFirestore

struct NotificationCenterView: View {
    @EnvironmentObject var appState: AppState
    @State private var notifications: [AppNotification] = []

    var body: some View {
        ScrollView {
            LazyVStack(spacing: 15) {
                if notifications.isEmpty {
                    Text("No notifications yet.")
                        .font(.custom("Poppins-Regular", size: 14))
                        .foregroundColor(.gray)
                        .padding(.top, 50)
                } else {
                    ForEach(notifications) { notif in
                        if notif.type == "collaboration_request" {
                            CollaborationNotificationCard(notification: notif)
                        }
                    }
                }
            }
            .padding()
        }
        .navigationTitle("Notifications")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear(perform: fetchNotifications)
    }

    func fetchNotifications() {
        let db = Firestore.firestore()
        guard let uid = appState.currentUser?.uid else { return }
        
        db.collection("notifications")
            .whereField("receiverId", isEqualTo: uid)
            .order(by: "timestamp", descending: true)
            .addSnapshotListener { query, error in
                if let error = error {
                    print("DEBUG: \(error.localizedDescription)")
                    return
                }
                self.notifications = query?.documents.compactMap { try? $0.data(as: AppNotification.self) } ?? []
            }
    }
}
