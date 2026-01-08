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
        
        // Check if this was an overdue review and adjust schedule accordingly
        let daysMissed = getDaysMissed(for: poem)
        let adjustedInterval = calculateAdjustedInterval(reviewCount: reviewCount, daysMissed: daysMissed)
        
        session.nextReviewDate = Date().addingTimeInterval(adjustedInterval)
    }
    
    private func getDaysMissed(for poem: Poem) -> Int {
        guard let lastReviewDate = poem.nextReviewDate else { return 0 }
        let daysMissed = Calendar.current.dateComponents([.day], from: lastReviewDate, to: Date()).day ?? 0
        return max(0, daysMissed)
    }
    
    private func calculateAdjustedInterval(reviewCount: Int, daysMissed: Int) -> TimeInterval {
        let baseIntervalIndex = min(reviewCount, intervals.count - 1)
        let baseInterval = intervals[baseIntervalIndex]
        
        if daysMissed == 0 {
            return baseInterval
        }
        
        // Apply spaced repetition principle: if review was missed, reduce the next interval
        // This follows the forgetting curve - missed reviews indicate weaker retention
        let missedDaysPenalty = Double(daysMissed) * 0.2 // 20% reduction per missed day
        let reductionFactor = max(0.3, 1.0 - missedDaysPenalty) // Minimum 30% of original interval
        
        // Calculate adjusted interval
        let adjustedInterval = baseInterval * reductionFactor
        
        // Ensure minimum interval of 1 day
        return max(24 * 60 * 60, adjustedInterval)
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
    
    func getOverduePoems(context: NSManagedObjectContext) -> [Poem] {
        let request: NSFetchRequest<Poem> = Poem.fetchRequest()
        request.predicate = NSPredicate(format: "isInLibrary == true")
        
        do {
            let poems = try context.fetch(request)
            return poems.filter { poem in
                guard let nextReview = poem.nextReviewDate else { return false }
                let daysMissed = Calendar.current.dateComponents([.day], from: nextReview, to: Date()).day ?? 0
                return daysMissed > 0
            }
        } catch {
            print("Error fetching overdue poems: \(error)")
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