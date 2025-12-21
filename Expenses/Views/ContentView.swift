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

    @State private var viewModel: ExpenseListViewModel

    init() {
        // Provide a temporary model context for the State until the real one is assigned in onAppear.
        let container = (try? ModelContainer(for: Expense.self))
            ?? (try! ModelContainer(for: Expense.self, configurations: .init(isStoredInMemoryOnly: true)))
        let tempContext = ModelContext(container)
        _viewModel = State(initialValue: ExpenseListViewModel(modelContext: tempContext))
    }

    var body: some View {
        NavigationStack {
            List {
                ForEach(expenses) { item in
                    ExpenseCellView(expense: item)
                        .onTapGesture {
                            viewModel.selectExpense(item)
                        }
                }
                .onDelete { indexSet in
                    viewModel.deleteExpenses(at: indexSet, from: expenses)
                }
            }
            .navigationTitle("app.title")
            .navigationBarTitleDisplayMode(.large)
            .sheet(isPresented: $viewModel.isShowingAddSheet) {
                AddExpenseSheet()
            }
            .sheet(item: $viewModel.selectedExpense) { expense in
                EditExpenseSheet(expense: expense)
            }
            .toolbar {
                if !expenses.isEmpty {
                    ToolbarItem(placement: .primaryAction) {
                        Button(action: {
                            viewModel.showAddSheet()
                        }) {
                            Label("toolbar.addExpense", systemImage: "plus")
                        }
                    }
                }
            }
            .overlay {
                if expenses.isEmpty {
                    emptyPlaceholder
                }
            }
            .onAppear {
                // Reinitialize ViewModel with proper context
                viewModel = ExpenseListViewModel(modelContext: context)
            }
        }
    }
    
    var emptyPlaceholder: some View {
        ContentUnavailableView(
            label: {
                Label(
                    "home.noExpenses",
                    systemImage: "list.bullet.rectangle.portrait"
                )
            },
            description: {
                Text("home.start")
            },
            actions: {
                Button("toolbar.addExpense") {
                    viewModel.showAddSheet()
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
