//
//  ReminderCellView.swift
//  Expenses
//
//  Created by Phong Hy on 25/12/25.
//

import SwiftUI

struct ReminderCellView: View {
    let reminder: Reminder
    let onToggleCompleted: () -> Void
    
    private var isOverdue: Bool {
        !reminder.isCompleted && reminder.reminderDate < Date()
    }
    
    private var iconName: String {
        if reminder.isCompleted {
            return "checkmark.circle.fill"
        } else if reminder.calendarEventId != nil {
            return "calendar.badge.clock"
        } else {
            return "bell.fill"
        }
    }
    
    private var iconColor: Color {
        if reminder.isCompleted {
            return .green
        } else if isOverdue {
            return .red
        } else {
            return .blue
        }
    }
    
    var body: some View {
        HStack(spacing: 12) {
            // Completion toggle button
            Button {
                onToggleCompleted()
            } label: {
                Image(systemName: reminder.isCompleted ? "checkmark.circle.fill" : "circle")
                    .font(.title2)
                    .foregroundStyle(reminder.isCompleted ? .green : .secondary)
            }
            .buttonStyle(.plain)
            .accessibilityLabel(reminder.isCompleted ? "reminder.markIncomplete" : "reminder.markComplete")
            
            // Icon
            Image(systemName: iconName)
                .font(.title3)
                .foregroundStyle(iconColor)
                .frame(width: 32)
            
            // Content
            VStack(alignment: .leading, spacing: 4) {
                Text(reminder.title)
                    .font(.headline)
                    .strikethrough(reminder.isCompleted)
                    .foregroundStyle(reminder.isCompleted ? .secondary : .primary)
                
                HStack(spacing: 8) {
                    // Date
                    Text(reminder.reminderDate, format: .dateTime.day().month().year().hour().minute())
                        .font(.caption)
                        .foregroundStyle(isOverdue ? .red : .secondary)
                    
                    // Calendar badge
                    if reminder.calendarEventId != nil {
                        Label("reminder.synced", systemImage: "icloud.fill")
                            .font(.caption2)
                            .foregroundStyle(.blue)
                    }
                }
                
                // Note
                if let note = reminder.note, !note.isEmpty {
                    Text(note)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .lineLimit(1)
                }
            }
            
            Spacer()
        }
        .padding(.vertical, 4)
        .contentShape(Rectangle())
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(reminder.title)")
        .accessibilityValue("reminder.date.\(reminder.reminderDate.formatted())")
        .accessibilityHint("reminder.accessibilityHint")
    }
}

#Preview {
    List {
        ReminderCellView(
            reminder: Reminder(
                title: "Pay electricity bill",
                reminderDate: Date().addingTimeInterval(3600),
                note: "Around 500,000 VND"
            ),
            onToggleCompleted: {}
        )
        
        ReminderCellView(
            reminder: {
                let r = Reminder(
                    title: "Completed reminder",
                    reminderDate: Date().addingTimeInterval(-3600)
                )
                r.isCompleted = true
                return r
            }(),
            onToggleCompleted: {}
        )
    }
}
