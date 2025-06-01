import SwiftUI

struct WelcomeView: View {
    @EnvironmentObject var viewModel: StudySpotsViewModel
    @State private var currentPage = 0
    @State private var navigateToHome = false
    
    private let pages = [
        OnboardingPage(
            icon: "building.2.fill",
            title: "Welcome to UTD Study Spots",
            description: "Discover the perfect study spaces across the University of Texas at Dallas campus.",
            color: .utdOrange
        ),
        OnboardingPage(
            icon: "magnifyingglass",
            title: "Find Your Perfect Spot",
            description: "Search and filter study spots by building, features, and availability to match your study needs.",
            color: .utdGreen
        ),
        OnboardingPage(
            icon: "heart.fill",
            title: "Save Your Favorites",
            description: "Mark your favorite study spots and access them quickly whenever you need them.",
            color: .utdOrange
        ),
        OnboardingPage(
            icon: "location.fill",
            title: "Navigate with Ease",
            description: "Get directions to any study spot and see real-time availability and hours.",
            color: .utdGreen
        )
    ]
    
    var body: some View {
        ZStack {
            // Background gradient
            LinearGradient(
                gradient: Gradient(colors: [
                    pages[currentPage].color.opacity(0.1),
                    Color.white
                ]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Page content
                TabView(selection: $currentPage) {
                    ForEach(0..<pages.count, id: \.self) { index in
                        OnboardingPageView(page: pages[index])
                            .tag(index)
                    }
                }
                .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
                .animation(.easeInOut, value: currentPage)
                
                // Bottom section with indicators and button
                VStack(spacing: 30) {
                    // Page indicators
                    HStack(spacing: 12) {
                        ForEach(0..<pages.count, id: \.self) { index in
                            Circle()
                                .fill(index == currentPage ? pages[currentPage].color : Color.gray.opacity(0.3))
                                .frame(width: 10, height: 10)
                                .scaleEffect(index == currentPage ? 1.2 : 1.0)
                                .animation(.easeInOut(duration: 0.3), value: currentPage)
                        }
                    }
                    
                    // Navigation buttons
                    HStack(spacing: 20) {
                        if currentPage > 0 {
                            Button("Back") {
                                withAnimation(.easeInOut(duration: 0.3)) {
                                    currentPage -= 1
                                }
                            }
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(pages[currentPage].color)
                            .padding(.horizontal, 24)
                            .padding(.vertical, 12)
                            .background(pages[currentPage].color.opacity(0.1))
                            .cornerRadius(25)
                        } else {
                            Spacer()
                        }
                        
                        Spacer()
                        
                        Button(currentPage == pages.count - 1 ? "Get Started" : "Next") {
                            if currentPage == pages.count - 1 {
                                // Navigate to main app
                                withAnimation(.easeInOut(duration: 0.5)) {
                                    navigateToHome = true
                                }
                            } else {
                                withAnimation(.easeInOut(duration: 0.3)) {
                                    currentPage += 1
                                }
                            }
                        }
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.white)
                        .padding(.horizontal, 32)
                        .padding(.vertical, 12)
                        .background(pages[currentPage].color)
                        .cornerRadius(25)
                        .shadow(color: pages[currentPage].color.opacity(0.3), radius: 8, x: 0, y: 4)
                    }
                    .padding(.horizontal, 30)
                }
                .padding(.bottom, 50)
            }
        }
        .fullScreenCover(isPresented: $navigateToHome) {
            HomeView()
                .environmentObject(viewModel)
        }
    }
}

struct OnboardingPage {
    let icon: String
    let title: String
    let description: String
    let color: Color
}

struct OnboardingPageView: View {
    let page: OnboardingPage
    @State private var iconScale: CGFloat = 0.8
    @State private var iconOpacity: Double = 0.0
    @State private var textOffset: CGFloat = 30
    @State private var textOpacity: Double = 0.0
    
    var body: some View {
        VStack(spacing: 40) {
            Spacer()
            
            // Icon
            Image(systemName: page.icon)
                .font(.system(size: 80, weight: .light))
                .foregroundColor(page.color)
                .scaleEffect(iconScale)
                .opacity(iconOpacity)
                .onAppear {
                    withAnimation(.spring(response: 0.8, dampingFraction: 0.6).delay(0.2)) {
                        iconScale = 1.0
                        iconOpacity = 1.0
                    }
                }
            
            // Text content
            VStack(spacing: 20) {
                Text(page.title)
                    .font(.system(size: 28, weight: .bold, design: .rounded))
                    .foregroundColor(.primary)
                    .multilineTextAlignment(.center)
                    .offset(y: textOffset)
                    .opacity(textOpacity)
                    .onAppear {
                        withAnimation(.easeOut(duration: 0.8).delay(0.4)) {
                            textOffset = 0
                            textOpacity = 1.0
                        }
                    }
                
                Text(page.description)
                    .font(.system(size: 18, weight: .regular))
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .lineLimit(nil)
                    .offset(y: textOffset)
                    .opacity(textOpacity)
                    .onAppear {
                        withAnimation(.easeOut(duration: 0.8).delay(0.6)) {
                            textOffset = 0
                            textOpacity = 1.0
                        }
                    }
            }
            .padding(.horizontal, 40)
            
            Spacer()
            Spacer()
        }
    }
}

struct WelcomeView_Previews: PreviewProvider {
    static var previews: some View {
        WelcomeView()
            .environmentObject(StudySpotsViewModel())
    }
} 
