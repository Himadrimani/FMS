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
            Vehicle.self,
            FleetTrip.self,
            WorkOrder.self,
            FleetMessage.self
        ])
    }
}
