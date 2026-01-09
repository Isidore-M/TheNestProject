import SwiftUI
import FirebaseFirestore
import FirebaseAuth

struct CollaborativeProfileView: View {
    @EnvironmentObject var appState: AppState
    
    @State private var name = ""
    @State private var role = ""
    @State private var isSaving = false
    @State private var errorMessage = ""
    
    let roles = ["Graphic Designer", "iOS Developer", "Android Developer", "UI|UX Designer", "Web Expert", "Illustrator"]
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 30) {
                // Header
                VStack(spacing: 8) {
                    Text("Set your collaborative profile")
                        .font(.custom("Poppins-Bold", size: 24))
                        .multilineTextAlignment(.center)
                    
                    Text("This information will be shown on your project cards")
                        .font(.custom("Poppins-Regular", size: 14))
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                }
                .padding(.top, 20)
                
                // Simplified Avatar (No Upload needed)
                Circle()
                    .fill(Color.purple.opacity(0.1))
                    .frame(width: 120, height: 120)
                    .overlay(
                        Text(name.isEmpty ? "?" : String(name.prefix(1)).uppercased())
                            .font(.custom("Poppins-Bold", size: 40))
                            .foregroundColor(.purple)
                    )
                
                // Form Fields
                VStack(alignment: .leading, spacing: 20) {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Full Name")
                            .font(.custom("Poppins-Bold", size: 16))
                        TextField("Enter your name", text: $name)
                            .padding()
                            .background(Color.gray.opacity(0.1))
                            .cornerRadius(12)
                    }
                    
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Your Role")
                            .font(.custom("Poppins-Bold", size: 16))
                        
                        Menu {
                            ForEach(roles, id: \.self) { r in
                                Button(r) { self.role = r }
                            }
                        } label: {
                            HStack {
                                Text(role.isEmpty ? "Select your primary skill" : role)
                                    .foregroundColor(role.isEmpty ? .gray : .black)
                                Spacer()
                                Image(systemName: "chevron.down")
                            }
                            .padding()
                            .background(Color.gray.opacity(0.1))
                            .cornerRadius(12)
                        }
                    }
                }
                
                if !errorMessage.isEmpty {
                    Text(errorMessage)
                        .font(.caption)
                        .foregroundColor(.red)
                }
                
                Spacer()
                
                // Save Button
                Button(action: saveProfileToFirestore) {
                    if isSaving {
                        ProgressView().tint(.white)
                    } else {
                        Text("Finish Setup")
                            .font(.custom("Poppins-Bold", size: 16))
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(name.isEmpty || role.isEmpty ? Color.gray : Color.purple)
                            .foregroundColor(.white)
                            .cornerRadius(15)
                    }
                }
                .disabled(name.isEmpty || role.isEmpty || isSaving)
            }
            .padding(25)
        }
    }
    
    // NEW SIMPLIFIED SAVE LOGIC
    func saveProfileToFirestore() {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        isSaving = true
        errorMessage = ""
        
        let db = Firestore.firestore()
        
        let userData: [String: Any] = [
            "name": name,
            "role": role,
            "hasCompleted": true, // This triggers the AppState switch
            "uid": uid,
            "profileImageUrl": "" // Leaving this empty as we aren't using Storage
        ]
        
        db.collection("users").document(uid).setData(userData, merge: true) { error in
            DispatchQueue.main.async {
                self.isSaving = false
                if let error = error {
                    self.errorMessage = error.localizedDescription
                }
                // AppState.swift is listening and will change the screen automatically
            }
        }
    }
}
