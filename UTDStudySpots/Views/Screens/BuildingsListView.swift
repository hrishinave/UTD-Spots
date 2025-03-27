import SwiftUI

struct BuildingsListView: View {
    @EnvironmentObject var viewModel: StudySpotsViewModel
    
    var body: some View {
        NavigationView {
            List {
                ForEach(sortedBuildings) { building in
                    NavigationLink(destination: BuildingDetailView(building: building)) {
                        HStack {
                            VStack(alignment: .leading, spacing: 4) {
                                Text(building.name)
                                    .font(.headline)
                                    .foregroundColor(.utdGreen)
                                
                                Text(building.code)
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                            }
                            
                            Spacer()
                            
                            // Availability badge
                            Text(building.isCurrentlyOpen ? "Open" : "Closed")
                                .font(.caption)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 4)
                                .background(building.isCurrentlyOpen ? Color.utdGreen.opacity(0.2) : Color.red.opacity(0.2))
                                .foregroundColor(building.isCurrentlyOpen ? .utdGreen : .red)
                                .cornerRadius(4)
                        }
                        .padding(.vertical, 4)
                    }
                }
            }
            .navigationTitle("UTD Buildings")
            .listStyle(InsetGroupedListStyle())
        }
    }
    
    // Sort buildings alphabetically by name
    private var sortedBuildings: [Building] {
        return viewModel.buildings.sorted { $0.name < $1.name }
    }
}

struct BuildingsListView_Previews: PreviewProvider {
    static var previews: some View {
        BuildingsListView()
            .environmentObject(StudySpotsViewModel())
    }
}
