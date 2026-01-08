import Foundation
import CoreData

@objc(Poem)
public class Poem: NSManagedObject {
    @nonobjc public class func fetchRequest() -> NSFetchRequest<Poem> {
        return NSFetchRequest<Poem>(entityName: "Poem")
    }
    
    @NSManaged public var id: UUID
    @NSManaged public var title: String
    @NSManaged public var author: String
    @NSManaged public var fullText: String
    @NSManaged public var notes: String
    @NSManaged public var wordCount: Int32
    @NSManaged public var sectionCount: Int32
    @NSManaged public var dateAdded: Date
    @NSManaged public var isInLibrary: Bool
    @NSManaged public var sections: NSSet?
    @NSManaged public var memorizationSessions: NSSet?
}

extension Poem {
    @objc(addSectionsObject:)
    @NSManaged public func addToSections(_ value: PoemSection)

    @objc(removeSectionsObject:)
    @NSManaged public func removeFromSections(_ value: PoemSection)

    @objc(addSections:)
    @NSManaged public func addToSections(_ values: NSSet)

    @objc(removeSections:)
    @NSManaged public func removeFromSections(_ values: NSSet)
    
    @objc(addMemorizationSessionsObject:)
    @NSManaged public func addToMemorizationSessions(_ value: MemorizationSession)

    @objc(removeMemorizationSessionsObject:)
    @NSManaged public func removeFromMemorizationSessions(_ value: MemorizationSession)

    @objc(addMemorizationSessions:)
    @NSManaged public func addToMemorizationSessions(_ values: NSSet)

    @objc(removeMemorizationSessions:)
    @NSManaged public func removeFromMemorizationSessions(_ values: NSSet)
}

extension Poem: Identifiable {
    var sectionsArray: [PoemSection] {
        let set = sections as? Set<PoemSection> ?? []
        return set.sorted { $0.sectionNumber < $1.sectionNumber }
    }
    
    var memorizationSessionsArray: [MemorizationSession] {
        let set = memorizationSessions as? Set<MemorizationSession> ?? []
        return set.sorted { $0.date > $1.date }
    }
    
    var nextReviewDate: Date? {
        return memorizationSessionsArray.first?.nextReviewDate
    }
    
    var shouldReview: Bool {
        guard let nextReview = nextReviewDate else { return isInLibrary }
        return Date() >= nextReview && isInLibrary
    }
}