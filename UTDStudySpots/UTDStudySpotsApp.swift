import SwiftUI

@main
struct UTDStudySpotsApp: App {
    // Create our environment objects as StateObjects so they persist
    @StateObject private var viewModel = StudySpotsViewModel()
    @StateObject private var locationService = LocationService()
    
    init() {
        setupAppearance()
    }
    
    var body: some Scene {
        WindowGroup {
            SplashView()
                .environmentObject(viewModel)
                .environmentObject(locationService)
        }
    }
    
    private func setupAppearance() {
        // Force light mode interface style
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene {
            windowScene.windows.forEach { window in
                window.overrideUserInterfaceStyle = .light
            }
        }
        
        // Set up navigation bar appearance with fixed light colors
        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = UIColor.white  // Fixed white background
        appearance.titleTextAttributes = [.foregroundColor: UIColor.black]  // Fixed black text
        appearance.largeTitleTextAttributes = [.foregroundColor: UIColor.black]  // Fixed black text
        
        UINavigationBar.appearance().standardAppearance = appearance
        UINavigationBar.appearance().compactAppearance = appearance
        UINavigationBar.appearance().scrollEdgeAppearance = appearance
        
        // Set the tint color for interactive elements
        let utdOrange = UIColor(red: 199/255, green: 91/255, blue: 18/255, alpha: 1.0)
        UIView.appearance().tintColor = utdOrange
    }
}
