import Charts
import MapKit
import SwiftUI

struct ManagerTabView: View {
    var body: some View {
        FleetManagerTabView()
    }
}

struct ManagerDashboardView: View {
    private let utilization = [
        TrendPoint(day: "Mon", value: 74), TrendPoint(day: "Tue", value: 81),
        TrendPoint(day: "Wed", value: 78), TrendPoint(day: "Thu", value: 86),
        TrendPoint(day: "Fri", value: 91), TrendPoint(day: "Sat", value: 69),
        TrendPoint(day: "Sun", value: 72)
    ]

    var body: some View {
        ScrollView {
            LazyVStack(alignment: .leading, spacing: FleetSpacing.xLarge) {
                Text("Good morning")
                    .font(.largeTitle.bold())
                    .accessibilityAddTraits(.isHeader)

                ScrollView(.horizontal) {
                    HStack(spacing: FleetSpacing.medium) {
                        MetricCard(title: "Vehicles active", value: "42", detail: "of 48 vehicles", symbol: "car.2.fill")
                            .frame(width: 190)
                        MetricCard(title: "On-time trips", value: "94%", detail: "Up 3% this week", symbol: "clock.badge.checkmark.fill", tint: .green)
                            .frame(width: 190)
                        MetricCard(title: "Needs attention", value: "3", detail: "1 high priority", symbol: "exclamationmark.triangle.fill", tint: .orange)
                            .frame(width: 190)
                    }
                }
                .scrollIndicators(.hidden)

                VStack(alignment: .leading, spacing: FleetSpacing.large) {
                    SectionHeader(title: "Fleet utilization")
                    Chart(utilization) { point in
                        LineMark(x: .value("Day", point.day), y: .value("Utilization", point.value))
                            .foregroundStyle(.brandPrimary)
                            .interpolationMethod(.catmullRom)
                        AreaMark(x: .value("Day", point.day), y: .value("Utilization", point.value))
                            .foregroundStyle(.linearGradient(colors: [.brandPrimary.opacity(0.25), .clear], startPoint: .top, endPoint: .bottom))
                    }
                    .frame(height: 180)
                    .chartYScale(domain: 50...100)
                    .accessibilityChartDescriptor(UtilizationChartDescriptor(points: utilization))
                }
                .fleetCard()

                SectionHeader(title: "Priority")
                InsightCard(
                    title: "Brake system risk",
                    summary: "Orion 07 shows a pattern consistent with accelerated front brake wear.",
                    score: 87,
                    recommendation: "Inspect within 24 hours"
                )

                SectionHeader(title: "Today’s operations")
                ForEach(SampleData.trips) { trip in
                    NavigationLink {
                        TripDetailView(trip: trip)
                    } label: {
                        TripRow(trip: trip)
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(FleetSpacing.large)
        }
        .background(Color.appBackground)
        .navigationTitle("Overview")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                NavigationLink {
                    AccountView()
                } label: {
                    Image(systemName: "person.crop.circle")
                }
                .accessibilityLabel("Account")
            }
        }
    }
}

private struct TrendPoint: Identifiable {
    let id = UUID()
    let day: String
    let value: Double
}

private struct UtilizationChartDescriptor: AXChartDescriptorRepresentable {
    let points: [TrendPoint]

    func makeChartDescriptor() -> AXChartDescriptor {
        let xAxis = AXCategoricalDataAxisDescriptor(title: "Day", categoryOrder: points.map(\.day))
        let yAxis = AXNumericDataAxisDescriptor(title: "Utilization percentage", range: 0...100, gridlinePositions: []) {
            $0.formatted(.number) + " percent"
        }
        let series = AXDataSeriesDescriptor(
            name: "Fleet utilization",
            isContinuous: false,
            dataPoints: points.map { .init(x: $0.day, y: $0.value) }
        )
        return AXChartDescriptor(title: "Fleet utilization this week", summary: "Utilization peaks on Friday.", xAxis: xAxis, yAxis: yAxis, series: [series])
    }
}

struct FleetListView: View {
    @State private var query = ""
    @State private var selection: FleetStatus?

    private var filtered: [Vehicle] {
        SampleData.vehicles.filter { vehicle in
            (query.isEmpty || vehicle.name.localizedStandardContains(query) || vehicle.registration.localizedStandardContains(query))
            && (selection == nil || vehicle.status == selection)
        }
    }

    var body: some View {
        List {
            Section {
                Picker("Status", selection: $selection) {
                    Text("All").tag(FleetStatus?.none)
                    ForEach(FleetStatus.allCases, id: \.self) { status in
                        Text(status.rawValue).tag(Optional(status))
                    }
                }
                .pickerStyle(.menu)
            }

            Section("Vehicles") {
                ForEach(filtered) { vehicle in
                    NavigationLink {
                        VehicleDetailView(vehicle: vehicle)
                    } label: {
                        VehicleRow(vehicle: vehicle)
                    }
                }
            }
        }
        .searchable(text: $query, prompt: "Vehicle or registration")
        .navigationTitle("Fleet")
        .overlay {
            if filtered.isEmpty {
                EmptyStateView(title: "No vehicles found", message: "Try another search or clear the status filter.", symbol: "car.2")
            }
        }
    }
}

private struct VehicleRow: View {
    let vehicle: Vehicle

    var body: some View {
        HStack(spacing: FleetSpacing.medium) {
            Image(systemName: "truck.box.fill")
                .font(.title2)
                .foregroundStyle(.brandPrimary)
                .frame(width: 44, height: 44)
                .background(.brandPrimary.opacity(0.12), in: .circle)
                .accessibilityHidden(true)
            VStack(alignment: .leading, spacing: FleetSpacing.xSmall) {
                Text(vehicle.name).font(.headline)
                Text(vehicle.registration).font(.subheadline).foregroundStyle(.secondary)
                StatusBadge(status: vehicle.status)
            }
        }
        .padding(.vertical, FleetSpacing.xSmall)
    }
}

struct VehicleDetailView: View {
    let vehicle: Vehicle

    var body: some View {
        List {
            Section {
                VStack(alignment: .leading, spacing: FleetSpacing.medium) {
                    Text(vehicle.name).font(.largeTitle.bold())
                    StatusBadge(status: vehicle.status)
                }
                .padding(.vertical, FleetSpacing.small)
            }
            Section("Vehicle") {
                LabeledContent("Registration", value: vehicle.registration)
                LabeledContent("Model", value: "\(vehicle.make) \(vehicle.model)")
                LabeledContent("Year", value: "\(vehicle.year)")
                LabeledContent("Odometer", value: vehicle.odometer, format: .number.precision(.fractionLength(0)))
            }
            Section("Quick actions") {
                NavigationLink {
                    FeatureCollectionView(title: "Maintenance History", role: .fleetManager)
                } label: {
                    Label("Maintenance history", systemImage: "wrench.and.screwdriver")
                }
                NavigationLink {
                    FeatureCollectionView(title: "Trip History", role: .fleetManager)
                } label: {
                    Label("Trip history", systemImage: "point.topleft.down.to.point.bottomright.curvepath")
                }
            }
        }
        .navigationTitle("Vehicle")
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct FleetMapView: View {
    @State private var position: MapCameraPosition = .region(
        MKCoordinateRegion(
            center: CLLocationCoordinate2D(latitude: 19.076, longitude: 72.8777),
            span: MKCoordinateSpan(latitudeDelta: 0.18, longitudeDelta: 0.18)
        )
    )

    var body: some View {
        Map(position: $position) {
            Marker("Atlas 12", systemImage: "truck.box.fill", coordinate: .init(latitude: 19.104, longitude: 72.875))
                .tint(.brandPrimary)
            Marker("Orion 07", systemImage: "exclamationmark.triangle.fill", coordinate: .init(latitude: 19.048, longitude: 72.903))
                .tint(.orange)
            MapCircle(center: .init(latitude: 19.076, longitude: 72.8777), radius: 4_500)
                .foregroundStyle(.brandSecondary.opacity(0.12))
                .stroke(.brandSecondary, lineWidth: 2)
        }
        .mapStyle(.standard(elevation: .realistic))
        .mapControls {
            MapCompass()
            MapScaleView()
            MapUserLocationButton()
        }
        .safeAreaInset(edge: .bottom) {
            HStack {
                Label("42 active", systemImage: "car.2.fill")
                Spacer()
                Button("Filters", systemImage: "line.3.horizontal.decrease.circle") {}
            }
            .padding()
            .background(.regularMaterial, in: .rect(cornerRadius: FleetRadius.card))
            .padding()
        }
        .navigationTitle("Live Fleet")
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct InsightsView: View {
    var body: some View {
        ScrollView {
            LazyVStack(alignment: .leading, spacing: FleetSpacing.xLarge) {
                Text("Recommendations are ranked by operational impact and confidence. They support — not replace — human decisions.")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                InsightCard(title: "Predictive maintenance", summary: "Two vehicles are likely to need brake service within 14 days.", score: 87, recommendation: "Review maintenance plan")
                InsightCard(title: "Fuel efficiency", summary: "Route changes could reduce weekly idling by approximately 6%.", score: 78, recommendation: "Compare suggested routes")
                InsightCard(title: "Inventory forecast", summary: "Brake pad stock may fall below safety level next month.", score: 82, recommendation: "Prepare purchase request")
            }
            .padding()
        }
        .background(Color.appBackground)
        .navigationTitle("Insights")
    }
}
