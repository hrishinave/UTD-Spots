import SwiftUI

struct FilterView: View {
    let buildings: [Building]
    @Binding var selectedBuilding: Building?
    @Binding var selectedFeatures: Set<String>
    let onApplyFilters: () -> Void
    
    @State private var tempSelectedBuilding: Building?
    @State private var tempSelectedFeatures: Set<String> = []
    @Environment(\.presentationMode) var presentationMode
    
    // Updated features to match actual study spot data
    let availableFeatures = [
        "Group Space", "Individual Space", "Silent Zone", "Quiet Zone",
        "Power Outlets", "Natural Light", "Whiteboard", "Whiteboards",
        "Computer Lab", "Workstations", "TV Screen", "Large Table",
        "Comfortable Seating", "Individual Desks", "Printing",
        "Coffee Shop", "Vending Machines", "Booths", "Tall Tables",
        "Open Area", "Outdoor", "Fresh Air", "Reservable",
        "Extended Hours", "24 Hours", "Study Rooms", "Cubicles"
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
                    LazyVGrid(columns: [
                        GridItem(.flexible()),
                        GridItem(.flexible())
                    ], spacing: 8) {
                        ForEach(availableFeatures.sorted(), id: \.self) { feature in
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
                
                Section {
                    HStack {
                        Button("Reset Filters") {
                            tempSelectedBuilding = nil
                            tempSelectedFeatures.removeAll()
                        }
                        .foregroundColor(.red)
                        
                        Spacer()
                        
                        Text("\(tempSelectedFeatures.count) features selected")
                            .font(.caption)
                            .foregroundColor(.secondary)
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
                    .fontWeight(.semibold)
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
                .font(.caption)
                .fontWeight(isSelected ? .semibold : .regular)
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(isSelected ? Color.utdOrange : Color.gray.opacity(0.1))
                .foregroundColor(isSelected ? .white : .primary)
                .cornerRadius(12)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(isSelected ? Color.utdOrange : Color.gray.opacity(0.3), lineWidth: 1)
                )
        }
        .buttonStyle(PlainButtonStyle())
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
