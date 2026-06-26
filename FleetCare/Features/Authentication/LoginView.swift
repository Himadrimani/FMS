import SwiftUI
import Supabase

// DTO to decode the `users` table
private struct UserDTO: Codable {
    let id: UUID
    let email: String
    let role: String
}

struct LoginView: View {
    @Environment(SessionStore.self) private var session
    @State private var email = ""
    @State private var password = ""
    @State private var isLoading = false
    @State private var errorMessage: String?

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 44) {

                    // ── Header ──
                    VStack(spacing: 14) {
                        Image(systemName: "truck.box.fill")
                            .font(.system(size: 64))
                            .foregroundStyle(.brandPrimary)
                            .accessibilityHidden(true)

                        Text("FleetCare")
                            .font(.system(size: 32, weight: .bold, design: .rounded))

                        Text("Sign in to manage your fleet.")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                    .padding(.top, 60)

                    // ── Error banner ──
                    if let errorMessage {
                        Text(errorMessage)
                            .font(.callout)
                            .foregroundStyle(.red)
                            .padding(12)
                            .frame(maxWidth: .infinity)
                            .background(Color.red.opacity(0.08))
                            .cornerRadius(10)
                            .padding(.horizontal, 24)
                    }

                    // ── Fields ──
                    VStack(spacing: 16) {
                        TextField("Work Email", text: $email)
                            .textContentType(.emailAddress)
                            .keyboardType(.emailAddress)
                            .textInputAutocapitalization(.never)
                            .padding()
                            .background(Color(UIColor.secondarySystemBackground))
                            .cornerRadius(12)
                            .disabled(isLoading)

                        SecureField("Password", text: $password)
                            .textContentType(.password)
                            .padding()
                            .background(Color(UIColor.secondarySystemBackground))
                            .cornerRadius(12)
                            .disabled(isLoading)
                    }
                    .padding(.horizontal, 24)

                    // ── Sign In button ──
                    Button(action: signIn) {
                        HStack(spacing: 8) {
                            if isLoading {
                                ProgressView()
                                    .tint(.white)
                            }
                            Text(isLoading ? "Signing in…" : "Sign In")
                        }
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(
                            email.isEmpty || password.isEmpty || isLoading
                                ? Color.brandPrimary.opacity(0.45)
                                : Color.brandPrimary
                        )
                        .cornerRadius(12)
                    }
                    .disabled(email.isEmpty || password.isEmpty || isLoading)
                    .padding(.horizontal, 24)

                    Spacer(minLength: 60)
                }
            }
            .background(Color.appBackground)
        }
    }

    // MARK: – Auth logic
    private func signIn() {
        isLoading = true
        errorMessage = nil

        Task {
            do {
                // 1. Authenticate with Supabase Auth
                _ = try await SupabaseConfig.client.auth.signIn(
                    email: email, password: password
                )

                // 2. Fetch the user's role from the `users` table
                var role: UserRole? = nil
                var dbUserId: UUID? = nil
                do {
                    let users: [UserDTO] = try await SupabaseConfig.client
                        .from("users")
                        .select("id, email, role")
                        .eq("email", value: email.lowercased())
                        .execute()
                        .value

                    if let user = users.first {
                        dbUserId = user.id
                        // Map DB enum → app enum
                        switch user.role {
                        case "FLEET_MANAGER": role = .fleetManager
                        case "DRIVER":        role = .driver
                        case "TECH":          role = .maintenance
                        default:              role = .fleetManager
                        }
                    }
                    if let role = role {
                        print("✅ Fetched role: \(role.rawValue)")
                    } else {
                        print("⚠️ User found, but role was empty or invalid.")
                    }
                } catch {
                    print("⚠️ Could not fetch role from users table: \(error)")
                }

                // 3. Update session
                await MainActor.run {
                    if let validRole = role {
                        session.selectedRole = validRole
                        // Store the user's identity for per-user data filtering using the public users table ID
                        session.currentUserId = dbUserId ?? SupabaseConfig.client.auth.currentUser?.id
                        session.currentUserEmail = email.lowercased()
                        session.signIn()
                    } else {
                        errorMessage = "No role assigned in 'users' table. Check database."
                    }
                    isLoading = false
                }
                print("✅ Auth flow finished.")

            } catch {
                await MainActor.run {
                    errorMessage = "Invalid email or password."
                    isLoading = false
                }
                print("❌ Login failed: \(error)")
            }
        }
    }
}
