import Foundation
import SwiftUI
import PhotosUI
import Combine

@MainActor
final class PlantDetailViewModel: ObservableObject {
    @Published var plant: Plant
    @Published var moodEntries: [MoodEntry] = []
    @Published var wateringRecords: [WateringRecord] = []
    @Published var isShowingMoodLog: Bool = false
    @Published var isEditingPlant: Bool = false
    @Published var selectedPhoto: PhotosPickerItem? {
        didSet { handleSelectedPhoto() }
    }

    private let plantRepository: PlantRepository
    private let moodRepository: MoodRepository
    private let wateringRepository: WateringRepository

    init(
        plant: Plant,
        plantRepository: PlantRepository = PlantRepository(),
        moodRepository: MoodRepository = MoodRepository(),
        wateringRepository: WateringRepository = WateringRepository()
    ) {
        self.plant = plant
        self.plantRepository = plantRepository
        self.moodRepository = moodRepository
        self.wateringRepository = wateringRepository
    }

    func loadData() {
        moodEntries = moodRepository.fetchAll(for: plant.id)
        wateringRecords = wateringRepository.fetchAll(for: plant.id)
        if let refreshed = plantRepository.fetch(id: plant.id) {
            plant = refreshed
        }
    }

    func logWatering() {
        let record = WateringRecord(plantID: plant.id, date: Date(), note: "")
        wateringRepository.save(record: record)
        plant.lastWateredDate = Date()
        plantRepository.save(plant: plant)
        NotificationManager.shared.scheduleWateringReminder(for: plant)
        loadData()
    }

    func updatePlant(_ updated: Plant) {
        plant = updated
        plantRepository.save(plant: updated)
        NotificationManager.shared.scheduleWateringReminder(for: updated)
        loadData()
    }

    func latestMood() -> PlantMood {
        moodEntries.first?.mood ?? .neutral
    }

    func recentPhotoEntries(limit: Int = 5) -> [MoodEntry] {
        moodEntries.filter { $0.photoData != nil }.prefix(limit).map { $0 }
    }

    private func handleSelectedPhoto() {
        guard let item = selectedPhoto else { return }
        Task { @MainActor in
            await savePhoto(item: item)
            selectedPhoto = nil
        }
    }

    func savePhoto(item: PhotosPickerItem) async {
        guard let data = try? await item.loadTransferable(type: Data.self) else { return }
        let entry = MoodEntry(
            plantID: plant.id,
            mood: latestMood(),
            note: "Photo diary entry",
            date: Date(),
            photoData: data
        )
        moodRepository.save(entry: entry)
        loadData()
    }
}
