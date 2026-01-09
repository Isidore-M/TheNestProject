import SwiftUI
import FirebaseAuth

struct SignInView: View {
    @EnvironmentObject var appState: AppState
    @State private var email = ""
    @State private var password = ""
    @State private var errorMessage = ""

    var body: some View {
        VStack(spacing: 20) {
            Text("The Nest")
                .font(.largeTitle.bold())
            
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

            Button(action: login) {
                Text("Sign In")
                    .bold()
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.black)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }
            .padding(.horizontal)

            Button("New here? Create an account") {
                appState.currentScreen = .signUp
            }
            .font(.footnote)
        }
    }

    func login() {
        Auth.auth().signIn(withEmail: email, password: password) { result, error in
            if let error = error {
                self.errorMessage = error.localizedDescription
            }
            // AppState listener handles the screen switch automatically
        }
    }
}
