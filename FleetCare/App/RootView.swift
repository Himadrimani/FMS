import SwiftUI
import SwiftData

struct RootView: View {
    @Environment(SessionStore.self) private var session

    var body: some View {
        Group {
            if !session.hasCompletedOnboarding {
                OnboardingView()
            } else if !session.isAuthenticated {
                LoginView()
            } else {
                RoleShellView()
            }
        }
        .tint(.brandPrimary)
        .preferredColorScheme(.light)
        .animation(.smooth, value: session.hasCompletedOnboarding)
        .animation(.smooth, value: session.isAuthenticated)
    }
}

#Preview("FleetCare App") {
    RootView()
        .environment(SessionStore())
        .modelContainer(for: [
            FleetUser.self,
            Vehicle.self,
            FleetTrip.self,
            Inspection.self,
            DefectReport.self,
            WorkOrder.self,
            MaintenanceTask.self,
            MaintenanceHistory.self,
            InventoryItem.self,
            PurchaseRequest.self,
            FuelLog.self,
            FleetMessage.self,
            FleetNotification.self,
            ComplianceDocument.self,
            AIAlert.self
        ], inMemory: true)
}

