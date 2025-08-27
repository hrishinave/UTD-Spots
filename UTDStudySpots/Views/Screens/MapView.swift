import SwiftUI
import MapKit
import CoreLocation

struct MapView: View {
    @EnvironmentObject var viewModel: StudySpotsViewModel
    @EnvironmentObject var locationService: LocationService
    @StateObject var mapViewModel = MapViewModel()
    
    @State private var selectedBuilding: Building?
    @State private var showingBuildingDetail = false
    @State private var showingDirectionsActionSheet = false
    
    var body: some View {
        ZStack(alignment: .center) {
            // Map
            BuildingMapViewRepresentable(
                region: $mapViewModel.region,
                annotations: mapViewModel.createBuildingAnnotations(from: viewModel.buildings),
                selectedBuilding: $mapViewModel.selectedBuilding,
                showUserLocation: mapViewModel.showUserLocation,
                userTrackingMode: $mapViewModel.userTrackingMode,
                routeOverlays: mapViewModel.routeOverlays,
                onAnnotationSelected: { annotation in
                    if let buildingAnnotation = annotation as? BuildingAnnotation {
                        selectedBuilding = buildingAnnotation.building
                    }
                }
            )
            .ignoresSafeArea(edges: .top)
        }
        // Top controls overlay (does not block map elsewhere)
        .overlay(alignment: .top) {
            HStack {
                Button(action: {
                    mapViewModel.resetRegionToUTD()
                }) {
                    Image(systemName: "arrow.counterclockwise")
                        .padding()
                        .background(Color.white)
                        .clipShape(Circle())
                        .shadow(radius: 2)
                }
                .padding(.leading)
                
                Spacer()
                
                Button(action: {
                    toggleLocationTracking()
                }) {
                    Image(systemName: locationTrackingImageName)
                        .padding()
                        .background(Color.white)
                        .clipShape(Circle())
                        .shadow(radius: 2)
                }
                .padding(.trailing)
            }
            .padding(.top, 50)
        }
        // Bottom card overlay
        .overlay(alignment: .bottom) {
            if let building = (selectedBuilding ?? mapViewModel.selectedBuilding) {
                VStack(spacing: 0) {
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            VStack(alignment: .leading, spacing: 4) {
                                Text(building.name)
                                    .font(.headline)
                                    .foregroundColor(.utdGreen)
                                Text(building.code)
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                            }
                            Spacer()
                            Text(building.isCurrentlyOpen ? "Open" : "Closed")
                                .font(.caption)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 4)
                                .background(building.isCurrentlyOpen ? Color.utdGreen.opacity(0.2) : Color.red.opacity(0.2))
                                .foregroundColor(building.isCurrentlyOpen ? .utdGreen : .red)
                                .cornerRadius(4)
                        }
                        Text(building.address)
                            .font(.caption)
                            .foregroundColor(.secondary)
                        if let todayHours = getTodayHours(for: building) {
                            Text("Today: \(todayHours)")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                    .padding()
                    
                    HStack {
                        Button(action: {
                            selectedBuilding = building
                            showingBuildingDetail = true
                        }) {
                            Text("View Spots")
                                .foregroundColor(.white)
                                .padding()
                                .frame(maxWidth: .infinity)
                                .background(Color.utdOrange)
                                .cornerRadius(8)
                        }
                        if locationService.userLocation != nil {
                            Button(action: { showingDirectionsActionSheet = true }) {
                                Text("Directions")
                                    .foregroundColor(.white)
                                    .padding()
                                    .frame(maxWidth: .infinity)
                                    .background(Color.utdGreen)
                                    .cornerRadius(8)
                            }
                        }
                    }
                    .padding(.horizontal)
                    .padding(.bottom)
                }
                .background(Color(.systemBackground))
                .cornerRadius(16)
                .shadow(radius: 5)
                .padding()
                .padding(.bottom, 90)
                .transition(.move(edge: .bottom))
            }
        }
        .navigationBarHidden(true)
        .sheet(isPresented: $showingBuildingDetail, onDismiss: {
            // Clear the selected building when returning from detail view
            selectedBuilding = nil
            mapViewModel.selectedBuilding = nil
        }) {
            if let building = selectedBuilding {
                NavigationStack {
                    SpotsInBuildingView(building: building)
                        .environmentObject(viewModel)
                        .environmentObject(locationService)
                }
            }
        }
        .actionSheet(isPresented: $showingDirectionsActionSheet) {
            directionActionSheet()
        }
        .onAppear {
            locationService.startUpdatingLocation()
        }
        .onDisappear {
            locationService.stopUpdatingLocation()
        }
    }
    
    // MARK: - Helper Methods
    
    private func directionActionSheet() -> ActionSheet {
        guard let building = selectedBuilding else {
            return ActionSheet(title: Text("Error"), message: Text("No building selected"), buttons: [.cancel()])
        }
        
        let title = Text("Directions to \(building.name)")
        let message = Text("Choose how to get directions")
        
        return ActionSheet(title: title, message: message, buttons: [
            .default(Text("Show in App")) { 
                if let userLocation = locationService.userLocation {
                    mapViewModel.calculateRouteToBuilding(
                        from: userLocation.coordinate,
                        to: building
                    )
                }
            },
            .default(Text("Open in Apple Maps")) {
                MapUtils.openDirectionsInMaps(to: building.coordinates, destinationName: building.name)
            },
            .cancel()
        ])
    }
    
    private var locationTrackingImageName: String {
        switch mapViewModel.userTrackingMode {
        case .none:
            return "location"
        case .follow:
            return "location.fill"
        case .followWithHeading:
            return "location.north.line.fill"
        @unknown default:
            return "location"
        }
    }
    
    private func toggleLocationTracking() {
        switch mapViewModel.userTrackingMode {
        case .none:
            mapViewModel.userTrackingMode = .follow
        case .follow:
            mapViewModel.userTrackingMode = .followWithHeading
        case .followWithHeading:
            mapViewModel.userTrackingMode = .none
        @unknown default:
            mapViewModel.userTrackingMode = .none
        }
    }
    
    private func getTodayHours(for building: Building) -> String? {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "EEEE" // Full weekday name
        let weekday = dateFormatter.string(from: Date())
        return building.openingHours[weekday]
    }
}

// Map Representable to bridge UIKit's MKMapView for buildings
struct BuildingMapViewRepresentable: UIViewRepresentable {
    @Binding var region: MKCoordinateRegion
    let annotations: [BuildingAnnotation]
    @Binding var selectedBuilding: Building?
    let showUserLocation: Bool
    @Binding var userTrackingMode: MKUserTrackingMode
    let routeOverlays: [MKOverlay]
    let onAnnotationSelected: (MKAnnotation) -> Void
    
    func makeUIView(context: Context) -> MKMapView {
        let mapView = MKMapView()
        mapView.delegate = context.coordinator
        mapView.region = region
        mapView.showsUserLocation = showUserLocation
        mapView.userTrackingMode = userTrackingMode
        return mapView
    }
    
    func updateUIView(_ mapView: MKMapView, context: Context) {
        mapView.region = region
        mapView.showsUserLocation = showUserLocation
        mapView.userTrackingMode = userTrackingMode
        
        // Update annotations
        let existingAnnotations = mapView.annotations.compactMap { $0 as? BuildingAnnotation }
        let newAnnotations = annotations.filter { annotation in
            !existingAnnotations.contains { $0.building.id == annotation.building.id }
        }
        mapView.addAnnotations(newAnnotations)
        
        // Remove old annotations
        let annotationsToRemove = existingAnnotations.filter { existingAnnotation in
            !annotations.contains { $0.building.id == existingAnnotation.building.id }
        }
        mapView.removeAnnotations(annotationsToRemove)
        
        // Update route overlays
        mapView.removeOverlays(mapView.overlays)
        mapView.addOverlays(routeOverlays)
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, MKMapViewDelegate {
        var parent: BuildingMapViewRepresentable
        
        init(_ parent: BuildingMapViewRepresentable) {
            self.parent = parent
        }
        
        func mapView(_ mapView: MKMapView, didSelect annotation: MKAnnotation) {
            if let annotation = annotation as? BuildingAnnotation {
                parent.selectedBuilding = annotation.building
                parent.onAnnotationSelected(annotation)
            }
        }
        
        func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
            if let polyline = overlay as? MKPolyline {
                let renderer = MKPolylineRenderer(polyline: polyline)
                renderer.strokeColor = UIColor(Color.utdOrange)
                renderer.lineWidth = 5
                renderer.lineJoin = .round
                renderer.lineCap = .round
                renderer.alpha = 0.9
                return renderer
            }
            return MKOverlayRenderer(overlay: overlay)
        }
        
        func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
            guard !annotation.isKind(of: MKUserLocation.self) else {
                return nil
            }
            
            let identifier = "building"
            var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: identifier) as? MKMarkerAnnotationView
            
            if annotationView == nil {
                annotationView = MKMarkerAnnotationView(annotation: annotation, reuseIdentifier: identifier)
                annotationView?.canShowCallout = false
            } else {
                annotationView?.annotation = annotation
            }
            
            // Customize building pins
            if let buildingAnnotation = annotation as? BuildingAnnotation {
                annotationView?.markerTintColor = UIColor(Color.utdGreen)
                annotationView?.glyphImage = UIImage(systemName: "building.2")
            }
            
            return annotationView
        }
        
        func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
            if let annotation = view.annotation as? BuildingAnnotation {
                parent.selectedBuilding = annotation.building
                parent.onAnnotationSelected(annotation)
            }
        }
    }
}

struct MapView_Previews: PreviewProvider {
    static var previews: some View {
        MapView()
            .environmentObject(StudySpotsViewModel())
            .environmentObject(LocationService())
    }
} 

// Inline SpotsInBuildingView to ensure availability without project file edits
struct SpotsInBuildingView: View {
    @EnvironmentObject var viewModel: StudySpotsViewModel
    @EnvironmentObject var locationService: LocationService
    let building: Building
    @Environment(\.dismiss) private var dismiss
    
    private var spotsInBuilding: [StudySpot] {
        viewModel.studySpots.filter { $0.buildingID == building.id }
    }
    
    var body: some View {
        VStack(spacing: 0) {
            if spotsInBuilding.isEmpty {
                EmptyStateView(
                    title: "No spots found",
                    message: "There are no study spots for this building.",
                    systemImage: "magnifyingglass"
                )
                .padding()
            } else {
                ScrollView {
                    LazyVStack(spacing: 16) {
                        ForEach(spotsInBuilding) { spot in
                            NavigationLink(destination: SpotDetailView(spot: spot)) {
                                SpotCardView(
                                    spot: spot,
                                    building: building,
                                    onFavoriteToggle: { viewModel.toggleFavorite(for: $0) },
                                    distance: userDistanceToSpot(spot)
                                )
                                .frame(maxWidth: .infinity)
                                .padding(.horizontal)
                            }
                            .buttonStyle(PlainButtonStyle())
                        }
                    }
                    .padding(.vertical)
                }
            }
        }
        .navigationTitle(building.name)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button(action: { dismiss() }) {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(.utdOrange)
                }
            }
        }
    }
    
    private func userDistanceToSpot(_ spot: StudySpot) -> Double? {
        guard let userLocation = locationService.userLocation else {
            return nil
        }
        let meters = viewModel.calculateDistance(
            from: userLocation.coordinate,
            to: spot
        )
        return meters * 3.28084
    }
}
