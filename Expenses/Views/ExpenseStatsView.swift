//
//  ExpenseStatsView.swift
//  Expenses
//
//  Created by Phong Hy on 21/12/25.
//

import SwiftUI
import SwiftData
import Charts

struct ExpenseStatsView: View {
    @Query(sort: \Expense.timestamp, order: .reverse) var expenses: [Expense]
    
    @State private var selectedPeriod: StatsPeriod = .week
    
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
    
    var body: some View {
        NavigationStack {
            VStack {
                if expenses.isEmpty {
                    emptyState
                } else {
                    ScrollView {
                        VStack(spacing: 20) {
                            // Period selector
                            Picker("stats.timePeriod", selection: $selectedPeriod) {
                                ForEach(StatsPeriod.allCases) { period in
                                    Text(period.localizedName).tag(period)
                                }
                            }
                            .pickerStyle(.segmented)
                            .padding(.horizontal)
                            
                            // Total expenses card
                            totalExpensesCard
                            
                            // Chart
                            chartView
                        }
                        .padding(.vertical)
                    }
                }
            }
            .navigationTitle("stats.title")
            .navigationBarTitleDisplayMode(.large)
        }
    }
    
    var emptyState: some View {
        ContentUnavailableView(
            label: {
                Label("stats.noData", systemImage: "chart.bar")
            },
            description: {
                Text("stats.noData.description")
            }
        )
    }
    
    var totalExpensesCard: some View {
        VStack(spacing: 8) {
            Text("stats.totalExpenses")
                .font(.subheadline)
                .foregroundStyle(.secondary)
            
            Text(formatCurrency(totalExpenses))
                .font(.system(size: 36, weight: .bold))
                .foregroundStyle(.primary)
            
            Text(selectedPeriod == .week ? "stats.last7Days" : "stats.last30Days")
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background {
            RoundedRectangle(cornerRadius: 16)
                .fill(.ultraThinMaterial)
        }
        .padding(.horizontal)
    }
    
    var chartView: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(selectedPeriod == .week ? "stats.expensesByWeekday" : "stats.expensesByWeekInMonth")
                .font(.headline)
                .padding(.horizontal)
            
            Chart {
                ForEach(chartData, id: \.label) { item in
                    BarMark(
                        x: .value("Ngày", item.label),
                        y: .value("Chi tiêu", item.amount)
                    )
                    .foregroundStyle(.blue.gradient)
                    .cornerRadius(8)
                }
            }
            .frame(height: 250)
            .chartYAxis {
                AxisMarks(position: .leading) { value in
                    AxisValueLabel {
                        if let doubleValue = value.as(Double.self) {
                            Text(formatCurrency(doubleValue))
                                .font(.caption)
                        }
                    }
                }
            }
            .chartXAxis {
                AxisMarks { value in
                    AxisValueLabel {
                        if let stringValue = value.as(String.self) {
                            Text(stringValue)
                                .font(.caption2)
                        }
                    }
                }
            }
            .padding()
            .background {
                RoundedRectangle(cornerRadius: 16)
                    .fill(.ultraThinMaterial)
            }
            .padding(.horizontal)
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
            // Group by day of week
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
            
        } else {
            // Group by week in month (4 weeks)
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
    }
    
    // MARK: - Helper Methods
    
    private func formatCurrency(_ value: Double) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = "VND"
        formatter.maximumFractionDigits = 0
        return formatter.string(from: NSNumber(value: value)) ?? "0đ"
    }
}

struct ChartDataPoint {
    let label: String
    let amount: Double
}

#Preview {
    ExpenseStatsView()
        .modelContainer(for: Expense.self, inMemory: true)
}
