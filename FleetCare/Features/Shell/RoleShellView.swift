import SwiftUI

struct RoleShellView: View {
    @Environment(SessionStore.self) private var session

    var body: some View {
        @Bindable var session = session
        VStack(spacing: 0) {
            if session.isOffline {
                OfflineBanner()
            }
            switch session.currentRole {
            case .fleetManager:
                ManagerTabView()
            case .driver:
                DriverTabView()
            case .maintenance:
                MaintenanceTabView()
            }
        }
        .safeAreaInset(edge: .top, spacing: 0) {
            EmptyView()
        }
    }
}

struct AccountView: View {
    @Environment(SessionStore.self) private var session

    var body: some View {
        @Bindable var session = session
        Form {
            Section("Workspace") {
                LabeledContent("Signed in", value: session.signedInEmail)
                LabeledContent("Role", value: session.currentRole.rawValue)
                Toggle("Simulate offline mode", isOn: $session.isOffline)
            }

            Section("Security") {
                Label("Password sign-in", systemImage: "key.fill")
                Label("Role validated at login", systemImage: "person.badge.shield.checkmark")
                Label("Data encrypted on device", systemImage: "lock.shield.fill")
            }

            Section {
                Button("Sign Out", role: .destructive) {
                    session.signOut()
                }
            }
        }
        .navigationTitle("Account")
    }
}

#Preview("Role Shell - Manager") {
    let session = SessionStore()
    _ = session.authenticate(email: "manager@fleetcare.example", password: "password", users: [])
    return RoleShellView()
        .environment(session)
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

#Preview("Account") {
    let session = SessionStore()
    _ = session.authenticate(email: "maintenance@fleetcare.example", password: "password", users: [])
    return NavigationStack {
        AccountView()
    }
    .environment(session)
}
