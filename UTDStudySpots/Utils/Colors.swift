import SwiftUI

extension Color {
    // UTD Official Colors
    static let utdOrange = Color(red: 199/255, green: 91/255, blue: 18/255)  // #C75B12
    static let utdGreen = Color(red: 21/255, green: 71/255, blue: 52/255)    // #154734
    
    // Secondary colors for UI elements
    static let utdLightOrange = Color(red: 199/255, green: 91/255, blue: 18/255).opacity(0.2)
    static let utdLightGreen = Color(red: 21/255, green: 71/255, blue: 52/255).opacity(0.2)
}

// UI Theme configuration
extension View {
    func utdPrimaryButtonStyle() -> some View {
        self.foregroundColor(.white)
            .padding()
            .background(Color.utdOrange)
            .cornerRadius(10)
    }
    
    func utdSecondaryButtonStyle() -> some View {
        self.foregroundColor(.utdOrange)
            .padding()
            .background(Color.utdLightOrange)
            .cornerRadius(10)
    }
}
