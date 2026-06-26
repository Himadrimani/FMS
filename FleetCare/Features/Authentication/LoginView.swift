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
    @State private var otp = ""
    @State private var isLoading = false
    @State private var errorMessage: String?
    @State private var showOTPField = false

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

                    if showOTPField {
                        // ── OTP Field ──
                        VStack(spacing: 16) {
                            Text("A verification code has been sent to your email.")
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                                .multilineTextAlignment(.center)
                                .padding(.horizontal)

                            TextField("Enter 6-digit OTP", text: $otp)
                                .textContentType(.oneTimeCode)
                                .keyboardType(.numberPad)
                                .padding()
                                .background(Color(UIColor.secondarySystemBackground))
                                .cornerRadius(12)
                                .disabled(isLoading)
                        }
                        .padding(.horizontal, 24)

                        // ── Verify button ──
                        Button(action: verifyOTP) {
                            HStack(spacing: 8) {
                                if isLoading { ProgressView().tint(.white) }
                                Text(isLoading ? "Verifying…" : "Verify Code")
                            }
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(
                                otp.isEmpty || isLoading ? Color.brandPrimary.opacity(0.45) : Color.brandPrimary
                            )
                            .cornerRadius(12)
                        }
                        .disabled(otp.isEmpty || isLoading)
                        .padding(.horizontal, 24)

                    } else {
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
                                if isLoading { ProgressView().tint(.white) }
                                Text(isLoading ? "Signing in…" : "Sign In")
                            }
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(
                                email.isEmpty || password.isEmpty || isLoading ? Color.brandPrimary.opacity(0.45) : Color.brandPrimary
                            )
                            .cornerRadius(12)
                        }
                        .disabled(email.isEmpty || password.isEmpty || isLoading)
                        .padding(.horizontal, 24)
                    }

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
                let role = try await fetchRole()

                await MainActor.run {
                    if let validRole = role {
                        let isDemoAccount = email.lowercased().contains("fleetdriver") || email.lowercased().contains("fleetmaintenance") || email.lowercased().contains("fleettech")
                        
                        if validRole == .fleetManager || isDemoAccount {
                            // Admin and Demo accounts bypass OTP
                            completeLogin(role: validRole)
                        } else {
                            // Non-admins require 2-step OTP
                            triggerOTP()
                        }
                    } else {
                        errorMessage = "No role assigned in 'users' table. Check database."
                        isLoading = false
                    }
                }
            } catch {
                await MainActor.run {
                    errorMessage = "Invalid email or password."
                    isLoading = false
                }
            }
        }
    }
    
    private func fetchRole() async throws -> UserRole? {
        let users: [UserDTO] = try await SupabaseConfig.client
            .from("users")
            .select("id, email, role")
            .eq("email", value: email.lowercased())
            .execute()
            .value

        if let user = users.first {
            switch user.role {
            case "FLEET_MANAGER": return .fleetManager
            case "DRIVER":        return .driver
            case "TECH":          return .maintenance
            default:              return .fleetManager
            }
        }
        return nil
    }

    private func triggerOTP() {
        Task {
            do {
                // Sign out of the password session to prepare for OTP session
                try? await SupabaseConfig.client.auth.signOut()
                
                // Send OTP to email
                try await SupabaseConfig.client.auth.signInWithOTP(email: email)
                
                await MainActor.run {
                    withAnimation {
                        showOTPField = true
                        isLoading = false
                    }
                }
            } catch {
                await MainActor.run {
                    errorMessage = "Failed to send OTP: \(error.localizedDescription)"
                    isLoading = false
                }
            }
        }
    }
    
    private func verifyOTP() {
        isLoading = true
        errorMessage = nil
        
        Task {
            do {
                _ = try await SupabaseConfig.client.auth.verifyOTP(
                    email: email,
                    token: otp,
                    type: .email
                )
                
                let role = try await fetchRole()
                
                await MainActor.run {
                    if let validRole = role {
                        completeLogin(role: validRole)
                    } else {
                        errorMessage = "Role missing."
                        isLoading = false
                    }
                }
            } catch {
                await MainActor.run {
                    errorMessage = "Invalid or expired OTP."
                    isLoading = false
                }
            }
        }
    }
    
    private func completeLogin(role: UserRole) {
        session.selectedRole = role
        session.currentUserEmail = email.lowercased()
        session.signIn()
        isLoading = false
    }
}
