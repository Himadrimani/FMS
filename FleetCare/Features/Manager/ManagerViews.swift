import Charts
import MapKit
import SwiftUI

struct ManagerTabView: View {
    var body: some View {
        TabView {
            Tab("Overview", systemImage: "rectangle.grid.2x2.fill") {
                NavigationStack { ManagerDashboardView() }
            }
            Tab("Fleet", systemImage: "car.2.fill") {
                NavigationStack { FleetListView() }
            }
            Tab("Map", systemImage: "map.fill") {
                NavigationStack { FleetMapView() }
            }
            Tab("Insights", systemImage: "chart.xyaxis.line") {
                NavigationStack { InsightsView() }
            }
            Tab("More", systemImage: "ellipsis") {
                NavigationStack { MoreFeaturesView(role: .fleetManager) }
            }
        }
    }
}

struct ManagerDashboardView: View {
    @StateObject private var supabase = SupabaseService.shared
    @State private var showAssignTripSheet = false
    @State private var showCreateWorkOrderSheet = false

    private var activeVehiclesCount: Int {
        supabase.vehicles.filter { $0.status == .active }.count
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 28) {
                dashboardHeader
                overviewSection
                quickActionsSection
                aiInsightsSection
                recentActivitySection
            }
            .padding(.horizontal, 20)
            .padding(.top, 16)
            .padding(.bottom, 40)
        }
        .background(Color(UIColor.systemGroupedBackground).ignoresSafeArea())
        .navigationBarHidden(true)
        .task {
            if supabase.vehicles.isEmpty { await supabase.fetchVehicles() }
            if supabase.trips.isEmpty { await supabase.fetchTrips() }
            if supabase.drivers.isEmpty { await supabase.fetchDrivers() }
            if supabase.technicians.isEmpty { await supabase.fetchTechnicians() }
        }
        .sheet(isPresented: $showAssignTripSheet) {
            AssignTripSheet(supabase: supabase)
        }
        .sheet(isPresented: $showCreateWorkOrderSheet) {
            CreateWorkOrderSheet(supabase: supabase)
        }
    }

    private var dashboardHeader: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text("Good Afternoon,")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                Text("Demo Manager")
                    .font(.title2.bold())
            }
            Spacer()
            
            HStack(spacing: 12) {
                Button(action: {}) {
                    Image(systemName: "bell.fill")
                        .font(.body)
                        .foregroundStyle(.primary)
                        .padding(10)
                        .background(Color(UIColor.secondarySystemBackground))
                        .clipShape(Circle())
                }
                
                Button(action: {}) {
                    Text("DM")
                        .font(.subheadline.bold())
                        .foregroundColor(.white)
                        .padding(10)
                        .background(Color.blue)
                        .clipShape(Circle())
                }
            }
        }
    }

    private var overviewSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Overview")
                .font(.title3.bold())
            
            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 16) {
                NavigationLink(destination: FleetListView()) {
                    OverviewCard(title: "Total Vehicles", value: "\(supabase.vehicles.count)", subtitle: "All vehicles in your fleet", iconName: "car.fill", iconColor: .blue, chevronColor: .blue)
                }
                .buttonStyle(.plain)
                
                NavigationLink(destination: FleetListView()) {
                    OverviewCard(title: "Ready Vehicles", value: "\(activeVehiclesCount)", subtitle: "Vehicles ready to assign", iconName: "checkmark.circle.fill", iconColor: .green, chevronColor: .green)
                }
                .buttonStyle(.plain)
                
                NavigationLink(destination: FeatureCollectionView(title: "Drivers", role: .fleetManager)) {
                    OverviewCard(title: "Drivers Online", value: "0", subtitle: "Active drivers right now", iconName: "person.2.fill", iconColor: .orange, chevronColor: .orange)
                }
                .buttonStyle(.plain)
                
                NavigationLink(destination: FleetMapView()) {
                    OverviewCard(title: "Live Trips", value: "\(supabase.trips.filter { $0.status == .active }.count)", subtitle: "Trips in progress", iconName: "arrow.up.arrow.down", iconColor: .purple, chevronColor: .purple)
                }
                .buttonStyle(.plain)
            }
        }
    }

    private var quickActionsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Quick Actions")
                .font(.title3.bold())
            
            HStack(spacing: 0) {
                NavigationLink(destination: FeatureCollectionView(title: "Chat", role: .fleetManager)) {
                    QuickActionButton(icon: "message.fill", title: "Chat")
                }
                .buttonStyle(.plain)
                Spacer()
                
                NavigationLink(destination: FleetMapView()) {
                    QuickActionButton(icon: "location.fill", title: "Tracking")
                }
                .buttonStyle(.plain)
                Spacer()
                
                Button {
                    showAssignTripSheet = true
                } label: {
                    QuickActionButton(icon: "person.badge.plus", title: "Assign Driver")
                }
                .buttonStyle(.plain)
                Spacer()
                
                Button {
                    showCreateWorkOrderSheet = true
                } label: {
                    QuickActionButton(icon: "wrench.and.screwdriver.fill", title: "Maintenance")
                }
                .buttonStyle(.plain)
            }
        }
    }

    private var aiInsightsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("AI Insights")
                .font(.title3.bold())
            
            VStack(spacing: 12) {
                NavigationLink(destination: InsightsView()) {
                    AIInsightRow(icon: "chart.line.uptrend.xyaxis", iconColor: .blue, title: "Predictive Maintenance Alert", badge: "SMART", badgeColor: .blue, subtitle: "Identify telemetry risks, vehicle alerts, and wear trends...")
                }
                .buttonStyle(.plain)
                
                NavigationLink(destination: InsightsView()) {
                    AIInsightRow(icon: "box.truck.fill", iconColor: .blue, title: "AI Parts Demand Forecasting", badge: "PREDICT", badgeColor: .blue, subtitle: "Calculate upcoming parts consumption & reorder recommendations...")
                }
                .buttonStyle(.plain)
                
                NavigationLink(destination: InsightsView()) {
                    AIInsightRow(icon: "fuelpump.fill", iconColor: .blue, title: "Fuel Insights & Optimization", badge: "OPTIMIZE", badgeColor: .blue, subtitle: "Uncover cost savings, efficiency grades, and consumption anomalies...")
                }
                .buttonStyle(.plain)
                
                NavigationLink(destination: InsightsView()) {
                    AIInsightRow(icon: "doc.text.fill", iconColor: .blue, title: "AI Vehicle Health Analytics", badge: "HEALTH", badgeColor: .blue, subtitle: "Assess fleet vehicle health grades, issue flags and repair tasks...")
                }
                .buttonStyle(.plain)
            }
        }
    }

    private var recentActivitySection: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("Recent Activity")
                    .font(.title3.bold())
                Spacer()
                Button("See All") {}
                    .font(.subheadline.bold())
            }
            
            VStack(spacing: 12) {
                Image(systemName: "clock.arrow.circlepath")
                    .font(.largeTitle)
                    .foregroundColor(Color(UIColor.tertiaryLabel))
                    .padding(.bottom, 4)
                
                Text("No activity yet")
                    .font(.headline)
                
                Text("Trips, alerts and maintenance events will appear here.")
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 40)
            .padding(.horizontal, 20)
            .background(Color(UIColor.systemBackground))
            .cornerRadius(16)
            .shadow(color: Color.black.opacity(0.03), radius: 8, x: 0, y: 4)
        }
    }
}

// MARK: - Dashboard UI Components

private struct OverviewCard: View {
    let title: String
    let value: String
    let subtitle: String
    let iconName: String
    let iconColor: Color
    let chevronColor: Color
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack(alignment: .top) {
                Image(systemName: iconName)
                    .font(.body)
                    .foregroundColor(iconColor)
                    .frame(width: 36, height: 36)
                    .background(iconColor.opacity(0.12))
                    .clipShape(Circle())
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(title)
                        .font(.system(size: 12, weight: .semibold))
                    Text(value)
                        .font(.title.bold())
                        .foregroundColor(iconColor)
                }
                Spacer()
                Image(systemName: "chevron.right")
                    .font(.caption.bold())
                    .foregroundColor(chevronColor)
                    .padding(.top, 4)
            }
            Text(subtitle)
                .font(.system(size: 11))
                .foregroundColor(.secondary)
                .lineLimit(1)
                .minimumScaleFactor(0.8)
        }
        .padding(14)
        .background(Color(UIColor.systemBackground))
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.04), radius: 6, x: 0, y: 2)
    }
}

private struct QuickActionButton: View {
    let icon: String
    let title: String
    
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(.blue)
                .frame(width: 64, height: 64)
                .background(Color.blue.opacity(0.1))
                .cornerRadius(20)
            
            Text(title)
                .font(.system(size: 12, weight: .bold))
                .foregroundColor(.primary)
        }
    }
}

private struct AIInsightRow: View {
    let icon: String
    let iconColor: Color
    let title: String
    let badge: String
    let badgeColor: Color
    let subtitle: String
    
    var body: some View {
        HStack(alignment: .top, spacing: 16) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundColor(iconColor)
                .frame(width: 44, height: 44)
                .background(iconColor.opacity(0.1))
                .cornerRadius(12)
            
            VStack(alignment: .leading, spacing: 6) {
                HStack(spacing: 8) {
                    Text(title)
                        .font(.subheadline)
                        .fontWeight(.bold)
                        .lineLimit(1)
                    
                    Text(badge)
                        .font(.system(size: 9, weight: .black))
                        .foregroundColor(.white)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(badgeColor)
                        .cornerRadius(6)
                }
                
                Text(subtitle)
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .lineLimit(2)
            }
            
            Spacer()
            
            Image(systemName: "chevron.right")
                .font(.caption.bold())
                .foregroundColor(Color(UIColor.tertiaryLabel))
                .padding(.top, 14)
        }
        .padding(16)
        .background(Color(UIColor.systemBackground))
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.04), radius: 6, x: 0, y: 2)
    }
}

struct FleetListView: View {
    @StateObject private var supabase = SupabaseService.shared
    @State private var query = ""
    @State private var selection: FleetStatus?

    private var filtered: [Vehicle] {
        supabase.vehicles.filter { vehicle in
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
                if supabase.isLoading {
                    HStack {
                        Spacer()
                        ProgressView("Loading vehicles...")
                            .padding()
                        Spacer()
                    }
                } else {
                    ForEach(filtered) { vehicle in
                        NavigationLink {
                            VehicleDetailView(vehicle: vehicle)
                        } label: {
                            VehicleRow(vehicle: vehicle)
                        }
                    }
                }
            }
        }
        .searchable(text: $query, prompt: "Vehicle or registration")
        .navigationTitle("Fleet")
        .overlay {
            if !supabase.isLoading && filtered.isEmpty {
                EmptyStateView(title: "No vehicles found", message: "Try another search or clear the status filter.", symbol: "car.2")
            }
        }
        .task {
            // Fetch real live data from Supabase!
            if supabase.vehicles.isEmpty {
                await supabase.fetchVehicles()
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
