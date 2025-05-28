import SwiftUI

struct SplashView: View {
    @State private var logoScale: CGFloat = 0.5
    @State private var logoOpacity: Double = 0.0
    @State private var titleOffset: CGFloat = 50
    @State private var titleOpacity: Double = 0.0
    @State private var loadingDotsOpacity: Double = 0.0
    @State private var showMainContent = false
    
    @EnvironmentObject var viewModel: StudySpotsViewModel
    
    var body: some View {
        if showMainContent {
            HomeView()
                .transition(.opacity.combined(with: .scale))
        } else {
            ZStack {
                // Background gradient
                LinearGradient(
                    gradient: Gradient(colors: [
                        Color.utdOrange.opacity(0.1),
                        Color.utdGreen.opacity(0.1),
                        Color.white
                    ]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
                
                VStack(spacing: 40) {
                    Spacer()
                    
                    // Logo Section
                    VStack(spacing: 20) {
                        // UTD Logo placeholder (you can replace with actual logo)
                        ZStack {
                            Circle()
                                .fill(Color.utdOrange)
                                .frame(width: 120, height: 120)
                                .scaleEffect(logoScale)
                                .opacity(logoOpacity)
                            
                            Image(systemName: "building.2.fill")
                                .font(.system(size: 50, weight: .bold))
                                .foregroundColor(.white)
                                .scaleEffect(logoScale)
                                .opacity(logoOpacity)
                        }
                        
                        // App Title
                        VStack(spacing: 8) {
                            Text("UTD Study Spots")
                                .font(.title)
                                .fontWeight(.bold)
                                .foregroundColor(.utdOrange)
                                .offset(y: titleOffset)
                                .opacity(titleOpacity)
                            
                            Text("Find Your Perfect Study Space")
                                .font(.subheadline)
                                .foregroundColor(.utdGreen)
                                .offset(y: titleOffset)
                                .opacity(titleOpacity)
                        }
                    }
                    
                    Spacer()
                    
                    // Loading Section
                    VStack(spacing: 20) {
                        // Loading Progress Bar
                        VStack(spacing: 12) {
                            HStack {
                                Text(viewModel.loadingMessage)
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                    .animation(.easeInOut(duration: 0.3), value: viewModel.loadingMessage)
                                Spacer()
                                Text("\(Int(viewModel.loadingProgress * 100))%")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                            
                            // Progress Bar
                            GeometryReader { geometry in
                                ZStack(alignment: .leading) {
                                    Rectangle()
                                        .fill(Color.gray.opacity(0.2))
                                        .frame(height: 4)
                                        .cornerRadius(2)
                                    
                                    Rectangle()
                                        .fill(LinearGradient(
                                            gradient: Gradient(colors: [Color.utdOrange, Color.utdGreen]),
                                            startPoint: .leading,
                                            endPoint: .trailing
                                        ))
                                        .frame(width: geometry.size.width * viewModel.loadingProgress, height: 4)
                                        .cornerRadius(2)
                                        .animation(.easeInOut(duration: 0.3), value: viewModel.loadingProgress)
                                }
                            }
                            .frame(height: 4)
                        }
                        .opacity(loadingDotsOpacity)
                        
                        // Loading Dots Animation
                        HStack(spacing: 8) {
                            ForEach(0..<3) { index in
                                Circle()
                                    .fill(Color.utdOrange)
                                    .frame(width: 8, height: 8)
                                    .scaleEffect(loadingDotsOpacity > 0 ? 1.0 : 0.5)
                                    .animation(
                                        .easeInOut(duration: 0.6)
                                        .repeatForever(autoreverses: true)
                                        .delay(Double(index) * 0.2),
                                        value: loadingDotsOpacity
                                    )
                            }
                        }
                        .opacity(loadingDotsOpacity)
                    }
                    .padding(.horizontal, 40)
                    .padding(.bottom, 60)
                }
            }
            .onAppear {
                startAnimations()
            }
            .onChange(of: viewModel.hasLoadedInitialData) { hasLoaded in
                if hasLoaded {
                    // Wait a moment to show completion, then transition
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                        withAnimation(.easeInOut(duration: 0.8)) {
                            showMainContent = true
                        }
                    }
                }
            }
        }
    }
    
    private func startAnimations() {
        // Logo animation
        withAnimation(.spring(response: 0.8, dampingFraction: 0.6)) {
            logoScale = 1.0
            logoOpacity = 1.0
        }
        
        // Title animation (delayed)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            withAnimation(.easeOut(duration: 0.6)) {
                titleOffset = 0
                titleOpacity = 1.0
            }
        }
        
        // Loading animation (delayed)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
            withAnimation(.easeIn(duration: 0.4)) {
                loadingDotsOpacity = 1.0
            }
            
            // Start actual data loading
            viewModel.loadData()
        }
    }
}

struct SplashView_Previews: PreviewProvider {
    static var previews: some View {
        SplashView()
            .environmentObject(StudySpotsViewModel())
            .environmentObject(LocationService())
    }
} 
