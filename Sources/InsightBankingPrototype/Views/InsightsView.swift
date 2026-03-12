import SwiftUI

struct InsightsView: View {
    @EnvironmentObject private var session: SessionViewModel

    var body: some View {
        let insights = session.insightResult()

        NavigationStack {
            List {
                Section("Unusual Spending") {
                    ForEach(insights.unusualSpending, id: \.self) { finding in
                        Text("• \(finding)")
                    }
                }

                Section("Next Month Projection") {
                    Text(insights.projectedExpensesNextMonth, format: .currency(code: "USD"))
                        .font(.title3.weight(.semibold))
                }

                Section("Personalized Tips") {
                    ForEach(insights.personalizedTips, id: \.self) { tip in
                        Text("• \(tip)")
                    }
                }

                Section("Investment Tips") {
                    ForEach(insights.investmentTips, id: \.self) { tip in
                        Text("• \(tip)")
                    }
                }
            }
            .navigationTitle("AI Insights")
        }
    }
}
