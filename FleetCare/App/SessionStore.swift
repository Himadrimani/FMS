import Foundation
import Observation
import SwiftData

enum UserRole: String, CaseIterable, Identifiable, Codable {
    case fleetManager = "Fleet Manager"
    case driver = "Driver"
    case maintenance = "Maintenance"

    var id: Self { self }

    var symbol: String {
        switch self {
        case .fleetManager: "chart.bar.xaxis"
        case .driver: "steeringwheel"
        case .maintenance: "wrench.and.screwdriver"
        }
    }
}

@Observable
@MainActor
final class SessionStore {
    var hasCompletedOnboarding = false
    var isAuthenticated = false
    var isOffline = false
    private(set) var currentUser: AuthenticatedUser?

    var signedInEmail: String {
        currentUser?.email ?? ""
    }

    var currentRole: UserRole {
        currentUser?.role ?? .fleetManager
    }

    func authenticate(email: String, password: String, users: [FleetUser]) -> AuthenticationResult {
        guard let user = Self.userRecord(for: email, users: users) else {
            return .failure("No account exists for this email.")
        }

        if user.hasTemporaryPassword && password.lowercased() == "temporary" {
            return .requiresActivation
        }

        currentUser = AuthenticatedUser(email: user.email, fullName: user.fullName, role: user.role)
        isAuthenticated = true
        return .authenticated
    }

    func activate(email: String, users: [FleetUser]) -> AuthenticationResult {
        guard let user = Self.userRecord(for: email, users: users) else {
            return .failure("No account exists for this email.")
        }

        user.isActivated = true
        user.hasTemporaryPassword = false
        currentUser = AuthenticatedUser(email: user.email, fullName: user.fullName, role: user.role)
        isAuthenticated = true
        return .authenticated
    }

    func signOut() {
        isAuthenticated = false
        currentUser = nil
    }

    private static func userRecord(for email: String, users: [FleetUser]) -> FleetUser? {
        if let storedUser = users.first(where: { $0.email.caseInsensitiveCompare(email) == .orderedSame }) {
            return storedUser
        }
        return demoUsers.first { $0.email.caseInsensitiveCompare(email) == .orderedSame }
    }

    private static let demoUsers = [
        FleetUser(email: "manager@fleetcare.example", fullName: "Fleet Manager", role: .fleetManager, isActivated: true, hasTemporaryPassword: false),
        FleetUser(email: "driver@fleetcare.example", fullName: "Assigned Driver", role: .driver, isActivated: true, hasTemporaryPassword: false),
        FleetUser(email: "maintenance@fleetcare.example", fullName: "Maintenance Personnel", role: .maintenance, isActivated: true, hasTemporaryPassword: false)
    ]
}

struct AuthenticatedUser: Equatable {
    let email: String
    let fullName: String
    let role: UserRole
}

enum AuthenticationResult: Equatable {
    case authenticated
    case requiresActivation
    case failure(String)
}
