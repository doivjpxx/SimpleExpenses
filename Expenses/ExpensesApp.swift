//
//  ExpensesApp.swift
//  Expenses
//
//  Created by Phong Hy on 21/12/25.
//

import SwiftUI
import SwiftData

@main
struct ExpensesApp: App {
    @StateObject private var reminderManager = ReminderManager.shared
    
    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            Expense.self,
            Reminder.self,
        ])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)

        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()

    var body: some Scene {
        WindowGroup {
            MainTabView()
                .task {
                    // Request notification permission on app launch
                    _ = await reminderManager.requestNotificationPermission()
                }
        }
        .modelContainer(sharedModelContainer)
    }
}
