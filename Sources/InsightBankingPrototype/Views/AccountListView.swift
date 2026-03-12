import SwiftUI

struct AccountListView: View {
    @EnvironmentObject private var session: SessionViewModel

    var body: some View {
        NavigationStack {
            List(session.accounts) { account in
                NavigationLink(value: account) {
                    HStack {
                        VStack(alignment: .leading) {
                            Text(account.name)
                                .font(.headline)
                            Text(account.type.rawValue.capitalized)
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                        }
                        Spacer()
                        Text(account.balance, format: .currency(code: account.currency))
                            .font(.body.weight(.medium))
                    }
                }
            }
            .navigationTitle("Accounts")
            .navigationDestination(for: Account.self) { account in
                AccountDetailView(account: account)
            }
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Logout") {
                        session.logout()
                    }
                }
            }
        }
    }
}
