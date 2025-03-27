import SwiftUI

struct BuildingDetailView: View {
    @EnvironmentObject var viewModel: StudySpotsViewModel
    @EnvironmentObject var locationService: LocationService
    let building: Building
    @Environment(\.presentationMode) var presentationMode
    @State private var showingDirectionsActionSheet = false
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Building header with image
                if !building.imageNames.isEmpty, let imageName = building.imageNames.first {
                    Image(imageName)
                        .resizable()
                        .scaledToFill()
                        .frame(height: 200)
                        .clipped()
                        .overlay(
                            VStack {
                                Spacer()
                                HStack {
                                    VStack(alignment: .leading) {
                                        Text(building.name)
                                            .font(.title.bold())
                                            .foregroundColor(.white)
                                        Text(building.code)
                                            .font(.headline)
                                            .foregroundColor(.white.opacity(0.9))
                                    }
                                    .padding()
                                    .shadow(radius: 3)
                                    Spacer()
                                }
                                .background(
                                    LinearGradient(
                                        gradient: Gradient(colors: [.black.opacity(0.7), .clear]),
                                        startPoint: .bottom,
                                        endPoint: .top
                                    )
                                )
                            }
                        )
                } else {
                    HStack {
                        VStack(alignment: .leading) {
                            Text(building.name)
                                .font(.title.bold())
                            Text(building.code)
                                .font(.headline)
                                .foregroundColor(.secondary)
                        }
                        .padding()
                        Spacer()
                    }
                    .background(Color.utdGreen.opacity(0.1))
                }
                
                // Address and Directions Button
                HStack {
                    VStack(alignment: .leading) {
                        Text(building.address)
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    
                    Spacer()
                    
                    Button(action: {
                        showingDirectionsActionSheet = true
                    }) {
                        Label("Directions", systemImage: "map")
                            .font(.subheadline)
                            .foregroundColor(.utdGreen)
                    }
                }
                .padding(.horizontal)
                .padding(.vertical, 8)
                
                // Hours section
                VStack(alignment: .leading, spacing: 8) {
                    Text("Hours")
                        .font(.headline)
                        .foregroundColor(.utdGreen)
                        .padding(.horizontal)
                    
                    VStack(alignment: .leading, spacing: 4) {
                        ForEach(["Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday", "Sunday"], id: \.self) { day in
                            if let hours = building.openingHours[day] {
                                HStack {
                                    Text(day)
                                        .foregroundColor(.secondary)
                                        .frame(width: 100, alignment: .leading)
                                    Text(hours)
                                        .foregroundColor(.primary)
                                    Spacer()
                                }
                                .padding(.horizontal)
                                .padding(.vertical, 2)
                            }
                        }
                    }
                    .padding(.vertical, 4)
                }
                .padding(.vertical)
                
                // Divider
                Divider()
                    .padding(.horizontal)
                
                // Study spots in this building
                VStack(alignment: .leading) {
                    Text("Study Spots")
                        .font(.headline)
                        .foregroundColor(.utdGreen)
                        .padding(.horizontal)
                        .padding(.top, 8)
                    
                    if spotsInBuilding.isEmpty {
                        Text("No study spots available for this building.")
                            .foregroundColor(.secondary)
                            .padding()
                    } else {
                        List {
                            ForEach(spotsInBuilding) { spot in
                                NavigationLink(destination: SpotDetailView(spot: spot)) {
                                    VStack(alignment: .leading, spacing: 4) {
                                        Text(spot.name)
                                            .font(.headline)
                                        
                                        HStack {
                                            Text("Floor \(spot.floor)")
                                                .foregroundColor(.secondary)
                                                .font(.subheadline)
                                            
                                            Spacer()
                                            
                                            Text("\(spot.capacity) seats")
                                                .foregroundColor(.secondary)
                                                .font(.subheadline)
                                        }
                                        
                                        // Feature tags
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
                                    .padding(.vertical, 4)
                                }
                            }
                        }
                        .listStyle(PlainListStyle())
                    }
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .navigationTitle(building.name)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        presentationMode.wrappedValue.dismiss()
                    }) {
                        Text("Done")
                    }
                }
            }
            .actionSheet(isPresented: $showingDirectionsActionSheet) {
                directionActionSheet()
            }
        }
    }
    
    private func directionActionSheet() -> ActionSheet {
        let title = Text("Directions to \(building.name)")
        let message = Text("Choose how to get directions")
        
        return ActionSheet(title: title, message: message, buttons: [
            .default(Text("Open in Apple Maps")) {
                MapUtils.openDirectionsInMaps(to: building.coordinates, destinationName: building.name)
            },
            .cancel()
        ])
    }
    
    // Get study spots for this building
    private var spotsInBuilding: [StudySpot] {
        return viewModel.studySpots.filter { $0.buildingID == building.id }
    }
}

struct BuildingDetailView_Previews: PreviewProvider {
    static var previews: some View {
        BuildingDetailView(building: Building.samples[0])
            .environmentObject(StudySpotsViewModel())
            .environmentObject(LocationService())
    }
}
