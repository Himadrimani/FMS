import SwiftData
import SwiftUI

struct LoginView: View {
    @Environment(SessionStore.self) private var session
    @Query(sort: \FleetUser.email) private var users: [FleetUser]
    @State private var email = "manager@fleetcare.example"
    @State private var password = "password"
    @State private var personalPassword = ""
    @State private var confirmedPassword = ""
    @State private var errorMessage: String?
    @State private var requiresActivation = false

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: FleetSpacing.xLarge) {
                    VStack(alignment: .leading, spacing: FleetSpacing.small) {
                        Image(systemName: "truck.box.fill")
                            .font(.system(size: 48))
                            .foregroundStyle(.brandPrimary)
                            .accessibilityHidden(true)
                        Text("Welcome to FleetCare")
                            .font(.largeTitle.bold())
                        Text("Secure access to your fleet workspace.")
                            .font(.body)
                            .foregroundStyle(.secondary)
                    }

                    VStack(spacing: FleetSpacing.large) {
                        TextField("Work email", text: $email)
                            .textContentType(.username)
                            .keyboardType(.emailAddress)
                            .textInputAutocapitalization(.never)
                            .accessibilityLabel("Work email")
                        if requiresActivation {
                            SecureField("Create personal password", text: $personalPassword)
                                .textContentType(.newPassword)
                                .accessibilityLabel("Create personal password")
                            SecureField("Confirm password", text: $confirmedPassword)
                                .textContentType(.newPassword)
                                .accessibilityLabel("Confirm password")
                        } else {
                            SecureField("Password", text: $password)
                                .textContentType(.password)
                                .accessibilityLabel("Password")
                        }
                    }
                    .textFieldStyle(.roundedBorder)

                    if let errorMessage {
                        Label(errorMessage, systemImage: "exclamationmark.circle.fill")
                            .font(.footnote)
                            .foregroundStyle(.red)
                            .accessibilityLabel("Error: \(errorMessage)")
                    }

                    Button(requiresActivation ? "Activate Account" : "Sign In") {
                        submit()
                    }
                    .buttonStyle(.borderedProminent)
                    .controlSize(.large)
                    .frame(maxWidth: .infinity)

                    Text(requiresActivation ? "Create a personal password to complete first login." : "Use the temporary password supplied by the Fleet Manager on first login.")
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                        .accessibilityHint("Fleet Manager controls account creation and temporary password distribution.")
                }
                .padding(FleetSpacing.xLarge)
            }
            .background(Color.appBackground)
        }
    }

    private func submit() {
        errorMessage = nil
        guard email.contains("@") else {
            errorMessage = "Enter a valid work email."
            return
        }

        if requiresActivation {
            guard personalPassword.count >= 8 else {
                errorMessage = "Password must be at least 8 characters."
                return
            }
            guard personalPassword == confirmedPassword else {
                errorMessage = "Passwords do not match."
                return
            }
            handle(session.activate(email: email, users: users))
            return
        }

        guard !password.isEmpty else {
            errorMessage = "Enter your password."
            return
        }

        if password.lowercased() == "temporary" {
            handle(session.authenticate(email: email, password: password, users: users))
            password = ""
        } else {
            handle(session.authenticate(email: email, password: password, users: users))
        }
    }

    private func handle(_ result: AuthenticationResult) {
        switch result {
        case .authenticated:
            break
        case .requiresActivation:
            requiresActivation = true
        case .failure(let message):
            errorMessage = message
        }
    }
}

#Preview("Login") {
    LoginView()
        .environment(SessionStore())
        .modelContainer(for: [FleetUser.self], inMemory: true)
}
