import SwiftUI
import CoreLocation

struct SpotListView: View {
    @EnvironmentObject var viewModel: StudySpotsViewModel
    @EnvironmentObject var locationService: LocationService
    @State private var showFilters = false
    @State private var sortSelection: SortSelection = .distance
    @State private var navigateToSpotID: UUID?
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Sticky search + filter + sort
                VStack(spacing: 8) {
                    // Search bar + filter button
                    HStack {
                        HStack {
                            Image(systemName: "magnifyingglass")
                                .foregroundColor(.gray)
                                .font(.system(size: 16))
                            TextField("Search study spots...", text: $viewModel.searchText)
                                .font(.system(size: 16))
                        }
                        .padding(.horizontal, 12)
                        .padding(.vertical, 10)
                        .background(Color(.systemBackground))
                        .overlay(
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(Color(.systemGray4), lineWidth: 1)
                        )
                        .cornerRadius(10)
                        
                        Button(action: { showFilters.toggle() }) {
                            HStack(spacing: 6) {
                                Image(systemName: "line.3.horizontal.decrease.circle")
                                if hasActiveFilters {
                                    Circle()
                                        .fill(.orange)
                                        .frame(width: 8, height: 8)
                                }
                            }
                            .foregroundColor(.utdOrange)
                            .padding(.horizontal, 10)
                            .padding(.vertical, 8)
                            .background(Color.utdOrange.opacity(0.12))
                            .cornerRadius(10)
                        }
                    }
                    
                    // Filter summary chips
                    if hasActiveFilters {
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 8) {
                                if let b = viewModel.selectedBuilding {
                                    FilterSummaryChip(title: b.name) {
                                        viewModel.selectedBuilding = nil
                                        viewModel.filterSpots()
                                    }
                                }
                                ForEach(Array(viewModel.selectedFeatures), id: \.self) { feature in
                                    FilterSummaryChip(title: feature) {
                                        viewModel.selectedFeatures.remove(feature)
                                        viewModel.filterSpots()
                                    }
                                }
                                if !viewModel.searchText.isEmpty {
                                    FilterSummaryChip(title: "\"\(viewModel.searchText)\"") {
                                        viewModel.searchText = ""
                                        viewModel.filterSpots()
                                    }
                                }
                                Button("Clear All") {
                                    viewModel.clearFilters()
                                }
                                .font(.caption)
                                .foregroundColor(.red)
                            }
                            .padding(.horizontal, 16)
                        }
                    }
                    
                    // Sorting segmented control
                    Picker("Sort", selection: $sortSelection) {
                        ForEach(SortSelection.allCases, id: \.self) { option in
                            Text(option.title).tag(option)
                        }
                    }
                    .pickerStyle(SegmentedPickerStyle())
                    .padding(.horizontal, 16)
                    .onChange(of: sortSelection) { _ in
                        applySort()
                    }
                }
                .padding(.top, 8)
                .padding(.bottom, 8)
                .background(Color(.systemGroupedBackground))
                
                // Main Content
                ZStack {
                    Color(.systemGroupedBackground)
                        .ignoresSafeArea()
                    
                    if viewModel.isLoading {
                        SpotsSkeletonList()
                    } else if viewModel.studySpots.isEmpty {
                        EmptyStateView(
                            title: "No study spots found",
                            message: "Try adjusting your filters or search term",
                            systemImage: "magnifyingglass"
                        )
                    } else {
                        ScrollView {
                            LazyVStack(spacing: 16) {
                                ForEach(Array(viewModel.studySpots.enumerated()), id: \.element.id) { index, spot in
                                    let isActive = Binding<Bool>(
                                        get: { navigateToSpotID == spot.id },
                                        set: { active in if !active { navigateToSpotID = nil } }
                                    )
                                    SpotCardView(
                                        spot: spot,
                                        building: viewModel.buildingForSpot(spot) ?? Building.samples[0],
                                        onFavoriteToggle: { viewModel.toggleFavorite(for: $0) },
                                        distance: userDistanceToSpot(spot)
                                    )
                                    .frame(width: 300)
                                    .opacity(animateOpacity(index: index))
                                    .offset(y: animateOffset(index: index))
                                    .animation(.easeOut(duration: 0.4).delay(0.03 * Double(index)), value: viewModel.studySpots.count)
                                    .onTapGesture { navigateToSpotID = spot.id }
                                    .background(
                                        NavigationLink(destination: SpotDetailView(spot: spot), isActive: isActive) {
                                            EmptyView()
                                        }
                                        .hidden()
                                    )
                                }
                            }
                            .padding()
                        }
                    }
                }
            }
            .navigationTitle("All Study Spots")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    EmptyView()
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    EmptyView()
                }
            }
            .sheet(isPresented: $showFilters) {
                FilterView(
                    buildings: viewModel.buildings,
                    selectedBuilding: $viewModel.selectedBuilding,
                    selectedFeatures: $viewModel.selectedFeatures,
                    onApplyFilters: { viewModel.filterSpots() }
                )
            }
            .tint(.utdOrange)
        }
        .navigationViewStyle(StackNavigationViewStyle())
    }
    
    // Calculate distance from user to spot if location is available
    private func userDistanceToSpot(_ spot: StudySpot) -> Double? {
        guard let userLocation = locationService.userLocation else {
            return nil
        }

        let distanceInMeters = viewModel.calculateDistance(
            from: userLocation.coordinate,
            to: spot
        )

        // Convert meters to feet for display
        return distanceInMeters * 3.28084
    }
    
    // Sort spots by distance from user
    private func sortSpotsByDistance() {
        guard let userLocation = locationService.userLocation else {
            // Sort alphabetically if no location
            viewModel.studySpots.sort { $0.name < $1.name }
            return
        }
        
        viewModel.studySpots.sort { spot1, spot2 in
            let dist1 = viewModel.calculateDistance(from: userLocation.coordinate, to: spot1)
            let dist2 = viewModel.calculateDistance(from: userLocation.coordinate, to: spot2)
            return dist1 < dist2
        }
    }
    
    // Check if any filters are active
    private var hasActiveFilters: Bool {
        !viewModel.searchText.isEmpty || 
        viewModel.selectedBuilding != nil || 
        !viewModel.selectedFeatures.isEmpty
    }

    // Simple staged appearance helpers
    private func animateOpacity(index: Int) -> Double { 1.0 }
    private func animateOffset(index: Int) -> CGFloat { 0 }

    private func applySort() {
        switch sortSelection {
        case .distance:
            sortSpotsByDistance()
        case .name:
            viewModel.studySpots.sort { $0.name < $1.name }
        case .openNow:
            viewModel.studySpots.sort { ($0.isCurrentlyOpen ? 1 : 0) > ($1.isCurrentlyOpen ? 1 : 0) }
        }
    }
}

// MARK: - Sorting and Filter Summary UI

enum SortSelection: CaseIterable {
    case distance
    case name
    case openNow
    
    var title: String {
        switch self {
        case .distance: return "Distance"
        case .name: return "Name"
        case .openNow: return "Open Now"
        }
    }
}

struct FilterSummaryChip: View {
    let title: String
    let onClear: () -> Void
    
    var body: some View {
        HStack(spacing: 6) {
            Text(title)
            Button(action: onClear) {
                Image(systemName: "xmark.circle.fill")
            }
        }
        .font(.caption)
        .foregroundColor(.secondary)
        .padding(.horizontal, 10)
        .padding(.vertical, 6)
        .background(Color.gray.opacity(0.08))
        .overlay(
            RoundedRectangle(cornerRadius: 10)
                .stroke(Color.gray.opacity(0.3), lineWidth: 1)
        )
        .cornerRadius(10)
    }
}

// MARK: - Skeleton List

struct SpotsSkeletonList: View {
    var body: some View {
        ScrollView {
            LazyVStack(spacing: 16) {
                ForEach(0..<6, id: \.self) { _ in
                    SpotCardSkeleton()
                        .padding(.horizontal)
                }
            }
            .padding(.top)
        }
    }
}

struct SpotCardSkeleton: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 12) {
                RoundedRectangle(cornerRadius: 8)
                    .fill(Color.gray.opacity(0.15))
                    .frame(width: 48, height: 48)
                VStack(alignment: .leading, spacing: 6) {
                    RoundedRectangle(cornerRadius: 6)
                        .fill(Color.gray.opacity(0.2))
                        .frame(height: 14)
                    RoundedRectangle(cornerRadius: 6)
                        .fill(Color.gray.opacity(0.15))
                        .frame(width: 140, height: 12)
                }
                Spacer()
                Circle()
                    .fill(Color.gray.opacity(0.15))
                    .frame(width: 24, height: 24)
            }
            RoundedRectangle(cornerRadius: 6)
                .fill(Color.gray.opacity(0.12))
                .frame(height: 12)
            HStack {
                RoundedRectangle(cornerRadius: 6)
                    .fill(Color.gray.opacity(0.12))
                    .frame(width: 80, height: 20)
                RoundedRectangle(cornerRadius: 6)
                    .fill(Color.gray.opacity(0.12))
                    .frame(width: 80, height: 20)
                Spacer()
            }
            .padding(.top, 4)
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(radius: 2)
    }
}

// Empty state view for when no results are found
struct EmptyStateView: View {
    let title: String
    let message: String
    let systemImage: String
    
    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: systemImage)
                .font(.system(size: 60))
                .foregroundColor(.utdGreen)
            
            Text(title)
                .font(.headline)
                .foregroundColor(.utdGreen)
            
            Text(message)
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
        }
    }
}

struct SpotListView_Previews: PreviewProvider {
    static var previews: some View {
        SpotListView()
            .environmentObject(StudySpotsViewModel())
            .environmentObject(LocationService())
    }
}
