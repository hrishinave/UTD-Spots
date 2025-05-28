
import Foundation

class FavoritesManager {
    static let shared = FavoritesManager()
    private let favoritesKey = "userFavoriteSpots"
    
    private init() {}
    
    // Save favorite spot IDs to UserDefaults
    func saveFavorites(_ spotIDs: [String]) {
        UserDefaults.standard.set(spotIDs, forKey: favoritesKey)
    }
    
    // Load favorite spot IDs from UserDefaults
    func loadFavorites() -> [String] {
        return UserDefaults.standard.stringArray(forKey: favoritesKey) ?? []
    }
    
    // Add a spot to favorites
    func addFavorite(spotID: String) {
        var favorites = loadFavorites()
        if !favorites.contains(spotID) {
            favorites.append(spotID)
            saveFavorites(favorites)
        }
    }
    
    // Remove a spot from favorites
    func removeFavorite(spotID: String) {
        var favorites = loadFavorites()
        favorites.removeAll { $0 == spotID }
        saveFavorites(favorites)
    }
    
    // Check if a spot is favorited
    func isFavorite(spotID: String) -> Bool {
        return loadFavorites().contains(spotID)
    }
    
    // Toggle favorite status for a spot
    func toggleFavorite(spotID: String) {
        if isFavorite(spotID: spotID) {
            removeFavorite(spotID: spotID)
        } else {
            addFavorite(spotID: spotID)
        }
    }
} 
