//
//  MainTabView.swift
//  The nest
//
import SwiftUI
struct MainTabView: View {
    @EnvironmentObject var appState: AppState
    @EnvironmentObject var navNotifVM: NotificationViewModel // Receive from App level

    var body: some View {
        TabView {
            DiscoveryFeedView()
                .tabItem { Label("Feed", systemImage: "square.grid.2x2.fill") }
            
            ChatListView()
                .tabItem { Label("Messages", systemImage: "bubble.left.and.bubble.right.fill") }

            NotificationCenterView()
                .tabItem { Label("Alerts", systemImage: "bell.fill") }
                .badge(navNotifVM.unreadCount)

            ProfileDetailsView()
                .tabItem { Label("Profile", systemImage: "person.fill") }
        }
    }
}
#Preview {
    MainTabView()
        .environmentObject(AppState())
}
