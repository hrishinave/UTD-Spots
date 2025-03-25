import SwiftUI
import MapKit

struct MapView: View {
    @EnvironmentObject var viewModel: StudySpotsViewModel
    @EnvironmentObject var locationService: LocationService
    @StateObject var mapViewModel = MapViewModel()
    
    @State private var selectedSpot: StudySpot?
    @State private var showingDetail = false
    
    var body: some View {
        ZStack {
            // Map
            MapViewRepresentable(
                region: $mapViewModel.region,
                annotations: mapViewModel.createAnnotations(from: viewModel.studySpots),
                selectedAnnotation: $mapViewModel.selectedAnnotation,
                showUserLocation: mapViewModel.showUserLocation,
                userTrackingMode: $mapViewModel.userTrackingMode,
                routeOverlays: mapViewModel.routeOverlays,
                onAnnotationSelected: { annotation in
                    if let spot = annotation as? StudySpotAnnotation {
                        selectedSpot = spot.spot
                        showingDetail = true
                    }
                }
            )
            .ignoresSafeArea(edges: .top)
            
            // Controls overlay
            VStack {
                HStack {
                    // Reset map button
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
                    
                    // Location tracking button
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
                
                Spacer()
                
                // Bottom card for selected spot
                if let spot = selectedSpot, let building = viewModel.buildingForSpot(spot) {
                    VStack {
                        SpotCardView(
                            spot: spot,
                            building: building,
                            onFavoriteToggle: { viewModel.toggleFavorite(for: $0) },
                            distance: userDistanceToSpot(spot)
                        )
                        .padding()
                        
                        HStack {
                            Button(action: {
                                showingDetail = true
                            }) {
                                Text("View Details")
                                    .foregroundColor(.white)
                                    .padding()
                                    .frame(maxWidth: .infinity)
                                    .background(Color.blue)
                                    .cornerRadius(8)
                            }
                            
                            if let userLocation = locationService.userLocation {
                                Button(action: {
                                    mapViewModel.calculateRoute(
                                        from: userLocation.coordinate,
                                        to: spot
                                    )
                                }) {
                                    Text("Directions")
                                        .foregroundColor(.white)
                                        .padding()
                                        .frame(maxWidth: .infinity)
                                        .background(Color.green)
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
                    .transition(.move(edge: .bottom))
                }
            }
        }
        .navigationBarHidden(true)
        .sheet(isPresented: $showingDetail, onDismiss: {
            // Adjust map focus when returning from detail view
            if let spot = selectedSpot {
                mapViewModel.focusOn(spot: spot)
            }
        }) {
            if let spot = selectedSpot {
                SpotDetailView(spot: spot)
            }
        }
        .onAppear {
            locationService.startUpdatingLocation()
        }
        .onDisappear {
            locationService.stopUpdatingLocation()
        }
    }
    
    // MARK: - Helper Methods
    
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
    
    // Calculate distance from user to spot if location is available
    private func userDistanceToSpot(_ spot: StudySpot) -> Double? {
        guard let userLocation = locationService.userLocation else {
            return nil
        }
        
        return viewModel.calculateDistance(
            from: userLocation.coordinate,
            to: spot
        )
    }
}

// Map Representable to bridge UIKit's MKMapView
struct MapViewRepresentable: UIViewRepresentable {
    @Binding var region: MKCoordinateRegion
    let annotations: [StudySpotAnnotation]
    @Binding var selectedAnnotation: StudySpot?
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
        let existingAnnotations = mapView.annotations.compactMap { $0 as? StudySpotAnnotation }
        let newAnnotations = annotations.filter { annotation in
            !existingAnnotations.contains { $0.spot.id == annotation.spot.id }
        }
        mapView.addAnnotations(newAnnotations)
        
        // Remove old annotations
        let annotationsToRemove = existingAnnotations.filter { existingAnnotation in
            !annotations.contains { $0.spot.id == existingAnnotation.spot.id }
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
        var parent: MapViewRepresentable
        
        init(_ parent: MapViewRepresentable) {
            self.parent = parent
        }
        
        func mapView(_ mapView: MKMapView, didSelect annotation: MKAnnotation) {
            if let annotation = annotation as? StudySpotAnnotation {
                parent.selectedAnnotation = annotation.spot
                parent.onAnnotationSelected(annotation)
            }
        }
        
        func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
            if let polyline = overlay as? MKPolyline {
                let renderer = MKPolylineRenderer(polyline: polyline)
                renderer.strokeColor = .blue
                renderer.lineWidth = 5
                return renderer
            }
            return MKOverlayRenderer(overlay: overlay)
        }
        
        func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
            guard !annotation.isKind(of: MKUserLocation.self) else {
                return nil
            }
            
            let identifier = "studySpot"
            var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: identifier)
            
            if annotationView == nil {
                annotationView = MKMarkerAnnotationView(annotation: annotation, reuseIdentifier: identifier)
                annotationView?.canShowCallout = true
                
                let infoButton = UIButton(type: .detailDisclosure)
                annotationView?.rightCalloutAccessoryView = infoButton
            } else {
                annotationView?.annotation = annotation
            }
            
            if let markerView = annotationView as? MKMarkerAnnotationView {
                markerView.markerTintColor = .blue
                
                // Customize marker based on study spot features
                if let spotAnnotation = annotation as? StudySpotAnnotation {
                    if spotAnnotation.spot.features.contains("Quiet") {
                        markerView.glyphImage = UIImage(systemName: "book")
                    } else if spotAnnotation.spot.features.contains("Group Study") {
                        markerView.glyphImage = UIImage(systemName: "person.3")
                    } else {
                        markerView.glyphImage = UIImage(systemName: "graduationcap")
                    }
                }
            }
            
            return annotationView
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
