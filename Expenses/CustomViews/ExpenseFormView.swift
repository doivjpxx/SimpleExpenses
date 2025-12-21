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
            TextField("Expense name", text: $title)
            TextField("Value", value: $value, format: .currency(code: currencyCode))
                .keyboardType(.decimalPad)
            DatePicker("Date", selection: $timestamp, displayedComponents: .date)
        }
    }
}
