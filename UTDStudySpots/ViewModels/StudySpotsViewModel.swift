import Foundation
import Combine
import CoreLocation

class StudySpotsViewModel: ObservableObject {
    @Published var studySpots: [StudySpot] = []
    @Published var buildings: [Building] = []
    @Published var reviews: [Review] = []
    @Published var favoriteSpots: [StudySpot] = []
    
    @Published var selectedSpot: StudySpot?
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?
    
    // Search and filtering
    @Published var searchText: String = ""
    @Published var selectedBuilding: Building?
    @Published var selectedFeatures: Set<String> = []
    
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        loadData()
        
        // Set up search filtering
        $searchText
            .debounce(for: .milliseconds(300), scheduler: RunLoop.main)
            .sink { [weak self] _ in
                self?.filterSpots()
            }
            .store(in: &cancellables)
    }
    
    // MARK: - Data Loading
    
    func loadData() {
        isLoading = true
        
        // In a real app, this would fetch from a server or local database
        // For now, we're using sample data
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
            guard let self = self else { return }
            
            self.buildings = Building.samples
            self.reviews = Review.samples
            self.studySpots = StudySpot.samples
            
            // Update favorite spots
            self.favoriteSpots = self.studySpots.filter { $0.isFavorite }
            
            self.isLoading = false
        }
    }
    
    // MARK: - Filtering
    
    func filterSpots() {
        var filteredSpots = StudySpot.samples
        
        // Filter by search text
        if !searchText.isEmpty {
            filteredSpots = filteredSpots.filter { spot in
                spot.name.localizedCaseInsensitiveContains(searchText) ||
                self.buildings.first(where: { $0.id == spot.buildingID })?.name.localizedCaseInsensitiveContains(searchText) == true ||
                spot.description.localizedCaseInsensitiveContains(searchText)
            }
        }
        
        // Filter by selected building
        if let building = selectedBuilding {
            filteredSpots = filteredSpots.filter { $0.buildingID == building.id }
        }
        
        // Filter by selected features
        if !selectedFeatures.isEmpty {
            filteredSpots = filteredSpots.filter { spot in
                selectedFeatures.allSatisfy { feature in
                    spot.features.contains(feature)
                }
            }
        }
        
        studySpots = filteredSpots
    }
    
    // MARK: - Favorites
    
    func toggleFavorite(for spot: StudySpot) {
        if let index = studySpots.firstIndex(where: { $0.id == spot.id }) {
            var updatedSpot = studySpots[index]
            updatedSpot.isFavorite.toggle()
            studySpots[index] = updatedSpot
            
            // Update favorites list
            if updatedSpot.isFavorite {
                favoriteSpots.append(updatedSpot)
            } else {
                favoriteSpots.removeAll { $0.id == spot.id }
            }
        }
    }
    
    // MARK: - Reviews
    
    func reviewsForSpot(_ spot: StudySpot) -> [Review] {
        return reviews.filter { $0.spotID == spot.id }
    }
    
    func addReview(for spot: StudySpot, rating: Int, comment: String) {
        let newReview = Review(
            id: UUID(),
            spotID: spot.id,
            rating: rating,
            comment: comment,
            timestamp: Date(),
            userName: "Current User", // In a real app, get from user profile
            userID: nil
        )
        
        reviews.append(newReview)
    }
    
    // MARK: - Building Info
    
    func buildingForSpot(_ spot: StudySpot) -> Building? {
        return buildings.first(where: { $0.id == spot.buildingID })
    }
    
    // MARK: - Distance Calculation
    
    func calculateDistance(from userLocation: CLLocationCoordinate2D, to spot: StudySpot) -> Double {
        let userLoc = CLLocation(latitude: userLocation.latitude, longitude: userLocation.longitude)
        let spotLoc = CLLocation(latitude: spot.latitude, longitude: spot.longitude)
        
        return userLoc.distance(from: spotLoc) // Distance in meters
    }
} 
