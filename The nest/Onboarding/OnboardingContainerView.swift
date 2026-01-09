//
//  OnboardingContainerView.swift
//  The nest
//
//  Created by Eezy Mongo on 2026-01-09.
//

import Foundation
import SwiftUI

struct OnboardingContainerView: View {
    @State private var currentStep = 0
    @EnvironmentObject var appState: AppState
    
    var body: some View {
        ZStack {
            // Background color matches the illustration backgrounds
            backgroundColor.ignoresSafeArea()
            
            VStack(spacing: 0) {
                // 1. Illustration Area
                TabView(selection: $currentStep) {
                    OnboardingIllustration(imageName: "onboard1").tag(0)
                    OnboardingIllustration(imageName: "onboard2").tag(1)
                    OnboardingIllustration(imageName: "onboard3").tag(2)
                }
                .tabViewStyle(.page(indexDisplayMode: .never))
                .frame(maxHeight: .infinity)
                
                // 2. The Content Card
                VStack(spacing: 30) {
                    // Progress Indicator (The three bars)
                    HStack(spacing: 8) {
                        ForEach(0..<3) { index in
                            RoundedRectangle(cornerRadius: 2)
                                .fill(currentStep == index ? Color.accentColor : Color.gray.opacity(0.2))
                                .frame(width: currentStep == index ? 40 : 20, height: 4)
                                .animation(.spring(), value: currentStep)
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
    
    // MARK: - Components
    
    private var onboardingButtons: some View {
        HStack {
            if currentStep < 2 {
                Button("Skip") {
                    withAnimation { currentStep = 2 }
                }
                .font(.custom("Poppins-Medium", size: 16))
                .foregroundColor(.black)
                .padding(.leading, 40)
                
                Spacer()
                
                Button(action: {
                    withAnimation { currentStep += 1 }
                }) {
                    Image(systemName: "arrow.right")
                        .font(.system(size: 20, weight: .bold))
                        .foregroundColor(.black)
                        .frame(width: 60, height: 60)
                        .background(Circle().stroke(Color.black, lineWidth: 2))
                }
                .padding(.trailing, 40)
            } else {
                // Final Screen "Start Exploring"
                Button(action: {
                    // Logic to move to login or home
                }) {
                    Text("Start Exploring")
                        .font(.custom("Poppins-Bold", size: 18))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 60)
                        .background(Color(red: 0.1, green: 0.1, blue: 0.1)) // Dark gray from design
                        .cornerRadius(30)
                }
                .padding(.horizontal, 40)
            }
        }
    }
    
    // MARK: - Data
    private var backgroundColor: Color {
        switch currentStep {
        case 0: return Color(red: 0.85, green: 0.82, blue: 0.95) // Light Purple
        case 1: return Color(red: 0.75, green: 0.88, blue: 0.95) // Light Blue
        default: return Color(red: 0.94, green: 0.88, blue: 0.98) // Soft Lavender
        }
    }
    
    private let onboardingTitles = [
        "Welcome to the nest",
        "Discover Ideas & Collaborate",
        "Track & Grow Your Projects"
    ]
    
    private let onboardingSubtitles = [
        "Connect, collaborate, and bring your ideas to life. Find people with the skills and passion to join your projects.",
        "Browse exciting projects, express interest, and chat with potential collaborators.",
        "Follow your ideas, celebrate progress, and build amazing projects together."
    ]
}
