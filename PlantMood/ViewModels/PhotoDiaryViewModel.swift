import Foundation
import Combine

struct PhotoDiaryItem: Identifiable, Hashable {
    let id: UUID
    let plant: Plant
    let entry: MoodEntry
}

@MainActor
final class PhotoDiaryViewModel: ObservableObject {
    @Published var items: [PhotoDiaryItem] = []
    @Published var selectedPlantID: UUID?

    private let plantRepository: PlantRepository
    private let moodRepository: MoodRepository

    init(
        plantRepository: PlantRepository = PlantRepository(),
        moodRepository: MoodRepository = MoodRepository()
    ) {
        self.plantRepository = plantRepository
        self.moodRepository = moodRepository
    }

    var allPlants: [Plant] { plantRepository.fetchAll() }

    func load() {
        let plants = plantRepository.fetchAll()
        let filtered = selectedPlantID.flatMap { id in plants.filter { $0.id == id } } ?? plants
        var collected: [PhotoDiaryItem] = []
        for plant in filtered {
            let entries = moodRepository.fetchAll(for: plant.id).filter { $0.photoData != nil }
            for entry in entries {
                collected.append(PhotoDiaryItem(id: entry.id, plant: plant, entry: entry))
            }
        }
        items = collected.sorted { $0.entry.date > $1.entry.date }
    }

    func setFilter(plantID: UUID?) {
        selectedPlantID = plantID
        load()
    }
}
