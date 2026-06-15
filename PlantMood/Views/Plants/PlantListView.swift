import SwiftUI

struct PlantListView: View {
    @StateObject private var viewModel = PlantListViewModel()

    private let columns: [GridItem] = [
        GridItem(.flexible(), spacing: 14),
        GridItem(.flexible(), spacing: 14)
    ]

    var body: some View {
        Group {
            if viewModel.plants.isEmpty {
                EmptyStateView(
                    emoji: "🌱",
                    title: "Nothing here yet",
                    message: "Add your first plant to start tracking its mood.",
                    actionTitle: "Add plant",
                    action: { viewModel.isAddingPlant = true }
                )
            } else {
                ScrollView {
                    LazyVGrid(columns: columns, spacing: 14) {
                        ForEach(viewModel.plants) { plant in
                            NavigationLink(value: plant) {
                                PlantGridCard(
                                    plant: plant,
                                    mood: viewModel.todayMood(for: plant.id) ?? viewModel.latestMood(for: plant.id)
                                )
                            }
                            .buttonStyle(.plain)
                            .contextMenu {
                                Button(role: .destructive) {
                                    viewModel.deletePlant(plant)
                                } label: {
                                    Label("Delete", systemImage: "trash")
                                }
                            }
                        }
                    }
                    .padding(16)
                }
                .background(AppPalette.background.ignoresSafeArea())
            }
        }
        .background(AppPalette.background.ignoresSafeArea())
        .navigationTitle("My Plants")
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    viewModel.isAddingPlant = true
                } label: {
                    Image(systemName: "plus.circle.fill")
                        .font(.title3)
                        .foregroundStyle(AppPalette.accent)
                }
            }
        }
        .navigationDestination(for: Plant.self) { plant in
            PlantDetailView(plant: plant) {
                viewModel.loadPlants()
            }
        }
        .sheet(isPresented: $viewModel.isAddingPlant) {
            AddPlantView { _ in
                viewModel.loadPlants()
            }
        }
        .onAppear { viewModel.loadPlants() }
    }
}

private struct PlantGridCard: View {
    let plant: Plant
    let mood: PlantMood?

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            ZStack {
                Circle()
                    .fill((mood?.color ?? AppPalette.accent).opacity(0.18))
                    .frame(width: 80, height: 80)
                Text(plant.emoji)
                    .font(.system(size: 48))
            }
            .frame(maxWidth: .infinity, alignment: .center)

            VStack(alignment: .leading, spacing: 4) {
                Text(plant.name)
                    .font(.headline)
                    .foregroundStyle(AppPalette.primaryText)
                    .lineLimit(1)
                Text(plant.species)
                    .font(.caption)
                    .foregroundStyle(AppPalette.secondaryText)
                    .lineLimit(1)
            }

            HStack(spacing: 6) {
                Text(mood?.emoji ?? "🌿")
                Text(mood?.label ?? "No data")
                    .font(.caption.weight(.medium))
                    .foregroundStyle(AppPalette.secondaryText)
            }

            if plant.needsWatering {
                HStack(spacing: 4) {
                    Image(systemName: "drop.fill")
                        .font(.caption2)
                    Text(wateringLabel)
                        .font(.caption2.weight(.semibold))
                }
                .foregroundStyle(plant.lastWateredDate == nil ? AppPalette.waterBlue : AppPalette.warning)
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background((plant.lastWateredDate == nil ? AppPalette.waterBlue : AppPalette.warning).opacity(0.15))
                .clipShape(Capsule())
            }
        }
        .padding(14)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .fill(AppPalette.card)
        )
        .shadow(color: Color.black.opacity(0.04), radius: 6, x: 0, y: 2)
    }

    private var wateringLabel: String {
        if plant.lastWateredDate == nil { return "Water needed" }
        if let days = plant.daysUntilWatering, days < 0 {
            return "Overdue by \(-days) days"
        }
        return "Time to water"
    }
}
