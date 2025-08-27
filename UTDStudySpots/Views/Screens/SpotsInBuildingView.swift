import SwiftUI
import CoreLocation

struct SpotsInBuildingView: View {
    @EnvironmentObject var viewModel: StudySpotsViewModel
    @EnvironmentObject var locationService: LocationService
    let building: Building
    @Environment(\.dismiss) private var dismiss
    
    private var spotsInBuilding: [StudySpot] {
        viewModel.studySpots.filter { $0.buildingID == building.id }
    }
    
    var body: some View {
        VStack(spacing: 0) {
            if spotsInBuilding.isEmpty {
                EmptyStateView(
                    title: "No spots found",
                    message: "There are no study spots for this building.",
                    systemImage: "magnifyingglass"
                )
                .padding()
            } else {
                ScrollView {
                    LazyVStack(spacing: 16) {
                        ForEach(spotsInBuilding) { spot in
                            NavigationLink(destination: SpotDetailView(spot: spot)) {
                                SpotCardView(
                                    spot: spot,
                                    building: building,
                                    onFavoriteToggle: { viewModel.toggleFavorite(for: $0) },
                                    distance: userDistanceToSpot(spot)
                                )
                                .frame(maxWidth: .infinity)
                                .padding(.horizontal)
                            }
                            .buttonStyle(PlainButtonStyle())
                        }
                    }
                    .padding(.vertical)
                }
            }
        }
        .navigationTitle(building.name)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button(action: { dismiss() }) {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(.utdOrange)
                }
            }
        }
    }
    
    private func userDistanceToSpot(_ spot: StudySpot) -> Double? {
        guard let userLocation = locationService.userLocation else {
            return nil
        }
        let meters = viewModel.calculateDistance(
            from: userLocation.coordinate,
            to: spot
        )
        return meters * 3.28084
    }
}

struct SpotsInBuildingView_Previews: PreviewProvider {
    static var previews: some View {
        SpotsInBuildingView(building: Building.samples[0])
            .environmentObject(StudySpotsViewModel())
            .environmentObject(LocationService())
    }
}


