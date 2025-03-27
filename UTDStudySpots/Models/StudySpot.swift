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
            latitude: 32.98783650172627,
            longitude: -96.7478852394324,
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
            latitude: 32.98519557093538,
            longitude: -96.74690097620241,
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
            name: "Founders Building - Founders Lab",
            buildingID: Building.samples[3].id,
            floor: 1,
            description: "Open collaboration space with comfortable seating.",
            features: ["Group Study", "Power Outlets", "WiFi", "Coffee Nearby"],
            capacity: 40,
            latitude: 32.9868993,
            longitude: -96.7531533,
            reviewIDs: [],
            isFavorite: false
        ),
        StudySpot(
            id: UUID(),
            name: "ECSW 3.335 - Engineering Open Access Lab",
            buildingID: Building.samples[4].id,
            floor: 3,
            description: "Engineering Open Access Lab with computer workstations and study space.",
            features: ["Computer Lab", "Power Outlets", "WiFi", "Quiet"],
            capacity: 40,
            latitude: 32.98608739628137,
            longitude: -96.75152005916523,
            reviewIDs: [],
            isFavorite: false
            
        ),
        StudySpot(
            id: UUID(),
            name: "ECSS 2.103/2.104 - Computer Labs",
            buildingID: Building.samples[5].id,
            floor: 2,
            description: "Large computer labs with plenty of workstations and space for collaborative work.",
            features: ["Computer Lab", "Power Outlets", "WiFi", "Group Study"],
            capacity: 128,
            latitude: 32.98638887491088,
            longitude: -96.75046863323148,
            reviewIDs: [],
            isFavorite: false
        )
    ]
} 
