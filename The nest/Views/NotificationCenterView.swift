import SwiftUI

struct NotificationCenterView: View {
    @EnvironmentObject var appState: AppState
    @EnvironmentObject var navNotifVM: NotificationViewModel
    
    @State private var selectedTab = 0

    var body: some View {
        // --- THE CRITICAL FIX: NavigationStack ---
        // This provides the context needed for "Connect" to open the Chat
        NavigationStack {
            VStack(spacing: 0) {
                // --- TAB PICKER ---
                Picker("", selection: $selectedTab) {
                    Text("Activity").tag(0)
                    Text("Requests").tag(1)
                }
                .pickerStyle(.segmented)
                .padding()
                .background(Color.white)

                // --- NOTIFICATION LIST ---
                List {
                    let filteredNotifs = navNotifVM.notifications.filter { notif in
                        if selectedTab == 0 {
                            return notif.type == "like" || notif.type == "comment"
                        } else {
                            return notif.type == "collaboration_request"
                        }
                    }

                    if filteredNotifs.isEmpty {
                        emptyStateView
                    } else {
                        ForEach(filteredNotifs) { notif in
                            Group {
                                if selectedTab == 0 {
                                    GeneralNotificationRow(notification: notif)
                                } else {
                                    // This card's Connect button will now be ACTIVE
                                    CollaborationNotificationCard(notification: notif)
                                }
                            }
                            .listRowSeparator(.hidden)
                            .listRowBackground(Color.clear)
                            .listRowInsets(EdgeInsets(top: 8, leading: 16, bottom: 8, trailing: 16))
                            .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                                Button(role: .destructive) {
                                    if let id = notif.id {
                                        navNotifVM.deleteNotification(notificationID: id)
                                    }
                                } label: {
                                    Label("Delete", systemImage: "trash")
                                }
                            }
                        }
                    }
                }
                .listStyle(.plain)
                .background(Color(UIColor.systemGroupedBackground))
            }
            .navigationTitle("Notifications")
            .navigationBarTitleDisplayMode(.inline)
            // --- OPTIONAL: Clear All Button ---
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    if !navNotifVM.notifications.isEmpty {
                        Button("Mark Read") {
                            navNotifVM.markAllAsRead()
                        }
                        .font(.custom("Poppins-Medium", size: 13))
                    }
                }
            }
        }
        .onAppear {
            navNotifVM.fetchNotifications()
            navNotifVM.markAllAsRead()
        }
    }

    private var emptyStateView: some View {
        VStack(spacing: 15) {
            Image(systemName: selectedTab == 0 ? "bell.badge" : "person.badge.plus")
                .font(.system(size: 44))
                .foregroundColor(.gray.opacity(0.2))
            Text(selectedTab == 0 ? "No activity yet" : "No collaboration requests")
                .font(.custom("Poppins-Medium", size: 15))
                .foregroundColor(.gray)
        }
        .frame(maxWidth: .infinity)
        .padding(.top, 100)
        .listRowBackground(Color.clear)
        .listRowSeparator(.hidden)
    }
}
