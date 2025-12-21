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

    init(expense: Expense) {
        self.expense = expense
        _viewModel = State(initialValue: ExpenseFormViewModel(expense: expense))
    }

    var body: some View {
        NavigationStack {
            ExpenseFormView(
                title: $viewModel.title,
                value: $viewModel.value,
                timestamp: $viewModel.timestamp
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
                    .foregroundStyle(Color(.yellow))
                    .disabled(!viewModel.isValid)
                }
            }
        }
    }
    
    private func updateExpense() {
        do {
            try viewModel.updateExpense(expense, context: context)
            dismiss()
        } catch {
            // Handle error - could show an alert
            print("Error updating expense: \(error)")
        }
    }
}

#Preview {
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(
        for: Expense.self,
        configurations: config
    )

    let sample = Expense(title: "Coffee", value: 45000, timestamp: .now)
    container.mainContext.insert(sample)
    return EditExpenseSheet(expense: sample)
        .modelContainer(container)
}
