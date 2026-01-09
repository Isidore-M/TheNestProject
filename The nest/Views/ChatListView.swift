import SwiftUI

struct ChatListView: View {
    @EnvironmentObject var appState: AppState
    @StateObject var viewModel = ChatListViewModel()

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                if viewModel.chats.isEmpty {
                    // Empty State
                    VStack(spacing: 20) {
                        Image(systemName: "bubble.left.and.bubble.right")
                            .font(.system(size: 60))
                            .foregroundColor(.gray.opacity(0.2))
                        Text("No conversations yet.\nConnect with collaborators to start chatting!")
                            .font(.custom("Poppins-Medium", size: 15))
                            .foregroundColor(.gray)
                            .multilineTextAlignment(.center)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else {
                    // Chat List
                    List(viewModel.chats) { chat in
                        NavigationLink(destination: ChatRoomView(chat: chat).environmentObject(appState)) {
                            ChatRow(chat: chat, currentUID: appState.currentUser?.uid ?? "")
                        }
                        .listRowInsets(EdgeInsets(top: 10, leading: 16, bottom: 10, trailing: 16))
                    }
                    .listStyle(.plain)
                }
            }
            .navigationTitle("Messages")
            .onAppear {
                if let uid = appState.currentUser?.uid {
                    viewModel.listenForChats(uid: uid)
                }
            }
        }
    }
}

// MARK: - ChatRow Component
struct ChatRow: View {
    let chat: Chat
    let currentUID: String
    
    var body: some View {
        HStack(spacing: 15) {
            // 1. Dynamic Title (Helper function from Chat model)
            let title = chat.displayName(currentUserID: currentUID)
            
            // 2. Avatar/Icon Logic
            if chat.isGroupChat == true {
                ZStack {
                    Circle()
                        .fill(Color.accentColor.opacity(0.1))
                        .frame(width: 55, height: 55)
                    Image(systemName: "person.3.fill")
                        .foregroundColor(.accentColor)
                        .font(.system(size: 20))
                }
            } else {
                AvatarView(name: title, size: 55)
            }
            
            // 3. Content
            VStack(alignment: .leading, spacing: 5) {
                HStack {
                    Text(title)
                        .font(.custom("Poppins-Bold", size: 16))
                        .foregroundColor(.primary)
                    
                    Spacer()
                    
                    Text(chat.timestamp, style: .time)
                        .font(.custom("Poppins-Regular", size: 11))
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
