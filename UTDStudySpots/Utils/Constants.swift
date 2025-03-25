import Foundation
import CoreLocation

// App-wide constants
struct Constants {
    // UTD Campus Location
    struct Location {
        static let utdCampusCenter = CLLocationCoordinate2D(latitude: 32.9886, longitude: -96.7503)
        static let defaultZoomSpan = 0.01 // Approximately covers the campus area
        static let detailZoomSpan = 0.005 // Closer zoom for detail views
    }
    
    // Feature categories for study spots
    struct Features {
        static let all = [
            "Quiet", "Group Study", "Individual Study", "Power Outlets",
            "WiFi", "Coffee Nearby", "Printers", "Computers",
            "Whiteboard", "Natural Light", "Window View", "24/7 Access"
        ]
        
        static let quiet = ["Quiet", "Individual Study"]
        static let group = ["Group Study", "Whiteboard"]
        static let amenities = ["Power Outlets", "WiFi", "Coffee Nearby", "Printers", "Computers"]
        static let environment = ["Natural Light", "Window View"]
    }
    
    // App Colors
    struct Colors {
        static let primary = "UTDOrange" // Define in Assets.xcassets
        static let secondary = "UTDGreen" // Define in Assets.xcassets
    }
    
    // Default UI dimensions
    struct UI {
        static let cornerRadius: CGFloat = 12
        static let buttonHeight: CGFloat = 50
        static let standardPadding: CGFloat = 16
    }
    
    // CoreData
    struct CoreData {
        static let modelName = "UTDStudySpots"
    }
    
    // UserDefaults keys
    struct UserDefaultsKeys {
        static let hasLaunchedBefore = "hasLaunchedBefore"
        static let lastViewedSpot = "lastViewedSpot"
        static let preferredSortOrder = "preferredSortOrder"
        static let lastFilterSettings = "lastFilterSettings"
    }
    
    // Notification Names
    struct NotificationNames {
        static let favoriteToggled = "favoriteToggled"
        static let newReviewAdded = "newReviewAdded"
    }
    
    // Accessibility identifiers for testing
    struct AccessibilityIdentifiers {
        static let spotsList = "spotsList"
        static let mapView = "mapView"
        static let favoritesView = "favoritesView"
        static let filterButton = "filterButton"
        static let searchField = "searchField"
    }
    
    // Error messages
    struct ErrorMessages {
        static let locationAccessDenied = "Location access is required to show your position on the map. Please enable it in Settings."
        static let failedToLoadData = "Failed to load study spots data. Please check your connection and try again."
    }
} 
