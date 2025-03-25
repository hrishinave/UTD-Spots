import SwiftUI
import CoreLocation

struct SpotCardView: View {
    let spot: StudySpot
    let building: Building
    var onFavoriteToggle: ((StudySpot) -> Void)?
    var distance: Double?
    
    private var distanceText: String? {
        guard let distance = distance else { return nil }
        
        if distance < 1000 {
            return "\(Int(distance))m away"
        } else {
            let km = distance / 1000
            return String(format: "%.1f km away", km)
        }
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(spot.name)
                        .font(.headline)
                        .foregroundColor(.utdGreen)
                    
                    Text(building.name)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                Button(action: {
                    onFavoriteToggle?(spot)
                }) {
                    Image(systemName: spot.isFavorite ? "heart.fill" : "heart")
                        .foregroundColor(spot.isFavorite ? .utdOrange : .gray)
                }
            }
            
            HStack {
                // Feature badges
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
                
                Spacer()
                
                if let distanceText = distanceText {
                    Text(distanceText)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            
            HStack {
                // Rating stars
                ForEach(0..<5) { index in
                    Image(systemName: index < Int(spot.averageRating) ? "star.fill" : "star")
                        .foregroundColor(.utdOrange)
                        .font(.caption)
                }
                
                Text(String(format: "%.1f", spot.averageRating))
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                Spacer()
                
                // Availability badge
                Text(spot.isOpen ? "Open" : "Closed")
                    .font(.caption)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(spot.isOpen ? Color.utdGreen.opacity(0.2) : Color.red.opacity(0.2))
                    .foregroundColor(spot.isOpen ? .utdGreen : .red)
                    .cornerRadius(4)
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
    }
}

struct SpotCardView_Previews: PreviewProvider {
    static var previews: some View {
        SpotCardView(
            spot: StudySpot.samples[0],
            building: Building.samples[0],
            distance: 250
        )
        .previewLayout(.sizeThatFits)
        .padding()
    }
} 
