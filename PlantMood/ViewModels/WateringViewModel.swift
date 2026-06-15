import Foundation
import Combine

struct WateringDay: Identifiable {
    let id = UUID()
    let date: Date
    let plants: [Plant]
    var isToday: Bool { Calendar.current.isDateInToday(date) }
    var isPast: Bool { Calendar.current.startOfDay(for: date) < Calendar.current.startOfDay(for: Date()) }
}

@MainActor
final class WateringViewModel: ObservableObject {
    @Published var upcomingDays: [WateringDay] = []
    @Published var overdue: [Plant] = []
    @Published var plants: [Plant] = []

    private let plantRepository: PlantRepository
    private let wateringRepository: WateringRepository

    init(
        plantRepository: PlantRepository = PlantRepository(),
        wateringRepository: WateringRepository = WateringRepository()
    ) {
        self.plantRepository = plantRepository
        self.wateringRepository = wateringRepository
    }

    func load() {
        plants = plantRepository.fetchAll()
        overdue = plants.filter { plant in
            guard let next = plant.nextWateringDate else { return false }
            return next < Calendar.current.startOfDay(for: Date())
        }
        upcomingDays = buildUpcoming(days: 14)
    }

    func waterToday(plant: Plant) {
        var updated = plant
        updated.lastWateredDate = Date()
        plantRepository.save(plant: updated)
        wateringRepository.save(record: WateringRecord(plantID: plant.id, date: Date()))
        NotificationManager.shared.scheduleWateringReminder(for: updated)
        load()
    }

    private func buildUpcoming(days: Int) -> [WateringDay] {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        var result: [WateringDay] = []
        for offset in 0..<days {
            guard let day = calendar.date(byAdding: .day, value: offset, to: today) else { continue }
            let plantsForDay = plants.filter { plant in
                guard let next = plant.nextWateringDate else { return false }
                return calendar.isDate(next, inSameDayAs: day)
            }
            result.append(WateringDay(date: day, plants: plantsForDay))
        }
        return result
    }
}
