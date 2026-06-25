import AuthenticationServices
import SwiftUI

struct LoginView: View {
    @Environment(SessionStore.self) private var session
    @State private var email = "manager@fleetcare.example"
    @State private var password = "password"
    @State private var showingRecovery = false

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
                        SecureField("Password", text: $password)
                            .textContentType(.password)
                            .accessibilityLabel("Password")
                    }
                    .textFieldStyle(.roundedBorder)

                    Button("Sign In") {
                        session.signIn()
                    }
                    .buttonStyle(.borderedProminent)
                    .controlSize(.large)
                    .frame(maxWidth: .infinity)

                    SignInWithAppleButton(.signIn) { _ in
                    } onCompletion: { _ in
                        session.signIn()
                    }
                    .signInWithAppleButtonStyle(.black)
                    .frame(height: 50)
                    .clipShape(.rect(cornerRadius: FleetRadius.control))
                    .accessibilityHint("Signs in using your Apple Account or passkey")

                    Button("Use Face ID") {
                        session.signIn()
                    }
                    .buttonStyle(.bordered)
                    .controlSize(.large)
                    .frame(maxWidth: .infinity)

                    Button("Forgot password?") {
                        showingRecovery = true
                    }
                    .frame(maxWidth: .infinity)
                }
                .padding(FleetSpacing.xLarge)
            }
            .background(Color.appBackground)
            .sheet(isPresented: $showingRecovery) {
                PasswordRecoveryView()
            }
        }
    }
}

private struct PasswordRecoveryView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var email = ""

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    TextField("Work email", text: $email)
                        .textContentType(.emailAddress)
                } footer: {
                    Text("We’ll send a one-time verification code. Codes expire after 10 minutes.")
                }
            }
            .navigationTitle("Reset Password")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Send Code") { dismiss() }
                        .disabled(email.isEmpty)
                }
            }
        }
        .presentationDetents([.medium])
    }
}
