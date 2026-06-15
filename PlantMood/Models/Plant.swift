import Foundation

struct Plant: Identifiable, Hashable {
    let id: UUID
    var name: String
    var species: String
    var emoji: String
    var wateringIntervalDays: Int
    var lastWateredDate: Date?
    var addedDate: Date
    var notes: String
    var isPremium: Bool

    var nextWateringDate: Date? {
        guard let last = lastWateredDate else { return nil }
        return Calendar.current.date(byAdding: .day, value: wateringIntervalDays, to: last)
    }

    var needsWatering: Bool {
        guard let next = nextWateringDate else { return true }
        return Calendar.current.startOfDay(for: next) <= Calendar.current.startOfDay(for: Date())
    }

    var daysUntilWatering: Int? {
        guard let next = nextWateringDate else { return nil }
        let calendar = Calendar.current
        let start = calendar.startOfDay(for: Date())
        let end = calendar.startOfDay(for: next)
        return calendar.dateComponents([.day], from: start, to: end).day
    }

    init(
        id: UUID = UUID(),
        name: String,
        species: String,
        emoji: String,
        wateringIntervalDays: Int,
        lastWateredDate: Date? = nil,
        addedDate: Date = Date(),
        notes: String = "",
        isPremium: Bool = false
    ) {
        self.id = id
        self.name = name
        self.species = species
        self.emoji = emoji
        self.wateringIntervalDays = wateringIntervalDays
        self.lastWateredDate = lastWateredDate
        self.addedDate = addedDate
        self.notes = notes
        self.isPremium = isPremium
    }
}
