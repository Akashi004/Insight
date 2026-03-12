import SwiftUI

struct LoginView: View {
    @EnvironmentObject private var session: SessionViewModel
    @State private var username = "demo.user"
    @State private var password = "Pass@123"

    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                Text("Insight Banking")
                    .font(.largeTitle.bold())

                TextField("Username", text: $username)
                    .textInputAutocapitalization(.never)
                    .autocorrectionDisabled()
                    .padding()
                    .background(Color(.secondarySystemBackground))
                    .clipShape(RoundedRectangle(cornerRadius: 12))

                SecureField("Password", text: $password)
                    .padding()
                    .background(Color(.secondarySystemBackground))
                    .clipShape(RoundedRectangle(cornerRadius: 12))

                if let error = session.loginError {
                    Text(error)
                        .foregroundStyle(.red)
                        .font(.footnote)
                }

                Button("Login") {
                    session.login(username: username, password: password)
                }
                .buttonStyle(.borderedProminent)

                Text("Demo: demo.user / Pass@123")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            .padding()
        }
    }
}
