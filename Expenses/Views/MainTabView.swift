//
//  MainTabView.swift
//  Expenses
//
//  Created by Phong Hy on 21/12/25.
//

import SwiftUI

struct MainTabView: View {
    var body: some View {
        TabView {
            ContentView()
                .tabItem {
                    Label("tab.list", systemImage: "list.bullet")
                }
            
            ExpenseStatsView()
                .tabItem {
                    Label("tab.stats", systemImage: "chart.bar")
                }
        }
    }
}

#Preview {
    MainTabView()
}
