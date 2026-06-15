import Foundation
import Combine

@MainActor
final class PlantListViewModel: ObservableObject {
    @Published var plants: [Plant] = []
    @Published var isAddingPlant: Bool = false

    private let plantRepository: PlantRepository
    private let moodRepository: MoodRepository

    init(
        plantRepository: PlantRepository = PlantRepository(),
        moodRepository: MoodRepository = MoodRepository()
    ) {
        self.plantRepository = plantRepository
        self.moodRepository = moodRepository
    }

    func loadPlants() {
        plants = plantRepository.fetchAll()
    }

    func deletePlant(_ plant: Plant) {
        plantRepository.delete(plant: plant)
        NotificationManager.shared.cancelAll(for: plant.id)
        loadPlants()
    }

    func todayMood(for plantID: UUID) -> PlantMood? {
        moodRepository.todayEntry(for: plantID)?.mood
    }

    func latestMood(for plantID: UUID) -> PlantMood? {
        moodRepository.latestEntry(for: plantID)?.mood
    }
}
