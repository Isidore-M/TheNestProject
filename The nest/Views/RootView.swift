import SwiftUI


struct RootView: View {
    @EnvironmentObject var appState: AppState
    
    var body: some View {
        Group {
            if appState.isLoading {
                // Initial launch loading state
                VStack(spacing: 20) {
                    ProgressView()
                        .tint(.accentColor)
                    Text("Gathering the colony...")
                        .font(.custom("Poppins-Medium", size: 14))
                        .foregroundColor(.gray)
                }
            } else if !appState.hasSeenOnboarding {
                // PRIORITY 1: Show Onboarding if it's the first time
                OnboardingContainerView()
            } else {
                // PRIORITY 2: Handle standard screen navigation
                switch appState.currentScreen {
                case .mainFeed:
                    MainTabView() // Assuming you have a TabView wrapper for the feed
                case .signIn:
                    SignInView()
                case .signUp:
                    SignUpView()
                case .profileSetup:
                    ProfileSetupView()
                }
            }
        }
        // Smooth transition between login/signup/feed
        .animation(.easeInOut, value: appState.currentScreen)
        // Smooth transition for onboarding
        .animation(.easeInOut, value: appState.hasSeenOnboarding)
    }
}
