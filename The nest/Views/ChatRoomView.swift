import SwiftUI
import FirebaseFirestore
struct ChatRoomView: View {
    let chat: Chat
    @StateObject var viewModel: ChatRoomViewModel
    @EnvironmentObject var appState: AppState
    @State private var messageText = ""
    @Environment(\.dismiss) var dismiss

    init(chat: Chat) {
        self.chat = chat
        _viewModel = StateObject(wrappedValue: ChatRoomViewModel(chatId: chat.id ?? "temp_id"))
    }

    var body: some View {
        VStack(spacing: 0) {
            // 1. MESSAGES AREA
            ScrollViewReader { proxy in
                ScrollView {
                    LazyVStack(spacing: 12) {
                        ForEach(viewModel.messages) { message in
                            // For group chats, identify the sender name
                            let senderName = chat.isGroupChat == true ? chat.participantNames[message.senderId] : nil
                            
                            MessageBubble(
                                message: message,
                                isCurrentUser: message.isFromCurrentUser(uid: appState.currentUser?.uid ?? ""),
                                senderName: senderName
                            )
                        }
                    }
                    .padding()
                }
                .onChange(of: viewModel.messages.count) { _ in
                    withAnimation {
                        proxy.scrollTo(viewModel.messages.last?.id, anchor: .bottom)
                    }
                }
            }

            // 2. INPUT BAR
            VStack(spacing: 0) {
                Divider()
                HStack(spacing: 12) {
                    TextField("Write a message...", text: $messageText)
                        .font(.custom("Poppins-Regular", size: 14))
                        .padding(12)
                        .background(Color.gray.opacity(0.1))
                        .cornerRadius(20)
                    
                    Button(action: sendMessage) {
                        Image(systemName: "paperplane.fill")
                            .font(.system(size: 18, weight: .bold))
                            .foregroundColor(.white)
                            .padding(10)
                            .background(messageText.isEmpty ? Color.gray : Color.accentColor)
                            .clipShape(Circle())
                    }
                    .disabled(messageText.isEmpty)
                }
                .padding(.horizontal)
                .padding(.vertical, 10)
                .background(Color.white)
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .principal) {
                HStack(spacing: 10) {
                    let chatTitle = chat.displayName(currentUserID: appState.currentUser?.uid ?? "")
                    if chat.isGroupChat == true {
                        Image(systemName: "person.3.fill").foregroundColor(.accentColor)
                    } else {
                        AvatarView(name: chatTitle, size: 32)
                    }
                    Text(chatTitle).font(.custom("Poppins-Bold", size: 17))
                }
            }
        }
        .onAppear { viewModel.fetchMessages() }
    }

    private func sendMessage() {
        guard let myId = appState.currentUser?.uid else { return }
        let myName = appState.userProfile?["name"] as? String ?? "User"
        
        // Logic for 1-on-1 chats to satisfy ViewModel requirements
        let otherId = chat.participants.first(where: { $0 != myId }) ?? ""
        let otherName = chat.participantNames[otherId] ?? "Member"

        // FIXED: Matching the specific argument labels expected by your ViewModel
        viewModel.sendMessage(
            text: messageText,
            senderId: myId,
            senderName: myName,
            otherId: otherId,
            otherName: otherName
        )
        messageText = ""
    }
}

// MARK: - Message Bubble Component
struct MessageBubble: View {
    let message: Message
    let isCurrentUser: Bool
    let senderName: String?

    var body: some View {
        VStack(alignment: isCurrentUser ? .trailing : .leading, spacing: 4) {
            if let name = senderName, !isCurrentUser {
                Text(name)
                    .font(.custom("Poppins-Medium", size: 10))
                    .foregroundColor(.gray)
                    .padding(.horizontal, 8)
            }
            
            HStack {
                if isCurrentUser { Spacer() }

                Text(message.text)
                    .font(.custom("Poppins-Regular", size: 15))
                    .padding(.horizontal, 16)
                    .padding(.vertical, 10)
                    .background(isCurrentUser ? Color.accentColor : Color.gray.opacity(0.2))
                    .foregroundColor(isCurrentUser ? .white : .black)
                    // FIXED: Replaced custom extension with standard SwiftUI rounded corners
                    .clipShape(RoundedRectangle(cornerRadius: 18))

                if !isCurrentUser { Spacer() }
            }
        }
        .id(message.id)
    }
}
