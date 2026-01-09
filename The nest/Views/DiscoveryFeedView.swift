import SwiftUI

struct DiscoveryFeedView: View {
    // 1. Environment & State Objects
    @EnvironmentObject var appState: AppState
    @EnvironmentObject var navNotifVM: NotificationViewModel
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
                                .tint(.accent)
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
                
                // NEW TOP RIGHT: Team List Button
                ToolbarItem(placement: .navigationBarTrailing) {
                    NavigationLink(destination: TeamListView().environmentObject(appState)) {
                        ZStack {
                            Circle()
                                .fill(Color.accent.opacity(0.1))
                                .frame(width: 36, height: 36)
                            
                            Image(systemName: "person.2.fill")
                                .font(.system(size: 16, weight: .bold))
                                .foregroundColor(.accent)
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
                            .fill(Color.accent)
                            .frame(width: 56, height: 56)
                            .shadow(color: .accent.opacity(0.3), radius: 10, x: 0, y: 5)
                        
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
            navNotifVM.fetchNotifications()
        }
    }
}
