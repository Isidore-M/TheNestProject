import SwiftUI
import FirebaseFirestore
import FirebaseAuth

struct CreatePostView: View {
    @Environment(\.dismiss) var dismiss
    @State private var title = ""
    @State private var description = ""
    @State private var isPosting = false
    @State private var errorMessage = ""
    
    // Available skills matching design document Page 15
    let availableSkills = [
        "Graphic Designer", "iOS Developer", "Android Developer",
        "UI|UX Designer", "Web Expert", "Illustrator"
    ]
    @State private var selectedSkills: Set<String> = []

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 25) {
                    // Header
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Create a post")
                            .font(.custom("Poppins-Bold", size: 28))
                        Text("Share your project idea with the community")
                            .font(.custom("Poppins-Regular", size: 14))
                            .foregroundColor(.secondary)
                    }
                    .padding(.top)

                    // Post Title Input
                    VStack(alignment: .leading, spacing: 10) {
                        Text("Post title")
                            .font(.custom("Poppins-Bold", size: 16))
                        TextField("What's the name of your project?", text: $title)
                            .padding()
                            .background(Color.gray.opacity(0.08))
                            .cornerRadius(12)
                            .font(.custom("Poppins-Regular", size: 15))
                    }
                    
                    // Description Input
                    VStack(alignment: .leading, spacing: 10) {
                        Text("Description")
                            .font(.custom("Poppins-Bold", size: 16))
                        ZStack(alignment: .topLeading) {
                            TextEditor(text: $description)
                                .frame(height: 160)
                                .padding(8)
                                .background(Color.gray.opacity(0.08))
                                .cornerRadius(12)
                                .font(.custom("Poppins-Regular", size: 15))
                            
                            if description.isEmpty {
                                Text("Describe your project goals and what you're looking for...")
                                    .font(.custom("Poppins-Regular", size: 15))
                                    .foregroundColor(.gray.opacity(0.5))
                                    .padding(.horizontal, 14)
                                    .padding(.vertical, 16)
                                    .allowsHitTesting(false)
                            }
                        }
                    }
                    
                    // Skills Selection
                    VStack(alignment: .leading, spacing: 12) {
                        Text("I'm interested in")
                            .font(.custom("Poppins-Bold", size: 16))
                        Spacer()
                        // Flexible grid for skills
                        FlowLayout(items: availableSkills) { skill in
                            SkillTag(
                                title: skill,
                                isSelected: selectedSkills.contains(skill),
                                action: {
                                    if selectedSkills.contains(skill) {
                                        selectedSkills.remove(skill)
                                    } else {
                                        selectedSkills.insert(skill)
                                    }
                                }
                            )
                        }
                    }
                    
                    if !errorMessage.isEmpty {
                        Text(errorMessage)
                            .foregroundColor(.red)
                            .font(.custom("Poppins-Medium", size: 13))
                    }
                    
                    // Share Button
                    Button(action: sharePost) {
                        if isPosting {
                            ProgressView().tint(.white)
                        } else {
                            Text("Share now")
                                .font(.custom("Poppins-Bold", size: 16))
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 16)
                                .background(title.isEmpty || description.isEmpty ? Color.gray.opacity(0.3) : Color.purple)
                                .foregroundColor(.white)
                                .cornerRadius(14)
                                .shadow(color: Color.purple.opacity(title.isEmpty ? 0 : 0.3), radius: 10, x: 0, y: 5)
                        }
                    }
                    .disabled(title.isEmpty || description.isEmpty || isPosting)
                    
                    // Footer
                    Text("the nest All right reserved 2025")
                        .font(.custom("Poppins-Regular", size: 10))
                        .foregroundColor(.gray.opacity(0.6))
                        .frame(maxWidth: .infinity, alignment: .center)
                        .padding(.vertical, 10)
                }
                .padding(.horizontal)
            }
            .background(Color.white)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                        .font(.custom("Poppins-Medium", size: 15))
                        .foregroundColor(.black)
                }
            }
        }
    }

    // MARK: - Firebase Logic
    func sharePost() {
        guard let user = Auth.auth().currentUser else { return }
        isPosting = true
        
        let db = Firestore.firestore()
        
        // 1. Fetch the user's name AND the new 'role' field
        db.collection("users").document(user.uid).getDocument { snapshot, error in
            let data = snapshot?.data()
            let userName = data?["name"] as? String ?? "User"
            let userRole = data?["role"] as? String ?? "Founder" // Pulling the new 'role' field
            
            let postData: [String: Any] = [
                "authorId": user.uid,
                "authorName": userName,
                "authorRole": userRole, // This is now saved with every post
                "title": title,
                "description": description,
                "skillsNeeded": Array(selectedSkills),
                "timestamp": FieldValue.serverTimestamp(),
                "interestedCount": 0,
                "likesCount": 0,
                "commentCount": 0
            ]
            
            db.collection("posts").addDocument(data: postData) { error in
                DispatchQueue.main.async {
                    self.isPosting = false
                    if let error = error {
                        self.errorMessage = error.localizedDescription
                    } else {
                        dismiss()
                    }
                }
            }
        }
    }
}

// MARK: - Helper UI Components

struct SkillTag: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.custom("Poppins-Medium", size: 13))
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(isSelected ? Color.purple : Color.gray.opacity(0.1))
                .foregroundColor(isSelected ? .white : .black.opacity(0.7))
                .cornerRadius(20)
        }
    }
}

// Simple FlowLayout for the skills tags
