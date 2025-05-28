import SwiftUI
import MapKit

struct SpotDetailView: View {
    let spot: StudySpot
    
    @EnvironmentObject var viewModel: StudySpotsViewModel
    @EnvironmentObject var locationService: LocationService
    @Environment(\.presentationMode) var presentationMode
    
    @State private var showingReviewSheet = false
    @State private var selectedRating: Int = 5
    @State private var reviewComment: String = ""
    
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
                    
                    // Rating summary
                    HStack {
                        ForEach(1...5, id: \.self) { index in
                            Image(systemName: index <= Int(spot.averageRating) ? "star.fill" : "star")
                                .foregroundColor(.yellow)
                        }
                        
                        Text(String(format: "%.1f", spot.averageRating))
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        
                        Text("(\(viewModel.reviewsForSpot(spot).count) reviews)")
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
                                    .foregroundColor(.blue)
                                Text(feature)
                                    .foregroundColor(.primary)
                                Spacer()
                            }
                            .padding(8)
                            .background(Color.blue.opacity(0.1))
                            .cornerRadius(8)
                        }
                    }
                }
                .padding(.horizontal)
                
                // Opening hours
                if let building = viewModel.buildingForSpot(spot) {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Opening Hours")
                            .font(.title2)
                            .bold()
                        
                        ForEach(["Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday", "Sunday"], id: \.self) { day in
                            if let hours = building.openingHours[day] {
                                HStack {
                                    Text(day)
                                        .frame(width: 100, alignment: .leading)
                                    Text(hours)
                                    Spacer()
                                }
                                .padding(.vertical, 4)
                            }
                        }
                    }
                    .padding(.horizontal)
                }
                
                // Reviews section
                VStack(alignment: .leading, spacing: 12) {
                    HStack {
                        Text("Reviews")
                            .font(.title2)
                            .bold()
                        
                        Spacer()
                        
                        Button(action: {
                            showingReviewSheet = true
                        }) {
                            Text("Write Review")
                                .bold()
                                .foregroundColor(.white)
                                .padding(.horizontal, 12)
                                .padding(.vertical, 6)
                                .background(Color.blue)
                                .cornerRadius(8)
                        }
                    }
                    
                    let reviews = viewModel.reviewsForSpot(spot)
                    
                    if reviews.isEmpty {
                        Text("No reviews yet. Be the first to leave one!")
                            .foregroundColor(.secondary)
                            .padding(.vertical)
                    } else {
                        ForEach(reviews) { review in
                            ReviewCardView(review: review)
                                .padding(.vertical, 4)
                        }
                    }
                }
                .padding(.horizontal)
                .padding(.bottom, 20)
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .sheet(isPresented: $showingReviewSheet) {
            AddReviewView(
                spotID: spot.id,
                spotName: spot.name,
                rating: $selectedRating,
                comment: $reviewComment,
                onSubmit: { rating, comment in
                    viewModel.addReview(
                        for: spot,
                        rating: rating,
                        comment: comment
                    )
                }
            )
        }
    }
    
    // Helper to get icon for feature
    private func featureIcon(for feature: String) -> String {
        switch feature {
        case "Quiet":
            return "speaker.slash"
        case "Group Study":
            return "person.3"
        case "Individual Study":
            return "person"
        case "Power Outlets":
            return "bolt"
        case "WiFi":
            return "wifi"
        case "Coffee Nearby":
            return "cup.and.saucer"
        case "Printers":
            return "printer"
        case "Computers":
            return "desktopcomputer"
        case "Whiteboard":
            return "square.dashed"
        case "Natural Light":
            return "sun.max"
        default:
            return "checkmark.circle"
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

// Review submission sheet
struct AddReviewView: View {
    let spotID: UUID
    let spotName: String
    @Binding var rating: Int
    @Binding var comment: String
    let onSubmit: (Int, String) -> Void
    
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Rate this study spot")) {
                    HStack {
                        Spacer()
                        ForEach(1...5, id: \.self) { index in
                            Button(action: {
                                rating = index
                            }) {
                                Image(systemName: index <= rating ? "star.fill" : "star")
                                    .font(.title)
                                    .foregroundColor(.yellow)
                            }
                        }
                        Spacer()
                    }
                    .padding(.vertical)
                }
                
                Section(header: Text("Your review")) {
                    TextEditor(text: $comment)
                        .frame(minHeight: 100)
                }
                
                Section {
                    Button("Submit Review") {
                        // Only allow submission if comment is not empty
                        if !comment.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                            onSubmit(rating, comment)
                            presentationMode.wrappedValue.dismiss()
                            
                            // Reset form values
                            rating = 5
                            comment = ""
                        }
                    }
                    .disabled(comment.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }
            }
            .navigationTitle("Review \(spotName)")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarItems(trailing: Button("Cancel") {
                presentationMode.wrappedValue.dismiss()
            })
        }
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
