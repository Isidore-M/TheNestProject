import SwiftUI
import FirebaseAuth
import FirebaseFirestore

class AppState: ObservableObject {
    // 1. Updated Screen Enum to match the project navigation
    enum Screen {
        case signIn, signUp, profileSetup, home
    }
    
    // ONBOARDING PERSISTENCE
    @Published var hasSeenOnboarding: Bool {
        didSet {
            UserDefaults.standard.set(hasSeenOnboarding, forKey: "hasSeenOnboarding")
        }
    }
    
    @Published var currentScreen: Screen = .signIn
    @Published var currentUser: FirebaseAuth.User?
    @Published var userProfile: [String: Any]?
    @Published var isLoading = true
    
    // Project utilizes Firestore as the primary database [cite: 161, 162]
    private var db = Firestore.firestore()

    init() {
        self.hasSeenOnboarding = UserDefaults.standard.bool(forKey: "hasSeenOnboarding")
        setupAuthListener()
    }
    
    private func setupAuthListener() {
        // Firebase Auth listener for the "The nest" target [cite: 157]
        Auth.auth().addStateDidChangeListener { [weak self] _, user in
            guard let self = self else { return }
            
            DispatchQueue.main.async {
                self.currentUser = user
                
                if let user = user {
                    // Check if they've finished their profile setup
                    self.checkProfileStatus(uid: user.uid)
                } else {
                    self.currentScreen = .signIn
                    self.isLoading = false
                    self.userProfile = nil
                }
            }
        }
    }
    
    func checkProfileStatus(uid: String) {
        // Listening for profile changes in real-time
        db.collection("users").document(uid).addSnapshotListener { [weak self] snapshot, _ in
            guard let self = self else { return }
            
            DispatchQueue.main.async {
                if let data = snapshot?.data() {
                    self.userProfile = data
                    // Correcting the key to hasCompletedSetup to match your CollaborativeProfileView
                    let hasSetup = data["hasCompletedSetup"] as? Bool ?? false
                    
                    withAnimation {
                        self.currentScreen = hasSetup ? .home : .profileSetup
                    }
                } else {
                    // New user with no document yet
                    self.currentScreen = .profileSetup
                }
                self.isLoading = false
            }
        }
    }
    
    func logout() {
        try? Auth.auth().signOut()
    }
    
    func completeOnboarding() {
        withAnimation {
            self.hasSeenOnboarding = true
        }
    }
}
