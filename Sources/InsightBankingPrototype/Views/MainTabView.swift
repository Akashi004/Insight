import SwiftUI

struct MainTabView: View {
    var body: some View {
        TabView {
            AccountListView()
                .tabItem {
                    Label("Accounts", systemImage: "creditcard")
                }

            ExpensesChartView()
                .tabItem {
                    Label("Chart", systemImage: "chart.bar")
                }

            InsightsView()
                .tabItem {
                    Label("AI Insights", systemImage: "sparkles")
                }
        }
    }
}
