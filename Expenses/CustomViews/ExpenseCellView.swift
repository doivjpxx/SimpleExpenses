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
        HStack(alignment: .center) {
            VStack {
                Text(expense.title).font(.headline)
                Text("\(expense.value.formatted())")
            }
            Spacer()
            Text(
                expense.timestamp,
                format: Date.FormatStyle(date: .numeric, time: .standard)
            ).fontWeight(.light).foregroundStyle(.foreground)
        }
    }
}

#Preview {
    ExpenseCellView(
        expense: Expense(title: "Đổ xăng", value: 100000, timestamp: Date())
    )
}
