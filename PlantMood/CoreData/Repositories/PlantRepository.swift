import CoreData
import Combine
import Foundation

final class PlantRepository: ObservableObject {
    private let stack: CoreDataStack

    init(stack: CoreDataStack = .shared) {
        self.stack = stack
    }

    func fetchAll() -> [Plant] {
        let request = NSFetchRequest<NSManagedObject>(entityName: "PlantEntity")
        request.sortDescriptors = [NSSortDescriptor(key: "addedDate", ascending: false)]
        do {
            let entities = try stack.viewContext.fetch(request)
            return entities.compactMap { mapToPlant($0) }
        } catch {
            assertionFailure("PlantRepository.fetchAll failed: \(error)")
            return []
        }
    }

    func fetch(id: UUID) -> Plant? {
        guard let entity = entity(for: id) else { return nil }
        return mapToPlant(entity)
    }

    func save(plant: Plant) {
        let entity = entity(for: plant.id) ?? NSEntityDescription.insertNewObject(
            forEntityName: "PlantEntity",
            into: stack.viewContext
        )
        entity.setValue(plant.id, forKey: "id")
        entity.setValue(plant.name, forKey: "name")
        entity.setValue(plant.species, forKey: "species")
        entity.setValue(plant.emoji, forKey: "emoji")
        entity.setValue(Int32(plant.wateringIntervalDays), forKey: "wateringIntervalDays")
        entity.setValue(plant.lastWateredDate, forKey: "lastWateredDate")
        entity.setValue(plant.addedDate, forKey: "addedDate")
        entity.setValue(plant.notes, forKey: "notes")
        entity.setValue(plant.isPremium, forKey: "isPremium")
        stack.saveContext()
    }

    func delete(plant: Plant) {
        guard let entity = entity(for: plant.id) else { return }
        stack.viewContext.delete(entity)
        stack.saveContext()
    }

    private func entity(for id: UUID) -> NSManagedObject? {
        let request = NSFetchRequest<NSManagedObject>(entityName: "PlantEntity")
        request.predicate = NSPredicate(format: "id == %@", id as CVarArg)
        request.fetchLimit = 1
        return (try? stack.viewContext.fetch(request))?.first
    }

    private func mapToPlant(_ entity: NSManagedObject) -> Plant? {
        guard
            let id = entity.value(forKey: "id") as? UUID,
            let name = entity.value(forKey: "name") as? String,
            let species = entity.value(forKey: "species") as? String,
            let emoji = entity.value(forKey: "emoji") as? String,
            let interval = entity.value(forKey: "wateringIntervalDays") as? Int32,
            let addedDate = entity.value(forKey: "addedDate") as? Date,
            let notes = entity.value(forKey: "notes") as? String,
            let isPremium = entity.value(forKey: "isPremium") as? Bool
        else { return nil }
        let lastWatered = entity.value(forKey: "lastWateredDate") as? Date
        return Plant(
            id: id,
            name: name,
            species: species,
            emoji: emoji,
            wateringIntervalDays: Int(interval),
            lastWateredDate: lastWatered,
            addedDate: addedDate,
            notes: notes,
            isPremium: isPremium
        )
    }
}
