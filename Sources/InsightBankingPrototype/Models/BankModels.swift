import Foundation

typealias AccountID = String

enum AccountType: String, Codable, CaseIterable {
    case savings
    case credit
    case debit
}

enum TransactionCategory: String, Codable, CaseIterable, Identifiable {
    case food
    case subscription
    case travel
    case shopping
    case utilities
    case health
    case entertainment
    case salary
    case transfer

    var id: String { rawValue }

    var displayName: String {
        rawValue.capitalized
    }
}

struct UserCredential: Codable {
    let username: String
    let password: String
    let fullName: String
    let isInvesting: Bool
}

struct Account: Codable, Identifiable, Hashable {
    let id: AccountID
    let name: String
    let type: AccountType
    let balance: Double
    let currency: String
}

struct Transaction: Codable, Identifiable {
    let id: String
    let accountID: AccountID
    let date: Date
    let amount: Double
    let merchant: String
    let category: TransactionCategory
    let note: String?

    var isExpense: Bool {
        amount < 0
    }
}

struct BankingData: Codable {
    let users: [UserCredential]
    let accounts: [Account]
    let transactions: [Transaction]
}

struct TransactionSection: Identifiable {
    let date: Date
    let transactions: [Transaction]

    var id: String {
        DateFormatter.sectionDate.string(from: date)
    }
}

struct MonthlyCategoryExpense: Identifiable {
    let monthLabel: String
    let category: TransactionCategory
    let total: Double

    var id: String {
        "\(monthLabel)-\(category.rawValue)"
    }
}

extension DateFormatter {
    static let sectionDate: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        return formatter
    }()

    static let monthYear: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM yyyy"
        return formatter
    }()
}
