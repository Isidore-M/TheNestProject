import SwiftUI
import FirebaseAuth

struct ProfileDetailsView: View {
    @EnvironmentObject var appState: AppState
    @StateObject var statsVM = ProfileViewModel()
    @Environment(\.dismiss) var dismiss
    
    @State private var showEditProfile = false
    @State private var showLogoutAlert = false
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    
                    // --- 1. MASCOT HEADER ---
                    VStack(spacing: 12) {
                        let userName = appState.userProfile?["name"] as? String ?? "User"
                        AvatarView(name: userName, size: 90)
                            .shadow(color: .black.opacity(0.08), radius: 8, y: 4)
                        
                        VStack(spacing: 4) {
                            Text(userName).font(.custom("Poppins-Bold", size: 22))
                            Text(appState.userProfile?["role"] as? String ?? "Collaborator")
                                .font(.custom("Poppins-Medium", size: 14))
                                .foregroundColor(.accentColor)
                        }
                    }
                    .padding(.top, 10)
                    
                    // --- 2. IMPACT PROGRESS ---
                    ImpactProgressBar(score: statsVM.impactScore)
                    
                    // --- 3. DYNAMIC STATS (Uses StatItem below) ---
                    HStack(spacing: 0) {
                        StatItem(label: "Posts", value: "\(statsVM.postsCount)")
                        Divider().frame(height: 30)
                        StatItem(label: "Collabs", value: "\(statsVM.collabCount)")
                        Divider().frame(height: 30)
                        StatItem(label: "Impact", value: "\(statsVM.impactScore)")
                    }
                    .padding()
                    .background(Color.white)
                    .cornerRadius(15)
                    .shadow(color: .black.opacity(0.02), radius: 5)
                    .padding(.horizontal)

                    // --- 4. SETTINGS LIST (Uses ProfileSettingsRow below) ---
                    VStack(alignment: .leading, spacing: 10) {
                        Text("Settings")
                            .font(.custom("Poppins-Bold", size: 14))
                            .foregroundColor(.gray)
                            .padding(.leading, 20)
                        
                        VStack(spacing: 0) {
                            Button(action: { showEditProfile.toggle() }) {
                                ProfileSettingsRow(icon: "person.fill", title: "Edit Profile", color: .accentColor)
                            }
                            Divider().padding(.leading, 50)
                            ProfileSettingsRow(icon: "bell.fill", title: "Notifications", color: .orange)
                            Divider().padding(.leading, 50)
                            ProfileSettingsRow(icon: "shield.fill", title: "Security", color: .green)
                        }
                        .background(Color.white)
                        .cornerRadius(15)
                        .padding(.horizontal)
                    }

                    // --- 5. LOGOUT ---
                    Button(action: { showLogoutAlert = true }) {
                        Text("Log Out")
                            .font(.custom("Poppins-Bold", size: 16))
                            .foregroundColor(.red)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.red.opacity(0.05))
                            .cornerRadius(15)
                    }
                    .padding(.horizontal)
                }
                .padding(.bottom, 20)
            }
            .background(Color(UIColor.systemGroupedBackground))
            .navigationTitle("Your Profile")
            .onAppear { statsVM.fetchStats() }
            .sheet(isPresented: $showEditProfile) {
                EditProfileView().environmentObject(appState)
            }
            .alert("Log Out", isPresented: $showLogoutAlert) {
                Button("Cancel", role: .cancel) { }
                Button("Log Out", role: .destructive) {
                    try? Auth.auth().signOut()
                    appState.currentUser = nil
                    dismiss()
                }
            }
        }
    }
}

// MARK: - HELPER VIEWS (These fix your "In Scope" errors)

/// The small vertical blocks for Posts, Collabs, and Impact
struct StatItem: View {
    let label: String
    let value: String
    
    var body: some View {
        VStack(spacing: 4) {
            Text(value)
                .font(.custom("Poppins-Bold", size: 18))
            Text(label)
                .font(.custom("Poppins-Regular", size: 12))
                .foregroundColor(.gray)
        }
        .frame(maxWidth: .infinity)
    }
}

/// The individual rows in the Settings list
struct ProfileSettingsRow: View {
    let icon: String
    let title: String
    let color: Color
    
    var body: some View {
        HStack(spacing: 15) {
            ZStack {
                Circle()
                    .fill(color.opacity(0.1))
                    .frame(width: 35, height: 35)
                Image(systemName: icon)
                    .foregroundColor(color)
                    .font(.system(size: 14, weight: .bold))
            }
            
            Text(title)
                .font(.custom("Poppins-Medium", size: 15))
                .foregroundColor(.primary)
            
            Spacer()
            
            Image(systemName: "chevron.right")
                .font(.caption)
                .foregroundColor(.gray)
        }
        .padding()
    }
}
