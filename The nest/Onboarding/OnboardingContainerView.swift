import SwiftUI

struct OnboardingContainerView: View {
    @State private var currentStep = 0
    @EnvironmentObject var appState: AppState
    
    var body: some View {
        ZStack {
            // Background color logic
            backgroundColor.ignoresSafeArea()
            
            VStack(spacing: 0) {
                // 1. ILLUSTRATION AREA
                TabView(selection: $currentStep) {
                    OnboardingIllustration(imageName: "onboard1").tag(0)
                    OnboardingIllustration(imageName: "onboard2").tag(1)
                    OnboardingIllustration(imageName: "onboard3").tag(2)
                }
                .tabViewStyle(.page(indexDisplayMode: .never))
                .frame(maxHeight: .infinity)
                
                // 2. THE CONTENT CARD
                VStack(spacing: 30) {
                    // Progress Indicator
                    HStack(spacing: 8) {
                        ForEach(0..<3) { index in
                            RoundedRectangle(cornerRadius: 2)
                                .fill(currentStep == index ? Color.accentColor : Color.gray.opacity(0.2))
                                .frame(width: currentStep == index ? 40 : 20, height: 4)
                        }
                    }
                    .padding(.top, 40)
                    
                    // Text Content
                    VStack(spacing: 16) {
                        Text(onboardingTitles[currentStep])
                            .font(.custom("Poppins-Bold", size: 28))
                            .multilineTextAlignment(.center)
                        
                        Text(onboardingSubtitles[currentStep])
                            .font(.custom("Poppins-Regular", size: 16))
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 40)
                            .fixedSize(horizontal: false, vertical: true) // Prevents jumping
                    }
                    
                    Spacer()
                    
                    // Bottom Navigation
                    onboardingButtons
                        .padding(.bottom, 50)
                }
                .frame(maxWidth: .infinity)
                .frame(height: UIScreen.main.bounds.height * 0.45)
                .background(Color.white)
                .clipShape(CustomCorners(corners: [.topLeft, .topRight], radius: 60))
            }
            .ignoresSafeArea(edges: .bottom)
        }
    }
    
    private var onboardingButtons: some View {
        HStack {
            if currentStep < 2 {
                Button("Skip") {
                    withAnimation(.spring()) { currentStep = 2 }
                }
                .font(.custom("Poppins-Medium", size: 16))
                .foregroundColor(.black)
                .padding(.leading, 40)
                
                Spacer()
                
                Button(action: {
                    withAnimation(.spring()) { currentStep += 1 }
                }) {
                    Image(systemName: "arrow.right")
                        .font(.system(size: 20, weight: .bold))
                        .foregroundColor(.black)
                        .frame(width: 60, height: 60)
                        .background(Circle().stroke(Color.black, lineWidth: 2))
                }
                .padding(.trailing, 40)
            } else {
                // FIXED: This is the only place hasSeenOnboarding should ever change
                Button(action: {
                    appState.completeOnboarding()
                }) {
                    Text("Start Exploring")
                        .font(.custom("Poppins-Bold", size: 18))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 60)
                        .background(Color(red: 0.11, green: 0.11, blue: 0.11))
                        .cornerRadius(30)
                }
                .padding(.horizontal, 40)
                .transition(.opacity.combined(with: .scale))
            }
        }
    }
    
    // Background Colors from your designs
    private var backgroundColor: Color {
        switch currentStep {
        case 0: return Color(red: 0.93, green: 0.91, blue: 0.99)
        case 1: return Color(red: 0.88, green: 0.94, blue: 0.99)
        default: return Color(red: 0.94, green: 0.91, blue: 0.97)
        }
    }

    private let onboardingTitles = ["Welcome to the nest", "Discover Ideas & Collaborate", "Track & Grow Your Projects"]
    private let onboardingSubtitles = [
        "Connect, collaborate, and bring your ideas to life.",
        "Browse exciting projects and chat with collaborators.",
        "Follow your ideas and build amazing projects together."
    ]
}
