import CoreData
import Combine
import Foundation

final class MoodRepository: ObservableObject {
    private let stack: CoreDataStack

    init(stack: CoreDataStack = .shared) {
        self.stack = stack
    }

    func fetchAll(for plantID: UUID) -> [MoodEntry] {
        let request = NSFetchRequest<NSManagedObject>(entityName: "MoodEntryEntity")
        request.predicate = NSPredicate(format: "plantID == %@", plantID as CVarArg)
        request.sortDescriptors = [NSSortDescriptor(key: "date", ascending: false)]
        do {
            let entities = try stack.viewContext.fetch(request)
            return entities.compactMap { mapToEntry($0) }
        } catch {
            assertionFailure("MoodRepository.fetchAll failed: \(error)")
            return []
        }
    }

    func save(entry: MoodEntry) {
        let entity = entity(for: entry.id) ?? NSEntityDescription.insertNewObject(
            forEntityName: "MoodEntryEntity",
            into: stack.viewContext
        )
        entity.setValue(entry.id, forKey: "id")
        entity.setValue(entry.plantID, forKey: "plantID")
        entity.setValue(Int16(entry.mood.rawValue), forKey: "moodRawValue")
        entity.setValue(entry.note, forKey: "note")
        entity.setValue(entry.date, forKey: "date")
        entity.setValue(entry.photoData, forKey: "photoData")
        stack.saveContext()
    }

    func delete(entry: MoodEntry) {
        guard let entity = entity(for: entry.id) else { return }
        stack.viewContext.delete(entity)
        stack.saveContext()
    }

    func latestEntry(for plantID: UUID) -> MoodEntry? {
        let request = NSFetchRequest<NSManagedObject>(entityName: "MoodEntryEntity")
        request.predicate = NSPredicate(format: "plantID == %@", plantID as CVarArg)
        request.sortDescriptors = [NSSortDescriptor(key: "date", ascending: false)]
        request.fetchLimit = 1
        return (try? stack.viewContext.fetch(request))?.first.flatMap { mapToEntry($0) }
    }

    func entriesForChart(plantID: UUID, days: Int) -> [MoodEntry] {
        let calendar = Calendar.current
        guard let cutoff = calendar.date(byAdding: .day, value: -days, to: Date()) else { return [] }
        let request = NSFetchRequest<NSManagedObject>(entityName: "MoodEntryEntity")
        request.predicate = NSPredicate(format: "plantID == %@ AND date >= %@", plantID as CVarArg, cutoff as NSDate)
        request.sortDescriptors = [NSSortDescriptor(key: "date", ascending: true)]
        do {
            let entities = try stack.viewContext.fetch(request)
            return entities.compactMap { mapToEntry($0) }
        } catch {
            assertionFailure("MoodRepository.entriesForChart failed: \(error)")
            return []
        }
    }

    func todayEntry(for plantID: UUID) -> MoodEntry? {
        let calendar = Calendar.current
        let start = calendar.startOfDay(for: Date())
        guard let end = calendar.date(byAdding: .day, value: 1, to: start) else { return nil }
        let request = NSFetchRequest<NSManagedObject>(entityName: "MoodEntryEntity")
        request.predicate = NSPredicate(
            format: "plantID == %@ AND date >= %@ AND date < %@",
            plantID as CVarArg, start as NSDate, end as NSDate
        )
        request.fetchLimit = 1
        return (try? stack.viewContext.fetch(request))?.first.flatMap { mapToEntry($0) }
    }

    private func entity(for id: UUID) -> NSManagedObject? {
        let request = NSFetchRequest<NSManagedObject>(entityName: "MoodEntryEntity")
        request.predicate = NSPredicate(format: "id == %@", id as CVarArg)
        request.fetchLimit = 1
        return (try? stack.viewContext.fetch(request))?.first
    }

    private func mapToEntry(_ entity: NSManagedObject) -> MoodEntry? {
        guard
            let id = entity.value(forKey: "id") as? UUID,
            let plantID = entity.value(forKey: "plantID") as? UUID,
            let moodRaw = entity.value(forKey: "moodRawValue") as? Int16,
            let mood = PlantMood(rawValue: Int(moodRaw)),
            let note = entity.value(forKey: "note") as? String,
            let date = entity.value(forKey: "date") as? Date
        else { return nil }
        let photo = entity.value(forKey: "photoData") as? Data
        return MoodEntry(id: id, plantID: plantID, mood: mood, note: note, date: date, photoData: photo)
    }
}
