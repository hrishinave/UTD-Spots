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
                    ScrollView {
                        LazyVStack(spacing: 24) {
                            ForEach(0..<3, id: \.self) { _ in
                                BuildingCardSkeletonView()
                                    .padding(.horizontal, 20)
                            }
                        }
                        .padding(.top, 10)
                    }
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
                                NavigationLink(value: building) {
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
                        .padding(.bottom, 20) // Minimal space for tab bar
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
    @EnvironmentObject var viewModel: StudySpotsViewModel
    
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
        VStack(spacing: 0) {
            // Full-width Rectangular Building Image
            ZStack {
                if !building.imageNames.isEmpty {
                    if building.name == "Jindal School of Management" {
                        Rectangle()
                            .fill(Color.gray.opacity(0.1))
                            .frame(height: 160)
                        
                        Image(building.imageNames[0])
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(height: 160)
                    } else {
                        Image(building.imageNames[0])
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(height: 160)
                            .clipped()
                    }
                } else {
                    Rectangle()
                        .fill(Color.gray.opacity(0.2))
                        .frame(height: 160)
                        .overlay(
                            Text(building.code)
                                .font(.title2)
                                .fontWeight(.medium)
                                .foregroundColor(.gray)
                        )
                }

                // Subtle dark gradient for contrast
                LinearGradient(
                    gradient: Gradient(colors: [Color.black.opacity(0.0), Color.black.opacity(0.25)]),
                    startPoint: .top,
                    endPoint: .bottom
                )
                .allowsHitTesting(false)

                // Open/Closed pill in top-left
                VStack {
                    HStack {
                        Text(building.isCurrentlyOpen ? "Open" : "Closed")
                            .font(.caption)
                            .fontWeight(.semibold)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background((building.isCurrentlyOpen ? Color.green : Color.red).opacity(0.15))
                            .overlay(
                                RoundedRectangle(cornerRadius: 8)
                                    .stroke((building.isCurrentlyOpen ? Color.green : Color.red).opacity(0.35), lineWidth: 1)
                            )
                            .cornerRadius(8)
                            .foregroundColor(building.isCurrentlyOpen ? .green : .red)
                        Spacer()
                    }
                    .padding(10)
                    Spacer()
                }
            }
            .clipShape(RoundedRectangle(cornerRadius: 12))
            
            // Building Information
            VStack(alignment: .leading, spacing: 8) {
                Text(building.name)
                    .font(.title3)
                    .fontWeight(.bold)
                    .foregroundColor(.black)
                    .multilineTextAlignment(.leading)
                    .frame(maxWidth: .infinity, alignment: .leading)
                
                HStack(spacing: 8) {
                    Text(categoryDescription)
                        .font(.subheadline)
                        .foregroundColor(.gray)
                        .fontWeight(.regular)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    
                    // Spot count chip
                    if spotCount > 0 {
                        HStack(spacing: 6) {
                            Image(systemName: "mappin.and.ellipse")
                                .font(.system(size: 12, weight: .semibold))
                            Text("\(spotCount) spots")
                                .font(.caption)
                                .fontWeight(.semibold)
                        }
                        .foregroundColor(.secondary)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(Color.gray.opacity(0.08))
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                        )
                        .cornerRadius(8)
                    }
                }

                // Affordance row
                HStack {
                    Spacer()
                    Image(systemName: "chevron.right.circle.fill")
                        .foregroundColor(.gray.opacity(0.5))
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
        }
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .shadow(color: Color.black.opacity(0.1), radius: 8, x: 0, y: 2)
        .contentShape(Rectangle()) // Makes entire card tappable
    }

    private var spotCount: Int {
        viewModel.studySpots.filter { $0.buildingID == building.id }.count
    }
}

// MARK: - Skeletons

struct ShimmerView: View {
    @State private var phase: CGFloat = -0.6
    
    var body: some View {
        GeometryReader { proxy in
            let gradient = LinearGradient(
                gradient: Gradient(colors: [
                    Color.gray.opacity(0.25),
                    Color.gray.opacity(0.12),
                    Color.gray.opacity(0.25)
                ]),
                startPoint: .leading,
                endPoint: .trailing
            )
            Rectangle()
                .fill(gradient)
                .mask(
                    Rectangle()
                        .fill(
                            LinearGradient(
                                gradient: Gradient(colors: [Color.black.opacity(0.4), Color.black, Color.black.opacity(0.4)]),
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        )
                        .offset(x: proxy.size.width * phase)
                )
                .onAppear {
                    withAnimation(.linear(duration: 1.2).repeatForever(autoreverses: false)) {
                        phase = 1.6
                    }
                }
        }
        .clipped()
    }
}

struct BuildingCardSkeletonView: View {
    var body: some View {
        VStack(spacing: 0) {
            ZStack {
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.gray.opacity(0.15))
                    .frame(height: 160)
                ShimmerView()
                    .frame(height: 160)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
            }
            VStack(alignment: .leading, spacing: 8) {
                RoundedRectangle(cornerRadius: 6)
                    .fill(Color.gray.opacity(0.2))
                    .frame(height: 16)
                RoundedRectangle(cornerRadius: 6)
                    .fill(Color.gray.opacity(0.15))
                    .frame(width: 120, height: 12)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
        }
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .shadow(color: Color.black.opacity(0.05), radius: 6, x: 0, y: 2)
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
