import SwiftUI
import FirebaseAuth
import FirebaseFirestore

struct ProfileSetupView: View {
    @EnvironmentObject var appState: AppState
    @State private var name = ""
    @State private var role = ""
    @State private var portfolioLink = ""
    @State private var isSaving = false
    @State private var errorMessage = ""

    var body: some View {
        ZStack {
            // Background color matching your design
            Color(white: 0.98).ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: 24) {
                    // Header Section
                    VStack(spacing: 8) {
                        Text("Create a profile")
                            .font(.system(size: 28, weight: .bold))
                        Text("Tell us a bit about yourself")
                            .font(.system(size: 16))
                            .foregroundColor(.secondary)
                    }
                    .padding(.top, 40)

                    // Avatar Placeholder
                    Image(systemName: "person.crop.circle.fill")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 120, height: 120)
                        .foregroundColor(.gray.opacity(0.3))
                        .padding(.vertical, 10)

                    // Form Fields
                    VStack(alignment: .leading, spacing: 16) {
                        setupInputField(label: "Names", placeholder: "First and last name", text: $name)
                        setupInputField(label: "Your Role", placeholder: "e.g. Designer, Developer", text: $role)
                        setupInputField(label: "Portfolio Link", placeholder: "https://yourportfolio.com", text: $portfolioLink)
                    }
                    .padding(.horizontal)

                    if !errorMessage.isEmpty {
                        Text(errorMessage)
                            .foregroundColor(.red)
                            .font(.system(size: 14))
                            .padding(.horizontal)
                    }

                    // Action Button
                    Button(action: saveProfile) {
                        if isSaving {
                            ProgressView().tint(.white)
                        } else {
                            Text("Next")
                                .font(.headline)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(name.isEmpty ? Color.gray : Color.black.opacity(0.9))
                                .foregroundColor(.white)
                                .cornerRadius(30) // Pill shape from design
                        }
                    }
                    .padding(.horizontal)
                    .padding(.top, 20)
                    .disabled(name.isEmpty || isSaving)
                }
                .padding(.bottom, 30)
            }
        }
    }

    // Custom Input Field to match the image design
    @ViewBuilder
    func setupInputField(label: String, placeholder: String, text: Binding<String>) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(label)
                .font(.system(size: 14, weight: .medium))
            
            TextField(placeholder, text: text)
                .padding()
                .background(Color.white)
                .cornerRadius(12)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color.gray.opacity(0.1), lineWidth: 1)
                )
        }
    }

    func saveProfile() {
        guard let user = Auth.auth().currentUser else { return }
        let uid = user.uid
        let email = user.email ?? ""
        
        self.isSaving = true
        let db = Firestore.firestore()
        
        let profileData: [String: Any] = [
            "uid": uid,
            "name": name,
            "role": role,
            "email": email,
            "portfolioLink": portfolioLink,
            "hasCompletedSetup": true,
            "createdAt": FieldValue.serverTimestamp()
        ]
        
        db.collection("users").document(uid).setData(profileData) { error in
            DispatchQueue.main.async {
                self.isSaving = false
                if let error = error {
                    self.errorMessage = error.localizedDescription
                } else {
                    // FIX: Navigate to .home to match AppState.Screen
                    withAnimation {
                        self.appState.currentScreen = .home
                    }
                }
            }
        }
    }
}
