import SwiftUI

struct WelcomeView: View {
    @EnvironmentObject var viewModel: StudySpotsViewModel
    @State private var navigateToHome = false
    @State private var pulse = false
    
    var body: some View {
        ZStack {
            HeroBackground()
                .ignoresSafeArea()
            
            VStack(spacing: 28) {
                Spacer()
                
                // Logo badge
                ZStack {
                    Circle()
                        .fill(Color.white)
                        .frame(width: 140, height: 140)
                        .shadow(color: Color.black.opacity(0.12), radius: 16, x: 0, y: 8)
                    Image(systemName: "building.2")
                        .font(.system(size: 64, weight: .regular))
                        .foregroundStyle(LinearGradient(gradient: Gradient(colors: [Color.utdOrange, Color.utdGreen]), startPoint: .topLeading, endPoint: .bottomTrailing))
                }
                .scaleEffect(pulse ? 1.02 : 1.0)
                .animation(.easeInOut(duration: 1.8).repeatForever(autoreverses: true), value: pulse)
                
                // Title & subtitle
                VStack(spacing: 10) {
                    Text("Welcome to UTD Study Spots")
                        .font(.system(size: 28, weight: .bold, design: .rounded))
                        .foregroundColor(.black)
                    Text("Find quiet corners, group rooms, and directions across campus.")
                        .font(.system(size: 16, weight: .regular))
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 24)
                }
                
                // Feature chips
                HStack(spacing: 10) {
                    FeatureChip(title: "Quiet zones", icon: "speaker.slash")
                    FeatureChip(title: "Directions", icon: "figure.walk")
                    FeatureChip(title: "Favorites", icon: "heart.fill")
                }
                .padding(.top, 4)
                
                Spacer()
                
                // Primary CTA
                Button(action: {
                    let gen = UIImpactFeedbackGenerator(style: .medium)
                    gen.impactOccurred()
                    withAnimation(.easeInOut(duration: 0.4)) {
                        navigateToHome = true
                    }
                }) {
                    Text("Get Started")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.white)
                        .padding(.horizontal, 36)
                        .padding(.vertical, 14)
                        .background(Color.utdOrange)
                        .cornerRadius(28)
                        .shadow(color: Color.utdOrange.opacity(0.35), radius: 10, x: 0, y: 6)
                }
                .padding(.bottom, 40)
            }
        }
        .fullScreenCover(isPresented: $navigateToHome) {
            HomeView()
                .environmentObject(viewModel)
        }
        .onAppear { pulse = true }
    }
}

struct FeatureChip: View {
    let title: String
    let icon: String
    
    var body: some View {
        HStack(spacing: 6) {
            Image(systemName: icon)
                .font(.system(size: 12, weight: .semibold))
            Text(title)
                .font(.caption)
                .fontWeight(.semibold)
        }
        .foregroundColor(.primary)
        .padding(.horizontal, 10)
        .padding(.vertical, 6)
        .background(Color.gray.opacity(0.08))
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.gray.opacity(0.3), lineWidth: 1)
        )
        .cornerRadius(12)
    }
}

struct HeroBackground: View {
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

struct WelcomeView_Previews: PreviewProvider {
    static var previews: some View {
        WelcomeView()
            .environmentObject(StudySpotsViewModel())
    }
}
