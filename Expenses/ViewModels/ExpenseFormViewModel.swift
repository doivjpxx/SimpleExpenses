//
//  ExpenseFormViewModel.swift
//  Expenses
//
//  Created by Phong Hy on 21/12/25.
//

import Foundation
import SwiftData

@Observable
class ExpenseFormViewModel {
    
    // MARK: - Properties
    var title: String = ""
    var value: Double = 0
    var timestamp: Date = Date()
    
    // MARK: - Computed Properties
    
    var isValid: Bool {
        !title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty && value > 0
    }
    
    // MARK: - Initializers
    
    init() {
        // For new expense
    }
    
    init(expense: Expense) {
        // For editing existing expense
        self.title = expense.title
        self.value = expense.value
        self.timestamp = expense.timestamp
    }
    
    // MARK: - Methods
    
    func saveNewExpense(context: ModelContext) throws {
        guard isValid else {
            throw ValidationError.invalidData
        }
        
        let expense = Expense(
            title: title.trimmingCharacters(in: .whitespacesAndNewlines),
            value: value,
            timestamp: timestamp
        )
        
        context.insert(expense)
        try context.save()
    }
    
    func updateExpense(_ expense: Expense, context: ModelContext) throws {
        guard isValid else {
            throw ValidationError.invalidData
        }
        
        expense.title = title.trimmingCharacters(in: .whitespacesAndNewlines)
        expense.value = value
        expense.timestamp = timestamp
        
        try context.save()
    }
    
    func reset() {
        title = ""
        value = 0
        timestamp = Date()
    }
}

// MARK: - Errors

enum ValidationError: LocalizedError {
    case invalidData
    
    var errorDescription: String? {
        switch self {
        case .invalidData:
            return "Invalid expense data"
        }
    }
}
