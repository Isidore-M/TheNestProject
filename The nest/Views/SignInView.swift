import SwiftUI
import FirebaseAuth

struct SignInView: View {
    @EnvironmentObject var appState: AppState
    @State private var email = ""
    @State private var password = ""
    @State private var errorMessage = ""
    @State private var isLoggingIn = false

    var body: some View {
        ScrollView {
            VStack(spacing: 25) {
                // --- 1. HEADER ---
                VStack(spacing: 12) {
                    Text("Welcome back")
                        .font(.custom("Poppins-Bold", size: 32))
                    
                    Text("Let’s get you back to creating, sharing, and connecting with your community.")
                        .font(.custom("Poppins-Regular", size: 14))
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 30)
                }
                .padding(.top, 40)
                
                // --- 2. ILLUSTRATION ---
                // Ensure "login_illustration" is added to your Assets.xcassets
                Image("login")
                    .resizable()
                    .scaledToFit()
                    .frame(height: 200)
                
                // --- 3. FORM FIELDS ---
                VStack(alignment: .leading, spacing: 20) {
                    // Email Field
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Email")
                            .font(.custom("Poppins-Medium", size: 14))
                        TextField("example@gmail.com", text: $email)
                            .padding()
                            .background(Color.white)
                            .cornerRadius(12)
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(Color.gray.opacity(0.2), lineWidth: 1)
                            )
                            .textInputAutocapitalization(.never)
                            .keyboardType(.emailAddress)
                    }
                    
                    // Password Field
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Password")
                            .font(.custom("Poppins-Medium", size: 14))
                        SecureField("Password", text: $password)
                            .padding()
                            .background(Color.white)
                            .cornerRadius(12)
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(Color.gray.opacity(0.2), lineWidth: 1)
                            )
                        
                        Button("Forgot password?") { /* Action */ }
                            .font(.custom("Poppins-Medium", size: 14))
                            .foregroundColor(.accentColor)
                            .frame(maxWidth: .infinity, alignment: .trailing)
                    }
                }
                .padding(.horizontal, 25)

                // Error Message Display
                if !errorMessage.isEmpty {
                    Text(errorMessage)
                        .foregroundColor(.red)
                        .font(.custom("Poppins-Medium", size: 12))
                        .padding(.horizontal, 25)
                        .multilineTextAlignment(.center)
                }
                
                Spacer(minLength: 20)
                
                // --- 4. ACTION BUTTONS ---
                VStack(spacing: 20) {
                    Button(action: login) {
                        HStack {
                            if isLoggingIn {
                                ProgressView().tint(.white)
                            } else {
                                Text("Next")
                                    .font(.custom("Poppins-Bold", size: 18))
                            }
                        }
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 60)
                        .background(Color(red: 0.11, green: 0.11, blue: 0.11))
                        .cornerRadius(30)
                    }
                    .disabled(isLoggingIn)
                    
                    HStack {
                        Text("Don’t have an account yet?")
                            .font(.custom("Poppins-Regular", size: 14))
                            .foregroundColor(.secondary)
                        
                        Button("Sign Up") {
                            appState.currentScreen = .signUp
                        }
                        .font(.custom("Poppins-Bold", size: 14))
                        .foregroundColor(.accentColor)
                    }
                }
                .padding(.horizontal, 25)
                .padding(.bottom, 30)
            }
        }
        .background(Color.white.ignoresSafeArea())
    }

    // --- FIREBASE LOGIC ---
    func login() {
        guard !email.isEmpty && !password.isEmpty else {
            errorMessage = "Please enter both email and password."
            return
        }
        
        isLoggingIn = true
        errorMessage = ""
        
        Auth.auth().signIn(withEmail: email, password: password) { result, error in
            isLoggingIn = false
            if let error = error {
                self.errorMessage = error.localizedDescription
            }
            // AppState listener in your RootView will automatically switch
            // the screen to the Feed when result is successful.
        }
    }
}
