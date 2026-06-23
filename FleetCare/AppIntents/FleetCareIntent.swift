import AppIntents

struct OpenTodayTripsIntent: AppIntent {
    static let title: LocalizedStringResource = "Open Today’s Fleet Trips"
    static let description = IntentDescription("Opens FleetCare to today’s assigned trips.")
    static let openAppWhenRun = true

    func perform() async throws -> some IntentResult {
        .result(dialog: "Opening today’s trips.")
    }
}

struct FleetCareShortcuts: AppShortcutsProvider {
    static var appShortcuts: [AppShortcut] {
        AppShortcut(
            intent: OpenTodayTripsIntent(),
            phrases: ["Open today's trips in \(.applicationName)"],
            shortTitle: "Today’s Trips",
            systemImageName: "point.topleft.down.to.point.bottomright.curvepath"
        )
    }
}
