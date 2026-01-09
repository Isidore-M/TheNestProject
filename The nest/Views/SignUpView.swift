import SwiftUI
import FirebaseAuth
import FirebaseFirestore

struct SignUpView: View {
    @EnvironmentObject var appState: AppState
    @State private var email = ""
    @State private var password = ""
    @State private var errorMessage = ""

    var body: some View {
        VStack(spacing: 20) {
            Text("Join The Nest")
                .font(.title.bold())

            VStack(spacing: 15) {
                TextField("Email", text: $email)
                    .textFieldStyle(.roundedBorder)
                    .autocapitalization(.none)
                SecureField("Password", text: $password)
                    .textFieldStyle(.roundedBorder)
            }
            .padding(.horizontal)

            if !errorMessage.isEmpty {
                Text(errorMessage).foregroundColor(.red).font(.caption)
            }

            Button(action: signUp) {
                Text("Create Account")
                    .bold()
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }
            .padding(.horizontal)

            Button("Already have an account? Login") {
                appState.currentScreen = .signIn
            }
        }
    }

    func signUp() {
        Auth.auth().createUser(withEmail: email, password: password) { result, error in
            if let error = error {
                self.errorMessage = error.localizedDescription
                return
            }
            
            guard let uid = result?.user.uid else { return }
            
            // CREATE INITIAL DOCUMENT
            let db = Firestore.firestore()
            db.collection("users").document(uid).setData([
                "email": email,
                "hasCompletedSetup": false, // This forces them to ProfileSetupView
                "createdAt": Timestamp()
            ])
        }
    }
}
