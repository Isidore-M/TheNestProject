import SwiftUI
import FirebaseFirestore

struct TeamListView: View {
    @EnvironmentObject var appState: AppState
    @State private var adminTeams: [ProjectTeam] = []
    @State private var memberTeams: [ProjectTeam] = []
    @State private var isLoading = true

    var body: some View {
        List {
            // SECTION 1: PROJECTS YOU LEAD
            if !adminTeams.isEmpty {
                Section(header: Text("Projects I Lead").font(.custom("Poppins-Bold", size: 12))) {
                    ForEach(adminTeams) { teamItem in
                        // FIXED: Using 'team:' label and 'ProjectTeam' type
                        TeamListRow(team: teamItem)
                    }
                }
            }
            
            // SECTION 2: PROJECTS YOU JOINED
            if !memberTeams.isEmpty {
                Section(header: Text("Collaborations").font(.custom("Poppins-Bold", size: 12))) {
                    ForEach(memberTeams) { teamItem in
                        // FIXED: Using 'team:' label and 'ProjectTeam' type
                        TeamListRow(team: teamItem)
                    }
                }
            }
            
            if adminTeams.isEmpty && memberTeams.isEmpty && !isLoading {
                emptyState
            }
        }
        .navigationTitle("My Teams")
        .listStyle(.insetGrouped)
        .onAppear { fetchMyTeams() }
    }

    private func fetchMyTeams() {
        guard let uid = appState.currentUser?.uid else { return }
        let db = Firestore.firestore()
        
        // Listen for Admin Teams
        db.collection("projects")
            .whereField("authorId", isEqualTo: uid)
            .addSnapshotListener { snap, _ in
                self.adminTeams = snap?.documents.compactMap { try? $0.data(as: ProjectTeam.self) } ?? []
                self.isLoading = false
            }
        
        // Listen for Member Teams
        db.collection("projects")
            .whereField("members", arrayContains: uid)
            .addSnapshotListener { snap, _ in
                self.memberTeams = snap?.documents.compactMap { try? $0.data(as: ProjectTeam.self) } ?? []
                self.isLoading = false
            }
    }
    
    private var emptyState: some View {
        VStack(spacing: 20) {
            Image(systemName: "person.3.sequence.fill")
                .font(.system(size: 50))
                .foregroundColor(.gray.opacity(0.3))
            Text("No active teams yet.")
                .font(.custom("Poppins-Medium", size: 14))
                .foregroundColor(.gray)
        }
        .frame(maxWidth: .infinity)
        .padding(.top, 50)
        .listRowBackground(Color.clear)
    }
}
