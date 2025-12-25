//
//  ReminderFormViewModel.swift
//  Expenses
//
//  Created by Phong Hy on 25/12/25.
//

import Foundation
import SwiftData

@Observable
final class ReminderFormViewModel {
    var title: String = ""
    var reminderDate: Date = Date().addingTimeInterval(3600) // 1 hour from now
    var note: String = ""
    var addToCalendar: Bool = true
    
    var isLoading: Bool = false
    var errorMessage: String?
    
    private var existingReminder: Reminder?
    private let reminderManager = ReminderManager.shared
    
    // MARK: - Computed Properties
    
    var isValid: Bool {
        !title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
        reminderDate > Date()
    }
    
    var isEditing: Bool {
        existingReminder != nil
    }
    
    // MARK: - Initializers
    
    init() {}
    
    init(reminder: Reminder) {
        self.existingReminder = reminder
        self.title = reminder.title
        self.reminderDate = reminder.reminderDate
        self.note = reminder.note ?? ""
        self.addToCalendar = reminder.calendarEventId != nil
    }
    
    // MARK: - Methods
    
    @MainActor
    func save(context: ModelContext) async -> Bool {
        guard isValid else { return false }
        
        isLoading = true
        errorMessage = nil
        
        do {
            if let existingReminder {
                // Update existing reminder
                existingReminder.title = title.trimmingCharacters(in: .whitespacesAndNewlines)
                existingReminder.reminderDate = reminderDate
                existingReminder.note = note.isEmpty ? nil : note
                
                // Update notification
                try await reminderManager.updateNotification(for: existingReminder)
                
                // Handle calendar event
                if addToCalendar {
                    if existingReminder.calendarEventId != nil {
                        try await reminderManager.updateCalendarEvent(for: existingReminder)
                    } else {
                        existingReminder.calendarEventId = try await reminderManager.addToCalendar(reminder: existingReminder)
                    }
                } else if let _ = existingReminder.calendarEventId {
                    try reminderManager.removeFromCalendar(reminder: existingReminder)
                    existingReminder.calendarEventId = nil
                }
                
            } else {
                // Create new reminder
                let reminder = Reminder(
                    title: title.trimmingCharacters(in: .whitespacesAndNewlines),
                    reminderDate: reminderDate,
                    note: note.isEmpty ? nil : note
                )
                
                // Schedule notification and optionally add to calendar
                let calendarEventId = try await reminderManager.scheduleReminder(
                    reminder,
                    addToCalendar: addToCalendar
                )
                reminder.calendarEventId = calendarEventId
                
                context.insert(reminder)
            }
            
            try context.save()
            isLoading = false
            return true
            
        } catch {
            errorMessage = error.localizedDescription
            isLoading = false
            return false
        }
    }
    
    @MainActor
    func toggleCompleted(reminder: Reminder, context: ModelContext) async {
        reminder.isCompleted.toggle()
        
        do {
            if reminder.isCompleted {
                reminderManager.cancelNotification(for: reminder)
            } else {
                try await reminderManager.scheduleNotification(for: reminder)
            }
            try context.save()
        } catch {
            errorMessage = error.localizedDescription
        }
    }
    
    @MainActor
    func delete(reminder: Reminder, context: ModelContext) {
        do {
            try reminderManager.cancelReminder(reminder)
            context.delete(reminder)
            try context.save()
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}
