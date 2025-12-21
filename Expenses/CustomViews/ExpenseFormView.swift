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
    var currencyCode: String = "VND"
    
    var body: some View {
        Form {
            TextField("form.expenseName", text: $title)
            TextField("form.value", value: $value, format: .currency(code: currencyCode))
                .keyboardType(.decimalPad)
            DatePicker("form.date", selection: $timestamp, displayedComponents: .date)
        }
    }
}

#Preview {
    ExpenseFormView(
        title: .constant(""),
        value: .constant(0.0),
        timestamp: .constant(Date())
    )
}
