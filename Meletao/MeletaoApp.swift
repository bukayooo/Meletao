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
        CalendarService.shared.addReviewEventsToCalendar(context: context)
    }
}