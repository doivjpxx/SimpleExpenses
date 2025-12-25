//
//  ReminderFormView.swift
//  Expenses
//
//  Created by Phong Hy on 25/12/25.
//

import SwiftUI

struct ReminderFormView: View {
    @Bindable var viewModel: ReminderFormViewModel
    
    var body: some View {
        Form {
            // Details Section
            Section("reminder.form.details") {
                TextField("reminder.form.title", text: $viewModel.title)
                    .accessibilityLabel("reminder.form.title")
                
                DatePicker(
                    "reminder.form.date",
                    selection: $viewModel.reminderDate,
                    in: Date()...,
                    displayedComponents: [.date, .hourAndMinute]
                )
                .accessibilityLabel("reminder.form.date")
            }
            
            // Notes Section
            Section("reminder.form.notes") {
                TextField("reminder.form.notesPlaceholder", text: $viewModel.note, axis: .vertical)
                    .lineLimit(3...6)
                    .accessibilityLabel("reminder.form.notes")
            }
            
            // Calendar Section
            Section {
                Toggle("reminder.form.addToCalendar", isOn: $viewModel.addToCalendar)
                    .accessibilityLabel("reminder.form.addToCalendar")
                    .accessibilityHint("reminder.form.calendarHint")
            } header: {
                Text("reminder.form.calendar")
            } footer: {
                Text("reminder.form.calendarDescription")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            
            // Error message
            if let errorMessage = viewModel.errorMessage {
                Section {
                    Text(errorMessage)
                        .foregroundStyle(.red)
                        .font(.caption)
                }
            }
        }
    }
}

#Preview {
    NavigationStack {
        ReminderFormView(viewModel: ReminderFormViewModel())
            .navigationTitle("reminder.add")
    }
}
