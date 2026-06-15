import CoreData
import Combine
import Foundation

final class WateringRepository: ObservableObject {
    private let stack: CoreDataStack

    init(stack: CoreDataStack = .shared) {
        self.stack = stack
    }

    func fetchAll(for plantID: UUID) -> [WateringRecord] {
        let request = NSFetchRequest<NSManagedObject>(entityName: "WateringRecordEntity")
        request.predicate = NSPredicate(format: "plantID == %@", plantID as CVarArg)
        request.sortDescriptors = [NSSortDescriptor(key: "date", ascending: false)]
        do {
            let entities = try stack.viewContext.fetch(request)
            return entities.compactMap { mapToRecord($0) }
        } catch {
            assertionFailure("WateringRepository.fetchAll failed: \(error)")
            return []
        }
    }

    func fetchAll() -> [WateringRecord] {
        let request = NSFetchRequest<NSManagedObject>(entityName: "WateringRecordEntity")
        request.sortDescriptors = [NSSortDescriptor(key: "date", ascending: false)]
        do {
            let entities = try stack.viewContext.fetch(request)
            return entities.compactMap { mapToRecord($0) }
        } catch {
            assertionFailure("WateringRepository.fetchAll failed: \(error)")
            return []
        }
    }

    func save(record: WateringRecord) {
        let entity = entity(for: record.id) ?? NSEntityDescription.insertNewObject(
            forEntityName: "WateringRecordEntity",
            into: stack.viewContext
        )
        entity.setValue(record.id, forKey: "id")
        entity.setValue(record.plantID, forKey: "plantID")
        entity.setValue(record.date, forKey: "date")
        entity.setValue(record.note, forKey: "note")
        stack.saveContext()
    }

    func delete(record: WateringRecord) {
        guard let entity = entity(for: record.id) else { return }
        stack.viewContext.delete(entity)
        stack.saveContext()
    }

    private func entity(for id: UUID) -> NSManagedObject? {
        let request = NSFetchRequest<NSManagedObject>(entityName: "WateringRecordEntity")
        request.predicate = NSPredicate(format: "id == %@", id as CVarArg)
        request.fetchLimit = 1
        return (try? stack.viewContext.fetch(request))?.first
    }

    private func mapToRecord(_ entity: NSManagedObject) -> WateringRecord? {
        guard
            let id = entity.value(forKey: "id") as? UUID,
            let plantID = entity.value(forKey: "plantID") as? UUID,
            let date = entity.value(forKey: "date") as? Date,
            let note = entity.value(forKey: "note") as? String
        else { return nil }
        return WateringRecord(id: id, plantID: plantID, date: date, note: note)
    }
}
