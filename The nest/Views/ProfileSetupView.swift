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
        NavigationStack {
            VStack(spacing: 20) {
                Text("Complete Profile")
                    .font(.custom("Poppins-Bold", size: 24))
                
                VStack(spacing: 12) {
                    TextField("Full Name", text: $name)
                        .font(.custom("Poppins-Regular", size: 15))
                        .textFieldStyle(.roundedBorder)
                    
                    TextField("Your Role (e.g. Designer)", text: $role)
                        .font(.custom("Poppins-Regular", size: 15))
                        .textFieldStyle(.roundedBorder)
                    
                    TextField("Portfolio Link (Optional)", text: $portfolioLink)
                        .font(.custom("Poppins-Regular", size: 15))
                        .textFieldStyle(.roundedBorder)
                        .autocapitalization(.none)
                        .keyboardType(.URL)
                }
                .padding()

                if !errorMessage.isEmpty {
                    Text(errorMessage).foregroundColor(.red).font(.custom("Poppins-Medium", size: 12))
                }

                Button(action: saveProfile) {
                    if isSaving {
                        ProgressView().tint(.white)
                    } else {
                        Text("Finish Setup")
                            .font(.custom("Poppins-Bold", size: 16))
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(name.isEmpty ? Color.gray : Color.accent)
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
        guard let user = Auth.auth().currentUser else { return }
        let uid = user.uid
        let email = user.email ?? "" // Auto-fetch email from Auth
        
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
                    self.appState.currentScreen = .mainFeed
                }
            }
        }
    }
}
