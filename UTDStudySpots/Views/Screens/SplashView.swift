import SwiftUI

struct SplashView: View {
    @EnvironmentObject var viewModel: StudySpotsViewModel
    @State private var navigateToWelcome = false
    @State private var startAnimations = false
    @State private var ringRotation: Double = 0
    @State private var pulse = false
    @State private var showReveal = false
    @State private var revealScale: CGFloat = 0.01
    
    var body: some View {
        ZStack {
            SplashAnimatedBackground()
                .ignoresSafeArea()
            
            // Particles
            ParticleField(isAnimating: startAnimations)
                .allowsHitTesting(false)
            
            VStack(spacing: 24) {
                Spacer()
                
                ZStack {
                    // Pulse rings
                    PulseRingsView(isAnimating: pulse)
                        .frame(width: 220, height: 220)
                        .opacity(0.9)
                    
                    // Badge + rotating ring + progress ring
                    ZStack {
                        // Progress ring
                        CircularProgressRing(progress: viewModel.loadingProgress)
                            .frame(width: 160, height: 160)
                            .opacity(0.9)
                        
                        // Rotating outer ring
                        RotatingRing()
                            .frame(width: 180, height: 180)
                            .rotationEffect(.degrees(ringRotation))
                            .opacity(0.9)
                        
                        // Logo badge
                        LogoBadgeView()
                    }
                }
                
                VStack(spacing: 8) {
                    Text("UTD Study Spots")
                        .font(.system(size: 30, weight: .bold, design: .rounded))
                        .foregroundColor(.black)
                        .shadow(color: Color.black.opacity(0.06), radius: 6, x: 0, y: 3)
                    
                    Text(viewModel.loadingMessage)
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.secondary)
                        .transition(.opacity)
                }
                .padding(.top, 4)
                
                Spacer()
                Text("Loading campus data…")
                    .font(.footnote)
                    .foregroundColor(.secondary)
                    .padding(.bottom, 40)
            }
            .padding()
            
            // Reveal transition overlay
            if showReveal {
                Circle()
                    .fill(Color.white)
                    .frame(width: 10, height: 10)
                    .scaleEffect(revealScale)
                    .ignoresSafeArea()
                    .animation(.easeInOut(duration: 0.5), value: revealScale)
            }
        }
        .onAppear {
            start()
            viewModel.loadData()
        }
        .onChange(of: viewModel.hasLoadedInitialData) { hasLoaded in
            if hasLoaded {
                // Circular reveal into onboarding
                showReveal = true
                withAnimation(.easeInOut(duration: 0.6)) {
                    revealScale = 200
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.65) {
                    navigateToWelcome = true
                    showReveal = false
                    revealScale = 0.01
                }
            }
        }
        .fullScreenCover(isPresented: $navigateToWelcome) {
            WelcomeView()
                .environmentObject(viewModel)
        }
    }
    
    private func start() {
        startAnimations = true
        pulse = true
        withAnimation(.linear(duration: 6.0).repeatForever(autoreverses: false)) {
            ringRotation = 360
        }
    }
}

// MARK: - Components

struct SplashAnimatedBackground: View {
    @State private var animate = false
    var body: some View {
        ZStack {
            LinearGradient(
                gradient: Gradient(colors: [Color.white, Color.utdOrange.opacity(0.12)]),
                startPoint: animate ? .topTrailing : .topLeading,
                endPoint: animate ? .bottomLeading : .bottomTrailing
            )
            .animation(.easeInOut(duration: 7.0).repeatForever(autoreverses: true), value: animate)
            Circle().fill(Color.utdOrange.opacity(0.08)).frame(width: 320, height: 320).blur(radius: 50).offset(x: animate ? -90 : 70, y: -120).animation(.easeInOut(duration: 10).repeatForever(autoreverses: true), value: animate)
            Circle().fill(Color.utdGreen.opacity(0.06)).frame(width: 380, height: 380).blur(radius: 60).offset(x: animate ? 80 : -70, y: 120).animation(.easeInOut(duration: 9).repeatForever(autoreverses: true), value: animate)
        }
        .onAppear { animate = true }
    }
}

struct LogoBadgeView: View {
    var body: some View {
        ZStack {
            Circle()
                .fill(Color.white)
                .frame(width: 140, height: 140)
                .shadow(color: Color.black.opacity(0.12), radius: 16, x: 0, y: 8)
            Image(systemName: "building.columns")
                .font(.system(size: 60, weight: .regular))
                .foregroundStyle(LinearGradient(gradient: Gradient(colors: [Color.utdOrange, Color.utdGreen]), startPoint: .topLeading, endPoint: .bottomTrailing))
        }
    }
}

struct RotatingRing: View {
    var body: some View {
        Circle()
            .trim(from: 0.0, to: 1.0)
            .stroke(AngularGradient(gradient: Gradient(colors: [Color.utdOrange, Color.utdGreen, Color.utdOrange]), center: .center), style: StrokeStyle(lineWidth: 6, lineCap: .round))
            .blur(radius: 0.2)
    }
}

struct CircularProgressRing: View {
    let progress: Double
    var body: some View {
        ZStack {
            Circle()
                .stroke(Color.gray.opacity(0.15), lineWidth: 10)
            Circle()
                .trim(from: 0, to: CGFloat(max(0.03, min(1.0, progress))))
                .stroke(LinearGradient(gradient: Gradient(colors: [Color.utdOrange, Color.utdGreen]), startPoint: .leading, endPoint: .trailing), style: StrokeStyle(lineWidth: 10, lineCap: .round))
                .rotationEffect(.degrees(-90))
                .animation(.easeInOut(duration: 0.6), value: progress)
        }
    }
}

struct PulseRingsView: View {
    let isAnimating: Bool
    @State private var anim = false
    var body: some View {
        ZStack {
            ForEach(0..<3) { i in
                Circle()
                    .stroke(Color.utdOrange.opacity(0.25 - Double(i) * 0.06), lineWidth: 2)
                    .scaleEffect(anim ? 1.6 + CGFloat(i) * 0.08 : 1.0)
                    .opacity(anim ? 0.0 : 1.0)
                    .animation(.easeOut(duration: 2.2).repeatForever().delay(Double(i) * 0.4), value: anim)
            }
        }
        .onAppear { if isAnimating { anim = true } }
    }
}

struct ParticleField: View {
    let isAnimating: Bool
    @State private var t: CGFloat = 0
    var body: some View {
        GeometryReader { proxy in
            ZStack {
                ForEach(0..<20) { idx in
                    let phase = t + CGFloat(idx) * 0.2
                    Circle()
                        .fill(Color.white.opacity(0.2))
                        .frame(width: 3, height: 3)
                        .offset(x: sin(phase) * 80, y: cos(phase * 0.8) * 120)
                        .position(x: proxy.size.width / 2, y: proxy.size.height / 2)
                        .blur(radius: 0.2)
                }
            }
            .onAppear {
                guard isAnimating else { return }
                withAnimation(.linear(duration: 10).repeatForever(autoreverses: false)) {
                    t = 6.28
                }
            }
        }
    }
}

struct SplashView_Previews: PreviewProvider {
    static var previews: some View {
        SplashView()
            .environmentObject(StudySpotsViewModel())
    }
} 
