import SwiftUI
import FirebaseAuth
import FirebaseFirestore

struct SignUpView: View {
    @EnvironmentObject var appState: AppState
    @State private var fullName = ""
    @State private var email = ""
    @State private var password = ""
    @State private var confirmPassword = ""
    @State private var errorMessage = ""
    @State private var isLoading = false

    var body: some View {
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
                Image("pp")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 120, height: 120)
                    .foregroundColor(.gray.opacity(0.3))
                    .padding(.vertical, 10)

                // Form Fields
                VStack(alignment: .leading, spacing: 16) {
                    InputField(label: "Names", placeholder: "First and last name", text: $fullName)
                    InputField(label: "Email", placeholder: "example@gmail.com", text: $email)
                    InputField(label: "Password", placeholder: "Password", text: $password, isSecure: true)
                    InputField(label: "Confirm password", placeholder: "Confirm password", text: $confirmPassword, isSecure: true)
                }
                .padding(.horizontal)

                if !errorMessage.isEmpty {
                    Text(errorMessage)
                        .foregroundColor(.red)
                        .font(.caption)
                        .padding(.horizontal)
                }

                // Action Section
                VStack(spacing: 20) {
                    Button(action: signUp) {
                        if isLoading {
                            ProgressView().tint(.white)
                        } else {
                            Text("Next")
                                .font(.headline)
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.black.opacity(0.9)) // Matches your dark "Next" button
                    .foregroundColor(.white)
                    .cornerRadius(30) // Rounded pill shape from design
                    .padding(.horizontal)
                    .disabled(isLoading)

                    HStack(spacing: 8) {
                        Text("Already have an account?")
                            .foregroundColor(.secondary)
                        Button("Sign in") {
                            appState.currentScreen = .signIn
                        }
                        .fontWeight(.bold)
                        .foregroundColor(.primary)
                    }
                    .font(.system(size: 14))
                }
                .padding(.top, 20)
            }
        }
        .background(Color(white: 0.98)) // Subtle off-white background
    }

    func signUp() {
        guard password == confirmPassword else {
            errorMessage = "Passwords do not match"
            return
        }
        
        isLoading = true
        Auth.auth().createUser(withEmail: email, password: password) { result, error in
            if let error = error {
                self.errorMessage = error.localizedDescription
                isLoading = false
                return
            }
            
            guard let uid = result?.user.uid else { return }
            
            let db = Firestore.firestore()
            db.collection("users").document(uid).setData([
                "fullName": fullName,
                "email": email,
                "hasCompletedSetup": false,
                "createdAt": Timestamp()
            ]) { _ in
                isLoading = false
            }
        }
    }
}

// Custom Reusable Input Field for consistency
struct InputField: View {
    let label: String
    let placeholder: String
    @Binding var text: String
    var isSecure: Bool = false

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(label)
                .font(.system(size: 14, weight: .medium))
            
            Group {
                if isSecure {
                    SecureField(placeholder, text: $text)
                } else {
                    TextField(placeholder, text: $text)
                }
            }
            .padding()
            .background(Color.white)
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(Color.gray.opacity(0.1), lineWidth: 1)
            )
        }
    }
}
