//
//  ContentView.swift
//  Expenses
//
//  Created by Phong Hy on 21/12/25.
//

import SwiftUI
import SwiftData

struct ContentView: View {
    
    @Environment(\.modelContext) private var context
    
    @Query(sort: \Expense.timestamp) var expenses: [Expense]

    @State private var isShowingSheet: Bool = false
    @State private var currentExpense: Expense? = nil

    var body: some View {
        NavigationStack {
            List {
                ForEach(expenses) { item in
                    ExpenseCell(expense: item)
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
                    ContentUnavailableView(label: {
                        Label("No Expenses", systemImage: "list.bullet.rectangle.portrait")
                    }, description: {
                        Text("Start adding an expense for tracking...")
                    }, actions: {
                        Button("Add expense") {
                            isShowingSheet = true
                        }
                    })
                    .offset(y: -60)
                }
            }
        }
    }
}

struct ExpenseCell: View {
    var expense: Expense
    
    var body: some View {
        HStack {
            Text(expense.title)
            Text("\(expense.value.formatted())")
            Spacer()
            Text(expense.timestamp, format: Date.FormatStyle(date: .numeric, time: .standard))
        }
        .padding()
    }
}

struct AddExpenseSheet: View {
    @Environment(\.modelContext) var context
    @Environment(\.dismiss) private var dismiss
    
    @State private var title: String = ""
    @State private var value: Double = 0
    @State private var timestamp: Date = .now
    
    var body: some View {
        NavigationStack {
            Form {
                TextField("Expense name", text: $title)
                TextField("Value", value: $value, format: .currency(code: "VND"))
                    .keyboardType(.decimalPad)
                DatePicker("Date", selection: $timestamp, displayedComponents: .date)
            }
            .navigationTitle("Add Expense")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItemGroup(placement: .topBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                ToolbarItemGroup(placement: .topBarTrailing) {
                    Button("Add") {
                        let expense = Expense(title: title, value: value, timestamp: timestamp)
                        context.insert(expense)
                        dismiss()
                    }
                    .foregroundStyle(Color(.blue))
                }
            }
        }
    }
}

struct EditExpenseSheet: View {
    @Environment(\.dismiss) private var dismiss
    @Bindable var expense: Expense

    @State private var draftTitle: String = ""
    @State private var draftValue: Double = 0
    @State private var draftTimestamp: Date = .now

    var body: some View {
        NavigationStack {
            Form {
                TextField("Expense name", text: $draftTitle)
                TextField("Value", value: $draftValue, format: .currency(code: "VND"))
                    .keyboardType(.decimalPad)
                DatePicker("Date", selection: $draftTimestamp, displayedComponents: .date)
            }
            .navigationTitle("Edit Expense")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItemGroup(placement: .topBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                ToolbarItemGroup(placement: .topBarTrailing) {
                    Button("Update") {
                        expense.title = draftTitle
                        expense.value = draftValue
                        expense.timestamp = draftTimestamp
                        dismiss()
                    }
                    .foregroundStyle(Color(.yellow))
                }
            }
        }
        .onAppear {
            draftTitle = expense.title
            draftValue = expense.value
            draftTimestamp = expense.timestamp
        }
    }
}

#Preview("cell") {
    ExpenseCell(expense: Expense(title: "Do xang", value: 100, timestamp: Date()))
}

#Preview("main") {
    ContentView()
        .modelContainer(for: Expense.self, inMemory: true)
}
