import SwiftUI
import UserNotifications
import EventKit

@main
struct MeletaoApp: App {
    let persistenceController = PersistenceController.shared
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
                .onAppear {
                    requestNotificationPermission()
                    CalendarService.shared.requestCalendarAccess()
                    scheduleInitialNotifications()
                }
                .onReceive(NotificationCenter.default.publisher(for: NSApplication.didBecomeActiveNotification)) { _ in
                    // Update badge when app becomes active
                    let context = persistenceController.container.viewContext
                    NotificationService.shared.updateAppBadge(context: context)
                }
        }
    }
    
    private func requestNotificationPermission() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { granted, error in
            if granted {
                print("Notification permission granted")
            } else if let error = error {
                print("Notification permission error: \(error)")
            }
        }
    }
    
    private func scheduleInitialNotifications() {
        let context = persistenceController.container.viewContext
        NotificationService.shared.scheduleReviewNotifications(context: context)
        NotificationService.shared.scheduleDailyNotificationRefresh(context: context)
        NotificationService.shared.updateAppBadge(context: context)
        CalendarService.shared.addReviewEventsToCalendar(context: context)
    }
}