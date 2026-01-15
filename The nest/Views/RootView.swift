import SwiftUI

struct RootView: View {
    @EnvironmentObject var appState: AppState
    
    var body: some View {
        // Wrapping in a ZStack or similar container with the @ViewBuilder logic
        ZStack {
            content
        }
        // Transitions using the values from your AppState logic [cite: 118, 124]
        .animation(.easeInOut, value: appState.currentScreen)
        .animation(.easeInOut, value: appState.hasSeenOnboarding)
    }

    // Using @ViewBuilder resolves the 'Generic parameter V' error by
    // allowing the switch to return different view types properly.
    @ViewBuilder
    private var content: some View {
        if appState.isLoading {
            // Initial launch loading state [cite: 105]
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
            // PRIORITY 2: Handle standard screen navigation based on your AppState Enum
            switch appState.currentScreen {
            case .home: // UPDATED: Changed from .mainFeed to match your AppState
                MainTabView()
            case .signIn:
                SignInView()
            case .signUp:
                SignUpView()
            case .profileSetup:
                ProfileSetupView()
            }
        }
    }
}
