import SwiftUI
import UserNotifications
import EventKit

@main
struct MeletaoApp: App {
    let persistenceController = PersistenceController.shared
    // Fires every 5 minutes to keep the dock badge current while the app is running
    let badgeTimer = Timer.publish(every: 300, on: .main, in: .common).autoconnect()

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
                    let context = persistenceController.container.viewContext
                    NotificationService.shared.updateAppBadge(context: context)
                }
                .onReceive(badgeTimer) { _ in
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