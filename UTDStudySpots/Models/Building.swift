import Foundation
import CoreLocation

// Shared building IDs to ensure consistency between Building and StudySpot models
struct BuildingIDs {
    static let mcDermottLibrary = UUID()
    static let jsom = UUID()
    static let slc = UUID()
    static let founders = UUID()
    static let ecsw = UUID()
    static let dgac = UUID()
    static let greenHall = UUID()
    static let sciences = UUID()
    static let ssa = UUID()
    static let residenceHall = UUID()
}

struct Building: Identifiable, Codable, Hashable {
    let id: UUID
    let name: String
    let code: String // e.g., "JSOM", "SLC"
    let address: String
    let openingHours: [String: String] // Dictionary of day -> hours (e.g. "Monday": "7:00 AM - 11:00 PM")
    let imageNames: [String]
  
    // Coordinates for map display
    var latitude: Double
    var longitude: Double
    
    var coordinates: CLLocationCoordinate2D {
        CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }
    
    // Computed property to check if building is currently open
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
    
    // Implement Hashable conformance
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    static func == (lhs: Building, rhs: Building) -> Bool {
        return lhs.id == rhs.id
    }
}

// Example extension to create sample data
extension Building {
    static let samples: [Building] = [
        Building(
            id: BuildingIDs.mcDermottLibrary,
            name: "McDermott Library",
            code: "MC",
            address: "800 W Campbell Rd, Richardson, TX 75080",
            openingHours: [
                "Monday": "7:30 AM - 2:00 AM",
                "Tuesday": "7:30 AM - 2:00 AM",
                "Wednesday": "7:30 AM - 2:00 AM",
                "Thursday": "7:30 AM - 2:00 AM",
                "Friday": "7:30 AM - 10:00 PM",
                "Saturday": "10:00 AM - 10:00 PM",
                "Sunday": "10:00 AM - 2:00 AM"
            ],
            imageNames: ["mcdermott_library"],
            latitude: 32.98731870864668,
            longitude: -96.74773635837403
        ),
        
        Building(
            id: BuildingIDs.jsom,
            name: "Jindal School of Management",
            code: "JSOM",
            address: "800 W Campbell Rd, Richardson, TX 75080",
            openingHours: [
                "Monday": "6:00 AM - 11:00 PM",
                "Tuesday": "6:00 AM - 11:00 PM",
                "Wednesday": "6:00 AM - 11:00 PM",
                "Thursday": "6:00 AM - 11:00 PM",
                "Friday": "6:00 AM - 10:00 PM",
                "Saturday": "8:00 AM - 10:00 PM",
                "Sunday": "8:00 AM - 11:00 PM"
            ],
            imageNames: ["jsom"],
            latitude: 32.985297924246915,
            longitude: -96.74697043881872
        ),
        
        Building(
            id: BuildingIDs.slc,
            name: "Science Learning Center",
            code: "SLC",
            address: "800 W Campbell Rd, Richardson, TX 75080",
            openingHours: [
                "Monday": "7:00 AM - 10:00 PM",
                "Tuesday": "7:00 AM - 10:00 PM",
                "Wednesday": "7:00 AM - 10:00 PM",
                "Thursday": "7:00 AM - 10:00 PM",
                "Friday": "7:00 AM - 8:00 PM",
                "Saturday": "9:00 AM - 6:00 PM",
                "Sunday": "12:00 PM - 10:00 PM"
            ],
            imageNames: ["slc"],
            latitude: 32.98811670344322,
            longitude: -96.75019295790247
        ),
        
        Building(
            id: BuildingIDs.founders,
            name: "Founders Building",
            code: "FO",
            address: "800 W Campbell Rd, Richardson, TX 75080",
            openingHours: [
                "Monday": "6:00 AM - 11:00 PM",
                "Tuesday": "6:00 AM - 11:00 PM",
                "Wednesday": "6:00 AM - 11:00 PM",
                "Thursday": "6:00 AM - 11:00 PM",
                "Friday": "6:00 AM - 10:00 PM",
                "Saturday": "8:00 AM - 10:00 PM",
                "Sunday": "8:00 AM - 11:00 PM"
            ],
            imageNames: ["founders"],
            latitude: 32.987867521651346,
            longitude: -96.74904891953264
        ),
        
        Building(
            id: BuildingIDs.ecsw,
            name: "Erik Jonsson School of Computer Science (West)",
            code: "ECSW",
            address: "800 W Campbell Rd, Richardson, TX 75080",
            openingHours: [
                "Monday": "6:00 AM - 11:00 PM",
                "Tuesday": "6:00 AM - 11:00 PM",
                "Wednesday": "6:00 AM - 11:00 PM",
                "Thursday": "6:00 AM - 11:00 PM",
                "Friday": "6:00 AM - 10:00 PM",
                "Saturday": "8:00 AM - 10:00 PM",
                "Sunday": "8:00 AM - 11:00 PM"
            ],
            imageNames: ["ecsw"],
            latitude: 32.98643879369642,
            longitude: -96.7516191834753
        ),
        
        // New buildings from document
        Building(
            id: BuildingIDs.dgac,
            name: "Davidson Gundy Alumni Center",
            code: "DGAC",
            address: "800 W Campbell Rd, Richardson, TX 75080",
            openingHours: [
                "Monday": "8:00 AM - 6:00 PM",
                "Tuesday": "8:00 AM - 6:00 PM",
                "Wednesday": "8:00 AM - 6:00 PM",
                "Thursday": "8:00 AM - 6:00 PM",
                "Friday": "8:00 AM - 5:00 PM",
                "Saturday": "Closed",
                "Sunday": "Closed"
            ],
            imageNames: [],
            latitude: 32.98634525701794,
            longitude: -96.74630435469747
        ),
        
        Building(
            id: BuildingIDs.greenHall,
            name: "Green Hall",
            code: "GH",
            address: "800 W Campbell Rd, Richardson, TX 75080",
            openingHours: [
                "Monday": "6:00 AM - 11:00 PM",
                "Tuesday": "6:00 AM - 11:00 PM",
                "Wednesday": "6:00 AM - 11:00 PM",
                "Thursday": "6:00 AM - 11:00 PM",
                "Friday": "6:00 AM - 10:00 PM",
                "Saturday": "8:00 AM - 10:00 PM",
                "Sunday": "8:00 AM - 11:00 PM"
            ],
            imageNames: ["green hall"],
            latitude: 32.98720,
            longitude: -96.75100
        ),
        
        Building(
            id: BuildingIDs.sciences,
            name: "Sciences Building",
            code: "SCI",
            address: "800 W Campbell Rd, Richardson, TX 75080",
            openingHours: [
                "Monday": "6:00 AM - 11:00 PM",
                "Tuesday": "6:00 AM - 11:00 PM",
                "Wednesday": "6:00 AM - 11:00 PM",
                "Thursday": "6:00 AM - 11:00 PM",
                "Friday": "6:00 AM - 10:00 PM",
                "Saturday": "8:00 AM - 10:00 PM",
                "Sunday": "8:00 AM - 11:00 PM"
            ],
            imageNames: ["sciences"],
            latitude: 32.98650,
            longitude: -96.74950
        ),
        
        Building(
            id: BuildingIDs.ssa,
            name: "Student Services Addition",
            code: "SSA",
            address: "800 W Campbell Rd, Richardson, TX 75080",
            openingHours: [
                "Monday": "7:00 AM - 10:00 PM",
                "Tuesday": "7:00 AM - 10:00 PM",
                "Wednesday": "7:00 AM - 10:00 PM",
                "Thursday": "7:00 AM - 10:00 PM",
                "Friday": "7:00 AM - 8:00 PM",
                "Saturday": "9:00 AM - 6:00 PM",
                "Sunday": "12:00 PM - 10:00 PM"
            ],
            imageNames: [],
            latitude: 32.98600,
            longitude: -96.74800
        )
    ]
}
