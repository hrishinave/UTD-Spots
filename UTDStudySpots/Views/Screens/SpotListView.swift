import SwiftUI
import CoreLocation

struct SpotListView: View {
    @EnvironmentObject var viewModel: StudySpotsViewModel
    @EnvironmentObject var locationService: LocationService
    @State private var showFilters = false
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Custom Search Bar
                HStack {
                    HStack {
                        Image(systemName: "magnifyingglass")
                            .foregroundColor(.gray)
                            .font(.system(size: 16))
                        
                        TextField("Search study spots...", text: $viewModel.searchText)
                            .font(.system(size: 16))
                    }
                    .padding(.horizontal, 12)
                    .padding(.vertical, 10)
                    .background(Color(.systemBackground))
                    .overlay(
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(Color(.systemGray4), lineWidth: 1)
                    )
                    .cornerRadius(10)
                }
                .padding(.horizontal, 16)
                .padding(.top, 8)
                .padding(.bottom, 12)
                .background(Color(.systemGroupedBackground))
                
                // Main Content
                ZStack {
                    Color(.systemGroupedBackground)
                        .ignoresSafeArea()
                    
                    if viewModel.isLoading {
                        ProgressView("Loading study spots...")
                            .tint(.utdOrange)
                    } else if viewModel.studySpots.isEmpty {
                        EmptyStateView(
                            title: "No study spots found",
                            message: "Try adjusting your filters or search term",
                            systemImage: "magnifyingglass"
                        )
                    } else {
                        ScrollView {
                            LazyVStack(spacing: 16) {
                                ForEach(Array(viewModel.studySpots.enumerated()), id: \.element.id) { index, spot in
                                    NavigationLink(destination: SpotDetailView(spot: spot)) {
                                        SpotCardView(
                                            spot: spot,
                                            building: viewModel.buildingForSpot(spot) ?? Building.samples[0],
                                            onFavoriteToggle: { viewModel.toggleFavorite(for: $0) },
                                            distance: userDistanceToSpot(spot)
                                        )
                                        .frame(width: 300)
                                        .opacity(animateOpacity(index: index))
                                        .offset(y: animateOffset(index: index))
                                        .animation(.easeOut(duration: 0.4).delay(0.03 * Double(index)), value: viewModel.studySpots.count)
                                    }
                                    .buttonStyle(PlainButtonStyle())
                                }
                            }
                            .padding()
                        }
                    }
                }
            }
            .navigationTitle("All Study Spots")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    HStack {
                        Button(action: { showFilters.toggle() }) {
                            HStack(spacing: 4) {
                                Image(systemName: "line.3.horizontal.decrease.circle")
                                if hasActiveFilters {
                                    Circle()
                                        .fill(.orange)
                                        .frame(width: 8, height: 8)
                                }
                            }
                            .foregroundColor(.utdOrange)
                        }
                        
                        if hasActiveFilters {
                            Button("Clear") {
                                viewModel.clearFilters()
                            }
                            .font(.caption)
                            .foregroundColor(.utdOrange)
                        }
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { sortSpotsByDistance() }) {
                        Image(systemName: "arrow.up.arrow.down")
                            .foregroundColor(.utdOrange)
                    }
                }
            }
            .sheet(isPresented: $showFilters) {
                FilterView(
                    buildings: viewModel.buildings,
                    selectedBuilding: $viewModel.selectedBuilding,
                    selectedFeatures: $viewModel.selectedFeatures,
                    onApplyFilters: { viewModel.filterSpots() }
                )
            }
            .tint(.utdOrange)
        }
        .navigationViewStyle(StackNavigationViewStyle())
    }
    
    // Calculate distance from user to spot if location is available
    private func userDistanceToSpot(_ spot: StudySpot) -> Double? {
        guard let userLocation = locationService.userLocation else {
            return nil
        }

        let distanceInMeters = viewModel.calculateDistance(
            from: userLocation.coordinate,
            to: spot
        )

        // Convert meters to feet for display
        return distanceInMeters * 3.28084
    }
    
    // Sort spots by distance from user
    private func sortSpotsByDistance() {
        guard let userLocation = locationService.userLocation else {
            // Sort alphabetically if no location
            viewModel.studySpots.sort { $0.name < $1.name }
            return
        }
        
        viewModel.studySpots.sort { spot1, spot2 in
            let dist1 = viewModel.calculateDistance(from: userLocation.coordinate, to: spot1)
            let dist2 = viewModel.calculateDistance(from: userLocation.coordinate, to: spot2)
            return dist1 < dist2
        }
    }
    
    // Check if any filters are active
    private var hasActiveFilters: Bool {
        !viewModel.searchText.isEmpty || 
        viewModel.selectedBuilding != nil || 
        !viewModel.selectedFeatures.isEmpty
    }

    // Simple staged appearance helpers
    private func animateOpacity(index: Int) -> Double { 1.0 }
    private func animateOffset(index: Int) -> CGFloat { 0 }
}

// Empty state view for when no results are found
struct EmptyStateView: View {
    let title: String
    let message: String
    let systemImage: String
    
    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: systemImage)
                .font(.system(size: 60))
                .foregroundColor(.utdGreen)
            
            Text(title)
                .font(.headline)
                .foregroundColor(.utdGreen)
            
            Text(message)
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
        }
    }
}

struct SpotListView_Previews: PreviewProvider {
    static var previews: some View {
        SpotListView()
            .environmentObject(StudySpotsViewModel())
            .environmentObject(LocationService())
    }
}
