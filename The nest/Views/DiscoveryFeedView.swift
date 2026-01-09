import SwiftUI

struct DiscoveryFeedView: View {
    // 1. Environment & State Objects
    @EnvironmentObject var appState: AppState
    @EnvironmentObject var navNotifVM: NotificationViewModel // Added for the Red Badge logic
    @StateObject var feedVM = FeedViewModel()
    
    // 2. UI State
    @State private var searchText = ""
    @State private var showCreatePost = false

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                
                // --- SEARCH BAR ---
                HStack {
                    Image(systemName: "magnifyingglass")
                        .foregroundColor(.gray)
                    TextField("Search for a skill (e.g. SwiftUI, UI/UX)", text: $searchText)
                        .font(.custom("Poppins-Regular", size: 14))
                }
                .padding()
                .background(Color.gray.opacity(0.1))
                .cornerRadius(12)
                .padding(.horizontal)
                .padding(.top, 10)

                // --- POST FEED ---
                ScrollView {
                    if feedVM.isLoading && feedVM.posts.isEmpty {
                        // Loading / Empty State
                        VStack(spacing: 20) {
                            ProgressView()
                                .tint(.accentColor)
                            Text("Gathering the colony...")
                                .font(.custom("Poppins-Medium", size: 14))
                                .foregroundColor(.gray)
                        }
                        .padding(.top, 100)
                    } else {
                        // List of Posts
                        LazyVStack(spacing: 16) {
                            ForEach(feedVM.posts) { post in
                                PostCard(post: post)
                            }
                        }
                        .padding()
                    }
                }
                .refreshable {
                    feedVM.fetchPosts()
                }
            }
            // --- NAVIGATION SETTINGS ---
            .navigationTitle("The Nest")
            .navigationBarTitleDisplayMode(.inline)
            
            // --- TOOLBAR ---
            .toolbar {
                // TOP LEFT: Profile Link with Ant Avatar
                ToolbarItem(placement: .navigationBarLeading) {
                    NavigationLink(destination: ProfileDetailsView()) {
                        let userName = appState.userProfile?["name"] as? String ?? "User"
                        AvatarView(name: userName, size: 36)
                    }
                }
                
                // TOP RIGHT: Messages and Notifications with Badge
                ToolbarItem(placement: .navigationBarTrailing) {
                    HStack(spacing: 15) {
                        // NAVIGATION TO CHAT LIST
                        NavigationLink(destination: ChatListView().environmentObject(appState)) {
                            Image(systemName: "bubble.left.and.bubble.right")
                                .font(.system(size: 15))
                                .foregroundColor(.black)
                        }
                        
                        // NAVIGATION TO NOTIFICATIONS WITH RED CIRCLE
                        NavigationLink(destination: NotificationCenterView().environmentObject(navNotifVM)) {
                            ZStack(alignment: .topTrailing) {
                                Image(systemName: "bell")
                                    .font(.system(size: 18))
                                    .foregroundColor(.black)
                                
                                // THE RED BADGE
                                if navNotifVM.unreadCount > 0 {
                                    Circle()
                                        .fill(Color.red)
                                        .frame(width: 9, height: 9)
                                        .offset(x: 2, y: -2)
                                        .overlay(
                                            Circle()
                                                .stroke(Color.white, lineWidth: 1.5)
                                                .offset(x: 2, y: -2)
                                        )
                                }
                            }
                        }
                    }
                }
            }
            
            // --- FLOATING ACTION BUTTON ---
            .overlay(alignment: .bottomTrailing) {
                Button {
                    showCreatePost.toggle()
                } label: {
                    ZStack {
                        Circle()
                            .fill(Color.accentColor)
                            .frame(width: 56, height: 56)
                            .shadow(color: .accentColor.opacity(0.3), radius: 10, x: 0, y: 5)
                        
                        Image(systemName: "plus")
                            .font(.system(size: 24, weight: .bold))
                            .foregroundColor(.white)
                    }
                }
                .padding(25)
            }
            
            // --- CREATE POST MODAL ---
            .sheet(isPresented: $showCreatePost) {
                CreatePostView()
                    .environmentObject(appState)
            }
        }
        .onAppear {
            feedVM.fetchPosts()
            navNotifVM.fetchNotifications() // Sync notifications on load
        }
    }
}
// MARK: - Preview
#Preview {
    DiscoveryFeedView()
        .environmentObject(AppState())
        .environmentObject(NotificationViewModel()) // Add this to stop Preview crashes
}
