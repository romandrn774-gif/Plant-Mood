import SwiftUI

struct PhotoDiaryView: View {
    @StateObject private var viewModel = PhotoDiaryViewModel()

    private let columns: [GridItem] = [
        GridItem(.flexible(), spacing: 8),
        GridItem(.flexible(), spacing: 8),
        GridItem(.flexible(), spacing: 8)
    ]

    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                filterBar
                if viewModel.items.isEmpty {
                    EmptyStateView(
                        emoji: "📸",
                        title: "Diary is empty",
                        message: "Take photos when logging moods and they will collect here as a memory feed."
                    )
                    .padding(.top, 40)
                } else {
                    LazyVGrid(columns: columns, spacing: 8) {
                        ForEach(viewModel.items) { item in
                            PhotoDiaryCell(item: item)
                        }
                    }
                    .padding(.horizontal, 12)
                }
            }
            .padding(.vertical, 16)
        }
        .background(AppPalette.background.ignoresSafeArea())
        .navigationTitle("Photo Diary")
        .onAppear { viewModel.load() }
        .refreshable { viewModel.load() }
    }

    private var filterBar: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                FilterChip(
                    title: "All",
                    emoji: "🌿",
                    isSelected: viewModel.selectedPlantID == nil
                ) {
                    viewModel.setFilter(plantID: nil)
                }
                ForEach(viewModel.allPlants) { plant in
                    FilterChip(
                        title: plant.name,
                        emoji: plant.emoji,
                        isSelected: viewModel.selectedPlantID == plant.id
                    ) {
                        viewModel.setFilter(plantID: plant.id)
                    }
                }
            }
            .padding(.horizontal, 16)
        }
    }
}

private struct FilterChip: View {
    let title: String
    let emoji: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 6) {
                Text(emoji)
                Text(title)
                    .font(.caption.weight(.semibold))
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(isSelected ? AppPalette.accent : AppPalette.card)
            .foregroundStyle(isSelected ? .white : AppPalette.primaryText)
            .clipShape(Capsule())
        }
        .buttonStyle(.plain)
    }
}

private struct PhotoDiaryCell: View {
    let item: PhotoDiaryItem

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            if let data = item.entry.photoData, let uiImage = UIImage(data: data) {
                Image(uiImage: uiImage)
                    .resizable()
                    .scaledToFill()
                    .frame(height: 110)
                    .frame(maxWidth: .infinity)
                    .clipped()
                    .overlay(alignment: .topTrailing) {
                        Text(item.entry.mood.emoji)
                            .font(.caption)
                            .padding(4)
                            .background(.ultraThinMaterial)
                            .clipShape(Circle())
                            .padding(4)
                    }
            }
            VStack(alignment: .leading, spacing: 2) {
                Text(item.plant.emoji + " " + item.plant.name)
                    .font(.caption2.weight(.semibold))
                    .foregroundStyle(AppPalette.primaryText)
                    .lineLimit(1)
                Text(formatted(item.entry.date))
                    .font(.caption2)
                    .foregroundStyle(AppPalette.secondaryText)
            }
            .padding(.horizontal, 6)
            .padding(.bottom, 6)
        }
        .background(
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .fill(AppPalette.card)
        )
        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
    }

    private func formatted(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.dateFormat = "d MMM"
        return formatter.string(from: date)
    }
}
