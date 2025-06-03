import SwiftUI
import CoreLocation

struct BuildingsListView: View {
    @EnvironmentObject var viewModel: StudySpotsViewModel
    @State private var animateItems = false
    
    var body: some View {
        ZStack {
            Color.white
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Custom Header
                HStack {
                    
                    Spacer()
                    
                    Text("UTD Buildings")
                        .font(.title)
                        .fontWeight(.bold)
                        .foregroundColor(.black)
                
                    Spacer()
                    
                    // Invisible spacer to center the title
                    Image(systemName: "chevron.left")
                        .font(.title2)
                        .opacity(0)
                }
                .padding(.horizontal, 20)
                .padding(.top, 10)
                .padding(.bottom, 30)
                
                // Buildings List
                if viewModel.isLoading {
                    Spacer()
                    ProgressView()
                        .scaleEffect(1.2)
                    Spacer()
                } else if viewModel.buildings.isEmpty {
                    Spacer()
                    Text("No buildings available")
                        .font(.body)
                        .foregroundColor(.gray)
                    Spacer()
                } else {
                    ScrollView {
                        LazyVStack(spacing: 24) {
                            ForEach(Array(sortedBuildings.enumerated()), id: \.element.id) { index, building in
                                NavigationLink(destination: BuildingDetailView(building: building)) {
                                    BuildingRowView(building: building)
                                        .opacity(animateItems ? 1 : 0)
                                        .offset(x: animateItems ? 0 : 50)
                                        .animation(
                                            .easeOut(duration: 0.6)
                                            .delay(Double(index) * 0.1),
                                            value: animateItems
                                        )
                                }
                                .buttonStyle(PlainButtonStyle())
                            }
                        }
                        .padding(.horizontal, 20)
                        .padding(.bottom, 100) // Space for tab bar
                    }
                }
            }
        }
        .navigationBarHidden(true)
        .onAppear {
            // Trigger animations when view appears
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                animateItems = true
            }
        }
    }
    
    private var sortedBuildings: [Building] {
        return viewModel.buildings.sorted { $0.name < $1.name }
    }
}

struct BuildingRowView: View {
    let building: Building
    
    // Map building names to cleaner category descriptions
    private var categoryDescription: String {
        switch building.name {
        case "McDermott Library":
            return "LIB"
        case "Student Union":
            return "SU"
        case "Erik Jonsson School of Computer Science (West)":
            return "ECSW"
        case "Erik Jonsson School of Computer Science (South)":
            return "ECSS"
        case "Science Learning Center":
            return "SLC"
        case "Jindal School of Management":
            return "JSOM"
        case "Founders Building":
            return "FO"
        case "Green Hall":
            return "GH"
        default:
            // Fallback to using building code for shorter names
            switch building.code {
            case "MC":
                return "Library"
            case "SU":
                return "Student Union"
            case "ECSW", "ECSS":
                return "Engineering and Computer Science"
            case "NSE":
                return "Natural Science and Engineering"
            case "ATEC":
                return "Arts and Technology"
            case "BSB":
                return "Bioengineering and Sciences"
            case "JSOM":
                return "Business School"
            case "SLC":
                return "Natural Science and Engineering"
            case "FO":
                return "Arts and Technology"
            case "GH":
                return "Bioengineering and Sciences"
            default:
                return "Academic Building"
            }
        }
    }
    
    var body: some View {
        HStack(spacing: 16) {
            // Circular Building Image
            ZStack {
                if !building.imageNames.isEmpty {
                    Image(building.imageNames[0])
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: 85, height: 85)
                        .clipShape(Circle())
                        .overlay(
                            Circle()
                                .stroke(Color.gray.opacity(0.1), lineWidth: 1)
                        )
                } else {
                    Circle()
                        .fill(Color.gray.opacity(0.2))
                        .frame(width: 85, height: 85)
                        .overlay(
                            Text(building.code)
                                .font(.caption)
                                .fontWeight(.medium)
                                .foregroundColor(.gray)
                        )
                }
            }
            
            // Building Information
            VStack(alignment: .leading, spacing: 4) {
                Text(building.name)
                    .font(.title3)
                    .fontWeight(.bold)
                    .foregroundColor(.black)
                    .multilineTextAlignment(.leading)
                
                Text(categoryDescription)
                    .font(.subheadline)
                    .foregroundColor(.gray)
                    .fontWeight(.regular)
            }
            
            Spacer()
        }
        .padding(.vertical, 8)
        .contentShape(Rectangle()) // Makes entire row tappable
    }
}

// Custom navigation bar style
extension View {
    func customNavigationBar() -> some View {
        self
            .navigationBarHidden(true)
            .navigationBarBackButtonHidden(true)
    }
}

struct BuildingsListView_Previews: PreviewProvider {
    static var previews: some View {
        let viewModel = StudySpotsViewModel()
        viewModel.loadDataImmediately()
        
        return BuildingsListView()
            .environmentObject(viewModel)
            .environmentObject(LocationService())
    }
}
