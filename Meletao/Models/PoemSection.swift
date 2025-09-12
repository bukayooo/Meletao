import Foundation
import CoreData

@objc(PoemSection)
public class PoemSection: NSManagedObject {
    @nonobjc public class func fetchRequest() -> NSFetchRequest<PoemSection> {
        return NSFetchRequest<PoemSection>(entityName: "PoemSection")
    }
    
    @NSManaged public var id: UUID
    @NSManaged public var sectionNumber: Int32
    @NSManaged public var text: String
    @NSManaged public var wordCount: Int32
    @NSManaged public var poem: Poem?
}

extension PoemSection: Identifiable {
    var words: [String] {
        return text.components(separatedBy: .whitespacesAndNewlines)
            .filter { !$0.isEmpty }
    }
}