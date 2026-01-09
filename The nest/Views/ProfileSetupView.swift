import SwiftUI
import FirebaseAuth
import FirebaseFirestore

struct ProfileSetupView: View {
    @EnvironmentObject var appState: AppState
    @State private var name = ""
    @State private var nindo = ""
    @State private var bio = ""
    @State private var isSaving = false
    @State private var errorMessage = ""

    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                Text("Complete Profile")
                    .font(.custom("Poppins-Bold", size: 24))
                
                VStack(spacing: 12) {
                    TextField("Full Name", text: $name)
                        .textFieldStyle(.roundedBorder)
                    TextField("Your Role (e.g. Designer)", text: $nindo)
                        .textFieldStyle(.roundedBorder)
                    TextEditor(text: $bio)
                        .frame(height: 100)
                        .overlay(RoundedRectangle(cornerRadius: 8).stroke(Color.gray.opacity(0.2)))
                }
                .padding()

                if !errorMessage.isEmpty {
                    Text(errorMessage).foregroundColor(.red).font(.caption)
                }

                Button(action: saveProfile) {
                    if isSaving {
                        ProgressView().tint(.white)
                    } else {
                        Text("Finish Setup")
                            .bold()
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(name.isEmpty ? Color.gray : Color.purple)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                    }
                }
                .disabled(name.isEmpty || isSaving)
                .padding()
            }
        }
    }

    func saveProfile() {
        // 1. Get the UID directly from the source of truth
        guard let user = Auth.auth().currentUser else {
            print("DEBUG: No user is actually logged in")
            return
        }
        
        let uid = user.uid
        let db = Firestore.firestore()
        
        self.isSaving = true
        
        // 2. Simplest possible data set to test the connection
        let testData: [String: Any] = [
            "uid": uid,
            "name": name,
            "hasCompletedSetup": true
        ]
        
        // 3. FORCE the path to 'users/UID'
        // Ensure "users" is lowercase here and in your Firebase Console
        db.collection("users").document(uid).setData(testData) { error in
            DispatchQueue.main.async {
                self.isSaving = false
                if let error = error {
                    print("DEBUG: Permission Error: \(error.localizedDescription)")
                    self.errorMessage = error.localizedDescription
                } else {
                    print("DEBUG: Success! Connection established.")
                    self.appState.currentScreen = .mainFeed
                }
            }
        }
    }
}
