import SwiftUI

struct HomeView: View {
    @EnvironmentObject var viewModel: StudySpotsViewModel
    @EnvironmentObject var locationService: LocationService
    
    @State private var selectedTab = 0
    @State private var showLocationPermissionAlert = false
    
    var body: some View {
        TabView(selection: $selectedTab) {
            BuildingsListView()
                .tabItem {
                    Label("Buildings", systemImage: "building.2")
                }
                .tag(0)
            
            SpotListView()
                .tabItem {
                    Label("All Spots", systemImage: "list.bullet")
                }
                .tag(1)
            
            MapView()
                .tabItem {
                    Label("Map", systemImage: "map")
                }   
            
            FavoritesView()
                .tabItem {
                    Label("Favorites", systemImage: "heart")
                }
                .tag(3)
        }
        .accentColor(.utdOrange)
        .onAppear {
            checkLocationPermission()
            
            // Set the tab bar appearance
            let appearance = UITabBarAppearance()
            
            appearance.backgroundColor = UIColor(Color.utdGreen)
            appearance.stackedLayoutAppearance.selected.iconColor = UIColor(Color.utdOrange)
            appearance.stackedLayoutAppearance.selected.titleTextAttributes = [.foregroundColor: UIColor(Color.utdOrange)]
            appearance.stackedLayoutAppearance.normal.iconColor = UIColor.white
            appearance.stackedLayoutAppearance.normal.titleTextAttributes = [.foregroundColor: UIColor.white]
            
            UITabBar.appearance().standardAppearance = appearance
            UITabBar.appearance().scrollEdgeAppearance = appearance
        }
        .alert(isPresented: $showLocationPermissionAlert) {
            Alert(
                title: Text("Location Access Required"),
                message: Text(Constants.ErrorMessages.locationAccessDenied),
                primaryButton: .default(Text("Settings"), action: openSettings),
                secondaryButton: .cancel()
            )
        }
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

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView()
            .environmentObject(StudySpotsViewModel())
            .environmentObject(LocationService())
    }
} 
