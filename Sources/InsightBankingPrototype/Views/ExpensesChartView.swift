import SwiftUI
import Charts

struct ExpensesChartView: View {
    @EnvironmentObject private var session: SessionViewModel

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    Text("Monthly Expenses by Category")
                        .font(.headline)

                    Chart(session.monthlyCategoryExpenses()) { item in
                        BarMark(
                            x: .value("Month", item.monthLabel),
                            y: .value("Expense", item.total)
                        )
                        .foregroundStyle(by: .value("Category", item.category.displayName))
                    }
                    .frame(height: 320)

                    Text("Tip: Tap legends to compare category trends month over month.")
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                }
                .padding()
            }
            .navigationTitle("Expenses")
        }
    }
}
