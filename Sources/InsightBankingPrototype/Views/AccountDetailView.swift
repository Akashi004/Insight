import SwiftUI

struct AccountDetailView: View {
    @EnvironmentObject private var session: SessionViewModel
    let account: Account

    var body: some View {
        List {
            Section("Overview") {
                LabeledContent("Account", value: account.name)
                LabeledContent("Type", value: account.type.rawValue.capitalized)
                LabeledContent("Balance") {
                    Text(account.balance, format: .currency(code: account.currency))
                }
            }

            ForEach(session.groupedTransactions(for: account)) { section in
                Section(DateFormatter.sectionDate.string(from: section.date)) {
                    ForEach(section.transactions) { tx in
                        HStack {
                            VStack(alignment: .leading) {
                                Text(tx.merchant)
                                Text(tx.category.displayName)
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                            Spacer()
                            Text(tx.amount, format: .currency(code: account.currency))
                                .foregroundStyle(tx.isExpense ? .red : .green)
                        }
                    }
                }
            }
        }
        .navigationTitle(account.name)
        .navigationBarTitleDisplayMode(.inline)
    }
}
