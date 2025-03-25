import Foundation
import Combine

class DataService {
    // In a real app, this would include API calls, CoreData operations, etc.
    // For the prototype, we'll use the static sample data
    
    // MARK: - Data Loading
    
    func loadStudySpots() -> AnyPublisher<[StudySpot], Error> {
        // Simulate network delay
        return Future<[StudySpot], Error> { promise in
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                promise(.success(StudySpot.samples))
            }
        }
        .eraseToAnyPublisher()
    }
    
    func loadBuildings() -> AnyPublisher<[Building], Error> {
        return Future<[Building], Error> { promise in
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                promise(.success(Building.samples))
            }
        }
        .eraseToAnyPublisher()
    }
    
    func loadReviews() -> AnyPublisher<[Review], Error> {
        return Future<[Review], Error> { promise in
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.7) {
                promise(.success(Review.samples))
            }
        }
        .eraseToAnyPublisher()
    }
    
    // MARK: - Data Saving
    
    func saveReview(_ review: Review) -> AnyPublisher<Bool, Error> {
        // In a real app, this would save to a backend or local database
        return Future<Bool, Error> { promise in
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                promise(.success(true))
            }
        }
        .eraseToAnyPublisher()
    }
    
    func toggleFavorite(spotID: UUID, isFavorite: Bool) -> AnyPublisher<Bool, Error> {
        // In a real app, this would update the backend or local database
        return Future<Bool, Error> { promise in
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                promise(.success(true))
            }
        }
        .eraseToAnyPublisher()
    }
    
    // MARK: - User Settings
    
    func saveUserPreferences(preferences: [String: Any]) -> AnyPublisher<Bool, Error> {
        return Future<Bool, Error> { promise in
            // In a real app, this would save to UserDefaults or a settings database
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                promise(.success(true))
            }
        }
        .eraseToAnyPublisher()
    }
} 
