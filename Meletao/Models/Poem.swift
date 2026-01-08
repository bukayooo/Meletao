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
    @NSManaged public var category: String
    @NSManaged public var tags: String
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
    
    var tagsArray: [String] {
        guard !tags.isEmpty else { return [] }
        return tags.components(separatedBy: ",").map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }.filter { !$0.isEmpty }
    }
    
    func setTags(_ tagArray: [String]) {
        tags = tagArray.joined(separator: ", ")
    }
}

// MARK: - Categories and Tags
extension Poem {
    static let categories = [
        "Poem",
        "Book Excerpt",
        "Bible Verse",
        "Speech",
        "Song Lyrics",
        "Prayer",
        "Letter",
        "Monologue",
    ]
    
    static let availableTags = [
    // Emotions
    "Love", "Joy", "Hope", "Peace", "Gratitude", "Wonder", "Inspiration",
    "Melancholy", "Sadness", "Grief", "Loss", "Longing", "Nostalgia",
    "Solitude", "Introspection", "Anger", "Fear", "Despair", "Ecstasy",
    
    // Life Themes
    "Life", "Death & Mortality", "Birth & Growth", "Change", "Time",
    "Memory", "Dreams", "Life Stages", "Wisdom", "Journey", "Adventure",
    "Discovery", "Courage", "Strength", "Fate", "Destiny", "Legacy",
    
    // Relationships
    "Family", "Friendship", "Romance", "Marriage", "Parenthood",
    "Community", "Humanity", "Compassion", "Empathy", "Loyalty",
    "Betrayal", "Brotherhood", "Sisterhood",
    
    // Spiritual/Religious
    "Faith", "God", "Divine", "Sacred", "Prayer", "Worship", "Grace",
    "Redemption", "Forgiveness", "Soul", "Heaven", "Eternity", "Sin",
    "Salvation", "Providence", "Miracles", "Humility",
    
    // Nature
    "Nature", "Seasons", "Spring", "Summer", "Autumn", "Winter",
    "Ocean", "Mountains", "Forest", "Sky", "Stars", "Moon", "Sun",
    "Rain", "Storm", "Garden", "Flowers", "Trees", "Birds", "Animals",
    "Rivers", "Wind", "Fire",
    
    // Abstract Concepts
    "Beauty", "Truth", "Justice", "Freedom", "Honor", "Duty", "Sacrifice",
    "Heroism", "Patriotism", "War", "Philosophy", "Knowledge", "Art",
    "Creativity", "Masculinity", "Femininity", "Good", "Evil", "Power",
    "Ambition", "Vanity",
    
    // Social & Cultural
    "Poverty", "Wealth", "Work", "History", "Culture", "Tradition",
    
    // Personal Growth
    "Self-Discovery", "Purpose", "Meaning", "Achievement", "Success",
    "Failure", "Perseverance", "Determination", "Character", "Virtue",
    "Ethics", "Morality", "Conscience", "Responsibility", "Discipline",
    "Temperance", "Prudence", "Fortitude", "Rhetoric"
].sorted()
}