import SwiftUI
import CoreLocation


struct BuildingsListView: View {
    @StateObject private var viewModel = StudySpotsViewModel()
    
    var body: some View {
        NavigationView {
            ScrollView {
                LazyVStack(spacing: 30) {
                    if viewModel.buildings.isEmpty {
                        Text("Loading buildings...")
                    } else {
                        ForEach(sortedBuildings) { building in
                            NavigationLink(destination: BuildingDetailView(building: building)) {
                                VStack(alignment: .leading, spacing: 8) {
                                    // Image Section
                                    if !building.imageNames.isEmpty {
                                        Image(building.imageNames[0])
                                            .resizable()
                                            .scaledToFill()
                                            .frame(width: 363, height: 200)
                                            .clipped()
                                    }
                                    
                                    // Info Section
                                    VStack(alignment: .leading, spacing: 4) {
                                        HStack {
                                            Text(building.name)
                                                .font(.headline)
                                                .foregroundColor(.utdGreen)
                                            
                                            Spacer()
                                            
                                            Text(building.isCurrentlyOpen ? "Open" : "Closed")
                                                .font(.subheadline)
                                                .padding(.horizontal, 8)
                                                .padding(.vertical, 4)
                                                .background(building.isCurrentlyOpen ? Color.utdGreen.opacity(0.2) : Color.red.opacity(0.2))
                                                .foregroundColor(building.isCurrentlyOpen ? .utdGreen : .red)
                                                .cornerRadius(4)
                                        }
                                        
                                        Text(building.code)
                                            .font(.subheadline)
                                            .foregroundColor(.secondary)
                                    }
                                    .padding(.horizontal, 12)
                                    .padding(.bottom, 12)
                                }
                                .background(Color(.systemBackground))
                                .cornerRadius(12)
                                .shadow(color: Color.black.opacity(0.2), radius: 5, x: 0, y: 2)
                            }
                            .padding(.horizontal)
                            .padding(.vertical, 4)
                        }
                    }
                }
                .padding(.top,30)
                .padding(.bottom,8)
            }
            .navigationTitle("Buildings")
            .background(Color(.systemGroupedBackground).ignoresSafeArea())
        }
        .environmentObject(viewModel)
    }
    
    private var sortedBuildings: [Building] {
        return viewModel.buildings.sorted { $0.name < $1.name }
    }
}

class PreviewStudySpotsViewModel: StudySpotsViewModel {
    override init() {
        super.init()
        self.buildings = Building.samples
    }
}

struct BuildingsListView_Previews: PreviewProvider {
    static var previews: some View {
        let viewModel = StudySpotsViewModel()
        viewModel.buildings = Building.samples // Directly set the buildings for preview
        return BuildingsListView()
            .environmentObject(viewModel)
            .environmentObject(LocationService())
    }
}
