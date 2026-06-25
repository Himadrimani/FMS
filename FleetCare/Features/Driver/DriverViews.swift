import SwiftUI

struct DriverTabView: View {
    var body: some View {
        TabView {
            Tab("Today", systemImage: "steeringwheel") {
                NavigationStack { DriverDashboardView() }
            }
            Tab("Trips", systemImage: "point.topleft.down.to.point.bottomright.curvepath") {
                NavigationStack { TripsView() }
            }
            Tab("Messages", systemImage: "message.fill") {
                NavigationStack { MessagesView() }
            }
            Tab("More", systemImage: "ellipsis") {
                NavigationStack { MoreFeaturesView(role: .driver) }
            }
        }
    }
}

struct DriverDashboardView: View {
    @State private var showingInspection = false

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: FleetSpacing.xLarge) {
                VStack(alignment: .leading, spacing: FleetSpacing.small) {
                    Text("Next trip")
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(.secondary)
                    Text("Mumbai Hub → Pune DC")
                        .font(.largeTitle.bold())
                    Label("Starts at 10:30 AM · Atlas 12", systemImage: "clock.fill")
                        .foregroundStyle(.secondary)
                }

                Button {
                    showingInspection = true
                } label: {
                    Label("Start Pre-Trip Inspection", systemImage: "checklist")
                        .frame(maxWidth: .infinity, minHeight: 56)
                }
                .buttonStyle(.borderedProminent)
                .controlSize(.large)
                .accessibilityHint("Opens the required safety checklist")

                VStack(alignment: .leading, spacing: FleetSpacing.large) {
                    SectionHeader(title: "Route")
                    LabeledContent("Distance", value: "151 km")
                    LabeledContent("Estimated drive", value: "3 hr 12 min")
                    LabeledContent("Traffic", value: "Moderate")
                    Button("Preview Route", systemImage: "map.fill") {}
                        .buttonStyle(.bordered)
                        .controlSize(.large)
                }
                .fleetCard()

                HStack(spacing: FleetSpacing.medium) {
                    SafetyAction(title: "Report issue", symbol: "exclamationmark.bubble.fill", tint: .orange)
                    SafetyAction(title: "Emergency", symbol: "sos.circle.fill", tint: .red)
                }
            }
            .padding()
        }
        .background(Color.appBackground)
        .navigationTitle("Today")
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                NavigationLink(destination: AccountView()) {
                    Image(systemName: "person.crop.circle")
                }
                .accessibilityLabel("Account")
            }
        }
        .fullScreenCover(isPresented: $showingInspection) {
            InspectionView()
        }
    }
}

private struct SafetyAction: View {
    let title: String
    let symbol: String
    let tint: Color

    var body: some View {
        Button {} label: {
            VStack(spacing: FleetSpacing.small) {
                Image(systemName: symbol).font(.title)
                Text(title).font(.headline)
            }
            .frame(maxWidth: .infinity, minHeight: 88)
        }
        .buttonStyle(.bordered)
        .tint(tint)
    }
}

struct TripsView: View {
    var body: some View {
        List(SampleData.trips) { trip in
            NavigationLink {
                TripDetailView(trip: trip)
            } label: {
                TripRow(trip: trip)
            }
        }
        .navigationTitle("Assigned Trips")
    }
}

struct TripRow: View {
    let trip: FleetTrip

    var body: some View {
        VStack(alignment: .leading, spacing: FleetSpacing.small) {
            HStack {
                Text(trip.title).font(.headline)
                Spacer()
                StatusBadge(status: trip.status)
            }
            Text("\(trip.origin) → \(trip.destination)")
                .font(.subheadline)
                .foregroundStyle(.secondary)
            Text(trip.scheduledAt, format: .dateTime.weekday().hour().minute())
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .padding(.vertical, FleetSpacing.xSmall)
    }
}

struct TripDetailView: View {
    let trip: FleetTrip

    var body: some View {
        List {
            Section {
                VStack(alignment: .leading, spacing: FleetSpacing.medium) {
                    Text(trip.title).font(.title.bold())
                    StatusBadge(status: trip.status)
                }
                .padding(.vertical, FleetSpacing.small)
            }
            Section("Route") {
                LabeledContent("From", value: trip.origin)
                LabeledContent("To", value: trip.destination)
                LabeledContent("Distance", value: trip.distanceKilometers.formatted(.number) + " km")
                LabeledContent("Departure", value: trip.scheduledAt, format: .dateTime.weekday().hour().minute())
            }
            Section {
                Button("Start Trip", systemImage: "play.fill") {}
                    .disabled(trip.status == .completed)
                Button("Log by Voice", systemImage: "waveform") {}
                Button("Report Delay", systemImage: "exclamationmark.bubble") {}
            }
        }
        .navigationTitle("Trip")
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct InspectionView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var checked = Set<String>()

    private let checks = ["Tyres and wheels", "Lights and indicators", "Brakes", "Mirrors and glass", "Fluids and leaks", "Safety equipment"]

    var body: some View {
        NavigationStack {
            List {
                Section {
                    Text("Walk around the vehicle and confirm each safety item. Report anything uncertain.")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                Section("Safety checks") {
                    ForEach(checks, id: \.self) { check in
                        Button {
                            if checked.contains(check) { checked.remove(check) } else { checked.insert(check) }
                        } label: {
                            Label(check, systemImage: checked.contains(check) ? "checkmark.circle.fill" : "circle")
                                .foregroundStyle(checked.contains(check) ? .green : .primary)
                                .frame(minHeight: 44)
                        }
                        .accessibilityValue(checked.contains(check) ? "Checked" : "Not checked")
                    }
                }
                Section {
                    Button("Report a Defect", systemImage: "camera.fill", role: .destructive) {}
                }
            }
            .navigationTitle("Pre-Trip Inspection")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Close") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Complete") { dismiss() }
                        .disabled(checked.count != checks.count)
                }
            }
        }
    }
}

#Preview("Driver Tab") {
    let session = SessionStore()
    _ = session.authenticate(email: "driver@fleetcare.example", password: "password", users: [])
    return DriverTabView()
        .environment(session)
}

#Preview("Driver Dashboard") {
    NavigationStack {
        DriverDashboardView()
    }
    .environment(SessionStore())
}

#Preview("Assigned Trips") {
    NavigationStack {
        TripsView()
    }
}

#Preview("Trip Detail") {
    NavigationStack {
        TripDetailView(trip: SampleData.trips[0])
    }
}

#Preview("Inspection") {
    InspectionView()
}
