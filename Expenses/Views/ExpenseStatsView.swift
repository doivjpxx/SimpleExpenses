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
    
    @State private var viewModel = ExpenseStatsViewModel()
    
    var body: some View {
        NavigationStack {
            VStack {
                if expenses.isEmpty {
                    emptyState
                } else {
                    ScrollView {
                        VStack(spacing: 20) {
                            // Period selector
                            Picker("stats.timePeriod", selection: $viewModel.selectedPeriod) {
                                ForEach(ExpenseStatsViewModel.StatsPeriod.allCases) { period in
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
            .onChange(of: expenses) { _, newValue in
                viewModel.expenses = newValue
            }
            .onAppear {
                viewModel.expenses = expenses
            }
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
            
            Text(viewModel.formatCurrency(viewModel.totalExpenses))
                .font(.system(size: 36, weight: .bold))
                .foregroundStyle(.primary)
            
            Text(viewModel.periodDescription)
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
            Text(viewModel.chartTitle)
                .font(.headline)
                .padding(.horizontal)
            
            Chart {
                ForEach(viewModel.chartData, id: \.label) { item in
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
                            Text(viewModel.formatCurrency(doubleValue))
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
}

#Preview {
    ExpenseStatsView()
        .modelContainer(for: Expense.self, inMemory: true)
}
