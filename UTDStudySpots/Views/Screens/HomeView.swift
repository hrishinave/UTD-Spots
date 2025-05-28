import SwiftUI

struct HomeView: View {
    @EnvironmentObject var viewModel: StudySpotsViewModel
    @EnvironmentObject var locationService: LocationService
    
    @State private var selectedTab = 0
    @State private var showLocationPermissionAlert = false
    
    var body: some View {
        NavigationView {
            TabView(selection: $selectedTab) {
                BuildingsListView()
                    .tabItem {
                        Image(systemName: selectedTab == 0 ? "building.2.fill" : "building.2")
                            .font(.system(size: 20, weight: .medium))
                        Text("Buildings")
                            .font(.caption)
                    }
                    .tag(0)
                
                SpotListView()
                    .tabItem {
                        Image(systemName: selectedTab == 1 ? "list.bullet" : "list.bullet")
                            .font(.system(size: 20, weight: .medium))
                        Text("All Spots")
                            .font(.caption)
                    }
                    .tag(1)
                
                MapView()
                    .tabItem {
                        Image(systemName: selectedTab == 2 ? "location.fill" : "location")
                            .font(.system(size: 20, weight: .medium))
                        Text("Map")
                            .font(.caption)
                    }
                    .tag(2)
                
                FavoritesView()
                    .tabItem {
                        Image(systemName: selectedTab == 3 ? "heart.fill" : "heart")
                            .font(.system(size: 20, weight: .medium))
                        Text("Favorites")
                            .font(.caption)
                    }
                    .tag(3)
            }
            .navigationBarHidden(true)
        }
        .navigationViewStyle(StackNavigationViewStyle())
        .onAppear {
            setupTabBarAppearance()
            checkLocationPermission()
        }
        .alert(isPresented: $showLocationPermissionAlert) {
            Alert(
                title: Text("Location Access Required"),
                message: Text("Location access is needed to show your position on the map and provide directions."),
                primaryButton: .default(Text("Settings"), action: openSettings),
                secondaryButton: .cancel()
            )
        }
    }
    
    private func setupTabBarAppearance() {
        let appearance = UITabBarAppearance()
        appearance.configureWithOpaqueBackground()
        
        // Set background color to white
        appearance.backgroundColor = UIColor.white
        
        // Remove any border/shadow
        appearance.shadowColor = UIColor.clear
        appearance.shadowImage = UIImage()
        
        // Configure unselected (normal) state - gray color
        appearance.stackedLayoutAppearance.normal.iconColor = UIColor.lightGray
        appearance.stackedLayoutAppearance.normal.titleTextAttributes = [
            .foregroundColor: UIColor.lightGray,
            .font: UIFont.systemFont(ofSize: 10, weight: .medium)
        ]
        
        // Configure selected state - dark color
        appearance.stackedLayoutAppearance.selected.iconColor = UIColor.black
        appearance.stackedLayoutAppearance.selected.titleTextAttributes = [
            .foregroundColor: UIColor.black,
            .font: UIFont.systemFont(ofSize: 10, weight: .medium)
        ]
        
        // Apply the appearance
        UITabBar.appearance().standardAppearance = appearance
        UITabBar.appearance().scrollEdgeAppearance = appearance
        
        // Set tint color for system-level selection
        UITabBar.appearance().tintColor = UIColor.black
        UITabBar.appearance().unselectedItemTintColor = UIColor.lightGray
    }
    
    private func checkLocationPermission() {
        if locationService.authorizationStatus == .denied || locationService.authorizationStatus == .restricted {
            showLocationPermissionAlert = true
        } else if locationService.authorizationStatus == .notDetermined {
            locationService.requestLocationAuthorization()
        }
    }
    
    private func openSettings() {
        if let url = URL(string: UIApplication.openSettingsURLString) {
            UIApplication.shared.open(url)
        }
    }
}

// Placeholder for Profile View
struct ProfileView: View {
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                Image(systemName: "person.circle.fill")
                    .font(.system(size: 100))
                    .foregroundColor(.gray.opacity(0.5))
                
                Text("Profile")
                    .font(.title)
                    .fontWeight(.bold)
                
                Text("Coming Soon")
                    .font(.subheadline)
                    .foregroundColor(.gray)
                
                Text("User profiles and settings will be available in a future update.")
                    .font(.body)
                    .foregroundColor(.gray)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 40)
            }
            .navigationTitle("Profile")
            .navigationBarHidden(true)
        }
    }
}

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        let viewModel = StudySpotsViewModel()
        viewModel.loadDataImmediately()
        
        return HomeView()
            .environmentObject(viewModel)
            .environmentObject(LocationService())
    }
} 
