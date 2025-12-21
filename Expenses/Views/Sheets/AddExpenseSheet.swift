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
    @State private var showingError = false
    @State private var errorMessage = ""

    var body: some View {
        NavigationStack {
            ExpenseFormView(
                title: $viewModel.title,
                value: $viewModel.value,
                timestamp: $viewModel.timestamp,
                category: $viewModel.category,
                note: $viewModel.note
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
    
    private func saveExpense() {
        do {
            try viewModel.saveNewExpense(context: context)
            HapticManager.shared.notification(type: .success)
            dismiss()
        } catch {
            errorMessage = "Error saving expense: \(error.localizedDescription)"
            showingError = true
            HapticManager.shared.notification(type: .error)
        }
    }
}

#Preview {
    AddExpenseSheet()
}
