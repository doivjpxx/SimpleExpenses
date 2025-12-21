//
//  ExpenseStatsViewModel.swift
//  Expenses
//
//  Created by Phong Hy on 21/12/25.
//

import Foundation
import SwiftUI

@Observable
class ExpenseStatsViewModel {
    
    // MARK: - Input Properties
    var selectedPeriod: StatsPeriod = .week
    var expenses: [Expense] = []
    
    // MARK: - Period Enum
    enum StatsPeriod: String, CaseIterable, Identifiable {
        case week
        case month
        
        var id: String { self.rawValue }
        
        var localizedName: LocalizedStringKey {
            switch self {
            case .week: return "stats.period.week"
            case .month: return "stats.period.month"
            }
        }
    }
    
    // MARK: - Computed Properties
    
    var filteredExpenses: [Expense] {
        let calendar = Calendar.current
        let now = Date()
        let daysAgo = selectedPeriod == .week ? 7 : 30
        
        guard let startDate = calendar.date(byAdding: .day, value: -daysAgo, to: now) else {
            return []
        }
        
        return expenses.filter { $0.timestamp >= startDate }
    }
    
    var totalExpenses: Double {
        filteredExpenses.reduce(0) { $0 + $1.value }
    }
    
    var chartData: [ChartDataPoint] {
        let calendar = Calendar.current
        let now = Date()
        
        if selectedPeriod == .week {
            return calculateWeeklyChartData(calendar: calendar, now: now)
        } else {
            return calculateMonthlyChartData(calendar: calendar, now: now)
        }
    }
    
    var periodDescription: LocalizedStringKey {
        selectedPeriod == .week ? "stats.last7Days" : "stats.last30Days"
    }
    
    var chartTitle: LocalizedStringKey {
        selectedPeriod == .week ? "stats.expensesByWeekday" : "stats.expensesByWeekInMonth"
    }
    
    // MARK: - Private Methods
    
    private func calculateWeeklyChartData(calendar: Calendar, now: Date) -> [ChartDataPoint] {
        var dayData: [Int: Double] = [:]
        
        // Initialize all days with 0
        for day in 0..<7 {
            dayData[day] = 0
        }
        
        // Sum expenses for each day
        for expense in filteredExpenses {
            let daysAgo = calendar.dateComponents([.day], from: calendar.startOfDay(for: expense.timestamp), to: calendar.startOfDay(for: now)).day ?? 0
            if daysAgo >= 0 && daysAgo < 7 {
                dayData[6 - daysAgo, default: 0] += expense.value
            }
        }
        
        // Create chart data points
        let weekdaySymbols = ["CN", "T2", "T3", "T4", "T5", "T6", "T7"]
        var result: [ChartDataPoint] = []
        
        for day in 0..<7 {
            guard let date = calendar.date(byAdding: .day, value: day - 6, to: now) else { continue }
            let weekday = calendar.component(.weekday, from: date)
            let label = weekdaySymbols[weekday - 1]
            result.append(ChartDataPoint(label: label, amount: dayData[day] ?? 0))
        }
        
        return result
    }
    
    private func calculateMonthlyChartData(calendar: Calendar, now: Date) -> [ChartDataPoint] {
        var weekData: [Int: Double] = [:]
        
        // Initialize all weeks with 0
        for week in 0..<4 {
            weekData[week] = 0
        }
        
        for expense in filteredExpenses {
            let daysAgo = calendar.dateComponents([.day], from: calendar.startOfDay(for: expense.timestamp), to: calendar.startOfDay(for: now)).day ?? 0
            if daysAgo < 28 {
                let week = daysAgo / 7
                weekData[week, default: 0] += expense.value
            }
        }
        
        var result: [ChartDataPoint] = []
        for week in (0..<4).reversed() {
            let label: String
            if week == 0 {
                label = String(localized: "stats.week.current")
            } else {
                label = String(localized: "stats.week.ago \(week)")
            }
            result.append(ChartDataPoint(label: label, amount: weekData[week] ?? 0))
        }
        
        return result
    }
    
    // MARK: - Public Methods
    
    func formatCurrency(_ value: Double) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = "VND"
        formatter.maximumFractionDigits = 0
        return formatter.string(from: NSNumber(value: value)) ?? "0đ"
    }
}

// MARK: - Supporting Types

struct ChartDataPoint {
    let label: String
    let amount: Double
}
