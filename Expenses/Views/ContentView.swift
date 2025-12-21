//
//  ContentView.swift
//  Expenses
//
//  Created by Phong Hy on 21/12/25.
//

import SwiftData
import SwiftUI

struct ContentView: View {

    @Environment(\.modelContext) private var context

    @Query(sort: \Expense.timestamp) var expenses: [Expense]

    @State private var isShowingSheet: Bool = false
    @State private var currentExpense: Expense? = nil

    var body: some View {
        NavigationStack {
            List {
                ForEach(expenses) { item in
                    ExpenseCellView(expense: item)
                        .onTapGesture {
                            currentExpense = item
                        }
                }
                .onDelete { indexSet in
                    for index in indexSet {
                        context.delete(expenses[index])
                    }
                }
            }
            .navigationTitle("Expenses")
            .navigationBarTitleDisplayMode(.large)
            .sheet(isPresented: $isShowingSheet) {
                AddExpenseSheet()
            }
            .sheet(item: $currentExpense) { expense in
                EditExpenseSheet(expense: expense)
            }
            .toolbar {
                if !expenses.isEmpty {
                    ToolbarItem(placement: .primaryAction) {
                        Button(action: {
                            isShowingSheet = true
                        }) {
                            Label("Add Item", systemImage: "plus")
                        }
                    }
                }
            }
            .overlay {
                if expenses.isEmpty {
                    emptyPlaceholder
                }
            }
        }
    }
    
    var emptyPlaceholder: some View {
        ContentUnavailableView(
            label: {
                Label(
                    "No Expenses",
                    systemImage: "list.bullet.rectangle.portrait"
                )
            },
            description: {
                Text("Start adding an expense for tracking...")
            },
            actions: {
                Button("Add expense") {
                    isShowingSheet = true
                }
            }
        )
        .offset(y: -60)
    }
}

#Preview {
    ContentView()
        .modelContainer(for: Expense.self, inMemory: true)
}
