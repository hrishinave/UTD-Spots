import SwiftUI
import CoreLocation

struct BuildingDetailView: View {
    @EnvironmentObject var viewModel: StudySpotsViewModel
    @EnvironmentObject var locationService: LocationService
    let building: Building
    @Environment(\.dismiss) private var dismiss
    
    private var spotsInBuilding: [StudySpot] {
        return viewModel.studySpots.filter { spot in
            spot.buildingID == building.id
        }
    }
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                // Header Section
                VStack(alignment: .leading, spacing: 8) {
                    Text(building.name)
                        .font(.title)
                        .fontWeight(.bold)
                    
                    Text(building.code)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    
                    HStack {
                        Text(building.address)
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        
                        Spacer()
                        
                        Button {
                            // Open in Maps
                            let url = URL(string: "maps://?q=\(building.latitude),\(building.longitude)")
                            if let url = url, UIApplication.shared.canOpenURL(url) {
                                UIApplication.shared.open(url)
                            }
                        } label: {
                            HStack(spacing: 4) {
                                Image(systemName: "location.fill")
                                    .font(.system(size: 14, weight: .medium))
                                Text("Directions")
                                    .font(.system(size: 14, weight: .medium))
                            }
                            .foregroundColor(.white)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .background(Color.utdOrange)
                            .cornerRadius(8)
                        }
                    }
                }
                .padding(.horizontal)
                
                // Hours Section
                VStack(alignment: .leading, spacing: 12) {
                    Text("Hours")
                        .font(.title2)
                        .fontWeight(.bold)
                    
                    ForEach(Calendar.current.weekdaySymbols, id: \.self) { day in
                        if let hours = building.openingHours[day] {
                            HStack {
                                Text(day)
                                    .frame(width: 100, alignment: .leading)
                                Text(hours)
                                Spacer()
                            }
                        }
                    }
                }
                .padding(.horizontal)
                
                // Study Spots Section
                VStack(alignment: .leading, spacing: 12) {
                    Text("Study Spots")
                        .font(.title2)
                        .fontWeight(.bold)
                        .padding(.horizontal)
                    
                    if spotsInBuilding.isEmpty {
                        Text("No study spots available")
                            .foregroundColor(.secondary)
                            .padding()
                    } else {
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 16) {
                                ForEach(spotsInBuilding) { spot in
                                    NavigationLink(value: spot) {
                                        SpotCardView(
                                            spot: spot,
                                            building: building,
                                            onFavoriteToggle: { spot in
                                                viewModel.toggleFavorite(for: spot)
                                            },
                                            distance: {
                                                guard let userLoc = locationService.userLocation else {
                                                    return nil
                                                }
                                                let meters = viewModel.calculateDistance(
                                                    from: userLoc.coordinate,
                                                    to: spot
                                                )
                                                return meters * 3.28084
                                            }()
                                        )
                                        .frame(width: 300)
                                    }
                                    .buttonStyle(PlainButtonStyle())
                                }
                            }
                            .padding(.horizontal)
                        }
                    }
                }
            }
            .padding(.vertical)
        }
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button(action: {
                    dismiss()
                }) {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(.utdOrange)
                }
            }
        }
    }
}

struct StudySpotCard: View {
    let spot: StudySpot
    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.secondary.opacity(0.1))
            
            VStack(alignment: .leading) {
                Text(spot.name)
                    .font(.headline)
                Text("Floor \(spot.floor)")
                    .font(.subheadline)
                Text("\(spot.capacity) seats")
                    .font(.subheadline)
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack {
                        ForEach(spot.features.prefix(3), id: \.self) { feature in
                            Text(feature)
                                .font(.caption)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 4)
                                .background(Color.utdOrange.opacity(0.2))
                                .foregroundColor(.utdOrange)
                                .cornerRadius(4)
                        }
                        
                        if spot.features.count > 3 {
                            Text("+\(spot.features.count - 3)")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                }
            }
            .padding()
        }
    }
}

struct BuildingDetailView_Previews: PreviewProvider {
    static var previews: some View {
        BuildingDetailView(building: Building.samples[0])
            .environmentObject(StudySpotsViewModel())
            .environmentObject(LocationService())
    }
}
