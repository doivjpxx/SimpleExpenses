//
//  Color+Expense.swift
//  Expenses
//
//  Created by Phong Hy on 21/12/25.
//

import SwiftUI

extension Color {
    static let categoryColors: [String: Color] = [
        "Food": .orange,
        "Transport": .blue,
        "Shopping": .purple,
        "Entertainment": .pink,
        "Health": .red,
        "Education": .green,
        "Other": .gray
    ]
    
    static func forCategory(_ category: String) -> Color {
        categoryColors[category] ?? .gray
    }
}
