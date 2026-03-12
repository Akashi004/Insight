import Foundation

@MainActor
final class SessionViewModel: ObservableObject {
    @Published var authenticatedUser: UserCredential?
    @Published var accounts: [Account] = []
    @Published var transactions: [Transaction] = []
    @Published var loginError: String?

    private let dataLoader: DataLoading
    private let aiService: AIInsightGenerating
    private var data: BankingData?

    init(dataLoader: DataLoading = JSONDataService(), aiService: AIInsightGenerating = AIInsightsService()) {
        self.dataLoader = dataLoader
        self.aiService = aiService
        loadData()
    }

    func login(username: String, password: String) {
        guard let users = data?.users else {
            loginError = "Unable to load user credentials."
            return
        }

        guard let user = users.first(where: { $0.username == username && $0.password == password }) else {
            loginError = "Invalid credentials. Try demo.user / Pass@123"
            return
        }

        authenticatedUser = user
        loginError = nil
    }

    func logout() {
        authenticatedUser = nil
    }

    func transactions(for account: Account) -> [Transaction] {
        transactions
            .filter { $0.accountID == account.id }
            .sorted(by: { $0.date > $1.date })
    }

    func groupedTransactions(for account: Account) -> [TransactionSection] {
        let grouped = Dictionary(grouping: transactions(for: account)) { tx in
            Calendar.current.startOfDay(for: tx.date)
        }

        return grouped.keys.sorted(by: >).map { key in
            TransactionSection(date: key, transactions: grouped[key, default: []])
        }
    }

    func monthlyCategoryExpenses() -> [MonthlyCategoryExpense] {
        let map = AnalyticsEngine.monthlyExpenses(transactions: transactions)
        return map.keys.sorted().flatMap { month in
            (map[month] ?? [:]).map { MonthlyCategoryExpense(monthLabel: month, category: $0.key, total: $0.value) }
        }
    }

    func insightResult() -> InsightResult {
        aiService.analyze(
            transactions: transactions,
            isInvesting: authenticatedUser?.isInvesting ?? false,
            now: Date()
        )
    }

    private func loadData() {
        do {
            let loaded = try dataLoader.loadBankingData()
            data = loaded
            accounts = loaded.accounts
            transactions = loaded.transactions.sorted(by: { $0.date > $1.date })
        } catch {
            loginError = error.localizedDescription
        }
    }
}
