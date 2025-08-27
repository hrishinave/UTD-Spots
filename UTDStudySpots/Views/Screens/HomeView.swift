import SwiftUI

struct HomeView: View {
    @EnvironmentObject var viewModel: StudySpotsViewModel
    @EnvironmentObject var locationService: LocationService
    
    @State private var selectedTab = 0
    @State private var showLocationPermissionAlert = false
    
    var body: some View {
        NavigationStack {
            ZStack(alignment: .bottom) {
                Group {
                    switch selectedTab {
                    case 0:
                        BuildingsListView()
                    case 1:
                        SpotListView()
                    case 2:
                        MapView()
                    case 3:
                        FavoritesView()
                    default:
                        BuildingsListView()
                    }
                }
                
                CustomTabBar(selectedTab: $selectedTab)
                    .padding(.horizontal, 16)
                    .padding(.bottom, 8)
            }
            .navigationBarHidden(true)
            .navigationDestination(for: StudySpot.self) { spot in
                SpotDetailView(spot: spot)
            }
            .navigationDestination(for: Building.self) { building in
                BuildingDetailView(building: building)
            }
        }
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
        
        // Configure selected state - UTD orange color
        let utdOrangeColor = UIColor(red: 199/255, green: 91/255, blue: 18/255, alpha: 1.0) // UTD Orange from Colors.swift
        appearance.stackedLayoutAppearance.selected.iconColor = utdOrangeColor
        appearance.stackedLayoutAppearance.selected.titleTextAttributes = [
            .foregroundColor: utdOrangeColor,
            .font: UIFont.systemFont(ofSize: 10, weight: .medium)
        ]
        
        // Apply the appearance
        UITabBar.appearance().standardAppearance = appearance
        UITabBar.appearance().scrollEdgeAppearance = appearance
        
        // Set tint color for system-level selection
        UITabBar.appearance().tintColor = utdOrangeColor
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

// MARK: - Custom Tab Bar with Bubble Icons

struct CustomTabBar: View {
    @Binding var selectedTab: Int
    
    var body: some View {
        HStack(spacing: 24) {
            TabBarButton(
                title: "Buildings",
                systemImage: selectedTab == 0 ? "building.2.fill" : "building.2",
                isSelected: selectedTab == 0
            ) { selectedTab = 0 }
            
            TabBarButton(
                title: "All Spots",
                systemImage: "list.bullet",
                isSelected: selectedTab == 1
            ) { selectedTab = 1 }
            
            TabBarButton(
                title: "Map",
                systemImage: selectedTab == 2 ? "location.fill" : "location",
                isSelected: selectedTab == 2
            ) { selectedTab = 2 }
            
            TabBarButton(
                title: "Favorites",
                systemImage: selectedTab == 3 ? "heart.fill" : "heart",
                isSelected: selectedTab == 3
            ) { selectedTab = 3 }
        }
        .padding(.vertical, 10)
        .padding(.horizontal, 16)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color(.systemBackground))
                .shadow(color: Color.black.opacity(0.08), radius: 8, x: 0, y: 2)
        )
    }
}

struct TabBarButton: View {
    let title: String
    let systemImage: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: {
            let generator = UIImpactFeedbackGenerator(style: .light)
            generator.impactOccurred()
            action()
        }) {
            VStack(spacing: 6) {
                BubbleIcon(systemImage: systemImage, isSelected: isSelected)
                Text(title)
                    .font(.caption2)
                    .foregroundColor(isSelected ? .utdOrange : .gray)
            }
            .frame(maxWidth: .infinity)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct BubbleIcon: View {
    let systemImage: String
    let isSelected: Bool
    
    var body: some View {
        Image(systemName: systemImage)
            .font(.system(size: 18, weight: .semibold))
            .foregroundColor(isSelected ? .utdOrange : Color.gray)
            .padding(.vertical, 8)
            .padding(.horizontal, 10)
            .background(
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .fill(Color.gray.opacity(0.08))
                    .overlay(
                        RoundedRectangle(cornerRadius: 12, style: .continuous)
                            .stroke(isSelected ? Color.utdOrange : Color.gray.opacity(0.3), lineWidth: 1.2)
                    )
            )
            .scaleEffect(isSelected ? 1.08 : 1.0)
            .animation(.spring(response: 0.35, dampingFraction: 0.75), value: isSelected)
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
