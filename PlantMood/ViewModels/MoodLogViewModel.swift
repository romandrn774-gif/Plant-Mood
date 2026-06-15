import Foundation
import SwiftUI
import PhotosUI

@MainActor
final class MoodLogViewModel: ObservableObject {
    @Published var selectedMood: PlantMood?
    @Published var note: String = ""
    @Published var photoData: Data?
    @Published var photoItem: PhotosPickerItem? {
        didSet { handlePhotoItem() }
    }

    let plant: Plant
    private let moodRepository: MoodRepository

    init(plant: Plant, moodRepository: MoodRepository = MoodRepository()) {
        self.plant = plant
        self.moodRepository = moodRepository
    }

    var canSave: Bool { selectedMood != nil }

    func save(completion: () -> Void) {
        guard let mood = selectedMood else { return }
        let entry = MoodEntry(
            plantID: plant.id,
            mood: mood,
            note: note,
            date: Date(),
            photoData: photoData
        )
        moodRepository.save(entry: entry)
        completion()
    }

    func removePhoto() {
        photoData = nil
        photoItem = nil
    }

    private func handlePhotoItem() {
        guard let item = photoItem else { return }
        Task { @MainActor in
            if let data = try? await item.loadTransferable(type: Data.self) {
                photoData = data
            }
        }
    }
}
