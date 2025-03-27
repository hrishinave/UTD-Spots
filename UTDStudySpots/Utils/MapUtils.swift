import Foundation
import MapKit
import SwiftUI

struct MapUtils {
    
    /// Opens Apple Maps with directions from user's current location to a destination
    static func openDirectionsInMaps(to destination: CLLocationCoordinate2D, destinationName: String) {
        let placemark = MKPlacemark(coordinate: destination)
        let mapItem = MKMapItem(placemark: placemark)
        mapItem.name = destinationName
        
        // Set directions options
        let launchOptions = [
            MKLaunchOptionsDirectionsModeKey: MKLaunchOptionsDirectionsModeWalking
        ]
        
        // Open Maps with walking directions from current location
        mapItem.openInMaps(launchOptions: launchOptions)
    }
} 
