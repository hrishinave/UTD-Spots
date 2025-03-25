import Foundation

struct Building: Identifiable, Codable, Hashable {
    let id: UUID
    let name: String
    let code: String // e.g., "JSOM", "SLC"
    let address: String
    let openingHours: [String: String] // Dictionary of day -> hours (e.g. "Monday": "7:00 AM - 11:00 PM")
    let imageNames: [String]
    
    // Computed property to check if building is currently open
    var isCurrentlyOpen: Bool {
        // In a real app, this would check the current time against opening hours
        return true
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
            id: UUID(),
            name: "McDermott Library",
            code: "MC",
            address: "800 W Campbell Rd, Richardson, TX 75080",
            openingHours: [
                "Monday": "7:00 AM - 12:00 AM",
                "Tuesday": "7:00 AM - 12:00 AM",
                "Wednesday": "7:00 AM - 12:00 AM",
                "Thursday": "7:00 AM - 12:00 AM",
                "Friday": "7:00 AM - 6:00 PM",
                "Saturday": "9:00 AM - 6:00 PM",
                "Sunday": "12:00 PM - 12:00 AM"
            ],
            imageNames: ["mcdermott_exterior", "mcdermott_interior"]
        ),
        Building(
            id: UUID(),
            name: "Jindal School of Management",
            code: "JSOM",
            address: "800 W Campbell Rd, Richardson, TX 75080",
            openingHours: [
                "Monday": "7:00 AM - 10:00 PM",
                "Tuesday": "7:00 AM - 10:00 PM",
                "Wednesday": "7:00 AM - 10:00 PM",
                "Thursday": "7:00 AM - 10:00 PM",
                "Friday": "7:00 AM - 7:00 PM",
                "Saturday": "9:00 AM - 5:00 PM",
                "Sunday": "12:00 PM - 5:00 PM"
            ],
            imageNames: ["jsom_exterior", "jsom_interior"]
        ),
        Building(
            id: UUID(),
            name: "Student Learning Center",
            code: "SLC",
            address: "800 W Campbell Rd, Richardson, TX 75080",
            openingHours: [
                "Monday": "7:00 AM - 11:00 PM",
                "Tuesday": "7:00 AM - 11:00 PM",
                "Wednesday": "7:00 AM - 11:00 PM",
                "Thursday": "7:00 AM - 11:00 PM",
                "Friday": "7:00 AM - 9:00 PM",
                "Saturday": "9:00 AM - 6:00 PM",
                "Sunday": "12:00 PM - 9:00 PM"
            ],
            imageNames: ["slc_exterior", "slc_interior"]
        ),
        Building(
            id: UUID(),
            name: "Founders Building",
            code: "FO",
            address: "800 W Campbell Rd, Richardson, TX 75080",
            openingHours: [
                "Monday": "8:00am – 10:45pm",
                "Tuesday": "8:00am – 10:45pm",
                "Wednesday": "8:00am – 10:45pm",
                "Thursday": "8:00am – 10:45pm",
                "Friday": "8:00am – 9:45pm",
                "Saturday": "10:00am – 6:45pm",
                "Sunday": "12:00 PM - 9:45 PM"
            ],
            imageNames: ["founders_exterior", "founders_interior"]
        )
    ]
}
