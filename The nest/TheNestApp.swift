import SwiftUI
import FirebaseCore
import SwiftUI
import FirebaseCore

@main
struct TheNestApp: App {
    // 1. Create the AppState as the source of truth for navigation
    @StateObject var appState = AppState()
    
    // 2. Create the NotificationViewModel here so it persists across all tabs
    @StateObject var navNotifVM = NotificationViewModel()

    init() {
        FirebaseApp.configure()
    }

    var body: some Scene {
        WindowGroup {
            Group {
                if appState.isLoading {
                    SplashScreenView()
                } else {
                    switch appState.currentScreen {
                    case .signIn:
                        SignInView()
                            .environmentObject(appState)
                    
                    case .signUp:
                        SignUpView()
                            .environmentObject(appState)
                    
                    case .profileSetup:
                        CollaborativeProfileView()
                            .environmentObject(appState)
                    
                    case .mainFeed:
                        // 3. IMPORTANT: Switch this to MainTabView
                        // so users get all 4 tabs (Feed, Messages, Alerts, Profile)
                        MainTabView()
                            .environmentObject(appState)
                            .environmentObject(navNotifVM) // Injecting the missing piece
                    }
                }
            }
        }
    }
}

// Fixed SplashScreenView using the Ant mascot logic
struct SplashScreenView: View {
    var body: some View {
        VStack(spacing: 20) {
            Image("placeholder") // Your mascot
                .resizable()
                .scaledToFit()
                .frame(width: 80, height: 80)
            
            ProgressView()
                .tint(.accent)
            
            Text("The Nest")
                .font(.custom("Poppins-Bold", size: 24))
                .foregroundColor(.accent)
        }
    }
}
