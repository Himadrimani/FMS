import SwiftData
import SwiftUI

@main
struct FleetCareApp: App {
    @State private var session = SessionStore()

    var body: some Scene {
        WindowGroup {
            RootView()
                .environment(session)
        }
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
        ])
    }
}
