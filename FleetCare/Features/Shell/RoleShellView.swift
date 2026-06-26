import SwiftUI

struct RoleShellView: View {
    @Environment(SessionStore.self) private var session

    var body: some View {
        @Bindable var session = session
        VStack(spacing: 0) {
            if session.isOffline {
                OfflineBanner()
            }
            switch session.selectedRole {
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
            Section("Security") {
                Label("Passkey enabled", systemImage: "key.fill")
                Label("Face ID enabled", systemImage: "faceid")
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
