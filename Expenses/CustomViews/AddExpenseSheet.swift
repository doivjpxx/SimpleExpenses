//
//  AddExpenseSheet.swift
//  Expenses
//
//  Created by Phong Hy on 21/12/25.
//

import SwiftData
import SwiftUI

struct AddExpenseSheet: View {
    @Environment(\.modelContext) var context
    @Environment(\.dismiss) private var dismiss

    @State private var viewModel = ExpenseFormViewModel()

    var body: some View {
        NavigationStack {
            ExpenseFormView(
                title: $viewModel.title,
                value: $viewModel.value,
                timestamp: $viewModel.timestamp
            )
            .navigationTitle("sheet.addExpense")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItemGroup(placement: .topBarLeading) {
                    Button("toolbar.cancel") {
                        dismiss()
                    }
                }
                ToolbarItemGroup(placement: .topBarTrailing) {
                    Button("toolbar.save") {
                        saveExpense()
                    }
                    .foregroundStyle(Color(.blue))
                    .disabled(!viewModel.isValid)
                }
            }
        }
    }
    
    private func saveExpense() {
        do {
            try viewModel.saveNewExpense(context: context)
            dismiss()
        } catch {
            // Handle error - could show an alert
            print("Error saving expense: \(error)")
        }
    }
}

#Preview {
    AddExpenseSheet()
}
