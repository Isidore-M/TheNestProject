import SwiftUI
import FirebaseCore
import FirebaseMessaging
import UserNotifications

// 1. GLOBAL DEFINITION: This fixes the "Cannot find type 'IdentifiableUser' in scope" error.
struct IdentifiableUser: Identifiable {
    let id: String
}

@main
struct TheNestApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    @StateObject var appState = AppState()
    @StateObject var navNotifVM = NotificationViewModel()

    var body: some Scene {
        WindowGroup {
            ZStack {
                if appState.isLoading {
                    SplashScreenView()
                } else {
                    currentView
                }
            }
            .sheet(item: Binding(
                get: { delegate.selectedUserID },
                set: { delegate.selectedUserID = $0 }
            )) { (user: IdentifiableUser) in
                // 2. INITIALIZER FIX: This fixes the "Missing arguments for parameters" error.
                // We pass empty strings or relevant IDs for notificationID and projectID if they aren't available yet.
                ProfilePreview(
                    userID: user.id,
                    notificationID: "",
                    projectID: ""
                )
                .environmentObject(appState)
            }
        }
    }

    @ViewBuilder
    private var currentView: some View {
        switch appState.currentScreen {
        case .signIn:
            SignInView().environmentObject(appState)
        case .signUp:
            SignUpView().environmentObject(appState)
        case .profileSetup:
            CollaborativeProfileView().environmentObject(appState)
        case .home:
            MainTabView()
                .environmentObject(appState)
                .environmentObject(navNotifVM)
        }
    }
}

// MARK: - App Delegate Definition
// Fixed: Ensured NSObject and UIApplicationDelegate conformance
class AppDelegate: NSObject, UIApplicationDelegate, UNUserNotificationCenterDelegate, MessagingDelegate, ObservableObject {
    @Published var selectedUserID: IdentifiableUser?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        FirebaseApp.configure() // Configures Firebase as per project settings [cite: 19, 25]
        
        UNUserNotificationCenter.current().delegate = self
        Messaging.messaging().delegate = self
        
        let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
        UNUserNotificationCenter.current().requestAuthorization(options: authOptions) { _, _ in }
        application.registerForRemoteNotifications()
        
        return true
    }

    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse) async {
        let userInfo = response.notification.request.content.userInfo
        
        if let userID = userInfo["targetUserID"] as? String {
            await MainActor.run {
                self.selectedUserID = IdentifiableUser(id: userID)
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
