import Foundation
import MapKit
import Combine

class MapViewModel: ObservableObject {
    @Published var region = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 32.9886, longitude: -96.7503), // UTD's coordinates
        span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
    )
    
    @Published var userTrackingMode: MKUserTrackingMode = .none
    @Published var showUserLocation: Bool = true
    @Published var selectedAnnotation: StudySpot?
    @Published var routeOverlays: [MKOverlay] = []
    
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - Annotation Management
    
    func createAnnotations(from spots: [StudySpot]) -> [StudySpotAnnotation] {
        return spots.map { spot in
            StudySpotAnnotation(
                coordinate: spot.coordinates,
                title: spot.name,
                subtitle: "Tap for details",
                spot: spot
            )
        }
    }
    
    // MARK: - Routing
    
    func calculateRoute(from userLocation: CLLocationCoordinate2D, to spot: StudySpot) {
        let request = MKDirections.Request()
        request.source = MKMapItem(placemark: MKPlacemark(coordinate: userLocation))
        request.destination = MKMapItem(placemark: MKPlacemark(coordinate: spot.coordinates))
        request.transportType = .walking
        
        let directions = MKDirections(request: request)
        directions.calculate { [weak self] response, error in
            guard let self = self, let route = response?.routes.first else {
                print("Error calculating route: \(error?.localizedDescription ?? "Unknown error")")
                return
            }
            
            self.routeOverlays = [route.polyline]
            
            // Adjust the map view to show the entire route
            let padding: CGFloat = 50
            let mapRect = route.polyline.boundingMapRect
            self.region = MKCoordinateRegion(mapRect)
        }
    }
    
    // MARK: - Region Management
    
    func focusOn(spot: StudySpot) {
        region = MKCoordinateRegion(
            center: spot.coordinates,
            span: MKCoordinateSpan(latitudeDelta: 0.002, longitudeDelta: 0.002)
        )
        selectedAnnotation = spot
    }
    
    func resetRegionToUTD() {
        region = MKCoordinateRegion(
            center: CLLocationCoordinate2D(latitude: 32.9886, longitude: -96.7503), // UTD's coordinates
            span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
        )
    }
}

// Custom annotation class for study spots
class StudySpotAnnotation: NSObject, MKAnnotation {
    let coordinate: CLLocationCoordinate2D
    let title: String?
    let subtitle: String?
    let spot: StudySpot
    
    init(coordinate: CLLocationCoordinate2D, title: String?, subtitle: String?, spot: StudySpot) {
        self.coordinate = coordinate
        self.title = title
        self.subtitle = subtitle
        self.spot = spot
        super.init()
    }
} 
