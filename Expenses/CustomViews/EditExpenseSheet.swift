//
//  EditExpenseSheet.swift
//  Expenses
//
//  Created by Phong Hy on 21/12/25.
//

import SwiftData
import SwiftUI

struct EditExpenseSheet: View {
    @Environment(\.dismiss) private var dismiss
    @Bindable var expense: Expense

    @State private var draftTitle: String = ""
    @State private var draftValue: Double = 0
    @State private var draftTimestamp: Date = .now

    var body: some View {
        NavigationStack {
            ExpenseFormView(
                title: $draftTitle,
                value: $draftValue,
                timestamp: $draftTimestamp
            )
            .navigationTitle("Edit Expense")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItemGroup(placement: .topBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                ToolbarItemGroup(placement: .topBarTrailing) {
                    Button("Update") {
                        expense.title = draftTitle
                        expense.value = draftValue
                        expense.timestamp = draftTimestamp
                        dismiss()
                    }
                    .foregroundStyle(Color(.yellow))
                }
            }
        }
        .onAppear {
            draftTitle = expense.title
            draftValue = expense.value
            draftTimestamp = expense.timestamp
        }
    }
}
