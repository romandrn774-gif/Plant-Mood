import CoreData
import UIKit

final class CoreDataStack {
    static let shared = CoreDataStack()

    let persistentContainer: NSPersistentContainer

    var viewContext: NSManagedObjectContext { persistentContainer.viewContext }

    private init() {
        persistentContainer = NSPersistentContainer(name: "PlantMood")
        persistentContainer.loadPersistentStores { storeDescription, error in
            if let error = error as NSError? {
                assertionFailure("Unable to load persistent store: \(error), \(error.userInfo)")
            }
            storeDescription.shouldInferMappingModelAutomatically = true
            storeDescription.shouldMigrateStoreAutomatically = true
        }
        persistentContainer.viewContext.automaticallyMergesChangesFromParent = true
        persistentContainer.viewContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy

        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleWillResignActive),
            name: UIApplication.willResignActiveNotification,
            object: nil
        )
    }

    func backgroundContext() -> NSManagedObjectContext {
        let context = persistentContainer.newBackgroundContext()
        context.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
        return context
    }

    func saveContext() {
        let context = viewContext
        guard context.hasChanges else { return }
        do {
            try context.save()
        } catch {
            let nsError = error as NSError
            assertionFailure("CoreData save failed: \(nsError), \(nsError.userInfo)")
        }
    }

    @objc private func handleWillResignActive() {
        saveContext()
    }
}
