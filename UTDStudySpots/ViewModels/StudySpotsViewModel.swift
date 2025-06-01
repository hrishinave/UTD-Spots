import Foundation
import Combine
import CoreLocation

class StudySpotsViewModel: ObservableObject {
    @Published var studySpots: [StudySpot] = []
    @Published var buildings: [Building] = []
    @Published var reviews: [Review] = []
    
    @Published var selectedSpot: StudySpot?
    @Published var isLoading: Bool = false
    @Published var loadingProgress: Double = 0.0
    @Published var loadingMessage: String = "Initializing..."
    @Published var errorMessage: String?
    @Published var hasLoadedInitialData: Bool = false
    
    // Search and filtering
    @Published var searchText: String = ""
    @Published var selectedBuilding: Building?
    @Published var selectedFeatures: Set<String> = []
    
    // Store the original unfiltered data
    private var allStudySpots: [StudySpot] = []
    private var cancellables = Set<AnyCancellable>()
    
    // Computed property for favorite spots
    var favoriteSpots: [StudySpot] {
        return studySpots.filter { $0.isFavorite }
    }
    
    init() {
        // Don't auto-load data in init, let splash screen control it
        setupSearchFiltering()
    }
    
    private func setupSearchFiltering() {
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
        guard !hasLoadedInitialData else { return }
        
        isLoading = true
        loadingProgress = 0.0
        
        // Simulate realistic loading with progress updates
        let loadingSteps: [(progress: Double, message: String, delay: Double)] = [
            (0.2, "Connecting to campus network...", 0.5),
            (0.4, "Loading building information...", 0.5),
            (0.6, "Finding study spots...", 0.5),
            (0.8, "Checking availability...", 0.5),
            (1.0, "Finalizing setup...", 0.3)
        ]
        
        var currentDelay: Double = 0
        
        for step in loadingSteps {
            currentDelay += step.delay
            
            DispatchQueue.main.asyncAfter(deadline: .now() + currentDelay) { [weak self] in
                guard let self = self else { return }
                
                self.loadingProgress = step.progress
                self.loadingMessage = step.message
                
                // Load actual data when we reach 100%
                if step.progress == 1.0 {
                    self.loadActualData()
                }
            }
        }
    }
    
    // Load data immediately for previews and testing
    func loadDataImmediately() {
        self.buildings = Building.samples
        self.reviews = Review.samples
        self.allStudySpots = StudySpot.samples
        self.studySpots = StudySpot.samples
        self.hasLoadedInitialData = true
        self.isLoading = false
        self.loadingMessage = "Ready!"
    }
    
    private func loadActualData() {
        // Load the actual data
        self.buildings = Building.samples
        self.reviews = Review.samples
        self.allStudySpots = StudySpot.samples
        self.studySpots = StudySpot.samples // Initially show all spots
        
        // Mark as loaded and stop loading
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) { [weak self] in
            guard let self = self else { return }
            
            self.hasLoadedInitialData = true
            self.isLoading = false
            self.loadingMessage = "Ready!"
        }
    }
    
    // MARK: - Filtering
    
    func filterSpots() {
        var filteredSpots = allStudySpots
        
        // Filter by search text
        if !searchText.isEmpty {
            filteredSpots = filteredSpots.filter { spot in
                // Search in spot name
                spot.name.localizedCaseInsensitiveContains(searchText) ||
                // Search in building name
                self.buildings.first(where: { $0.id == spot.buildingID })?.name.localizedCaseInsensitiveContains(searchText) == true ||
                // Search in building code
                self.buildings.first(where: { $0.id == spot.buildingID })?.code.localizedCaseInsensitiveContains(searchText) == true ||
                // Search in description
                spot.description.localizedCaseInsensitiveContains(searchText) ||
                // Search in features
                spot.features.contains { feature in
                    feature.localizedCaseInsensitiveContains(searchText)
                }
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
    
    func clearFilters() {
        searchText = ""
        selectedBuilding = nil
        selectedFeatures.removeAll()
        studySpots = allStudySpots
    }
    
    // MARK: - Favorites
    
    func toggleFavorite(for spot: StudySpot) {
        // Use FavoritesManager to toggle favorite status
        FavoritesManager.shared.toggleFavorite(spotID: spot.id.uuidString)
        
        // Trigger UI update by updating the studySpots array
        // This forces SwiftUI to re-evaluate the isFavorite computed property
        objectWillChange.send()
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
