//
//  FormView.swift
//  Expenses
//
//  Created by Phong Hy on 21/12/25.
//

import SwiftUI

struct ExpenseFormView: View {
    @Binding var title: String
    @Binding var value: Double
    @Binding var timestamp: Date
    @Binding var category: String
    @Binding var note: String?
    
    var currencyCode: String = "VND"
    
    let categories = ["Food", "Transport", "Shopping", "Entertainment", "Health", "Education", "Other"]
    
    var body: some View {
        Form {
            Section("Details") {
                TextField("form.expenseName", text: $title)
                    .accessibilityLabel("Expense name")
                
                TextField("form.value", value: $value, format: .currency(code: currencyCode))
                    .keyboardType(.decimalPad)
                    .accessibilityLabel("Expense amount")
                
                DatePicker("form.date", selection: $timestamp, displayedComponents: .date)
                    .accessibilityLabel("Expense date")
            }
            
            Section("Category") {
                Picker("Category", selection: $category) {
                    ForEach(categories, id: \.self) { cat in
                        Label(cat, systemImage: categoryIcon(for: cat))
                            .tag(cat)
                    }
                }
                .pickerStyle(.menu)
                .accessibilityLabel("Expense category")
            }
            
            Section("Notes") {
                TextField("Add notes (optional)", text: Binding(
                    get: { note ?? "" },
                    set: { note = $0.isEmpty ? nil : $0 }
                ), axis: .vertical)
                .lineLimit(3...6)
                .accessibilityLabel("Expense notes")
            }
        }
    }
    
    private func categoryIcon(for category: String) -> String {
        switch category.lowercased() {
        case "food": return "fork.knife"
        case "transport": return "car.fill"
        case "shopping": return "cart.fill"
        case "entertainment": return "theatermasks.fill"
        case "health": return "heart.fill"
        case "education": return "book.fill"
        default: return "questionmark.circle.fill"
        }
    }
}

#Preview {
    ExpenseFormView(
        title: .constant(""),
        value: .constant(0.0),
        timestamp: .constant(Date()),
        category: .constant("Other"),
        note: .constant(nil)
    )
}
