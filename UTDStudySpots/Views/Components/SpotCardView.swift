import SwiftUI
import CoreLocation
import MapKit

struct SpotCardView: View {
    let spot: StudySpot
    let building: Building
    let onFavoriteToggle: (StudySpot) -> Void
    let distance: Double?
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(alignment: .top, spacing: 12) {
                // Thumbnail
                ZStack {
                    if let imageName = building.imageNames.first, !imageName.isEmpty {
                        Image(imageName)
                            .resizable()
                            .scaledToFill()
                    } else {
                        Image(systemName: "building.2")
                            .resizable()
                            .scaledToFit()
                            .padding(8)
                            .foregroundColor(.secondary)
                    }
                }
                .frame(width: 48, height: 48)
                .background(Color.gray.opacity(0.1))
                .clipShape(RoundedRectangle(cornerRadius: 8))
                
                VStack(alignment: .leading, spacing: 4) {
                    HStack(alignment: .firstTextBaseline) {
                        Text(spot.name)
                            .font(.headline)
                            .foregroundColor(.primary)
                        
                        Spacer()
                        
                        // Rating
                        HStack(spacing: 4) {
                            Image(systemName: "star.fill")
                                .foregroundColor(.yellow)
                                .font(.caption)
                            Text(String(format: "%.1f", spot.averageRating))
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                    
                    Text(building.name)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                Button {
                    let generator = UIImpactFeedbackGenerator(style: .light)
                    generator.impactOccurred()
                    onFavoriteToggle(spot)
                } label: {
                    Image(systemName: spot.isFavorite ? "heart.fill" : "heart")
                        .foregroundColor(spot.isFavorite ? .red : .gray)
                        .padding(8)
                }
                .buttonStyle(BorderlessButtonStyle())
            }
            
            Text(spot.description)
                .font(.subheadline)
                .foregroundColor(.secondary)
                .lineLimit(2)
            
            HStack {
                // Open/Closed pill
                HStack(spacing: 6) {
                    Image(systemName: spot.isCurrentlyOpen ? "checkmark.circle.fill" : "xmark.circle.fill")
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundColor(spot.isCurrentlyOpen ? .green : .red)
                    Text(spot.isCurrentlyOpen ? "Open" : "Closed")
                        .font(.caption)
                        .fontWeight(.semibold)
                        .foregroundColor(spot.isCurrentlyOpen ? .green : .red)
                }
                .padding(.horizontal, 10)
                .padding(.vertical, 6)
                .background((spot.isCurrentlyOpen ? Color.green : Color.red).opacity(0.08))
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke((spot.isCurrentlyOpen ? Color.green : Color.red).opacity(0.35), lineWidth: 1)
                )
                .cornerRadius(10)
                
                Spacer()
                
                if let distance = distance {
                    HStack(spacing: 6) {
                        Image(systemName: "location")
                            .font(.system(size: 12, weight: .semibold))
                            .foregroundColor(.secondary)
                        Text(String(format: "%.0f ft", distance))
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    .padding(.horizontal, 10)
                    .padding(.vertical, 6)
                    .background(Color.gray.opacity(0.08))
                    .overlay(
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                    )
                    .cornerRadius(10)
                }
            }
            
            HStack {
                ForEach(spot.features.prefix(3), id: \.self) { feature in
                    Text(feature)
                        .font(.caption)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(Color.secondary.opacity(0.1))
                        .cornerRadius(4)
                }
            }
            
            // Quick actions
            HStack(spacing: 8) {
                Button {
                    // Open Apple Maps with walking directions
                    MapUtils.openDirectionsInMaps(to: spot.coordinates, destinationName: spot.name)
                } label: {
                    HStack(spacing: 6) {
                        Image(systemName: "figure.walk")
                        Text("Directions")
                    }
                    .font(.caption)
                    .foregroundColor(.white)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 6)
                    .background(Color.utdGreen)
                    .cornerRadius(8)
                }
                .buttonStyle(.plain)
                
                Button {
                    // Open Apple Maps with just a pin
                    let placemark = MKPlacemark(coordinate: spot.coordinates)
                    let mapItem = MKMapItem(placemark: placemark)
                    mapItem.name = spot.name
                    mapItem.openInMaps()
                } label: {
                    HStack(spacing: 6) {
                        Image(systemName: "mappin.circle")
                        Text("View Map")
                    }
                    .font(.caption)
                    .foregroundColor(.utdOrange)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 6)
                    .background(Color.utdOrange.opacity(0.12))
                    .cornerRadius(8)
                }
                .buttonStyle(.plain)
                
                Spacer()
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(radius: 2)
    }
}

struct SpotCardView_Previews: PreviewProvider {
    static var previews: some View {
        SpotCardView(
            spot: StudySpot.samples[0],
            building: Building.samples[0],
            onFavoriteToggle: { _ in }, 
            distance: 250
        )
        .previewLayout(.sizeThatFits)
        .padding()
    }
}
