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
    @Query(sort: \Expense.timestamp, order: .reverse) var expenses: [Expense]

    @State private var isShowingAddSheet = false
    @State private var selectedExpense: Expense?
    @State private var errorMessage: String?
    @State private var showingError = false

    var body: some View {
        NavigationStack {
            VStack {
                if expenses.isEmpty {
                    emptyPlaceholder
                } else {
                    List {
                        ForEach(expenses) { item in
                            ExpenseCellView(expense: item)
                                .contentShape(Rectangle())
                                .onTapGesture {
                                    selectedExpense = item
                                }
                                .swipeActions(
                                    edge: .trailing,
                                    allowsFullSwipe: true
                                ) {
                                    Button(role: .destructive) {
                                        deleteExpense(item)
                                    } label: {
                                        Label("Delete", systemImage: "trash")
                                    }
                                }
                                .swipeActions(
                                    edge: .leading,
                                    allowsFullSwipe: false
                                ) {
                                    Button {
                                        selectedExpense = item
                                    } label: {
                                        Label("Edit", systemImage: "pencil")
                                    }
                                    .tint(.blue)
                                }
                                .accessibilityElement(children: .combine)
                                .accessibilityHint(
                                    "Tap to edit, swipe left to delete"
                                )
                        }
                        .onDelete(perform: deleteExpenses)
                    }
                }
            }
            .navigationTitle("app.title")
            .navigationBarTitleDisplayMode(.large)
            .sheet(isPresented: $isShowingAddSheet) {
                AddExpenseSheet()
            }
            .sheet(item: $selectedExpense) { expense in
                EditExpenseSheet(expense: expense)
            }
            .alert("Error", isPresented: $showingError) {
                Button("OK", role: .cancel) {}
            } message: {
                if let errorMessage {
                    Text(errorMessage)
                }
            }
            .toolbar {
                if !expenses.isEmpty {
                    ToolbarItem(placement: .primaryAction) {
                        Button(action: {
                            isShowingAddSheet = true
                        }) {
                            Label("toolbar.addExpense", systemImage: "plus")
                        }
                    }
                }
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
                    isShowingAddSheet = true
                }
            }
        )
        .offset(y: -60)
    }

    // MARK: - Methods

    private func deleteExpense(_ expense: Expense) {
        withAnimation {
            context.delete(expense)
            HapticManager.shared.impact(style: .medium)
        }
    }

    private func deleteExpenses(at offsets: IndexSet) {
        withAnimation {
            for index in offsets {
                context.delete(expenses[index])
            }
            HapticManager.shared.impact(style: .medium)
        }
    }
}

#Preview {
    ContentView()
        .modelContainer(for: Expense.self, inMemory: true)
}
