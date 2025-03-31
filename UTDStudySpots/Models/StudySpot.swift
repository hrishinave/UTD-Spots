import Foundation
import CoreLocation

struct StudySpot: Identifiable, Codable, Hashable {
    let id: UUID
    let name: String
    let buildingID: UUID
    let floor: Int
    let description: String
    let features: [String]
    let capacity: Int
    var latitude: Double
    var longitude: Double
    let openingHours: [String: String]
    var coordinates: CLLocationCoordinate2D {
        CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }
    var reviewIDs: [UUID]
    var isFavorite: Bool
    var averageRating: Double
    
    var isCurrentlyOpen: Bool {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "EEEE"
        let today = dateFormatter.string(from: Date())
        
        guard let hours = openingHours[today] else {
            return false
        }
        
        let times = hours.components(separatedBy: "-").map { $0.trimmingCharacters(in: .whitespaces)}
        guard times.count == 2 else { return false }
        
        let timeFormatter = DateFormatter()
        timeFormatter.dateFormat = "h:mm a"
        timeFormatter.locale = Locale(identifier: "en_US_POSIX")
        
        guard let openTime = timeFormatter.date(from: times[0]),
              let closeTime = timeFormatter.date(from: times[1]) else {
            return false
        }
        
        let calendar = Calendar.current
        let now = Date()
        let todayComponents = calendar.dateComponents([.year, .month, .day], from: now)
        
        var openComponents = calendar.dateComponents([.hour, .minute], from: openTime)
        openComponents.year = todayComponents.year
        openComponents.month = todayComponents.month
        openComponents.day = todayComponents.day
        
        var closeComponents = calendar.dateComponents([.hour, .minute], from: closeTime)
        closeComponents.year = todayComponents.year
        closeComponents.month = todayComponents.month
        closeComponents.day = todayComponents.day
        
        guard let openDate = calendar.date(from: openComponents),
              let closeDate = calendar.date(from: closeComponents) else {
            return false
        }
        
        if closeDate < openDate {
            if let adjustedCloseDate = calendar.date(byAdding: .day, value: 1, to: closeDate) {
                return now >= openDate && now <= adjustedCloseDate
            }
        }
        
        return now >= openDate && now <= closeDate
    }
}

extension StudySpot {
    static let samples: [StudySpot] = [
        // McDermott Library Spots
        StudySpot(
            id: UUID(),
            name: "Silent Study Area - 3rd Floor",
            buildingID: Building.samples[0].id,  // McDermott Library ID
            floor: 3,
            description: "Quiet individual study space with personal desks",
            features: ["Silent Zone", "Individual Desks", "Power Outlets", "Natural Light"],
            capacity: 50,
            latitude: 32.98731870864668,
            longitude: -96.74773635837403,
            openingHours: Building.samples[0].openingHours,  // Use same hours as building
            reviewIDs: [],
            isFavorite: false,
            averageRating: 4.5
        ),
        StudySpot(
            id: UUID(),
            name: "Group Study Room 2.304",
            buildingID: Building.samples[0].id,  // McDermott Library ID
            floor: 2,
            description: "Collaborative space with whiteboard and large table",
            features: ["Group Space", "Whiteboard", "Large Table", "TV Screen"],
            capacity: 6,
            latitude: 32.98731870864668,
            longitude: -96.74773635837403,
            openingHours: Building.samples[0].openingHours,
            reviewIDs: [],
            isFavorite: false,
            averageRating: 4.2
        ),
        
        // JSOM Spots
        StudySpot(
            id: UUID(),
            name: "JSOM 2.107 Study Lounge",
            buildingID: Building.samples[1].id,  // JSOM ID
            floor: 2,
            description: "Open study area with comfortable seating",
            features: ["Group Space", "Comfortable Seating", "Power Outlets", "Natural Light"],
            capacity: 30,
            latitude: 32.985297924246915,
            longitude: -96.74697043881872,
            openingHours: Building.samples[1].openingHours,
            reviewIDs: [],
            isFavorite: false,
            averageRating: 4.0
        ),
        
        // SLC Spots
        StudySpot(
            id: UUID(),
            name: "SLC Commons",
            buildingID: Building.samples[2].id,  // SLC ID
            floor: 1,
            description: "Large open study space with various seating options",
            features: ["Group Space", "Individual Desks", "Power Outlets", "Vending Machines"],
            capacity: 100,
            latitude: 32.9901393,
            longitude: -96.7503553,
            openingHours: Building.samples[2].openingHours,
            reviewIDs: [],
            isFavorite: false,
            averageRating: 4.3
        ),
        
        // Founders Building Spots
        StudySpot(
            id: UUID(),
            name: "Founders Study Nook",
            buildingID: Building.samples[3].id,  // Founders ID
            floor: 1,
            description: "Cozy study area with comfortable seating",
            features: ["Individual Space", "Comfortable Seating", "Quiet Zone"],
            capacity: 15,
            latitude: 32.987867521651346,
            longitude: -96.74904891953264,
            openingHours: Building.samples[3].openingHours,
            reviewIDs: [],
            isFavorite: false,
            averageRating: 4.1
        ),
        
        // ECSW Spots
        StudySpot(
            id: UUID(),
            name: "ECSW 2.160 Study Area",
            buildingID: Building.samples[4].id,  // ECSW ID
            floor: 2,
            description: "Modern study space with computer workstations",
            features: ["Computer Lab", "Individual Desks", "Power Outlets", "Printing"],
            capacity: 40,
            latitude: 32.98643879369642,
            longitude: -96.7516191834753,
            openingHours: Building.samples[4].openingHours,
            reviewIDs: [],
            isFavorite: false,
            averageRating: 4.4
        )
    ]
}
