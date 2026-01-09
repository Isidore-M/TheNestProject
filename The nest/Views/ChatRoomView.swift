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
        // Initializing the ViewModel with the specific Chat ID
        _viewModel = StateObject(wrappedValue: ChatRoomViewModel(chatId: chat.id ?? "temp_id"))
    }

    var body: some View {
        VStack(spacing: 0) {
            // 1. MESSAGES AREA
            ScrollViewReader { proxy in
                ScrollView {
                    LazyVStack(spacing: 12) {
                        ForEach(viewModel.messages) { message in
                            MessageBubble(
                                message: message,
                                isCurrentUser: message.isFromCurrentUser(uid: appState.currentUser?.uid ?? "")
                            )
                        }
                    }
                    .padding()
                }
                .onChange(of: viewModel.messages.count) { _ in
                    // Automatically scroll to the latest message
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
                HStack {
                    let otherName = chat.otherParticipantName(currentUID: appState.currentUser?.uid ?? "")
                    AvatarView(name: otherName, size: 32)
                    Text(otherName)
                        .font(.custom("Poppins-Bold", size: 17))
                }
            }
        }
        .onAppear {
            viewModel.fetchMessages()
        }
    }

    private func sendMessage() {
        guard let myId = appState.currentUser?.uid else { return }
        let myName = appState.userProfile?["name"] as? String ?? "User"
        let otherName = chat.otherParticipantName(currentUID: myId)
        let otherId = chat.participants.first(where: { $0 != myId }) ?? ""

        viewModel.sendMessage(
            text: messageText,
            senderId: myId,
            senderName: myName,
            otherId: otherId,
            otherName: otherName
        )
        messageText = "" // Clear input
    }
}

// MARK: - Message Bubble Component
struct MessageBubble: View {
    let message: Message
    let isCurrentUser: Bool

    var body: some View {
        HStack {
            if isCurrentUser { Spacer() }

            Text(message.text)
                .font(.custom("Poppins-Regular", size: 15))
                .padding(.horizontal, 16)
                .padding(.vertical, 10)
                .background(isCurrentUser ? Color.accentColor : Color.gray.opacity(0.2))
                .foregroundColor(isCurrentUser ? .white : .black)
                .cornerRadius(18, corners: isCurrentUser ? [.topLeft, .topRight, .bottomLeft] : [.topLeft, .topRight, .bottomRight])

            if !isCurrentUser { Spacer() }
        }
        .id(message.id) // Used by ScrollViewReader
    }
}

// MARK: - UI Helpers (Shape & Corners)
struct RoundedCorner: Shape {
    var radius: CGFloat = .infinity
    var corners: UIRectCorner = .allCorners
    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(roundedRect: rect, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
        return Path(path.cgPath)
    }
}

extension View {
    func cornerRadius(_ radius: CGFloat, corners: UIRectCorner) -> some View {
        clipShape(RoundedCorner(radius: radius, corners: corners))
    }
}
