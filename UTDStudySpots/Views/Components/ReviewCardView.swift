import SwiftUI

struct ReviewCardView: View {
    let review: Review
    
    private var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter.string(from: review.timestamp)
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(review.userName)
                    .font(.headline)
                
                Spacer()
                
                Text(formattedDate)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            HStack(spacing: 2) {
                ForEach(1...5, id: \.self) { index in
                    Image(systemName: index <= review.rating ? "star.fill" : "star")
                        .foregroundColor(.yellow)
                        .font(.caption)
                }
                Spacer()
            }
            
            Text(review.comment)
                .font(.body)
                .foregroundColor(.primary)
                .padding(.top, 4)
        }
        .padding()
        .background(Color(.secondarySystemBackground))
        .cornerRadius(12)
    }
}

struct ReviewCardView_Previews: PreviewProvider {
    static var previews: some View {
        ReviewCardView(review: Review.samples[0])
            .previewLayout(.sizeThatFits)
            .padding()
    }
} 
