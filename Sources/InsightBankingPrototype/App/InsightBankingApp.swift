import SwiftUI

@main
struct InsightBankingApp: App {
    @StateObject private var session = SessionViewModel()

    var body: some Scene {
        WindowGroup {
            RootView()
                .environmentObject(session)
        }
    }
}
