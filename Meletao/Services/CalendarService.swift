import Foundation
import EventKit
import CoreData

class CalendarService {
    static let shared = CalendarService()
    
    private let eventStore = EKEventStore()
    private var hasCalendarAccess = false
    
    private init() {}
    
    func requestCalendarAccess() {
        if #available(macOS 14.0, *) {
            eventStore.requestWriteOnlyAccessToEvents { granted, error in
                DispatchQueue.main.async {
                    self.hasCalendarAccess = granted
                    if let error = error {
                        print("Calendar access error: \(error)")
                    }
                }
            }
        } else {
            eventStore.requestAccess(to: .event) { granted, error in
                DispatchQueue.main.async {
                    self.hasCalendarAccess = granted
                    if let error = error {
                        print("Calendar access error: \(error)")
                    }
                }
            }
        }
    }
    
    func addReviewEventsToCalendar(context: NSManagedObjectContext) {
        guard hasCalendarAccess else {
            requestCalendarAccess()
            return
        }
        
        let reviewDates = SpacedRepetitionService.shared.getUpcomingReviewDates(context: context)
        
        for date in reviewDates {
            addCalendarEvent(for: date, context: context)
        }
    }
    
    private func addCalendarEvent(for date: Date, context: NSManagedObjectContext) {
        let event = EKEvent(eventStore: eventStore)
        event.title = "Meletao Poetry Review"
        
        let poemsCount = SpacedRepetitionService.shared.getPoemsForReview(context: context).count
        if poemsCount == 1 {
            event.notes = "Review 1 poem using spaced repetition"
        } else {
            event.notes = "Review \(poemsCount) poems using spaced repetition"
        }
        
        let startDate = Calendar.current.date(bySettingHour: 19, minute: 0, second: 0, of: date) ?? date
        let endDate = Calendar.current.date(byAdding: .minute, value: 30, to: startDate) ?? startDate
        
        event.startDate = startDate
        event.endDate = endDate
        event.calendar = eventStore.defaultCalendarForNewEvents
        
        let alarm = EKAlarm(absoluteDate: Calendar.current.date(byAdding: .minute, value: -10, to: startDate) ?? startDate)
        event.addAlarm(alarm)
        
        do {
            try eventStore.save(event, span: .thisEvent)
            print("Calendar event added for \(date)")
        } catch {
            print("Error adding calendar event: \(error)")
        }
    }
    
    func removeAllMeletaoEvents() {
        guard hasCalendarAccess else { return }
        
        guard let calendar = eventStore.defaultCalendarForNewEvents else { return }
        let predicate = eventStore.predicateForEvents(
            withStart: Date(),
            end: Calendar.current.date(byAdding: .year, value: 1, to: Date()) ?? Date(),
            calendars: [calendar]
        )
        
        let events = eventStore.events(matching: predicate)
        let meletaoEvents = events.filter { $0.title == "Meletao Poetry Review" }
        
        for event in meletaoEvents {
            do {
                try eventStore.remove(event, span: .thisEvent)
            } catch {
                print("Error removing calendar event: \(error)")
            }
        }
    }
    
    func updateCalendarEvents(context: NSManagedObjectContext) {
        removeAllMeletaoEvents()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            self.addReviewEventsToCalendar(context: context)
        }
    }
}