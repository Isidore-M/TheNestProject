//
//  CollaborativeProfileView 2.swift
//  The nest
//
//  Created by Eezy Mongo on 2026-01-09.
//


import SwiftUI
import FirebaseFirestore
import FirebaseAuth

struct CollaborativeProfileView: View {
    @EnvironmentObject var appState: AppState
    
    @State private var name = ""
    @State private var role = ""
    @State private var portfolioLink = ""
    @State private var isSaving = false
    @State private var errorMessage = ""
    
    let roles = ["Graphic Designer", "iOS Developer", "Android Developer", "UI|UX Designer", "Web Expert", "Illustrator"]
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 30) {
                    // Header
                    VStack(spacing: 8) {
                        Text("Set your collaborative profile")
                            .font(.custom("Poppins-Bold", size: 24))
                        Text("This information will be shown on your project cards")
                            .font(.custom("Poppins-Regular", size: 14))
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                    }
                    .padding(.top, 20)
                    
                    // Avatar Placeholder
                    Circle()
                        .fill(Color.accent.opacity(0.1))
                        .frame(width: 100, height: 100)
                        .overlay(
                            Text(name.isEmpty ? "?" : String(name.prefix(1)).uppercased())
                                .font(.custom("Poppins-Bold", size: 36))
                                .foregroundColor(.accent)
                        )
                    
                    // Form Fields
                    VStack(alignment: .leading, spacing: 20) {
                        customTextField(label: "Full Name", placeholder: "Enter your name", text: $name)
                        
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
                                        .foregroundColor(role.isEmpty ? .gray : .primary)
                                    Spacer()
                                    Image(systemName: "chevron.down")
                                }
                                .padding()
                                .background(Color.gray.opacity(0.1))
                                .cornerRadius(12)
                            }
                        }
                        
                        customTextField(label: "Portfolio Link", placeholder: "https://yourportfolio.com", text: $portfolioLink)
                            .keyboardType(.URL)
                            .autocapitalization(.none)
                    }
                    
                    if !errorMessage.isEmpty {
                        Text(errorMessage).font(.caption).foregroundColor(.red)
                    }
                    
                    Button(action: saveProfileToFirestore) {
                        if isSaving {
                            ProgressView().tint(.white)
                        } else {
                            Text("Finish Setup")
                                .font(.custom("Poppins-Bold", size: 16))
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(name.isEmpty || role.isEmpty ? Color.gray : Color.accent)
                                .foregroundColor(.white)
                                .cornerRadius(15)
                        }
                    }
                    .disabled(name.isEmpty || role.isEmpty || isSaving)
                }
                .padding(25)
            }
        }
    }
    
    func customTextField(label: String, placeholder: String, text: Binding<String>) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(label).font(.custom("Poppins-Bold", size: 16))
            TextField(placeholder, text: text)
                .padding()
                .background(Color.gray.opacity(0.1))
                .cornerRadius(12)
                .font(.custom("Poppins-Regular", size: 15))
        }
    }

    func saveProfileToFirestore() {
        guard let user = Auth.auth().currentUser else { return }
        isSaving = true
        let db = Firestore.firestore()
        
        let userData: [String: Any] = [
            "name": name,
            "role": role,
            "email": user.email ?? "",
            "portfolioLink": portfolioLink,
            "hasCompleted": true,
            "uid": user.uid
        ]
        
        db.collection("users").document(user.uid).setData(userData, merge: true) { error in
            DispatchQueue.main.async {
                self.isSaving = false
                if let error = error {
                    self.errorMessage = error.localizedDescription
                }
            }
        }
    }
}
