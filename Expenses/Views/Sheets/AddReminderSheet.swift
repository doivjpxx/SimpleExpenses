//
//  AddReminderSheet.swift
//  Expenses
//
//  Created by Phong Hy on 25/12/25.
//

import SwiftUI
import SwiftData

struct AddReminderSheet: View {
    @Environment(\.modelContext) private var context
    @Environment(\.dismiss) private var dismiss
    
    @State private var viewModel = ReminderFormViewModel()
    
    var body: some View {
        NavigationStack {
            ReminderFormView(viewModel: viewModel)
                .navigationTitle("reminder.add")
                .navigationBarTitleDisplayMode(.large)
                .toolbar {
                    ToolbarItem(placement: .topBarLeading) {
                        Button("toolbar.cancel") {
                            HapticManager.shared.impact(style: .light)
                            dismiss()
                        }
                    }
                    
                    ToolbarItem(placement: .topBarTrailing) {
                        Button("toolbar.save") {
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
    AddReminderSheet()
        .modelContainer(for: Reminder.self, inMemory: true)
}
