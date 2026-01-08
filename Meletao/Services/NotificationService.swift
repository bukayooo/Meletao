import Foundation
import UserNotifications
import CoreData
import AppKit

class NotificationService {
    static let shared = NotificationService()
    
    private init() {}
    
    func scheduleReviewNotifications(context: NSManagedObjectContext) {
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
        
        let reviewDates = SpacedRepetitionService.shared.getUpcomingReviewDates(context: context)
        let overduePoems = SpacedRepetitionService.shared.getOverduePoems(context: context)
        
        // Schedule notifications for upcoming reviews
        for date in reviewDates.prefix(60) { // Leave some room for overdue notifications
            scheduleNotification(for: date, context: context)
        }
        
        // Schedule persistent reminders for overdue poems
        scheduleOverdueReminders(for: overduePoems, context: context)
        
        // Update app badge with current review count
        updateAppBadge(context: context)
    }
    
    func updateAppBadge(context: NSManagedObjectContext) {
        let poemsForReview = SpacedRepetitionService.shared.getPoemsForReview(context: context)
        let badgeCount = poemsForReview.count
        
        DispatchQueue.main.async {
            NSApp.dockTile.badgeLabel = badgeCount > 0 ? "\(badgeCount)" : nil
        }
    }
    
    private func scheduleNotification(for date: Date, context: NSManagedObjectContext) {
        let content = UNMutableNotificationContent()
        content.title = "Review Time"
        
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
    
    private func scheduleOverdueReminders(for overduePoems: [Poem], context: NSManagedObjectContext) {
        guard !overduePoems.isEmpty else { return }
        
        let today = Date()
        
        for poem in overduePoems {
            guard let nextReviewDate = poem.nextReviewDate else { continue }
            
            let daysMissed = Calendar.current.dateComponents([.day], from: nextReviewDate, to: today).day ?? 0
            
            if daysMissed > 0 {
                // Schedule daily reminders for overdue poems
                for dayOffset in 0...min(daysMissed + 3, 7) { // Limit to 7 days of reminders
                    let reminderDate = Calendar.current.date(byAdding: .day, value: dayOffset, to: today)!
                    scheduleOverdueNotification(for: poem, daysMissed: daysMissed + dayOffset, date: reminderDate)
                }
            }
        }
    }
    
    private func scheduleOverdueNotification(for poem: Poem, daysMissed: Int, date: Date) {
        let content = UNMutableNotificationContent()
        content.title = "Overdue Review Reminder"
        
        if daysMissed == 1 {
            content.body = "You missed reviewing \"\(poem.title)\" yesterday. Review it now to stay on track!"
        } else {
            content.body = "You haven't reviewed \"\(poem.title)\" for \(daysMissed) days. Don't lose your progress!"
        }
        
        content.sound = .default
        content.categoryIdentifier = "OVERDUE_REMINDER"
        content.userInfo = [
            "poemId": poem.id.uuidString,
            "daysMissed": daysMissed
        ]
        
        var dateComponents = Calendar.current.dateComponents([.year, .month, .day], from: date)
        dateComponents.hour = 19 // 7 PM
        dateComponents.minute = 0
        
        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: false)
        
        let identifier = "overdue_\(poem.id.uuidString)_\(date.timeIntervalSince1970)"
        let request = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)
        
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Error scheduling overdue notification: \(error)")
            }
        }
    }
    
    func updateNotificationsAfterMemorization(context: NSManagedObjectContext) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            self.scheduleReviewNotifications(context: context)
        }
    }
    
    func scheduleDailyNotificationRefresh(context: NSManagedObjectContext) {
        // Schedule a daily refresh to check for overdue poems and update notifications
        let content = UNMutableNotificationContent()
        content.title = "Daily Notification Refresh"
        content.body = "Updating review reminders..."
        content.sound = nil // Silent notification
        content.categoryIdentifier = "DAILY_REFRESH"
        
        var dateComponents = DateComponents()
        dateComponents.hour = 8 // 8 AM daily refresh
        dateComponents.minute = 0
        
        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
        
        let identifier = "daily_refresh"
        let request = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)
        
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Error scheduling daily refresh notification: \(error)")
            }
        }
    }
    
    func requestNotificationPermission() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { granted, error in
            if granted {
                DispatchQueue.main.async {
                    // Permission granted - notifications can be scheduled
                }
            }
            if let error = error {
                print("Notification permission error: \(error)")
            }
        }
    }
}