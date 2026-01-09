import Foundation
import SwiftUI
import Firebase


struct MainFeedView: View {
    @EnvironmentObject var appState: AppState
    @StateObject var feedVM = FeedViewModel() // Initialize the logic
    @State private var showCreatePost = false

    var body: some View {
        NavigationStack {
            ScrollView {
                LazyVStack(spacing: 16) {
                    ForEach(feedVM.posts) { post in
                        PostCard(post: post)
                            .environmentObject(feedVM)
                            .padding(.horizontal)
                    }
                }
                .padding(.top)
            }
            .background(Color.gray.opacity(0.05)) // Subtle background for the cards
            .navigationTitle("The Nest")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button { showCreatePost.toggle() } label: {
                        Image(systemName: "plus.circle.fill")
                            .foregroundColor(.accent)
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Logout") { appState.logout() }
                        .foregroundColor(.red)
                        .font(.custom("Poppins-Medium", size: 14))
                }
            }
            .sheet(isPresented: $showCreatePost) {
                CreatePostView()
                    .environmentObject(appState)
            }
        }
    }
}
