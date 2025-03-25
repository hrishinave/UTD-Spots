import Foundation

struct Review: Identifiable, Codable {
    let id: UUID
    let spotID: UUID
    let rating: Int // 1-5 stars
    let comment: String
    let timestamp: Date
    let userName: String
    
    // Optional user ID for authenticated users
    let userID: String?
}

// Extension for sample data
extension Review {
    static let samples: [Review] = [
        Review(
            id: UUID(),
            spotID: StudySpot.samples[0].id,
            rating: 5,
            comment: "Super quiet and peaceful. Perfect for focused study.",
            timestamp: Date().addingTimeInterval(-86400 * 2), // 2 days ago
            userName: "StudiousComet",
            userID: nil
        ),
        Review(
            id: UUID(),
            spotID: StudySpot.samples[0].id,
            rating: 4,
            comment: "Great space but can get crowded during finals week.",
            timestamp: Date().addingTimeInterval(-86400 * 5), // 5 days ago
            userName: "AcademicAce",
            userID: nil
        ),
        Review(
            id: UUID(),
            spotID: StudySpot.samples[1].id,
            rating: 5,
            comment: "Best place for group work. Plenty of whiteboards and space.",
            timestamp: Date().addingTimeInterval(-86400 * 1), // 1 day ago
            userName: "TeamWorkPro",
            userID: nil
        ),
        Review(
            id: UUID(),
            spotID: StudySpot.samples[2].id,
            rating: 3,
            comment: "Good location but gets noisy sometimes.",
            timestamp: Date().addingTimeInterval(-86400 * 7), // 1 week ago
            userName: "QuietSeeker",
            userID: nil
        )
    ]
} 
