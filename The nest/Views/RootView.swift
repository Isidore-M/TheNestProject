import SwiftUI

struct RootView: View {
    @EnvironmentObject var appState: AppState
    
    var body: some View {
        Group {
            if appState.isLoading {
                ProgressView("Loading The Nest...")
            } else {
                switch appState.currentScreen {
                case .mainFeed: DiscoveryFeedView()
                case .signIn: SignInView()
                case .signUp: SignUpView()
                case .profileSetup: ProfileSetupView()
               
                }
            }
        }
        .animation(.default, value: appState.currentScreen)
    }
}
