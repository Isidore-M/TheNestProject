//
//  ChatRoomViewModel.swift
//  The nest
//

import Foundation
import SwiftUI
import FirebaseFirestore
import FirebaseAuth

class ChatRoomViewModel: ObservableObject {
    @Published var messages: [Message] = []
    private var db = Firestore.firestore()
    private var listener: ListenerRegistration?
    let chatId: String

    init(chatId: String) {
        self.chatId = chatId
    }

    func fetchMessages() {
        // Listen to the sub-collection "messages" inside this specific chat
        listener = db.collection("chats").document(chatId).collection("messages")
            .order(by: "timestamp", descending: false)
            .addSnapshotListener { querySnapshot, _ in
                guard let documents = querySnapshot?.documents else { return }
                self.messages = documents.compactMap { try? $0.data(as: Message.self) }
            }
    }

    func sendMessage(text: String, senderId: String, senderName: String, otherId: String, otherName: String) {
        if text.trimmingCharacters(in: .whitespaces).isEmpty { return }
        
        let messageData: [String: Any] = [
            "senderId": senderId,
            "text": text,
            "timestamp": FieldValue.serverTimestamp()
        ]

        // 1. Add message to the sub-collection
        db.collection("chats").document(chatId).collection("messages").addDocument(data: messageData)

        // 2. Update the parent "chat" document for Page 16
        db.collection("chats").document(chatId).setData([
            "lastMessage": text,
            "timestamp": FieldValue.serverTimestamp(),
            "participants": [senderId, otherId],
            "participantNames": [senderId: senderName, otherId: otherName]
        ], merge: true)
    }

    deinit {
        listener?.remove()
    }
}
