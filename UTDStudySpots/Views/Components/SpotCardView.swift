import SwiftUI
import CoreLocation

struct SpotCardView: View {
    let spot: StudySpot
    let building: Building
    let onFavoriteToggle: (StudySpot) -> Void
    let distance: Double?
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 4) {
                    Text(spot.name)
                        .font(.headline)
                        .foregroundColor(.primary)
                    Text(building.name)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                Button {
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
                // Open/Closed Status
                HStack(spacing: 4) {
                    Circle()
                        .fill(spot.isCurrentlyOpen ? Color.green : Color.red)
                        .frame(width: 8, height: 8)
                    Text(spot.isCurrentlyOpen ? "Open" : "Closed")
                        .foregroundColor(spot.isCurrentlyOpen ? .green : .red)
                        .font(.subheadline)
                }
                
                Spacer()
                
                if let distance = distance {
                    Text(String(format: "%.0f ft", distance))
                        .font(.subheadline)
                        .foregroundColor(.secondary)
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
