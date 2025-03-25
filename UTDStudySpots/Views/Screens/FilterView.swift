import SwiftUI

struct FilterView: View {
    let buildings: [Building]
    @Binding var selectedBuilding: Building?
    @Binding var selectedFeatures: Set<String>
    let onApplyFilters: () -> Void
    
    @State private var tempSelectedBuilding: Building?
    @State private var tempSelectedFeatures: Set<String> = []
    @Environment(\.presentationMode) var presentationMode
    
    // Common study spot features
    let availableFeatures = [
        "Quiet", "Group Study", "Individual Study", "Power Outlets",
        "WiFi", "Coffee Nearby", "Printers", "Computers",
        "Whiteboard", "Natural Light", "Window View", "24/7 Access"
    ]
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Building")) {
                    Picker("Select Building", selection: $tempSelectedBuilding) {
                        Text("All Buildings").tag(nil as Building?)
                        ForEach(buildings) { building in
                            Text(building.name).tag(building as Building?)
                        }
                    }
                }
                
                Section(header: Text("Features")) {
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 8) {
                            ForEach(availableFeatures, id: \.self) { feature in
                                FilterChipView(
                                    title: feature,
                                    isSelected: tempSelectedFeatures.contains(feature),
                                    onToggle: { selected in
                                        if selected {
                                            tempSelectedFeatures.insert(feature)
                                        } else {
                                            tempSelectedFeatures.remove(feature)
                                        }
                                    }
                                )
                            }
                        }
                        .padding(.vertical, 8)
                    }
                    .padding(.horizontal, -20) // Counteract Form's default padding
                }
                
                Section {
                    Button("Reset Filters") {
                        tempSelectedBuilding = nil
                        tempSelectedFeatures.removeAll()
                    }
                }
            }
            .navigationTitle("Filter Study Spots")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        presentationMode.wrappedValue.dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Apply") {
                        selectedBuilding = tempSelectedBuilding
                        selectedFeatures = tempSelectedFeatures
                        onApplyFilters()
                        presentationMode.wrappedValue.dismiss()
                    }
                }
            }
            .onAppear {
                // Initialize with current selections
                tempSelectedBuilding = selectedBuilding
                tempSelectedFeatures = selectedFeatures
            }
        }
    }
}

struct FilterChipView: View {
    let title: String
    let isSelected: Bool
    let onToggle: (Bool) -> Void
    
    var body: some View {
        Button(action: {
            onToggle(!isSelected)
        }) {
            Text(title)
                .font(.subheadline)
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(isSelected ? Color.blue : Color.gray.opacity(0.2))
                .foregroundColor(isSelected ? .white : .primary)
                .cornerRadius(16)
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(isSelected ? Color.blue : Color.gray.opacity(0.3), lineWidth: 1)
                )
        }
    }
}

struct FilterView_Previews: PreviewProvider {
    static var previews: some View {
        FilterView(
            buildings: Building.samples,
            selectedBuilding: .constant(nil),
            selectedFeatures: .constant([]),
            onApplyFilters: {}
        )
    }
} 
