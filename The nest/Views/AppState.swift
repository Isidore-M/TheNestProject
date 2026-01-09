import SwiftUI
import FirebaseAuth
import FirebaseFirestore

class AppState: ObservableObject {
    enum Screen {
        case signIn, signUp, profileSetup, mainFeed
    }
    
    @Published var currentScreen: Screen = .signIn
    @Published var currentUser: FirebaseAuth.User?
    @Published var userProfile: [String: Any]?
    @Published var isLoading = true
    
    private var db = Firestore.firestore()

    init() {
        Auth.auth().addStateDidChangeListener { [weak self] _, user in
            DispatchQueue.main.async {
                self?.currentUser = user
                if let user = user {
                    self?.checkProfileStatus(uid: user.uid)
                } else {
                    self?.currentScreen = .signIn
                    self?.isLoading = false
                    self?.userProfile = nil
                }
            }
        }
    }
    
    func checkProfileStatus(uid: String) {
        db.collection("users").document(uid).addSnapshotListener { [weak self] snapshot, _ in
            guard let self = self else { return }
            DispatchQueue.main.async {
                if let data = snapshot?.data() {
                    self.userProfile = data
                    let hasSetup = data["hasCompleted"] as? Bool ?? false
                    self.currentScreen = hasSetup ? .mainFeed : .profileSetup
                } else {
                    self.currentScreen = .profileSetup
                }
                self.isLoading = false
            }
        }
    }
    
    func logout() {
        try? Auth.auth().signOut()
    }
}
