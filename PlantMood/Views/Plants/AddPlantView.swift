import SwiftUI

struct AddPlantView: View {
    @Environment(\.dismiss) private var dismiss

    var prefill: PlantTemplate?
    let onAdded: (Plant) -> Void

    @State private var name: String = ""
    @State private var species: String = ""
    @State private var emoji: String = "🌿"
    @State private var wateringInterval: Int = 7
    @State private var notes: String = ""

    private let emojiOptions = ["🌿", "🌵", "🌸", "🌳", "🌱", "🪴", "🌼", "🌾", "🌻", "🌷"]
    private let plantRepository = PlantRepository()

    init(prefill: PlantTemplate? = nil, onAdded: @escaping (Plant) -> Void) {
        self.prefill = prefill
        self.onAdded = onAdded
        _name = State(initialValue: prefill?.name ?? "")
        _species = State(initialValue: prefill?.species ?? "")
        _emoji = State(initialValue: prefill?.emoji ?? "🌿")
        _wateringInterval = State(initialValue: prefill?.defaultWateringIntervalDays ?? 7)
    }

    var body: some View {
        NavigationStack {
            Form {
                Section("Basic") {
                    TextField("Plant name", text: $name)
                    TextField("Species", text: $species)
                }

                Section("Emoji") {
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 12) {
                            ForEach(emojiOptions, id: \.self) { option in
                                Button {
                                    emoji = option
                                } label: {
                                    Text(option)
                                        .font(.system(size: 36))
                                        .frame(width: 56, height: 56)
                                        .background(
                                            Circle()
                                                .fill(emoji == option ? AppPalette.accent.opacity(0.2) : Color.clear)
                                        )
                                        .overlay(
                                            Circle()
                                                .stroke(emoji == option ? AppPalette.accent : Color.clear, lineWidth: 2)
                                        )
                                }
                                .buttonStyle(.plain)
                            }
                        }
                        .padding(.vertical, 4)
                    }
                }

                Section("Watering") {
                    Stepper(value: $wateringInterval, in: 1...60) {
                        HStack {
                            Image(systemName: "drop.fill").foregroundStyle(AppPalette.waterBlue)
                            Text("Every \(wateringInterval) days")
                        }
                    }
                }

                Section("Notes") {
                    TextField("Anything important to remember...", text: $notes, axis: .vertical)
                        .lineLimit(3...6)
                }
            }
            .navigationTitle(prefill == nil ? "New Plant" : "Add from Catalog")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Save") { save() }
                        .disabled(name.trimmingCharacters(in: .whitespaces).isEmpty)
                        .fontWeight(.semibold)
                }
            }
        }
    }

    private func save() {
        let plant = Plant(
            name: name.trimmingCharacters(in: .whitespacesAndNewlines),
            species: species.trimmingCharacters(in: .whitespacesAndNewlines),
            emoji: emoji,
            wateringIntervalDays: wateringInterval,
            notes: notes,
            isPremium: prefill?.isPremium ?? false
        )
        plantRepository.save(plant: plant)
        NotificationManager.shared.scheduleWateringReminder(for: plant)
        onAdded(plant)
        dismiss()
    }
}
