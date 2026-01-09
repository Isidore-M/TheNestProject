import SwiftUI
import FirebaseFirestore
import FirebaseAuth

struct TeamsView: View {
    @Environment(\.dismiss) var dismiss
    @State private var teams = [ProjectTeam]()
    @State private var selectedTeam: ProjectTeam? = nil
    
    var body: some View {
        VStack(spacing: 0) {
            // Header (Source 179)
            HStack {
                Button(action: { dismiss() }) {
                    Image(systemName: "arrow.left").foregroundColor(.black)
                }
                Spacer()
                Text("Teams").font(.custom("Poppins-Bold", size: 20))
                Spacer()
                Image(systemName: "arrow.left").opacity(0)
            }
            .padding()
            
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    if teams.isEmpty {
                        Text("No active teams found.")
                            .font(.custom("Poppins-Medium", size: 14))
                            .foregroundColor(.gray)
                            .padding(.top, 40)
                    } else {
                        ForEach(teams) { team in
                            Button(action: { selectedTeam = team }) {
                                // This now references the external file
                                TeamListRow(team: team)
                            }
                            .buttonStyle(PlainButtonStyle())
                        }
                    }
                }
                .padding()
            }
        }
        .onAppear(perform: fetchTeams)
        .background(Color(white: 0.98))
    }
    
    func fetchTeams() {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        Firestore.firestore().collection("projects")
            .whereField("members", arrayContains: uid)
            .addSnapshotListener { snap, _ in
                self.teams = snap?.documents.compactMap { try? $0.data(as: ProjectTeam.self) } ?? []
            }
    }
}
