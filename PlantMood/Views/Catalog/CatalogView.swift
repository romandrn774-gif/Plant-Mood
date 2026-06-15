import SwiftUI

struct CatalogView: View {
    @StateObject private var viewModel = CatalogViewModel()
    @State private var prefillTemplate: PlantTemplate?

    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                searchAndFilter
                LazyVStack(spacing: 12) {
                    ForEach(viewModel.filtered) { template in
                        PlantCardView(template: template) {
                            prefillTemplate = template
                        }
                    }
                }
                .padding(.horizontal, 16)
                if viewModel.filtered.isEmpty {
                    EmptyStateView(
                        emoji: "🔍",
                        title: "Nothing found",
                        message: "Try changing the search term or clearing the filters."
                    )
                    .padding(.top, 24)
                }
            }
            .padding(.vertical, 16)
        }
        .background(AppPalette.background.ignoresSafeArea())
        .navigationTitle("Catalog")
        .sheet(item: $prefillTemplate) { template in
            AddPlantView(prefill: template) { _ in
                prefillTemplate = nil
            }
        }
    }

    private var searchAndFilter: some View {
        VStack(spacing: 12) {
            HStack {
                Image(systemName: "magnifyingglass")
                    .foregroundStyle(AppPalette.secondaryText)
                TextField("Search plants...", text: $viewModel.searchText)
            }
            .padding(12)
            .background(
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .fill(AppPalette.card)
            )
            .padding(.horizontal, 16)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    CareLevelChip(
                        title: "All",
                        isSelected: viewModel.careLevelFilter == nil
                    ) {
                        viewModel.careLevelFilter = nil
                    }
                    ForEach(viewModel.availableCareLevels, id: \.self) { level in
                        CareLevelChip(
                            title: level,
                            isSelected: viewModel.careLevelFilter == level
                        ) {
                            viewModel.careLevelFilter = (viewModel.careLevelFilter == level) ? nil : level
                        }
                    }
                }
                .padding(.horizontal, 16)
            }
        }
    }
}

private struct CareLevelChip: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.caption.weight(.semibold))
                .padding(.horizontal, 14)
                .padding(.vertical, 8)
                .background(isSelected ? AppPalette.accent : AppPalette.card)
                .foregroundStyle(isSelected ? .white : AppPalette.primaryText)
                .clipShape(Capsule())
        }
        .buttonStyle(.plain)
    }
}
