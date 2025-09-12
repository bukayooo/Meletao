import Foundation
import CoreData

class SpacedRepetitionService {
    static let shared = SpacedRepetitionService()
    
    private init() {}
    
    private let intervals: [TimeInterval] = [
        24 * 60 * 60,      // 1 day
        2 * 24 * 60 * 60,  // 2 days
        4 * 24 * 60 * 60,  // 4 days
        7 * 24 * 60 * 60,  // 1 week
        14 * 24 * 60 * 60, // 2 weeks
        30 * 24 * 60 * 60, // 1 month
        60 * 24 * 60 * 60, // 2 months
        120 * 24 * 60 * 60 // 4 months
    ]
    
    func scheduleNextReview(for poem: Poem, context: NSManagedObjectContext) {
        let session = MemorizationSession(context: context)
        session.id = UUID()
        session.date = Date()
        session.poem = poem
        session.isCompleted = true
        
        let reviewCount = Int(poem.memorizationSessionsArray.count)
        session.reviewCount = Int32(reviewCount + 1)
        
        let intervalIndex = min(reviewCount, intervals.count - 1)
        let interval = intervals[intervalIndex]
        session.nextReviewDate = Date().addingTimeInterval(interval)
    }
    
    func getPoemsForReview(context: NSManagedObjectContext) -> [Poem] {
        let request: NSFetchRequest<Poem> = Poem.fetchRequest()
        request.predicate = NSPredicate(format: "isInLibrary == true")
        
        do {
            let poems = try context.fetch(request)
            return poems.filter { poem in
                guard let nextReview = poem.nextReviewDate else {
                    return true
                }
                return Date() >= nextReview
            }
        } catch {
            print("Error fetching poems for review: \(error)")
            return []
        }
    }
    
    func getUpcomingReviewDates(context: NSManagedObjectContext) -> [Date] {
        let request: NSFetchRequest<MemorizationSession> = MemorizationSession.fetchRequest()
        request.predicate = NSPredicate(format: "poem.isInLibrary == true AND nextReviewDate > %@", Date() as NSDate)
        request.sortDescriptors = [NSSortDescriptor(keyPath: \MemorizationSession.nextReviewDate, ascending: true)]
        
        do {
            let sessions = try context.fetch(request)
            return sessions.compactMap { $0.nextReviewDate }
        } catch {
            print("Error fetching upcoming review dates: \(error)")
            return []
        }
    }
}