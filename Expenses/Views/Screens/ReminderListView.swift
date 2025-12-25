//
//  ReminderListView.swift
//  Expenses
//
//  Created by Phong Hy on 25/12/25.
//

import SwiftData
import SwiftUI

struct ReminderListView: View {
    @Environment(\.modelContext) private var context
    @Query(sort: \Reminder.reminderDate, order: .forward) var reminders: [Reminder]
    
    @State private var isShowingAddSheet = false
    @State private var selectedReminder: Reminder?
    @State private var showingError = false
    @State private var errorMessage = ""
    @State private var viewModel = ReminderFormViewModel()
    
    private var pendingReminders: [Reminder] {
        reminders.filter { !$0.isCompleted }
    }
    
    private var completedReminders: [Reminder] {
        reminders.filter { $0.isCompleted }
    }
    
    var body: some View {
        NavigationStack {
            VStack {
                if reminders.isEmpty {
                    emptyPlaceholder
                } else {
                    List {
                        // Pending reminders
                        if !pendingReminders.isEmpty {
                            Section("reminder.section.pending") {
                                ForEach(pendingReminders) { reminder in
                                    ReminderCellView(reminder: reminder) {
                                        toggleCompleted(reminder)
                                    }
                                    .contentShape(Rectangle())
                                    .onTapGesture {
                                        selectedReminder = reminder
                                    }
                                    .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                                        Button(role: .destructive) {
                                            deleteReminder(reminder)
                                        } label: {
                                            Label("Delete", systemImage: "trash")
                                        }
                                    }
                                    .swipeActions(edge: .leading, allowsFullSwipe: false) {
                                        Button {
                                            selectedReminder = reminder
                                        } label: {
                                            Label("Edit", systemImage: "pencil")
                                        }
                                        .tint(.blue)
                                        
                                        Button {
                                            toggleCompleted(reminder)
                                        } label: {
                                            Label("reminder.complete", systemImage: "checkmark")
                                        }
                                        .tint(.green)
                                    }
                                }
                            }
                        }
                        
                        // Completed reminders
                        if !completedReminders.isEmpty {
                            Section("reminder.section.completed") {
                                ForEach(completedReminders) { reminder in
                                    ReminderCellView(reminder: reminder) {
                                        toggleCompleted(reminder)
                                    }
                                    .contentShape(Rectangle())
                                    .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                                        Button(role: .destructive) {
                                            deleteReminder(reminder)
                                        } label: {
                                            Label("Delete", systemImage: "trash")
                                        }
                                    }
                                    .swipeActions(edge: .leading, allowsFullSwipe: false) {
                                        Button {
                                            toggleCompleted(reminder)
                                        } label: {
                                            Label("reminder.restore", systemImage: "arrow.uturn.backward")
                                        }
                                        .tint(.orange)
                                    }
                                }
                            }
                        }
                    }
                }
            }
            .navigationTitle("reminder.title")
            .navigationBarTitleDisplayMode(.large)
            .sheet(isPresented: $isShowingAddSheet) {
                AddReminderSheet()
            }
            .sheet(item: $selectedReminder) { reminder in
                EditReminderSheet(reminder: reminder)
            }
            .alert("Error", isPresented: $showingError) {
                Button("OK", role: .cancel) {}
            } message: {
                Text(errorMessage)
            }
            .toolbar {
                if !reminders.isEmpty {
                    ToolbarItem(placement: .primaryAction) {
                        Button {
                            isShowingAddSheet = true
                        } label: {
                            Label("reminder.add", systemImage: "plus")
                        }
                    }
                }
            }
        }
    }
    
    // MARK: - Empty Placeholder
    
    private var emptyPlaceholder: some View {
        ContentUnavailableView(
            label: {
                Label("reminder.empty", systemImage: "bell.slash")
            },
            description: {
                Text("reminder.emptyDescription")
            },
            actions: {
                Button("reminder.add") {
                    isShowingAddSheet = true
                }
            }
        )
        .offset(y: -60)
    }
    
    // MARK: - Methods
    
    private func toggleCompleted(_ reminder: Reminder) {
        Task {
            await viewModel.toggleCompleted(reminder: reminder, context: context)
            HapticManager.shared.impact(style: .medium)
            
            if let error = viewModel.errorMessage {
                errorMessage = error
                showingError = true
            }
        }
    }
    
    private func deleteReminder(_ reminder: Reminder) {
        withAnimation {
            viewModel.delete(reminder: reminder, context: context)
            HapticManager.shared.impact(style: .medium)
            
            if let error = viewModel.errorMessage {
                errorMessage = error
                showingError = true
            }
        }
    }
}

#Preview {
    ReminderListView()
        .modelContainer(for: Reminder.self, inMemory: true)
}
