import Foundation
import UserNotifications
import CoreData

class NotificationService {
    static let shared = NotificationService()
    
    private init() {}
    
    func scheduleReviewNotifications(context: NSManagedObjectContext) {
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
        
        let reviewDates = SpacedRepetitionService.shared.getUpcomingReviewDates(context: context)
        
        for date in reviewDates.prefix(64) { // iOS limit for scheduled notifications
            scheduleNotification(for: date, context: context)
        }
    }
    
    private func scheduleNotification(for date: Date, context: NSManagedObjectContext) {
        let content = UNMutableNotificationContent()
        content.title = "Meletao Review Time"
        
        let poemsCount = SpacedRepetitionService.shared.getPoemsForReview(context: context).count
        if poemsCount == 1 {
            content.body = "You have 1 poem ready for review"
        } else {
            content.body = "You have \(poemsCount) poems ready for review"
        }
        
        content.sound = .default
        content.categoryIdentifier = "REVIEW_REMINDER"
        
        var dateComponents = Calendar.current.dateComponents([.year, .month, .day], from: date)
        dateComponents.hour = 19 // 7 PM
        dateComponents.minute = 0
        
        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: false)
        
        let identifier = "review_\(date.timeIntervalSince1970)"
        let request = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)
        
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Error scheduling notification: \(error)")
            }
        }
    }
    
    func updateNotificationsAfterMemorization(context: NSManagedObjectContext) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            self.scheduleReviewNotifications(context: context)
        }
    }
}