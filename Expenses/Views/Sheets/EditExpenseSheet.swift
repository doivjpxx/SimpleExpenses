//
//  EditExpenseSheet.swift
//  Expenses
//
//  Created by Phong Hy on 21/12/25.
//

import SwiftData
import SwiftUI

struct EditExpenseSheet: View {
    @Environment(\.modelContext) var context
    @Environment(\.dismiss) private var dismiss
    @Bindable var expense: Expense

    @State private var viewModel: ExpenseFormViewModel
    @State private var showingError = false
    @State private var errorMessage = ""

    init(expense: Expense) {
        self.expense = expense
        _viewModel = State(initialValue: ExpenseFormViewModel(expense: expense))
    }

    var body: some View {
        NavigationStack {
            ExpenseFormView(
                title: $viewModel.title,
                value: $viewModel.value,
                timestamp: $viewModel.timestamp,
                category: $viewModel.category,
                note: $viewModel.note
            )
            .navigationTitle("sheet.editExpense")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItemGroup(placement: .topBarLeading) {
                    Button("toolbar.cancel") {
                        dismiss()
                    }
                }
                ToolbarItemGroup(placement: .topBarTrailing) {
                    Button("toolbar.update") {
                        updateExpense()
                    }
                    .foregroundStyle(.blue)
                    .disabled(!viewModel.isValid)
                }
            }
            .alert("Error", isPresented: $showingError) {
                Button("OK", role: .cancel) { }
            } message: {
                Text(errorMessage)
            }
        }
    }
    
    private func updateExpense() {
        do {
            try viewModel.updateExpense(expense, context: context)
            HapticManager.shared.notification(type: .success)
            dismiss()
        } catch {
            errorMessage = "Error updating expense: \(error.localizedDescription)"
            showingError = true
            HapticManager.shared.notification(type: .error)
        }
    }
}

#Preview {
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(
        for: Expense.self,
        configurations: config
    )

    let sample = Expense(
        title: "Coffee", 
        value: 45000, 
        timestamp: .now,
        category: "Food",
        note: "Morning coffee"
    )
    container.mainContext.insert(sample)
    return EditExpenseSheet(expense: sample)
        .modelContainer(container)
}
