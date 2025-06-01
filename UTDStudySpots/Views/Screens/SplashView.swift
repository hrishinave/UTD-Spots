import SwiftUI

struct SplashView: View {
    @EnvironmentObject var viewModel: StudySpotsViewModel
    @State private var logoScale: CGFloat = 0.5
    @State private var logoOpacity: Double = 0.0
    @State private var titleOffset: CGFloat = 50
    @State private var titleOpacity: Double = 0.0
    @State private var showProgressBar = false
    @State private var showLoadingDots = false
    @State private var navigateToWelcome = false
    
    var body: some View {
        ZStack {
            // UTD Orange gradient background
            LinearGradient(
                gradient: Gradient(colors: [Color.utdOrange, Color.utdOrange.opacity(0.8)]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            VStack(spacing: 30) {
                Spacer()
                
                // UTD Logo placeholder (you can replace with actual logo)
                VStack(spacing: 20) {
                    Image(systemName: "building.columns.fill")
                        .font(.system(size: 80, weight: .light))
                        .foregroundColor(.white)
                        .scaleEffect(logoScale)
                        .opacity(logoOpacity)
                        .animation(.easeOut(duration: 1.0), value: logoScale)
                        .animation(.easeOut(duration: 1.0), value: logoOpacity)
                    
                    Text("UTD Study Spots")
                        .font(.system(size: 32, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                        .offset(y: titleOffset)
                        .opacity(titleOpacity)
                        .animation(.easeOut(duration: 0.8).delay(0.5), value: titleOffset)
                        .animation(.easeOut(duration: 0.8).delay(0.5), value: titleOpacity)
                }
                
                Spacer()
                
                // Loading section
                VStack(spacing: 20) {
                    if showProgressBar {
                        VStack(spacing: 12) {
                            Text(viewModel.loadingMessage)
                                .font(.system(size: 16, weight: .medium))
                                .foregroundColor(.white.opacity(0.9))
                                .transition(.opacity)
                            
                            ProgressView(value: viewModel.loadingProgress)
                                .progressViewStyle(LinearProgressViewStyle(tint: .white))
                                .scaleEffect(x: 1, y: 2, anchor: .center)
                                .frame(width: 200)
                                .transition(.scale.combined(with: .opacity))
                        }
                        .animation(.easeInOut(duration: 0.5), value: viewModel.loadingMessage)
                    }
                    
                    if showLoadingDots {
                        LoadingDotsView()
                            .transition(.opacity)
                    }
                }
                .frame(height: 80)
                
                Spacer()
            }
            .padding()
        }
        .onAppear {
            startAnimations()
            viewModel.loadData()
        }
        .onChange(of: viewModel.hasLoadedInitialData) { hasLoaded in
            if hasLoaded {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    withAnimation(.easeInOut(duration: 0.5)) {
                        navigateToWelcome = true
                    }
                }
            }
        }
        .fullScreenCover(isPresented: $navigateToWelcome) {
            WelcomeView()
                .environmentObject(viewModel)
        }
    }
    
    private func startAnimations() {
        // Logo animation
        withAnimation(.easeOut(duration: 1.0)) {
            logoScale = 1.0
            logoOpacity = 1.0
        }
        
        // Title animation
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            withAnimation(.easeOut(duration: 0.8)) {
                titleOffset = 0
                titleOpacity = 1.0
            }
        }
        
        // Progress bar animation
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            withAnimation(.easeInOut(duration: 0.5)) {
                showProgressBar = true
            }
        }
        
        // Loading dots animation
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            withAnimation(.easeInOut(duration: 0.3)) {
                showLoadingDots = true
            }
        }
    }
}

struct LoadingDotsView: View {
    @State private var animating = false
    
    var body: some View {
        HStack(spacing: 8) {
            ForEach(0..<3) { index in
                Circle()
                    .fill(Color.white.opacity(0.7))
                    .frame(width: 8, height: 8)
                    .scaleEffect(animating ? 1.0 : 0.5)
                    .animation(
                        .easeInOut(duration: 0.6)
                        .repeatForever()
                        .delay(Double(index) * 0.2),
                        value: animating
                    )
            }
        }
        .onAppear {
            animating = true
        }
    }
}

struct SplashView_Previews: PreviewProvider {
    static var previews: some View {
        SplashView()
            .environmentObject(StudySpotsViewModel())
    }
} 
