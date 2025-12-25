//
//  Reminder.swift
//  Expenses
//
//  Created by Phong Hy on 25/12/25.
//

import Foundation
import SwiftData

@Model
final class Reminder {
    var title: String
    var reminderDate: Date
    var note: String?
    var isCompleted: Bool
    var calendarEventId: String?
    var notificationId: String
    var createdAt: Date
    
    init(
        title: String,
        reminderDate: Date,
        note: String? = nil,
        isCompleted: Bool = false,
        calendarEventId: String? = nil
    ) {
        self.title = title
        self.reminderDate = reminderDate
        self.note = note
        self.isCompleted = isCompleted
        self.calendarEventId = calendarEventId
        self.notificationId = UUID().uuidString
        self.createdAt = Date()
    }
}
