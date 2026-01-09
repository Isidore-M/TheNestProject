///// OnboardingView.swift
//import SwiftUI
//
//struct OnboardingView: View {
//    @State private var currentPage = 0
//    @Binding var didFinishOnboarding: Bool
//    
//    var body: some View {
//        ZStack {
//            onboardingPages[currentPage].backgroundColor.ignoresSafeArea().animation(.easeInOut, value: currentPage)
//            
//            VStack(spacing: 0) {
//                TabView(selection: $currentPage) {
//                    ForEach(0..<onboardingPages.count, id: \.self) { index in
//                        Image(onboardingPages[index].image).resizable().scaledToFill().tag(index).padding(.top, 50).transition(.opacity)
//                    }
//                }
//                .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
//                
//                VStack(spacing: 25) {
//                    Text(onboardingPages[currentPage].title).font(.title).bold()
//                    Text(onboardingPages[currentPage].description).font(.body).foregroundColor(.gray).multilineTextAlignment(.center).padding(.horizontal, 30)
//                    
//                    buttonSection(for: currentPage).padding(.horizontal, 40).padding(.bottom, 25)
//                    OnboardingIndicator(currentPage: currentPage, totalPages: onboardingPages.count)
//                }
//                .padding(.top, 30)
//                .background(RoundedRectangle(cornerRadius: 30).fill(Color.white).ignoresSafeArea(edges: .bottom).shadow(radius: 5))
//            }
//        }
//    }
//
//    @ViewBuilder
//    func buttonSection(for index: Int) -> some View {
//        HStack {
//            if index == 0 {
//                Button("Skip") { DispatchQueue.main.async { withAnimation { didFinishOnboarding = true } } }
//                .foregroundColor(.gray)
//                Spacer()
//                Button(action: { currentPage += 1 }) { Image(systemName: "arrow.right").frame(width: 44, height: 44).background(Circle().stroke(Color.black, lineWidth: 1.5)) }
//            } else if index == onboardingPages.count - 1 {
//                Spacer()
//                Button("Start Exploring") { DispatchQueue.main.async { withAnimation { didFinishOnboarding = true } } }
//                .fontWeight(.semibold).padding().frame(maxWidth: .infinity).background(Color.black).foregroundColor(.white).cornerRadius(12)
//            } else {
//                Spacer()
//                Button(action: { currentPage += 1 }) { Image(systemName: "arrow.right").frame(width: 44, height: 44).background(Circle().stroke(Color.black, lineWidth: 1.5)) }
//            }
//        }
//    }
//}
//#Preview {
//    // ⚠️ FIX: Pass a constant binding to satisfy the requirement of the OnboardingView
//    OnboardingView(didFinishOnboarding: .constant(false))
//}
