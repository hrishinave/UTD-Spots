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
            HomeView()
                .environmentObject(viewModel)
                .environmentObject(locationService)
        }
    }
    
    private func setupAppearance() {
        // Set up navigation bar appearance
        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = .systemBackground
        appearance.titleTextAttributes = [.foregroundColor: UIColor.label]
        appearance.largeTitleTextAttributes = [.foregroundColor: UIColor.label]
        
        UINavigationBar.appearance().standardAppearance = appearance
        UINavigationBar.appearance().compactAppearance = appearance
        UINavigationBar.appearance().scrollEdgeAppearance = appearance
        
        // Set the tint color for interactive elements
        UIView.appearance().tintColor = UIColor(named: "UTDOrange") ?? .systemBlue
    }
}