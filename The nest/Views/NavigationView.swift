//
//  NavigationView.swift
//  The nest
//
//  Created by Eezy Mongo on 2025-12-29.
//

struct MainFeedView: View {
    @EnvironmentObject var appState: AppState
    
    var body: some View {
        NavigationStack {
            VStack {
                Image(systemName: "bird.fill")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 60)
                    .foregroundColor(.blue)
                    .padding()
                
                Text("Welcome to The Nest")
                    .font(.headline)
                
                Text("No projects shared yet.")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            .navigationTitle("Feed")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Logout") {
                        appState.currentScreen = .signIn
                    }
                    .foregroundColor(.red)
                }
            }
        }
    }
}
