//
//  ExpenseCellView.swift
//  Expenses
//
//  Created by Phong Hy on 21/12/25.
//

import SwiftUI

struct ExpenseCellView: View {
    var expense: Expense

    var body: some View {
        HStack(alignment: .center, spacing: 12) {
            // Category icon
            Image(systemName: categoryIcon(for: expense.category))
                .font(.title2)
                .foregroundStyle(Color.forCategory(expense.category))
                .frame(width: 40, height: 40)
                .background(Color.forCategory(expense.category).opacity(0.15))
                .clipShape(Circle())
            
            // Title and date
            VStack(alignment: .leading, spacing: 4) {
                Text(expense.title)
                    .font(.headline)
                    .foregroundStyle(.primary)
                
                Text(expense.timestamp, format: .dateTime.day().month().year())
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
            
            Spacer(minLength: 12)
            
            // Value
            Text(formatCurrency(expense.value))
                .font(.body.weight(.semibold))
                .foregroundStyle(.primary)
        }
        .padding(.vertical, 4)
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(expense.title), \(formatCurrency(expense.value))")
        .accessibilityValue("Date: \(expense.timestamp.formatted(date: .abbreviated, time: .omitted))")
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
    
    private func formatCurrency(_ value: Double) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = "VND"
        formatter.maximumFractionDigits = 0
        return formatter.string(from: NSNumber(value: value)) ?? "0\u{20AB}"
    }
}

#Preview {
    ExpenseCellView(
        expense: Expense(
            title: "Đổ xăng", 
            value: 100000, 
            timestamp: Date(),
            category: "Transport"
        )
    )
    .padding()
}

