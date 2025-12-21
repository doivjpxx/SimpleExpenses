//
//  ExpenseListViewModel.swift
//  Expenses
//
//  Created by Phong Hy on 21/12/25.
//

import Foundation
import SwiftData

@Observable
class ExpenseListViewModel {
    
    // MARK: - UI State Properties
    var isShowingAddSheet: Bool = false
    var selectedExpense: Expense?
    
    // MARK: - Dependencies
    private var modelContext: ModelContext
    
    // MARK: - Initializer
    init(modelContext: ModelContext) {
        self.modelContext = modelContext
    }
    
    // MARK: - Methods
    
    func showAddSheet() {
        isShowingAddSheet = true
    }
    
    func hideAddSheet() {
        isShowingAddSheet = false
    }
    
    func selectExpense(_ expense: Expense) {
        selectedExpense = expense
    }
    
    func deselectExpense() {
        selectedExpense = nil
    }
    
    func deleteExpenses(at offsets: IndexSet, from expenses: [Expense]) {
        for index in offsets {
            modelContext.delete(expenses[index])
        }
    }
    
    func deleteExpense(_ expense: Expense) {
        modelContext.delete(expense)
        try? modelContext.save()
    }
}
