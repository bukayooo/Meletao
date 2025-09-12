import Foundation
import CoreData

@objc(MemorizationSession)
public class MemorizationSession: NSManagedObject {
    @nonobjc public class func fetchRequest() -> NSFetchRequest<MemorizationSession> {
        return NSFetchRequest<MemorizationSession>(entityName: "MemorizationSession")
    }
    
    @NSManaged public var id: UUID
    @NSManaged public var date: Date
    @NSManaged public var nextReviewDate: Date
    @NSManaged public var reviewCount: Int32
    @NSManaged public var isCompleted: Bool
    @NSManaged public var poem: Poem?
}

extension MemorizationSession: Identifiable {
    
}