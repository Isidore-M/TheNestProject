import SwiftUI
import FirebaseAuth
import FirebaseFirestore

class AppState: ObservableObject {
    enum Screen {
        case signIn, signUp, profileSetup, mainFeed
    }
    
    // 1. ONBOARDING PERSISTENCE
    @Published var hasSeenOnboarding: Bool {
        didSet {
            UserDefaults.standard.set(hasSeenOnboarding, forKey: "hasSeenOnboarding")
        }
    }
    
    @Published var currentScreen: Screen = .signIn
    @Published var currentUser: FirebaseAuth.User?
    @Published var userProfile: [String: Any]?
    @Published var isLoading = true
    
    private var db = Firestore.firestore()

    init() {
        // Load onboarding status from storage (defaults to false)
        self.hasSeenOnboarding = UserDefaults.standard.bool(forKey: "hasSeenOnboarding")
        
        setupAuthListener()
    }
    
    private func setupAuthListener() {
        Auth.auth().addStateDidChangeListener { [weak self] _, user in
            guard let self = self else { return }
            
            DispatchQueue.main.async {
                self.currentUser = user
                
                if let user = user {
                    // If logged in, check if they've finished their profile
                    self.checkProfileStatus(uid: user.uid)
                } else {
                    // If logged out, reset to sign in
                    self.currentScreen = .signIn
                    self.isLoading = false
                    self.userProfile = nil
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
    
    // Call this from the "Start Exploring" button in OnboardingContainerView
    func completeOnboarding() {
        withAnimation {
            self.hasSeenOnboarding = true
        }
    }
}
