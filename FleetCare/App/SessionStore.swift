import Foundation
import Observation

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
    var selectedRole: UserRole = .fleetManager
    var isOffline = false
    var currentUserId: UUID? = nil
    var currentUserEmail: String? = nil

    func signIn() {
        isAuthenticated = true
    }

    func signOut() {
        isAuthenticated = false
        currentUserId = nil
        currentUserEmail = nil
    }
}
