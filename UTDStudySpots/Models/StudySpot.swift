import Foundation
import CoreLocation

struct StudySpot: Identifiable, Codable {
    let id: UUID
    let name: String
    let buildingID: UUID
    let floor: Int
    let description: String
    let features: [String] // e.g., "Quiet", "Group Study", "Power Outlets", "Coffee Nearby"
    let capacity: Int
    
    // These properties are stored separately to handle CoreLocation which isn't Codable
    var latitude: Double
    var longitude: Double
    
    var coordinates: CLLocationCoordinate2D {
        CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }
    
    var reviewIDs: [UUID]
    var isFavorite: Bool = false
    
    // Computed properties
    var averageRating: Double {
        // In a real app, this would calculate the average from actual reviews
        return 4.0
    }
    
    var isOpen: Bool {
        // In a real app, this would check against actual building hours
        return true
    }
}

// Example extension to create sample data
extension StudySpot {
    static let samples: [StudySpot] = [
        StudySpot(
            id: UUID(),
            name: "McDermott Library - 3rd Floor",
            buildingID: Building.samples[0].id,
            floor: 3,
            description: "Quiet study area with individual desks and natural lighting.",
            features: ["Quiet", "Individual Study", "Power Outlets", "WiFi"],
            capacity: 100,
            latitude: 32.9888883,
            longitude: -96.7501263,
            reviewIDs: [],
            isFavorite: false
        ),
        StudySpot(
            id: UUID(),
            name: "JSOM - 2nd Floor Lounge",
            buildingID: Building.samples[1].id,
            floor: 2,
            description: "Open collaboration space with comfortable seating.",
            features: ["Group Study", "Power Outlets", "WiFi", "Coffee Nearby"],
            capacity: 40,
            latitude: 32.9868993,
            longitude: -96.7531533,
            reviewIDs: [],
            isFavorite: true
        ),
        StudySpot(
            id: UUID(),
            name: "SLC - Open Study Area",
            buildingID: Building.samples[2].id,
            floor: 1,
            description: "Bright and spacious study area with various seating options.",
            features: ["Group Study", "Individual Study", "Power Outlets", "WiFi"],
            capacity: 75,
            latitude: 32.9901393,
            longitude: -96.7503553,
            reviewIDs: [],
            isFavorite: false
        ),
        StudySpot(
            id: UUID(),
            name: "Founders Building - 1st Floor",
            buildingID: Building.samples[3].id,
            floor: 1,
            description: "Open collaboration space with comfortable seating.",
            features: ["Group Study", "Power Outlets", "WiFi", "Coffee Nearby"],
            capacity: 40,
            latitude: 32.9868993,
            longitude: -96.7531533,
            reviewIDs: []
        )
    ]
} 
