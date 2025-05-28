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
    var averageRating: Double
    
    // Computed property that checks FavoritesManager
    var isFavorite: Bool {
        return FavoritesManager.shared.isFavorite(spotID: id.uuidString)
    }
    
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
        // Existing McDermott Library Spots
        StudySpot(
            id: UUID(),
            name: "Common Study Area - 1st Floor",
            buildingID: BuildingIDs.mcDermottLibrary,
            floor: 2,
            description: "Common study area with individual chairs-tables",
            features: ["Common Space", "Whiteboard"],
            capacity: 6,
            latitude: 32.98731870864668,
            longitude: -96.74773635837403,
            openingHours: [
                "Monday": "7:30 AM - 2:00 AM",
                "Tuesday": "7:30 AM - 2:00 AM",
                "Wednesday": "7:30 AM - 2:00 AM",
                "Thursday": "7:30 AM - 2:00 AM",
                "Friday": "7:30 AM - 10:00 PM",
                "Saturday": "10:00 AM - 10:00 PM",
                "Sunday": "10:00 AM - 2:00 AM"
            ],
            reviewIDs: [],
            averageRating: 4.2
        ),
        
        StudySpot(
            id: UUID(),
            name: "Silent Study Area - 3rd Floor",
            buildingID: BuildingIDs.mcDermottLibrary,
            floor: 3,
            description: "Quiet individual study space with personal desks",
            features: ["Silent Zone", "Individual Desks", "Power Outlets", "Natural Light"],
            capacity: 50,
            latitude: 32.98731870864668,
            longitude: -96.74773635837403,
            openingHours: [
                "Monday": "7:30 AM - 2:00 AM",
                "Tuesday": "7:30 AM - 2:00 AM",
                "Wednesday": "7:30 AM - 2:00 AM",
                "Thursday": "7:30 AM - 2:00 AM",
                "Friday": "7:30 AM - 10:00 PM",
                "Saturday": "10:00 AM - 10:00 PM",
                "Sunday": "10:00 AM - 2:00 AM"
            ],
            reviewIDs: [],
            averageRating: 4.5
        ),
        
        StudySpot(
            id: UUID(),
            name: "Group Study Room 2.304",
            buildingID: BuildingIDs.mcDermottLibrary,
            floor: 2,
            description: "Collaborative space with whiteboard and large table",
            features: ["Group Space", "Whiteboard", "Large Table", "TV Screen"],
            capacity: 6,
            latitude: 32.98731870864668,
            longitude: -96.74773635837403,
            openingHours: [
                "Monday": "7:30 AM - 2:00 AM",
                "Tuesday": "7:30 AM - 2:00 AM",
                "Wednesday": "7:30 AM - 2:00 AM",
                "Thursday": "7:30 AM - 2:00 AM",
                "Friday": "7:30 AM - 10:00 PM",
                "Saturday": "10:00 AM - 10:00 PM",
                "Sunday": "10:00 AM - 2:00 AM"
            ],
            reviewIDs: [],
            averageRating: 4.2
        ),
        
        // New McDermott Library Spots
        StudySpot(
            id: UUID(),
            name: "Study Rooms",
            buildingID: BuildingIDs.mcDermottLibrary,
            floor: 1,
            description: "Great place for solo quiet study, meeting up for group projects, or practicing presentations! 11 different rooms available, 2 hours per student per 24 hours.",
            features: ["Reservable", "Group Space", "Quiet Zone", "Whiteboards", "Various Sizes"],
            capacity: 8,
            latitude: 32.98731870864668,
            longitude: -96.74773635837403,
            openingHours: [
                "Monday": "7:30 AM - 2:00 AM",
                "Tuesday": "7:30 AM - 2:00 AM",
                "Wednesday": "7:30 AM - 2:00 AM",
                "Thursday": "7:30 AM - 2:00 AM",
                "Friday": "7:30 AM - 10:00 PM",
                "Saturday": "10:00 AM - 10:00 PM",
                "Sunday": "10:00 AM - 2:00 AM"
            ],
            reviewIDs: [],
            averageRating: 4.6
        ),
        
        StudySpot(
            id: UUID(),
            name: "3rd Floor Cubicles",
            buildingID: BuildingIDs.mcDermottLibrary,
            floor: 3,
            description: "Comfortable seating in isolated space with desk and shelving. Remain open with 1st and 2nd floor at night after rest of 3rd and 4th floor close.",
            features: ["Individual Space", "Power Outlets", "Quiet Zone", "Extended Hours"],
            capacity: 30,
            latitude: 32.98731870864668,
            longitude: -96.74773635837403,
            openingHours: [
                "Monday": "7:30 AM - 2:00 AM",
                "Tuesday": "7:30 AM - 2:00 AM",
                "Wednesday": "7:30 AM - 2:00 AM",
                "Thursday": "7:30 AM - 2:00 AM",
                "Friday": "7:30 AM - 10:00 PM",
                "Saturday": "10:00 AM - 10:00 PM",
                "Sunday": "10:00 AM - 2:00 AM"
            ],
            reviewIDs: [],
            averageRating: 4.4
        ),
        
        // Existing JSOM Spots
        StudySpot(
            id: UUID(),
            name: "JSOM 2.107 Study Lounge",
            buildingID: BuildingIDs.jsom,
            floor: 2,
            description: "Open study area with comfortable seating",
            features: ["Group Space", "Comfortable Seating", "Power Outlets", "Natural Light"],
            capacity: 30,
            latitude: 32.985297924246915,
            longitude: -96.74697043881872,
            openingHours: [
                "Monday": "6:00 AM - 11:00 PM",
                "Tuesday": "6:00 AM - 11:00 PM",
                "Wednesday": "6:00 AM - 11:00 PM",
                "Thursday": "6:00 AM - 11:00 PM",
                "Friday": "6:00 AM - 10:00 PM",
                "Saturday": "8:00 AM - 10:00 PM",
                "Sunday": "8:00 AM - 11:00 PM"
            ],
            reviewIDs: [],
            averageRating: 4.0
        ),
        
        // New JSOM Spots
        StudySpot(
            id: UUID(),
            name: "JSOM 2 Main Area",
            buildingID: BuildingIDs.jsom,
            floor: 2,
            description: "JSOM 2 has plenty of tables for working. Coffee shop and vending machines available. Tables and booths directly in front of main stairs with large windows and natural light.",
            features: ["Group Space", "Natural Light", "Coffee Shop", "Vending Machines", "Booths"],
            capacity: 40,
            latitude: 32.985297924246915,
            longitude: -96.74697043881872,
            openingHours: [
                "Monday": "6:00 AM - 11:00 PM",
                "Tuesday": "6:00 AM - 11:00 PM",
                "Wednesday": "6:00 AM - 11:00 PM",
                "Thursday": "6:00 AM - 11:00 PM",
                "Friday": "6:00 AM - 10:00 PM",
                "Saturday": "8:00 AM - 10:00 PM",
                "Sunday": "8:00 AM - 11:00 PM"
            ],
            reviewIDs: [],
            averageRating: 4.1
        ),
        
        StudySpot(
            id: UUID(),
            name: "JSOM 3rd & 4th Floors",
            buildingID: BuildingIDs.jsom,
            floor: 3,
            description: "Primarily faculty offices with a few chairs and tables. Very quiet with effectively no one walking around or creating distracting noise.",
            features: ["Quiet Zone", "Individual Space", "Faculty Area"],
            capacity: 10,
            latitude: 32.985297924246915,
            longitude: -96.74697043881872,
            openingHours: [
                "Monday": "6:00 AM - 11:00 PM",
                "Tuesday": "6:00 AM - 11:00 PM",
                "Wednesday": "6:00 AM - 11:00 PM",
                "Thursday": "6:00 AM - 11:00 PM",
                "Friday": "6:00 AM - 10:00 PM",
                "Saturday": "8:00 AM - 10:00 PM",
                "Sunday": "8:00 AM - 11:00 PM"
            ],
            reviewIDs: [],
            averageRating: 4.3
        ),
        
        StudySpot(
            id: UUID(),
            name: "JSOM Undergraduate Lounge (JSOM 11.105)",
            buildingID: BuildingIDs.jsom,
            floor: 1,
            description: "Located on the first floor of JSOM. Great place for individual AND group studying.",
            features: ["Group Space", "Individual Space", "Whiteboards", "Tables"],
            capacity: 25,
            latitude: 32.985297924246915,
            longitude: -96.74697043881872,
            openingHours: [
                "Monday": "6:00 AM - 11:00 PM",
                "Tuesday": "6:00 AM - 11:00 PM",
                "Wednesday": "6:00 AM - 11:00 PM",
                "Thursday": "6:00 AM - 11:00 PM",
                "Friday": "6:00 AM - 10:00 PM",
                "Saturday": "8:00 AM - 10:00 PM",
                "Sunday": "8:00 AM - 11:00 PM"
            ],
            reviewIDs: [],
            averageRating: 4.2
        ),
        
        // Existing SLC Spots
        StudySpot(
            id: UUID(),
            name: "SLC Commons",
            buildingID: BuildingIDs.slc,
            floor: 1,
            description: "Large open study space with various seating options",
            features: ["Group Space", "Individual Desks", "Power Outlets", "Vending Machines"],
            capacity: 100,
            latitude: 32.98811670344322,
            longitude: -96.75019295790247,
            openingHours: [
                "Monday": "7:00 AM - 10:00 PM",
                "Tuesday": "7:00 AM - 10:00 PM",
                "Wednesday": "7:00 AM - 10:00 PM",
                "Thursday": "7:00 AM - 10:00 PM",
                "Friday": "7:00 AM - 8:00 PM",
                "Saturday": "9:00 AM - 6:00 PM",
                "Sunday": "12:00 PM - 10:00 PM"
            ],
            reviewIDs: [],
            averageRating: 4.3
        ),
        
        // Existing Founders Building Spots
        StudySpot(
            id: UUID(),
            name: "Founders Study Nook",
            buildingID: BuildingIDs.founders,
            floor: 1,
            description: "Cozy study area with comfortable seating",
            features: ["Individual Space", "Comfortable Seating", "Quiet Zone"],
            capacity: 15,
            latitude: 32.987867521651346,
            longitude: -96.74904891953264,
            openingHours: [
                "Monday": "6:00 AM - 11:00 PM",
                "Tuesday": "6:00 AM - 11:00 PM",
                "Wednesday": "6:00 AM - 11:00 PM",
                "Thursday": "6:00 AM - 11:00 PM",
                "Friday": "6:00 AM - 10:00 PM",
                "Saturday": "8:00 AM - 10:00 PM",
                "Sunday": "8:00 AM - 11:00 PM"
            ],
            reviewIDs: [],
            averageRating: 4.1
        ),
        
        StudySpot(
            id: UUID(),
            name: "Founders Lab",
            buildingID: BuildingIDs.founders,
            floor: 2,
            description: "Computer lab with workstations and collaborative space",
            features: ["Computer Lab", "Workstations", "Group Space", "Power Outlets"],
            capacity: 25,
            latitude: 32.987867521651346,
            longitude: -96.74904891953264,
            openingHours: [
                "Monday": "6:00 AM - 11:00 PM",
                "Tuesday": "6:00 AM - 11:00 PM",
                "Wednesday": "6:00 AM - 11:00 PM",
                "Thursday": "6:00 AM - 11:00 PM",
                "Friday": "6:00 AM - 10:00 PM",
                "Saturday": "8:00 AM - 10:00 PM",
                "Sunday": "8:00 AM - 11:00 PM"
            ],
            reviewIDs: [],
            averageRating: 4.3
        ),
        
        // Existing ECSW Spots
        StudySpot(
            id: UUID(),
            name: "ECSW 2.160 Study Area",
            buildingID: BuildingIDs.ecsw,
            floor: 2,
            description: "Modern study space with computer workstations",
            features: ["Computer Lab", "Individual Desks", "Power Outlets", "Printing"],
            capacity: 40,
            latitude: 32.98643879369642,
            longitude: -96.7516191834753,
            openingHours: [
                "Monday": "6:00 AM - 11:00 PM",
                "Tuesday": "6:00 AM - 11:00 PM",
                "Wednesday": "6:00 AM - 11:00 PM",
                "Thursday": "6:00 AM - 11:00 PM",
                "Friday": "6:00 AM - 10:00 PM",
                "Saturday": "8:00 AM - 10:00 PM",
                "Sunday": "8:00 AM - 11:00 PM"
            ],
            reviewIDs: [],
            averageRating: 4.4
        ),
        
        // New ECSW Spots
        StudySpot(
            id: UUID(),
            name: "ECSW Atrium",
            buildingID: BuildingIDs.ecsw,
            floor: 1,
            description: "Seating in the 1st floor atrium (lobby area) by the entrance windows and under the main stairs.",
            features: ["Natural Light", "Lobby Area", "Individual Space"],
            capacity: 20,
            latitude: 32.98643879369642,
            longitude: -96.7516191834753,
            openingHours: [
                "Monday": "6:00 AM - 11:00 PM",
                "Tuesday": "6:00 AM - 11:00 PM",
                "Wednesday": "6:00 AM - 11:00 PM",
                "Thursday": "6:00 AM - 11:00 PM",
                "Friday": "6:00 AM - 10:00 PM",
                "Saturday": "8:00 AM - 10:00 PM",
                "Sunday": "8:00 AM - 11:00 PM"
            ],
            reviewIDs: [],
            averageRating: 4.0
        ),
        
        StudySpot(
            id: UUID(),
            name: "ECSW Bird's Nest",
            buildingID: BuildingIDs.ecsw,
            floor: 2,
            description: "Large open area on the 2nd floor with booths, tall tables, and short tables.",
            features: ["Group Space", "Booths", "Tall Tables", "Open Area"],
            capacity: 50,
            latitude: 32.98643879369642,
            longitude: -96.7516191834753,
            openingHours: [
                "Monday": "6:00 AM - 11:00 PM",
                "Tuesday": "6:00 AM - 11:00 PM",
                "Wednesday": "6:00 AM - 11:00 PM",
                "Thursday": "6:00 AM - 11:00 PM",
                "Friday": "6:00 AM - 10:00 PM",
                "Saturday": "8:00 AM - 10:00 PM",
                "Sunday": "8:00 AM - 11:00 PM"
            ],
            reviewIDs: [],
            averageRating: 4.2
        ),
        
        StudySpot(
            id: UUID(),
            name: "ECSW Corner Study Nooks",
            buildingID: BuildingIDs.ecsw,
            floor: 2,
            description: "Seating in most corners on all floors. Some spots out in the open next to classrooms and some more tucked away. Typically have whiteboards and accessible outlets.",
            features: ["Individual Space", "Whiteboards", "Power Outlets", "Quiet Corners"],
            capacity: 30,
            latitude: 32.98643879369642,
            longitude: -96.7516191834753,
            openingHours: [
                "Monday": "6:00 AM - 11:00 PM",
                "Tuesday": "6:00 AM - 11:00 PM",
                "Wednesday": "6:00 AM - 11:00 PM",
                "Thursday": "6:00 AM - 11:00 PM",
                "Friday": "6:00 AM - 10:00 PM",
                "Saturday": "8:00 AM - 10:00 PM",
                "Sunday": "8:00 AM - 11:00 PM"
            ],
            reviewIDs: [],
            averageRating: 4.3
        ),
        
        StudySpot(
            id: UUID(),
            name: "ECSW Balcony Seating",
            buildingID: BuildingIDs.ecsw,
            floor: 2,
            description: "Outdoor seating on 2nd and 3rd floor balconies open until 7pm. Small round tables and rectangular tall tables. Great for natural light and fresh air.",
            features: ["Outdoor", "Natural Light", "Fresh Air", "Round Tables", "Tall Tables"],
            capacity: 25,
            latitude: 32.98643879369642,
            longitude: -96.7516191834753,
            openingHours: [
                "Monday": "6:00 AM - 7:00 PM",
                "Tuesday": "6:00 AM - 7:00 PM",
                "Wednesday": "6:00 AM - 7:00 PM",
                "Thursday": "6:00 AM - 7:00 PM",
                "Friday": "6:00 AM - 7:00 PM",
                "Saturday": "8:00 AM - 7:00 PM",
                "Sunday": "8:00 AM - 7:00 PM"
            ],
            reviewIDs: [],
            averageRating: 4.5
        ),
        
        // New Davidson Gundy Alumni Center Spots
        StudySpot(
            id: UUID(),
            name: "Alumni Center Outdoor Seating",
            buildingID: BuildingIDs.dgac,
            floor: 1,
            description: "Outside seating with chairs and tables. Great area to sit and enjoy nature on nice weather days with low foot traffic.",
            features: ["Outdoor", "Natural Setting", "Low Traffic", "Weather Dependent"],
            capacity: 15,
            latitude: 32.98550,
            longitude: -96.74850,
            openingHours: [
                "Monday": "8:00 AM - 6:00 PM",
                "Tuesday": "8:00 AM - 6:00 PM",
                "Wednesday": "8:00 AM - 6:00 PM",
                "Thursday": "8:00 AM - 6:00 PM",
                "Friday": "8:00 AM - 5:00 PM",
                "Saturday": "Closed",
                "Sunday": "Closed"
            ],
            reviewIDs: [],
            averageRating: 4.0
        ),
        
        // New Green Hall Spots
        StudySpot(
            id: UUID(),
            name: "Green Hall Pit",
            buildingID: BuildingIDs.greenHall,
            floor: 1,
            description: "Several high and low tables on the first floor. Study spaces bordering and in the pit with accessible outlets. Best for individual or 2-3 person studying.",
            features: ["Individual Space", "Small Groups", "Power Outlets", "High Tables", "Low Tables"],
            capacity: 20,
            latitude: 32.98720,
            longitude: -96.75100,
            openingHours: [
                "Monday": "6:00 AM - 11:00 PM",
                "Tuesday": "6:00 AM - 11:00 PM",
                "Wednesday": "6:00 AM - 11:00 PM",
                "Thursday": "6:00 AM - 11:00 PM",
                "Friday": "6:00 AM - 10:00 PM",
                "Saturday": "8:00 AM - 10:00 PM",
                "Sunday": "8:00 AM - 11:00 PM"
            ],
            reviewIDs: [],
            averageRating: 4.1
        ),
        
        StudySpot(
            id: UUID(),
            name: "Jonsson-Green Sky Bridge",
            buildingID: BuildingIDs.greenHall,
            floor: 4,
            description: "Cubicle seating located on the 4th floor Jonsson and 4th floor Green Hall connection (Skybridge JO to GR).",
            features: ["Individual Space", "Cubicles", "Bridge Connection", "Quiet Zone"],
            capacity: 12,
            latitude: 32.98720,
            longitude: -96.75100,
            openingHours: [
                "Monday": "6:00 AM - 11:00 PM",
                "Tuesday": "6:00 AM - 11:00 PM",
                "Wednesday": "6:00 AM - 11:00 PM",
                "Thursday": "6:00 AM - 11:00 PM",
                "Friday": "6:00 AM - 10:00 PM",
                "Saturday": "8:00 AM - 10:00 PM",
                "Sunday": "8:00 AM - 11:00 PM"
            ],
            reviewIDs: [],
            averageRating: 4.2
        ),
        
        // New Sciences Building Spots
        StudySpot(
            id: UUID(),
            name: "SCI Lecture Hall (SCI 1.220)",
            buildingID: BuildingIDs.sciences,
            floor: 1,
            description: "Large lecture hall utilized as a library room or giant coworking quiet study room. Has whiteboards available. Not available during scheduled classes.",
            features: ["Large Space", "Whiteboards", "Quiet Zone", "Class Schedule Dependent"],
            capacity: 100,
            latitude: 32.98650,
            longitude: -96.74950,
            openingHours: [
                "Monday": "6:00 AM - 11:00 PM",
                "Tuesday": "6:00 AM - 11:00 PM",
                "Wednesday": "6:00 AM - 11:00 PM",
                "Thursday": "6:00 AM - 11:00 PM",
                "Friday": "6:00 AM - 10:00 PM",
                "Saturday": "8:00 AM - 10:00 PM",
                "Sunday": "8:00 AM - 11:00 PM"
            ],
            reviewIDs: [],
            averageRating: 4.0
        ),
        
        StudySpot(
            id: UUID(),
            name: "SCI Elevated Tables",
            buildingID: BuildingIDs.sciences,
            floor: 1,
            description: "Several tall tables with barstool chairs and some short tables outside SCI 1.220. Lots of natural light and accessible outlets near windows. Next to UTD market.",
            features: ["Tall Tables", "Natural Light", "Power Outlets", "Near Market", "Barstool Chairs"],
            capacity: 30,
            latitude: 32.98650,
            longitude: -96.74950,
            openingHours: [
                "Monday": "6:00 AM - 11:00 PM",
                "Tuesday": "6:00 AM - 11:00 PM",
                "Wednesday": "6:00 AM - 11:00 PM",
                "Thursday": "6:00 AM - 11:00 PM",
                "Friday": "6:00 AM - 10:00 PM",
                "Saturday": "8:00 AM - 10:00 PM",
                "Sunday": "8:00 AM - 11:00 PM"
            ],
            reviewIDs: [],
            averageRating: 4.3
        ),
        
        // New Student Services Addition Spots
        StudySpot(
            id: UUID(),
            name: "SSA Fourth Floor",
            buildingID: BuildingIDs.ssa,
            floor: 4,
            description: "Tons of tables with no talking restrictions like the library! Perfect for catching up with friends or killing time between classes.",
            features: ["Group Space", "No Talking Restrictions", "Booths", "Individual Seating", "Social"],
            capacity: 60,
            latitude: 32.98600,
            longitude: -96.74800,
            openingHours: [
                "Monday": "7:00 AM - 10:00 PM",
                "Tuesday": "7:00 AM - 10:00 PM",
                "Wednesday": "7:00 AM - 10:00 PM",
                "Thursday": "7:00 AM - 10:00 PM",
                "Friday": "7:00 AM - 8:00 PM",
                "Saturday": "9:00 AM - 6:00 PM",
                "Sunday": "12:00 PM - 10:00 PM"
            ],
            reviewIDs: [],
            averageRating: 4.1
        )
    ]
}
