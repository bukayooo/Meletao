import CoreData

struct PersistenceController {
    static let shared = PersistenceController()

    static var preview: PersistenceController = {
        let result = PersistenceController(inMemory: true)
        let viewContext = result.container.viewContext
        
        // Add some sample data for previews
        let samplePoem = Poem(context: viewContext)
        samplePoem.id = UUID()
        samplePoem.title = "Sample Poem"
        samplePoem.author = "Sample Author"
        samplePoem.fullText = "This is a sample poem for preview purposes."
        samplePoem.wordCount = 9
        samplePoem.sectionCount = 1
        samplePoem.dateAdded = Date()
        samplePoem.isInLibrary = false
        samplePoem.category = "Poem"
        samplePoem.tags = ""
        
        do {
            try viewContext.save()
        } catch {
            let nsError = error as NSError
            fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
        }
        return result
    }()

    let container: NSPersistentContainer

    init(inMemory: Bool = false) {
        container = NSPersistentContainer(name: "DataModel")

        if inMemory {
            container.persistentStoreDescriptions.first!.url = URL(fileURLWithPath: "/dev/null")
        }

        // Enable automatic lightweight migration
        container.persistentStoreDescriptions.forEach { description in
            description.shouldMigrateStoreAutomatically = true
            description.shouldInferMappingModelAutomatically = true
        }

        loadStore()

        container.viewContext.automaticallyMergesChangesFromParent = true
    }

    private func loadStore() {
        container.loadPersistentStores { [weak container] storeDescription, error in
            if let error = error as NSError? {
                print("⚠️ Core Data error: \(error)")
                print("Error domain: \(error.domain)")
                print("Error code: \(error.code)")
                print("User info: \(error.userInfo)")
                print("Store description: \(storeDescription)")

                // Attempt recovery by removing the corrupted store
                if let storeURL = storeDescription.url {
                    print("🔧 Attempting to remove corrupted store at: \(storeURL)")

                    do {
                        let fileManager = FileManager.default
                        // Remove the store file
                        if fileManager.fileExists(atPath: storeURL.path) {
                            try fileManager.removeItem(at: storeURL)
                            print("✓ Removed store file")
                        }

                        // Remove associated files (-shm, -wal)
                        let shmURL = storeURL.deletingPathExtension().appendingPathExtension("sqlite-shm")
                        let walURL = storeURL.deletingPathExtension().appendingPathExtension("sqlite-wal")

                        if fileManager.fileExists(atPath: shmURL.path) {
                            try fileManager.removeItem(at: shmURL)
                            print("✓ Removed .sqlite-shm file")
                        }
                        if fileManager.fileExists(atPath: walURL.path) {
                            try fileManager.removeItem(at: walURL)
                            print("✓ Removed .sqlite-wal file")
                        }

                        print("✓ Successfully removed corrupted store files. Recreating fresh store...")

                        // Recreate the store
                        if let container = container {
                            container.loadPersistentStores { _, retryError in
                                if let retryError = retryError {
                                    fatalError("Failed to recreate Core Data store after cleanup: \(retryError)")
                                } else {
                                    print("✓ Successfully created fresh Core Data store")
                                }
                            }
                        }
                    } catch {
                        fatalError("Failed to remove corrupted store: \(error)")
                    }
                } else {
                    fatalError("Unresolved Core Data error: \(error), \(error.userInfo)")
                }
            }
        }
    }
}

extension PersistenceController {
    func save() {
        let context = container.viewContext

        if context.hasChanges {
            do {
                try context.save()
            } catch {
                let nsError = error as NSError
                fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
            }
        }
    }
}