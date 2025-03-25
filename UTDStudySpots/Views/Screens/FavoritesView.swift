import SwiftUI
import CoreLocation

struct FavoritesView: View {
    @EnvironmentObject var viewModel: StudySpotsViewModel
    @EnvironmentObject var locationService: LocationService
    
    var body: some View {
        NavigationView {
            ZStack {
                Color(.systemGroupedBackground)
                    .ignoresSafeArea()
                
                if viewModel.favoriteSpots.isEmpty {
                    EmptyStateView(
                        title: "No Favorites Yet",
                        message: "Tap the heart icon on any study spot to add it to your favorites for quick access.",
                        systemImage: "heart"
                    )
                } else {
                    ScrollView {
                        LazyVStack(spacing: 16) {
                            ForEach(viewModel.favoriteSpots) { spot in
                                NavigationLink(destination: SpotDetailView(spot: spot)) {
                                    SpotCardView(
                                        spot: spot,
                                        building: viewModel.buildingForSpot(spot) ?? Building.samples[0],
                                        onFavoriteToggle: { viewModel.toggleFavorite(for: $0) },
                                        distance: userDistanceToSpot(spot)
                                    )
                                }
                                .buttonStyle(PlainButtonStyle())
                                .contextMenu {
                                    Button(action: {
                                        viewModel.toggleFavorite(for: spot)
                                    }) {
                                        Label("Remove from Favorites", systemImage: "heart.slash")
                                    }
                                }
                            }
                        }
                        .padding()
                    }
                }
            }
            .navigationTitle("Favorites")
        }
    }
    
    // Calculate distance from user to spot if location is available
    private func userDistanceToSpot(_ spot: StudySpot) -> Double? {
        guard let userLocation = locationService.userLocation else {
            return nil
        }
        
        return viewModel.calculateDistance(
            from: userLocation.coordinate,
            to: spot
        )
    }
}

struct FavoritesView_Previews: PreviewProvider {
    static var previews: some View {
        FavoritesView()
            .environmentObject(StudySpotsViewModel())
            .environmentObject(LocationService())
    }
} 
