import SwiftUI

struct ChatListView: View {
    @StateObject var viewModel = ChatListViewModel()
    @EnvironmentObject var appState: AppState

    var body: some View {
        VStack(spacing: 0) {
            if viewModel.isLoading {
                ProgressView("Opening the Nest...")
                    .padding(.top, 50)
                Spacer()
            } else if viewModel.chats.isEmpty {
                // Empty State
                VStack(spacing: 20) {
                    AvatarView(name: "Empty", size: 100)
                        .opacity(0.3)
                    Text("No conversations yet")
                        .font(.custom("Poppins-Bold", size: 18))
                    Text("Reach out to a collaborator from the feed to start a project.")
                        .font(.custom("Poppins-Regular", size: 14))
                        .foregroundColor(.gray)
                        .multilineTextAlignment(.center)
                }
                .padding(40)
                Spacer()
            } else {
                List(viewModel.chats) { chat in
                    // Destination is a placeholder for now
                    NavigationLink(destination: ChatRoomView(chat: chat).environmentObject(appState)) {
                        ChatRow(chat: chat, currentUID: appState.currentUser?.uid ?? "")
                    }
                    .listRowSeparator(.visible, edges: .bottom)
                    .listRowInsets(EdgeInsets(top: 10, leading: 16, bottom: 10, trailing: 16))
                }
                .listStyle(.plain)
            }
        }
        .navigationTitle("Messages")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            viewModel.fetchChats()
        }
    }
}

// Custom Row Component
struct ChatRow: View {
    let chat: Chat
    let currentUID: String
    
    var body: some View {
        HStack(spacing: 15) {
            let otherName = chat.otherParticipantName(currentUID: currentUID)
            
            // Your Ant Mascot
            AvatarView(name: otherName, size: 50)
            
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text(otherName)
                        .font(.custom("Poppins-Bold", size: 16))
                    Spacer()
                    Text(chat.timestamp, style: .time)
                        .font(.custom("Poppins-Regular", size: 12))
                        .foregroundColor(.gray)
                }
                
                Text(chat.lastMessage)
                    .font(.custom("Poppins-Regular", size: 14))
                    .foregroundColor(.secondary)
                    .lineLimit(1)
            }
        }
    }
}
