import Foundation

struct InsightResult {
    let unusualSpending: [String]
    let projectedExpensesNextMonth: Double
    let personalizedTips: [String]
    let investmentTips: [String]
}

protocol AIInsightGenerating {
    func analyze(transactions: [Transaction], isInvesting: Bool, now: Date) -> InsightResult
}

/// LLM-ready service for generating personal finance insights.
///
/// Integration notes:
/// - Replace `MockLLMClient` with a provider-backed client (OpenAI, Azure OpenAI, local model).
/// - Keep the protocol stable to allow swapping providers without touching views.
final class AIInsightsService: AIInsightGenerating {
    private let llmClient: LLMClient

    init(llmClient: LLMClient = MockLLMClient()) {
        self.llmClient = llmClient
    }

    func analyze(transactions: [Transaction], isInvesting: Bool, now: Date = Date()) -> InsightResult {
        let monthlyExpenses = AnalyticsEngine.monthlyExpenses(transactions: transactions)
        let unusual = AnalyticsEngine.detectUnusualSpending(monthlyExpenses: monthlyExpenses)
        let projection = AnalyticsEngine.projectNextMonthExpense(monthlyExpenses: monthlyExpenses)
        let tips = AnalyticsEngine.personalizedTips(transactions: transactions, unusualSpending: unusual)
        let investmentTips = AnalyticsEngine.investmentTips(isInvesting: isInvesting)

        let prompt = LLMInsightPromptBuilder.buildPrompt(
            monthlyExpenses: monthlyExpenses,
            unusualSpending: unusual,
            projectedExpenses: projection,
            tips: tips,
            investmentTips: investmentTips
        )

        _ = llmClient.complete(prompt: prompt)

        return InsightResult(
            unusualSpending: unusual,
            projectedExpensesNextMonth: projection,
            personalizedTips: tips,
            investmentTips: investmentTips
        )
    }
}

protocol LLMClient {
    func complete(prompt: String) -> String
}

struct MockLLMClient: LLMClient {
    func complete(prompt: String) -> String {
        "Mock LLM response based on prompt: \(prompt.prefix(120))..."
    }
}

enum AnalyticsEngine {
    static func monthlyExpenses(transactions: [Transaction]) -> [String: [TransactionCategory: Double]] {
        let calendar = Calendar.current

        return transactions.filter { $0.amount < 0 }.reduce(into: [:]) { partial, tx in
            let components = calendar.dateComponents([.year, .month], from: tx.date)
            guard let date = calendar.date(from: components) else { return }
            let monthLabel = DateFormatter.monthYear.string(from: date)
            let value = abs(tx.amount)
            partial[monthLabel, default: [:]][tx.category, default: 0] += value
        }
    }

    static func detectUnusualSpending(monthlyExpenses: [String: [TransactionCategory: Double]]) -> [String] {
        let months = monthlyExpenses.keys.sorted()
        guard let latest = months.last else { return ["Not enough spending data yet."] }
        guard months.count > 1 else { return ["Need at least 2 months to detect unusual patterns."] }

        let previousMonths = months.dropLast()
        var findings: [String] = []

        for category in TransactionCategory.allCases {
            let latestAmount = monthlyExpenses[latest]?[category, default: 0] ?? 0
            let previousValues = previousMonths.map { monthlyExpenses[$0]?[category, default: 0] ?? 0 }
            let average = previousValues.reduce(0, +) / Double(max(previousValues.count, 1))

            if average > 0, latestAmount > average * 1.4 {
                findings.append("\(category.displayName) spending is up \(Int(((latestAmount - average) / average) * 100))% in \(latest).")
            }
        }

        return findings.isEmpty ? ["No unusual spending spikes detected."] : findings
    }

    static func projectNextMonthExpense(monthlyExpenses: [String: [TransactionCategory: Double]]) -> Double {
        let totalPerMonth = monthlyExpenses.values.map { $0.values.reduce(0, +) }
        guard !totalPerMonth.isEmpty else { return 0 }

        let average = totalPerMonth.reduce(0, +) / Double(totalPerMonth.count)
        let last = totalPerMonth.last ?? average
        return (average * 0.7) + (last * 0.3)
    }

    static func personalizedTips(transactions: [Transaction], unusualSpending: [String]) -> [String] {
        var tips: [String] = []

        if unusualSpending.contains(where: { $0.localizedCaseInsensitiveContains("Food") }) {
            tips.append("Set a weekly dining budget and prepare 2 meal-prep days to lower food spend.")
        }

        let subscriptions = transactions.filter { $0.category == .subscription && $0.isExpense }
        if subscriptions.count > 3 {
            tips.append("Review recurring subscriptions; cancel at least one low-value service this month.")
        }

        if tips.isEmpty {
            tips.append("Automate savings transfers right after payday to reduce discretionary spending.")
        }

        return tips
    }

    static func investmentTips(isInvesting: Bool) -> [String] {
        guard !isInvesting else {
            return ["Your investment habit looks active—rebalance quarterly to match your risk profile."]
        }

        return [
            "Start with a low-cost index fund and automate a small monthly contribution.",
            "Build a 3-6 month emergency fund before increasing investment risk.",
            "Use dollar-cost averaging to smooth market volatility."
        ]
    }
}

enum LLMInsightPromptBuilder {
    static func buildPrompt(
        monthlyExpenses: [String: [TransactionCategory: Double]],
        unusualSpending: [String],
        projectedExpenses: Double,
        tips: [String],
        investmentTips: [String]
    ) -> String {
        """
        You are a personal finance assistant.
        Monthly expenses by category: \(monthlyExpenses)
        Unusual spending findings: \(unusualSpending)
        Projected next month expense: \(projectedExpenses)
        Personalized saving tips: \(tips)
        Investment advice: \(investmentTips)
        Provide concise, actionable insights for the mobile app.
        """
    }
}
