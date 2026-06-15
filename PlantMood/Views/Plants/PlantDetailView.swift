import SwiftUI
import PhotosUI

struct PlantDetailView: View {
    @StateObject private var viewModel: PlantDetailViewModel
    private let onChange: () -> Void

    init(plant: Plant, onChange: @escaping () -> Void = {}) {
        _viewModel = StateObject(wrappedValue: PlantDetailViewModel(plant: plant))
        self.onChange = onChange
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                header
                moodSection
                wateringSection
                photosSection
                notesSection
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 20)
        }
        .background(AppPalette.background.ignoresSafeArea())
        .navigationTitle(viewModel.plant.name)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    viewModel.isEditingPlant = true
                } label: {
                    Image(systemName: "pencil.circle")
                        .foregroundStyle(AppPalette.accent)
                }
            }
        }
        .sheet(isPresented: $viewModel.isShowingMoodLog) {
            MoodLogView(plant: viewModel.plant) {
                viewModel.loadData()
                onChange()
            }
        }
        .sheet(isPresented: $viewModel.isEditingPlant) {
            EditPlantView(plant: viewModel.plant) { updated in
                viewModel.updatePlant(updated)
                onChange()
            }
        }
        .onAppear { viewModel.loadData() }
    }

    private var header: some View {
        VStack(spacing: 12) {
            PlantAvatarView(emoji: viewModel.plant.emoji, mood: viewModel.latestMood(), size: 80)
            VStack(spacing: 4) {
                Text(viewModel.plant.name)
                    .font(.title2.weight(.bold))
                    .foregroundStyle(AppPalette.primaryText)
                Text(viewModel.plant.species)
                    .font(.subheadline)
                    .foregroundStyle(AppPalette.secondaryText)
            }
        }
    }

    private var moodSection: some View {
        sectionCard {
            VStack(alignment: .leading, spacing: 16) {
                sectionTitle(icon: "heart.fill", text: "Mood over 14 days")
                MoodChartView(entries: viewModel.moodEntries, days: 14)
                Button {
                    viewModel.isShowingMoodLog = true
                } label: {
                    HStack {
                        Image(systemName: "square.and.pencil")
                        Text("Log mood")
                            .fontWeight(.semibold)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                    .background(AppPalette.accent)
                    .foregroundStyle(.white)
                    .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                }
                .buttonStyle(.plain)
            }
        }
    }

    private var wateringSection: some View {
        sectionCard {
            VStack(alignment: .leading, spacing: 12) {
                sectionTitle(icon: "drop.fill", text: "Watering")
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Last watered")
                            .font(.caption)
                            .foregroundStyle(AppPalette.secondaryText)
                        Text(viewModel.plant.lastWateredDate.map(formatted) ?? "Not watered yet")
                            .font(.subheadline.weight(.semibold))
                            .foregroundStyle(AppPalette.primaryText)
                    }
                    Spacer()
                    VStack(alignment: .trailing, spacing: 4) {
                        Text("Next watering")
                            .font(.caption)
                            .foregroundStyle(AppPalette.secondaryText)
                        Text(viewModel.plant.nextWateringDate.map(formatted) ?? "Water today")
                            .font(.subheadline.weight(.semibold))
                            .foregroundStyle(viewModel.plant.needsWatering ? AppPalette.warning : AppPalette.primaryText)
                    }
                }

                Button {
                    viewModel.logWatering()
                    onChange()
                } label: {
                    HStack {
                        Image(systemName: "drop.fill")
                        Text("Watered today")
                            .fontWeight(.semibold)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                    .background(AppPalette.waterBlue)
                    .foregroundStyle(.white)
                    .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                }
                .buttonStyle(.plain)
            }
        }
    }

    private var photosSection: some View {
        sectionCard {
            VStack(alignment: .leading, spacing: 12) {
                sectionTitle(icon: "photo.on.rectangle", text: "Photos")
                let entries = viewModel.recentPhotoEntries(limit: 5)
                if entries.isEmpty {
                    Text("No photos yet")
                        .font(.subheadline)
                        .foregroundStyle(AppPalette.secondaryText)
                        .frame(maxWidth: .infinity, alignment: .center)
                        .padding(.vertical, 12)
                } else {
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 10) {
                            ForEach(entries) { entry in
                                if let data = entry.photoData, let uiImage = UIImage(data: data) {
                                    Image(uiImage: uiImage)
                                        .resizable()
                                        .scaledToFill()
                                        .frame(width: 80, height: 80)
                                        .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
                                }
                            }
                        }
                    }
                }
                PhotosPicker(selection: $viewModel.selectedPhoto, matching: .images) {
                    HStack {
                        Image(systemName: "photo.badge.plus")
                        Text("Add photo")
                            .fontWeight(.semibold)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                    .background(AppPalette.accent.opacity(0.15))
                    .foregroundStyle(AppPalette.accent)
                    .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                }
            }
        }
    }

    private var notesSection: some View {
        sectionCard {
            VStack(alignment: .leading, spacing: 8) {
                sectionTitle(icon: "text.alignleft", text: "Notes")
                if viewModel.plant.notes.isEmpty {
                    Text("Open edit mode to add care notes.")
                        .font(.subheadline)
                        .foregroundStyle(AppPalette.secondaryText)
                } else {
                    Text(viewModel.plant.notes)
                        .font(.subheadline)
                        .foregroundStyle(AppPalette.primaryText)
                }
            }
        }
    }

    @ViewBuilder
    private func sectionCard<Content: View>(@ViewBuilder content: () -> Content) -> some View {
        content()
            .padding(16)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(
                RoundedRectangle(cornerRadius: 20, style: .continuous)
                    .fill(AppPalette.card)
            )
            .shadow(color: Color.black.opacity(0.04), radius: 6, x: 0, y: 2)
    }

    private func sectionTitle(icon: String, text: String) -> some View {
        HStack(spacing: 8) {
            Image(systemName: icon).foregroundStyle(AppPalette.accent)
            Text(text)
                .font(.headline)
                .foregroundStyle(AppPalette.primaryText)
        }
    }

    private func formatted(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.dateFormat = "d MMM"
        return formatter.string(from: date)
    }
}

private struct EditPlantView: View {
    @Environment(\.dismiss) private var dismiss

    @State private var name: String
    @State private var species: String
    @State private var emoji: String
    @State private var interval: Int
    @State private var notes: String

    private let original: Plant
    private let onSave: (Plant) -> Void
    private let emojiOptions = ["🌿", "🌵", "🌸", "🌳", "🌱", "🪴", "🌼", "🌾", "🌻", "🌷"]

    init(plant: Plant, onSave: @escaping (Plant) -> Void) {
        self.original = plant
        self.onSave = onSave
        _name = State(initialValue: plant.name)
        _species = State(initialValue: plant.species)
        _emoji = State(initialValue: plant.emoji)
        _interval = State(initialValue: plant.wateringIntervalDays)
        _notes = State(initialValue: plant.notes)
    }

    var body: some View {
        NavigationStack {
            Form {
                Section("Basic") {
                    TextField("Name", text: $name)
                    TextField("Species", text: $species)
                }
                Section("Emoji") {
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack {
                            ForEach(emojiOptions, id: \.self) { option in
                                Button {
                                    emoji = option
                                } label: {
                                    Text(option)
                                        .font(.system(size: 32))
                                        .padding(8)
                                        .background(
                                            Circle().fill(emoji == option ? AppPalette.accent.opacity(0.2) : .clear)
                                        )
                                }
                                .buttonStyle(.plain)
                            }
                        }
                    }
                }
                Section("Watering") {
                    Stepper("Every \(interval) days", value: $interval, in: 1...60)
                }
                Section("Notes") {
                    TextField("Notes", text: $notes, axis: .vertical)
                        .lineLimit(3...6)
                }
            }
            .navigationTitle("Edit Plant")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") {
                        var updated = original
                        updated.name = name
                        updated.species = species
                        updated.emoji = emoji
                        updated.wateringIntervalDays = interval
                        updated.notes = notes
                        onSave(updated)
                        dismiss()
                    }
                    .fontWeight(.semibold)
                    .disabled(name.trimmingCharacters(in: .whitespaces).isEmpty)
                }
            }
        }
    }
}
