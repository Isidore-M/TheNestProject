import SwiftUI
import FirebaseFirestore
import FirebaseAuth

struct CollaborativeProfileView: View {
    @EnvironmentObject var appState: AppState
    
    // State variables aligned with design fields
    @State private var bio = ""
    @State private var skills = ""
    @State private var interests = ""
    @State private var portfolioLink = ""
    
    @State private var isSaving = false
    @State private var errorMessage = ""
    
    // Placeholder options for the dropdowns
    let skillsOptions = ["Designer", "Web developer", "Illustrator", "iOS Developer"]
    let interestsOptions = ["Mobile development", "Web design", "Music", "AI"]

    var body: some View {
        ZStack {
            // Background color from design
            Color(white: 0.96).ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: 30) {
                    // Header
                    VStack(spacing: 12) {
                        Text("Set your collaborative profile")
                            .font(.system(size: 28, weight: .bold))
                            .multilineTextAlignment(.center)
                        
                        Text("Tell others about your skills and passions\nto find the right collaborators")
                            .font(.system(size: 16))
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                    }
                    .padding(.top, 50)
                    .padding(.bottom, 30)
                    
                    Spacer()
                    
                    // Form Fields
                    VStack(alignment: .leading, spacing: 20) {
                        
                        // Bio Field (Large Text Area)
                        VStack(alignment: .leading, spacing: 10) {
                            Text("A Short Bio about Yourself")
                                .font(.system(size: 16, weight: .medium))
                            
                            TextEditor(text: $bio)
                                .padding(12)
                                .frame(height: 120)
                                .background(Color.white)
                                .cornerRadius(15)
                                .overlay(
                                    ZStack(alignment: .topLeading) {
                                        if bio.isEmpty {
                                            Text("Tell us more about your collaborative\nprofile and your passions")
                                                .foregroundColor(.gray.opacity(0.5))
                                                .padding(.horizontal, 16)
                                                .padding(.vertical, 20)
                                        }
                                    }
                                )
                        }

                        // Skills Dropdown
                        customDropdown(label: "Your Skills", selection: $skills, placeholder: "Designer, Web developper, Illustrator...", options: skillsOptions)
                        
                        // Interests Dropdown
                        customDropdown(label: "You are interested in", selection: $interests, placeholder: "Mobile development, web design, Music...", options: interestsOptions)
                        
                        // Portfolio Link - CHANGED TO SIMPLE INPUT
                        VStack(alignment: .leading, spacing: 10) {
                            Text("Portfolio link")
                                .font(.system(size: 16, weight: .medium))
                            
                            TextField("https://yourportfolio.com", text: $portfolioLink)
                                .padding()
                                .background(Color.white)
                                .cornerRadius(15)
                                .autocapitalization(.none)
                                .keyboardType(.URL)
                                .font(.system(size: 14))
                        }
                    }
                    .padding(.horizontal, 20)
                    
                    if !errorMessage.isEmpty {
                        Text(errorMessage)
                            .font(.caption)
                            .foregroundColor(.red)
                    }
                    
                    // Action Button
                    Button(action: saveProfileToFirestore) {
                        if isSaving {
                            ProgressView().tint(.white)
                        } else {
                            Text("Start Exploring")
                                .font(.system(size: 18, weight: .bold))
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 18)
                                .background(Color.black.opacity(0.9))
                                .foregroundColor(.white)
                                .clipShape(Capsule())
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 10)
                    .padding(.bottom, 30)
                }
            }
        }
        .navigationBarHidden(true)
    }
    
    // Custom Dropdown UI to match image_9d2d23.png
    func customDropdown(label: String, selection: Binding<String>, placeholder: String, options: [String]) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(label)
                .font(.system(size: 16, weight: .medium))
            
            Menu {
                ForEach(options, id: \.self) { option in
                    Button(option) { selection.wrappedValue = option }
                }
            } label: {
                HStack {
                    if selection.wrappedValue.isEmpty {
                        Text(placeholder)
                            .foregroundColor(.gray.opacity(0.5))
                            .lineLimit(1)
                    } else {
                        Text(selection.wrappedValue)
                            .foregroundColor(.primary)
                    }
                    Spacer()
                    Image(systemName: "chevron.down")
                        .foregroundColor(.gray)
                        .font(.system(size: 14, weight: .bold))
                }
                .padding()
                .background(Color.white)
                .cornerRadius(15)
            }
        }
    }

    func saveProfileToFirestore() {
        guard let user = Auth.auth().currentUser else { return }
        isSaving = true
        let db = Firestore.firestore()
        
        let userData: [String: Any] = [
            "bio": bio,
            "skills": skills,
            "interests": interests,
            "portfolioLink": portfolioLink,
            "hasCompletedSetup": true,
            "updatedAt": Timestamp()
        ]
        
        db.collection("users").document(user.uid).setData(userData, merge: true) { error in
            DispatchQueue.main.async {
                self.isSaving = false
                if let error = error {
                    self.errorMessage = error.localizedDescription
                } else {
                    withAnimation {
                        // Corrected to use .home based on your AppState update
                        appState.currentScreen = .home
                    }
                }
            }
        }
    }
}
