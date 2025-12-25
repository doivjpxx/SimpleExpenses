//
//  EditReminderSheet.swift
//  Expenses
//
//  Created by Phong Hy on 25/12/25.
//

import SwiftUI
import SwiftData

struct EditReminderSheet: View {
    @Environment(\.modelContext) private var context
    @Environment(\.dismiss) private var dismiss
    
    let reminder: Reminder
    @State private var viewModel: ReminderFormViewModel
    
    init(reminder: Reminder) {
        self.reminder = reminder
        self._viewModel = State(initialValue: ReminderFormViewModel(reminder: reminder))
    }
    
    var body: some View {
        NavigationStack {
            ReminderFormView(viewModel: viewModel)
                .navigationTitle("reminder.edit")
                .navigationBarTitleDisplayMode(.large)
                .toolbar {
                    ToolbarItem(placement: .topBarLeading) {
                        Button("toolbar.cancel") {
                            HapticManager.shared.impact(style: .light)
                            dismiss()
                        }
                    }
                    
                    ToolbarItem(placement: .topBarTrailing) {
                        Button("toolbar.update") {
                            Task {
                                let success = await viewModel.save(context: context)
                                if success {
                                    HapticManager.shared.notification(type: .success)
                                    dismiss()
                                } else {
                                    HapticManager.shared.notification(type: .error)
                                }
                            }
                        }
                        .disabled(!viewModel.isValid || viewModel.isLoading)
                    }
                }
        }
        .interactiveDismissDisabled(viewModel.isLoading)
    }
}

#Preview {
    EditReminderSheet(
        reminder: Reminder(
            title: "Test reminder",
            reminderDate: Date().addingTimeInterval(3600)
        )
    )
    .modelContainer(for: Reminder.self, inMemory: true)
}
