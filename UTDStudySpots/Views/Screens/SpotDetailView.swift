import SwiftUI
import MapKit

struct SpotDetailView: View {
    let spot: StudySpot
    
    @EnvironmentObject var viewModel: StudySpotsViewModel
    @EnvironmentObject var locationService: LocationService
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                
                // Spot info header
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Text(spot.name)
                            .font(.largeTitle)
                            .bold()
                        
                        Spacer()
                        
                        Button(action: {
                            viewModel.toggleFavorite(for: spot)
                        }) {
                            Image(systemName: spot.isFavorite ? "heart.fill" : "heart")
                                .font(.title2)
                                .foregroundColor(spot.isFavorite ? .red : .gray)
                        }
                    }
                    
                    if let building = viewModel.buildingForSpot(spot) {
                        Text("\(building.name) • Floor \(spot.floor)")
                            .font(.headline)
                            .foregroundColor(.secondary)
                    }
                    
                    // Capacity info
                    HStack {
                        Image(systemName: "person.2")
                            .foregroundColor(.utdOrange)
                        Text("Capacity: \(spot.capacity) people")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                }
                .padding(.horizontal)
                
                Divider()
                
                // Description
                VStack(alignment: .leading, spacing: 8) {
                    Text("About")
                        .font(.title2)
                        .bold()
                    
                    Text(spot.description)
                        .fixedSize(horizontal: false, vertical: true)
                }
                .padding(.horizontal)
                
                // Features
                VStack(alignment: .leading, spacing: 8) {
                    Text("Features")
                        .font(.title2)
                        .bold()
                    
                    LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                        ForEach(spot.features, id: \.self) { feature in
                            HStack {
                                Image(systemName: featureIcon(for: feature))
                                    .foregroundColor(.utdOrange)
                                Text(feature)
                                    .foregroundColor(.primary)
                                Spacer()
                            }
                            .padding(8)
                            .background(Color.utdOrange.opacity(0.1))
                            .cornerRadius(8)
                        }
                    }
                }
                .padding(.horizontal)
                
                // Opening hours
                VStack(alignment: .leading, spacing: 8) {
                    Text("Opening Hours")
                        .font(.title2)
                        .bold()
                    
                    ForEach(["Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday", "Sunday"], id: \.self) { day in
                        if let hours = spot.openingHours[day] {
                            HStack {
                                Text(day)
                                    .frame(width: 100, alignment: .leading)
                                    .fontWeight(.medium)
                                Text(hours)
                                    .foregroundColor(hours == "Closed" ? .red : .primary)
                                Spacer()
                                
                                // Show if currently open for this day
                                if Calendar.current.component(.weekday, from: Date()) == weekdayNumber(for: day) {
                                    Text(spot.isCurrentlyOpen ? "Open" : "Closed")
                                        .font(.caption)
                                        .fontWeight(.semibold)
                                        .foregroundColor(spot.isCurrentlyOpen ? .green : .red)
                                        .padding(.horizontal, 8)
                                        .padding(.vertical, 2)
                                        .background(spot.isCurrentlyOpen ? Color.green.opacity(0.1) : Color.red.opacity(0.1))
                                        .cornerRadius(4)
                                }
                            }
                            .padding(.vertical, 4)
                        }
                    }
                }
                .padding(.horizontal)
                .padding(.bottom, 20)
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button(action: {
                    presentationMode.wrappedValue.dismiss()
                }) {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(.utdOrange)
                        
                }
            }
        }
    }
    
    // Helper to get icon for feature
    private func featureIcon(for feature: String) -> String {
        switch feature {
        case "Silent Zone", "Quiet Zone":
            return "speaker.slash"
        case "Group Space":
            return "person.3"
        case "Individual Space", "Individual Desks":
            return "person"
        case "Power Outlets":
            return "bolt"
        case "Natural Light":
            return "sun.max"
        case "Whiteboard", "Whiteboards":
            return "square.and.pencil"
        case "Computer Lab", "Workstations":
            return "desktopcomputer"
        case "TV Screen":
            return "tv"
        case "Large Table":
            return "rectangle.3.group"
        case "Comfortable Seating":
            return "sofa"
        case "Printing":
            return "printer"
        case "Coffee Shop":
            return "cup.and.saucer"
        case "Vending Machines":
            return "creditcard"
        case "Booths", "Tall Tables":
            return "table.furniture"
        case "Open Area":
            return "building.2"
        case "Outdoor", "Fresh Air":
            return "leaf"
        case "Reservable":
            return "calendar.badge.plus"
        case "Extended Hours", "24 Hours":
            return "clock"
        case "Study Rooms":
            return "door.left.hand.open"
        case "Cubicles":
            return "square.split.2x2"
        default:
            return "checkmark.circle"
        }
    }
    
    // Helper to convert day name to weekday number (1 = Sunday, 2 = Monday, etc.)
    private func weekdayNumber(for day: String) -> Int {
        switch day {
        case "Sunday": return 1
        case "Monday": return 2
        case "Tuesday": return 3
        case "Wednesday": return 4
        case "Thursday": return 5
        case "Friday": return 6
        case "Saturday": return 7
        default: return 0
        }
    }
}

// Map preview for the detail view
struct MapPreview: UIViewRepresentable {
    let coordinate: CLLocationCoordinate2D
    
    func makeUIView(context: Context) -> MKMapView {
        let mapView = MKMapView()
        mapView.isScrollEnabled = false
        mapView.isZoomEnabled = false
        mapView.isUserInteractionEnabled = false
        return mapView
    }
    
    func updateUIView(_ mapView: MKMapView, context: Context) {
        let region = MKCoordinateRegion(
            center: coordinate,
            span: MKCoordinateSpan(latitudeDelta: 0.005, longitudeDelta: 0.005)
        )
        mapView.setRegion(region, animated: true)
        
        // Add annotation for study spot
        let annotation = MKPointAnnotation()
        annotation.coordinate = coordinate
        mapView.removeAnnotations(mapView.annotations)
        mapView.addAnnotation(annotation)
    }
}

struct SpotDetailView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            SpotDetailView(spot: StudySpot.samples[0])
                .environmentObject(StudySpotsViewModel())
                .environmentObject(LocationService())
        }
    }
} 
