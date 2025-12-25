//
//  ReminderManager.swift
//  Expenses
//
//  Created by Phong Hy on 25/12/25.
//

import EventKit
import UserNotifications
import SwiftUI
import Combine

final class ReminderManager: ObservableObject {
    static let shared = ReminderManager()
    
    private let eventStore = EKEventStore()
    private let notificationCenter = UNUserNotificationCenter.current()
    
    @Published var notificationPermissionGranted = false
    @Published var calendarPermissionGranted = false
    
    private init() {
        checkPermissions()
    }
    
    // MARK: - Permission Checking
    
    func checkPermissions() {
        // Check notification permission
        notificationCenter.getNotificationSettings { [weak self] settings in
            DispatchQueue.main.async {
                self?.notificationPermissionGranted = settings.authorizationStatus == .authorized
            }
        }
        
        // Check calendar permission
        let status = EKEventStore.authorizationStatus(for: .event)
        DispatchQueue.main.async {
            self.calendarPermissionGranted = status == .fullAccess || status == .authorized
        }
    }
    
    // MARK: - Request Permissions
    
    func requestNotificationPermission() async -> Bool {
        do {
            let granted = try await notificationCenter.requestAuthorization(options: [.alert, .badge, .sound])
            await MainActor.run {
                self.notificationPermissionGranted = granted
            }
            return granted
        } catch {
            return false
        }
    }
    
    func requestCalendarPermission() async -> Bool {
        do {
            let granted = try await eventStore.requestFullAccessToEvents()
            await MainActor.run {
                self.calendarPermissionGranted = granted
            }
            return granted
        } catch {
            return false
        }
    }
    
    // MARK: - Local Notifications
    
    func scheduleNotification(for reminder: Reminder) async throws {
        if !notificationPermissionGranted {
            let granted = await requestNotificationPermission()
            if !granted {
                throw ReminderError.notificationPermissionDenied
            }
        }
        
        let content = UNMutableNotificationContent()
        content.title = NSLocalizedString("notification.reminder.title", comment: "")
        content.body = reminder.title
        if let note = reminder.note, !note.isEmpty {
            content.body += "\n\(note)"
        }
        content.sound = .default
        content.badge = 1
        
        let dateComponents = Calendar.current.dateComponents(
            [.year, .month, .day, .hour, .minute],
            from: reminder.reminderDate
        )
        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: false)
        
        let request = UNNotificationRequest(
            identifier: reminder.notificationId,
            content: content,
            trigger: trigger
        )
        
        try await notificationCenter.add(request)
    }
    
    func cancelNotification(for reminder: Reminder) {
        notificationCenter.removePendingNotificationRequests(withIdentifiers: [reminder.notificationId])
        notificationCenter.removeDeliveredNotifications(withIdentifiers: [reminder.notificationId])
    }
    
    func updateNotification(for reminder: Reminder) async throws {
        cancelNotification(for: reminder)
        if !reminder.isCompleted {
            try await scheduleNotification(for: reminder)
        }
    }
    
    // MARK: - iCloud Calendar
    
    func addToCalendar(reminder: Reminder) async throws -> String? {
        if !calendarPermissionGranted {
            let granted = await requestCalendarPermission()
            if !granted {
                throw ReminderError.calendarPermissionDenied
            }
        }
        
        let event = EKEvent(eventStore: eventStore)
        event.title = reminder.title
        event.notes = reminder.note
        event.startDate = reminder.reminderDate
        event.endDate = Calendar.current.date(byAdding: .hour, value: 1, to: reminder.reminderDate)
        event.calendar = eventStore.defaultCalendarForNewEvents
        
        // Add alarm 15 minutes before
        let alarm = EKAlarm(relativeOffset: -15 * 60)
        event.addAlarm(alarm)
        
        try eventStore.save(event, span: .thisEvent)
        
        return event.eventIdentifier
    }
    
    func updateCalendarEvent(for reminder: Reminder) async throws {
        guard let eventId = reminder.calendarEventId,
              let event = eventStore.event(withIdentifier: eventId) else {
            return
        }
        
        event.title = reminder.title
        event.notes = reminder.note
        event.startDate = reminder.reminderDate
        event.endDate = Calendar.current.date(byAdding: .hour, value: 1, to: reminder.reminderDate)
        
        try eventStore.save(event, span: .thisEvent)
    }
    
    func removeFromCalendar(reminder: Reminder) throws {
        guard let eventId = reminder.calendarEventId,
              let event = eventStore.event(withIdentifier: eventId) else {
            return
        }
        
        try eventStore.remove(event, span: .thisEvent)
    }
    
    // MARK: - Combined Actions
    
    func scheduleReminder(_ reminder: Reminder, addToCalendar: Bool) async throws -> String? {
        // Schedule local notification
        try await scheduleNotification(for: reminder)
        
        // Add to iCloud Calendar if requested
        var calendarEventId: String? = nil
        if addToCalendar {
            calendarEventId = try await self.addToCalendar(reminder: reminder)
        }
        
        return calendarEventId
    }
    
    func cancelReminder(_ reminder: Reminder) throws {
        cancelNotification(for: reminder)
        if reminder.calendarEventId != nil {
            try removeFromCalendar(reminder: reminder)
        }
    }
}

// MARK: - Errors

enum ReminderError: LocalizedError {
    case notificationPermissionDenied
    case calendarPermissionDenied
    case schedulingFailed
    
    var errorDescription: String? {
        switch self {
        case .notificationPermissionDenied:
            return NSLocalizedString("error.notification.permission", comment: "")
        case .calendarPermissionDenied:
            return NSLocalizedString("error.calendar.permission", comment: "")
        case .schedulingFailed:
            return NSLocalizedString("error.reminder.scheduling", comment: "")
        }
    }
}
