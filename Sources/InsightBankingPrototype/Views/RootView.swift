import SwiftUI

struct RootView: View {
    @EnvironmentObject private var session: SessionViewModel

    var body: some View {
        Group {
            if session.authenticatedUser == nil {
                LoginView()
            } else {
                MainTabView()
            }
        }
    }
}
