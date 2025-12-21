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

    @State private var title: String = ""
    @State private var value: Double = 0
    @State private var timestamp: Date = .now

    var body: some View {
        NavigationStack {
            ExpenseFormView(title: $title, value: $value, timestamp: $timestamp)
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
                            let expense = Expense(
                                title: title,
                                value: value,
                                timestamp: timestamp
                            )
                            context.insert(expense)
                            try! context.save()
                            dismiss()
                        }
                        .foregroundStyle(Color(.blue))
                    }
                }
        }
    }
}

#Preview {
    AddExpenseSheet()
}
