import Charts
import MapKit
import SwiftData
import SwiftUI

// MARK: - Tab Shell

struct FleetManagerTabView: View {
    var body: some View {
        TabView {
            Tab("Home", systemImage: "house.fill") {
                NavigationStack { FleetManagerHomeView() }
            }
            Tab("Vehicle", systemImage: "car.fill") {
                NavigationStack { FleetManagerVehicleView() }
            }
            Tab("Trip", systemImage: "point.topleft.down.to.point.bottomright.curvepath") {
                NavigationStack { FleetManagerTripView() }
            }
            Tab("Communication", systemImage: "message.fill") {
                NavigationStack { FleetManagerCommunicationView() }
            }
        }
    }
}

// MARK: - Home

struct FleetManagerHomeView: View {
    @StateObject private var supabase = SupabaseService.shared

    @State private var showingAddDriver      = false
    @State private var showingAddMaintenance = false
    @State private var showingAddVehicle     = false
    @State private var showingAddTrip        = false
    @State private var showingDriversList    = false
    @State private var showingVehiclesList   = false
    @State private var showingTripsList      = false
    @State private var showingMaintenanceList = false

    // Sample driver locations spread across Indian cities
    private let driverLocations: [DriverMapPin] = [
        DriverMapPin(name: "Amit Singh",   status: .onTrip,    coordinate: CLLocationCoordinate2D(latitude: 19.0760, longitude: 72.8777)),  // Mumbai
        DriverMapPin(name: "Suresh Reddy", status: .onTrip,    coordinate: CLLocationCoordinate2D(latitude: 17.3850, longitude: 78.4867)),  // Hyderabad
        DriverMapPin(name: "Rahul Mehta",  status: .onTrip,    coordinate: CLLocationCoordinate2D(latitude: 12.9716, longitude: 77.5946)),  // Bengaluru
        DriverMapPin(name: "Rajesh Kumar", status: .available, coordinate: CLLocationCoordinate2D(latitude: 28.7041, longitude: 77.1025)),  // Delhi
        DriverMapPin(name: "Vikram Patel", status: .offline,   coordinate: CLLocationCoordinate2D(latitude: 23.0225, longitude: 72.5714))   // Ahmedabad
    ]

    // Map region centred on India
    @State private var mapRegion = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 20.5937, longitude: 78.9629),
        span: MKCoordinateSpan(latitudeDelta: 18, longitudeDelta: 18)
    )

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: FleetSpacing.xLarge) {

                // ── Greeting ──────────────────────────────────────────────
                Text("Good morning")
                    .font(.largeTitle.bold())
                    .accessibilityAddTraits(.isHeader)

                // ── Overview label + 2×2 grid ─────────────────────────────
                Text("Overview")
                    .font(.title3.bold())

                LazyVGrid(
                    columns: [GridItem(.flexible(), spacing: 12),
                              GridItem(.flexible(), spacing: 12)],
                    spacing: 12
                ) {
                    OverviewCard(
                        title: "Drivers",
                        value: "\(supabase.drivers.count)",
                        detail: "total drivers",
                        symbol: "person.2.fill",
                        tint: .brandPrimary
                    ) { showingDriversList = true }

                    OverviewCard(
                        title: "Vehicles",
                        value: "\(supabase.vehicles.count)",
                        detail: "total vehicles",
                        symbol: "car.2.fill",
                        tint: .green
                    ) { showingVehiclesList = true }

                    OverviewCard(
                        title: "Trips",
                        value: "\(supabase.trips.count)",
                        detail: "total trips",
                        symbol: "clock.badge.checkmark.fill",
                        tint: .orange
                    ) { showingTripsList = true }

                    OverviewCard(
                        title: "Maintenance",
                        value: "\(supabase.technicians.count)",
                        detail: "personnel",
                        symbol: "wrench.and.screwdriver.fill",
                        tint: .purple
                    ) { showingMaintenanceList = true }
                }

                // ── Live Driver Locations ─────────────────────────────────
                VStack(alignment: .leading, spacing: FleetSpacing.medium) {
                    HStack {
                        VStack(alignment: .leading, spacing: 2) {
                            Text("Live Driver Locations")
                                .font(.title3.bold())
                            Text("\(supabase.trips.filter { $0.status == .active }.count) drivers currently on trip")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                        Spacer()
                        // live pulse dot
                        Circle()
                            .fill(.green)
                            .frame(width: 8, height: 8)
                            .overlay(Circle().stroke(.green.opacity(0.4), lineWidth: 4))
                        Text("Live")
                            .font(.caption.weight(.semibold))
                            .foregroundStyle(.green)
                    }

                    Map(coordinateRegion: $mapRegion, annotationItems: driverLocations) { pin in
                        MapAnnotation(coordinate: pin.coordinate) {
                            DriverMapAnnotationView(pin: pin)
                        }
                    }
                    .frame(height: 260)
                    .clipShape(RoundedRectangle(cornerRadius: FleetRadius.card))
                    .overlay(
                        RoundedRectangle(cornerRadius: FleetRadius.card)
                            .stroke(Color.secondary.opacity(0.15), lineWidth: 1)
                    )

                    // Legend row
                    HStack(spacing: FleetSpacing.large) {
                        MapLegendItem(color: .blue,  label: "On Trip")
                        MapLegendItem(color: .green, label: "Available")
                        MapLegendItem(color: .gray,  label: "Offline")
                    }
                }
                .padding(FleetSpacing.large)
                .background(.background.secondary,
                            in: .rect(cornerRadius: FleetRadius.card))

                // ── Quick Actions ─────────────────────────────────────────
                VStack(alignment: .leading, spacing: 12) {
                    Text("Quick Actions")
                        .font(.title3.bold())

                    HStack(spacing: 12) {
                        ManagerQuickAction(
                            title: "Add\nDriver",
                            symbol: "person.badge.plus",
                            color: .blue
                        ) { showingAddDriver = true }

                        ManagerQuickAction(
                            title: "Add\nVehicle",
                            symbol: "car.fill",
                            color: .green
                        ) { showingAddVehicle = true }

                        ManagerQuickAction(
                            title: "Add\nTrip",
                            symbol: "point.topleft.down.to.point.bottomright.curvepath",
                            color: .orange
                        ) { showingAddTrip = true }

                        ManagerQuickAction(
                            title: "Add\nMaintenance",
                            symbol: "wrench.and.screwdriver.fill",
                            color: .purple
                        ) { showingAddMaintenance = true }
                    }
                }
            }
            .padding(FleetSpacing.large)
        }
        .background(Color.appBackground)
        .navigationTitle("Home")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                NavigationLink {
                    FleetManagerProfileView()
                } label: {
                    Image(systemName: "person.crop.circle.fill")
                        .font(.title2)
                }
                .accessibilityLabel("Profile")
            }
        }
        // Add sheets
        .sheet(isPresented: $showingAddDriver)       { AddDriverSheet() }
        .sheet(isPresented: $showingAddMaintenance)  { AddMaintenanceSheet() }
        .sheet(isPresented: $showingAddVehicle)      { AddVehicleSheet() }
        .sheet(isPresented: $showingAddTrip)         { AddTripSheet() }
        .sheet(isPresented: $showingDriversList)     { DriversListSheet(drivers: supabase.drivers) }
        .sheet(isPresented: $showingVehiclesList)    { VehiclesListSheet(vehicles: supabase.vehicles) }
        .sheet(isPresented: $showingTripsList)       { TripsListSheet(trips: supabase.trips) }
        .sheet(isPresented: $showingMaintenanceList) { MaintenanceListSheet(maintenance: supabase.technicians) }
    }
}

// MARK: - Overview Card (2×2 grid tile with chevron)

private struct OverviewCard: View {
    let title: String
    let value: String
    let detail: String
    let symbol: String
    let tint: Color
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(alignment: .leading, spacing: FleetSpacing.medium) {
                HStack {
                    Image(systemName: symbol)
                        .font(.title2)
                        .foregroundStyle(tint)
                        .symbolRenderingMode(.hierarchical)
                        .accessibilityHidden(true)
                    Spacer()
                    Image(systemName: "chevron.right")
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(.secondary)
                }
                Text(value)
                    .font(.title2.bold())
                    .foregroundStyle(.primary)
                    .contentTransition(.numericText())
                Text(title)
                    .font(.headline)
                    .foregroundStyle(.primary)
                Text(detail)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            // Fixed height so all four tiles are identical
            .frame(maxWidth: .infinity, minHeight: 120, alignment: .leading)
            .padding(FleetSpacing.large)
            .background(.background.secondary,
                        in: .rect(cornerRadius: FleetRadius.card))
        }
        .buttonStyle(.plain)
        .accessibilityElement(children: .combine)
        .accessibilityHint("Tap to view \(title)")
    }
}

// MARK: - Map annotation model

private struct DriverMapPin: Identifiable {
    let id = UUID()
    let name: String
    let status: DriverStatus
    let coordinate: CLLocationCoordinate2D

    var pinColor: Color {
        switch status {
        case .onTrip:    return .blue
        case .available: return .green
        case .offline:   return .gray
        }
    }
}

// MARK: - Map annotation view

private struct DriverMapAnnotationView: View {
    let pin: DriverMapPin
    @State private var showLabel = false

    var body: some View {
        VStack(spacing: 2) {
            if showLabel {
                Text(pin.name)
                    .font(.caption2.weight(.semibold))
                    .padding(.horizontal, 6)
                    .padding(.vertical, 3)
                    .background(.regularMaterial, in: Capsule())
                    .shadow(radius: 2)
                    .transition(.scale.combined(with: .opacity))
            }

            ZStack {
                Circle()
                    .fill(pin.pinColor.opacity(0.25))
                    .frame(width: 32, height: 32)
                Circle()
                    .fill(pin.pinColor)
                    .frame(width: 18, height: 18)
                Image(systemName: "person.fill")
                    .font(.system(size: 9, weight: .bold))
                    .foregroundStyle(.white)
            }
        }
        .onTapGesture {
            withAnimation(.spring(duration: 0.25)) { showLabel.toggle() }
        }
        .accessibilityLabel("\(pin.name), \(pin.status.rawValue)")
    }
}

// MARK: - Map legend helper

private struct MapLegendItem: View {
    let color: Color
    let label: String

    var body: some View {
        HStack(spacing: 4) {
            Circle().fill(color).frame(width: 8, height: 8)
            Text(label).font(.caption).foregroundStyle(.secondary)
        }
    }
}

// MARK: - Quick Action tile

private struct ManagerQuickAction: View {
    let title: String
    let symbol: String
    let color: Color
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                Image(systemName: symbol)
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundStyle(.white)
                    .frame(width: 44, height: 44)
                    .background(color, in: Circle())

                Text(title)
                    .font(.caption)
                    .multilineTextAlignment(.center)
                    .foregroundStyle(.primary)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 14)
            .background(Color(.secondarySystemGroupedBackground),
                        in: RoundedRectangle(cornerRadius: 12))
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Supporting cards (kept from original)

struct DriverLocationCard: View {
    let driver: Driver

    var body: some View {
        HStack(spacing: FleetSpacing.medium) {
            Image(systemName: "person.circle.fill")
                .font(.title2)
                .foregroundStyle(.brandPrimary)
                .frame(width: 44, height: 44)
            VStack(alignment: .leading, spacing: FleetSpacing.xSmall) {
                Text(driver.name).font(.headline)
                Text("On Trip").font(.subheadline).foregroundStyle(.green)
            }
            Spacer()
            Image(systemName: "location.fill").foregroundStyle(.red)
        }
        .padding(.vertical, FleetSpacing.small)
        .fleetCard()
    }
}

struct DriverAssignmentCard: View {
    let driver: Driver
    let vehicles: [Vehicle]
    let trips: [FleetTrip]
    let onAssign: (Vehicle, FleetTrip) -> Void

    @State private var selectedVehicleID: UUID?
    @State private var selectedTripID: UUID?

    private var selectedVehicle: Vehicle? { vehicles.first { $0.id == selectedVehicleID } }
    private var selectedTrip: FleetTrip?  { trips.first   { $0.id == selectedTripID   } }

    var body: some View {
        VStack(alignment: .leading, spacing: FleetSpacing.medium) {
            HStack(spacing: FleetSpacing.medium) {
                Image(systemName: "person.circle.fill")
                    .font(.title2)
                    .foregroundStyle(.brandPrimary)
                    .frame(width: 44, height: 44)
                VStack(alignment: .leading, spacing: FleetSpacing.xSmall) {
                    Text(driver.name).font(.headline)
                    Text(driver.licenseNumber).font(.caption).foregroundStyle(.secondary)
                }
            }

            Picker("Vehicle", selection: $selectedVehicleID) {
                Text("Select Vehicle").tag(nil as UUID?)
                ForEach(vehicles) { v in Text(v.name).tag(v.id as UUID?) }
            }
            .pickerStyle(.menu)

            Picker("Trip", selection: $selectedTripID) {
                Text("Select Trip").tag(nil as UUID?)
                ForEach(trips) { t in Text(t.title).tag(t.id as UUID?) }
            }
            .pickerStyle(.menu)

            if let sv = selectedVehicle, let st = selectedTrip {
                Button("Assign") { onAssign(sv, st) }
                    .buttonStyle(.borderedProminent)
                    .frame(maxWidth: .infinity)
            }
        }
        .padding(.vertical, FleetSpacing.small)
    }
}

// MARK: - Add sheets

struct AddDriverSheet: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    @State private var name = ""
    @State private var phone = ""
    @State private var licenseNumber = ""

    var body: some View {
        NavigationStack {
            Form {
                Section("Driver Information") {
                    TextField("Name", text: $name)
                    TextField("Phone", text: $phone)
                    TextField("License Number", text: $licenseNumber)
                }
            }
            .navigationTitle("Add Driver")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) { Button("Cancel") { dismiss() } }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Add") {
                        modelContext.insert(Driver(name: name, phone: phone, licenseNumber: licenseNumber, status: .available))
                        dismiss()
                    }
                    .disabled(name.isEmpty || phone.isEmpty || licenseNumber.isEmpty)
                }
            }
        }
    }
}

struct AddMaintenanceSheet: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    @State private var name = ""
    @State private var phone = ""
    @State private var specialization = ""

    var body: some View {
        NavigationStack {
            Form {
                Section("Maintenance Personnel Information") {
                    TextField("Name", text: $name)
                    TextField("Phone", text: $phone)
                    TextField("Specialization", text: $specialization)
                }
            }
            .navigationTitle("Add Maintenance Personnel")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) { Button("Cancel") { dismiss() } }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Add") {
                        modelContext.insert(MaintenancePersonnel(name: name, phone: phone, specialization: specialization, status: .available))
                        dismiss()
                    }
                    .disabled(name.isEmpty || phone.isEmpty || specialization.isEmpty)
                }
            }
        }
    }
}

struct AddVehicleSheet: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    @State private var name = ""
    @State private var registration = ""
    @State private var make = ""
    @State private var model = ""
    @State private var year = ""
    @State private var odometer = ""
    @State private var selectedVehicleType: VehicleType = .truck

    var body: some View {
        NavigationStack {
            Form {
                Section("Vehicle Information") {
                    TextField("Vehicle Name", text: $name)
                    TextField("Registration Number", text: $registration)
                    TextField("Make", text: $make)
                    TextField("Model", text: $model)
                    TextField("Year", text: $year).keyboardType(.numberPad)
                    TextField("Odometer (km)", text: $odometer).keyboardType(.decimalPad)
                    Picker("Vehicle Type", selection: $selectedVehicleType) {
                        ForEach(VehicleType.allCases) { type in
                            Text(type.rawValue.capitalized).tag(type)
                        }
                    }
                }
            }
            .navigationTitle("Add Vehicle")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) { Button("Cancel") { dismiss() } }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Add") {
                        modelContext.insert(Vehicle(name: name, registration: registration, make: make, model: model,
                                                    year: Int(year) ?? 2024, odometer: Double(odometer) ?? 0,
                                                    status: .scheduled, vehicleType: selectedVehicleType))
                        dismiss()
                    }
                    .disabled(name.isEmpty || registration.isEmpty || make.isEmpty || model.isEmpty || year.isEmpty || odometer.isEmpty)
                }
            }
        }
    }
}

struct AddTripSheet: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    @State private var title = ""
    @State private var reference = ""
    @State private var origin = ""
    @State private var destination = ""
    @State private var scheduledDate = Date()
    @State private var distance = ""

    var body: some View {
        NavigationStack {
            Form {
                Section("Trip Information") {
                    TextField("Trip Title", text: $title)
                    TextField("Reference Number", text: $reference)
                    TextField("Origin", text: $origin)
                    TextField("Destination", text: $destination)
                    DatePicker("Scheduled Time", selection: $scheduledDate)
                    TextField("Distance (km)", text: $distance).keyboardType(.decimalPad)
                }
            }
            .navigationTitle("Add Trip")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) { Button("Cancel") { dismiss() } }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Add") {
                        modelContext.insert(FleetTrip(title: title, reference: reference, origin: origin,
                                                      destination: destination, scheduledAt: scheduledDate,
                                                      status: .scheduled, distanceKilometers: Double(distance) ?? 0))
                        dismiss()
                    }
                    .disabled(title.isEmpty || origin.isEmpty || destination.isEmpty || distance.isEmpty)
                }
            }
        }
    }
}

// MARK: - Edit Vehicle Sheet

struct EditVehicleSheet: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    let vehicle: Vehicle

    @State private var vehicleName: String
    @State private var registration: String
    @State private var make: String
    @State private var model: String
    @State private var year: String
    @State private var odometer: String
    @State private var selectedVehicleType: VehicleType
    @State private var selectedStatus: FleetStatus
    @State private var showingAddDocument = false
    @State private var newDocumentName = ""
    @State private var newDocumentType = "Registration"
    @State private var documents: [(name: String, type: String, date: Date)] = []

    private let documentTypes = ["Registration","Insurance","Pollution Certificate","Fitness Certificate","Permit","Other"]

    init(vehicle: Vehicle) {
        self.vehicle = vehicle
        _vehicleName        = State(initialValue: vehicle.name)
        _registration       = State(initialValue: vehicle.registration)
        _make               = State(initialValue: vehicle.make)
        _model              = State(initialValue: vehicle.model)
        _year               = State(initialValue: String(vehicle.year))
        _odometer           = State(initialValue: String(vehicle.odometer))
        _selectedVehicleType = State(initialValue: vehicle.vehicleType)
        _selectedStatus     = State(initialValue: vehicle.status)
    }

    var body: some View {
        NavigationStack {
            Form {
                Section("Vehicle Details") {
                    TextField("Vehicle Name", text: $vehicleName)
                    TextField("Registration Number", text: $registration)
                    TextField("Make", text: $make)
                    TextField("Model", text: $model)
                    TextField("Year", text: $year).keyboardType(.numberPad)
                    TextField("Odometer (km)", text: $odometer).keyboardType(.decimalPad)
                    Picker("Vehicle Type", selection: $selectedVehicleType) {
                        ForEach(VehicleType.allCases) { type in Text(type.rawValue.capitalized).tag(type) }
                    }
                    Picker("Status", selection: $selectedStatus) {
                        ForEach(FleetStatus.allCases) { s in Text(s.rawValue).tag(s) }
                    }
                }
                Section("Documents") {
                    if documents.isEmpty {
                        Text("No documents added").foregroundStyle(.secondary)
                    } else {
                        ForEach(documents.indices, id: \.self) { i in
                            HStack {
                                VStack(alignment: .leading) {
                                    Text(documents[i].name).font(.headline)
                                    Text(documents[i].type).font(.caption).foregroundStyle(.secondary)
                                }
                                Spacer()
                                Text(documents[i].date, format: .dateTime.day().month().year())
                                    .font(.caption).foregroundStyle(.secondary)
                            }
                        }
                        .onDelete { documents.remove(atOffsets: $0) }
                    }
                    Button("Add Document") { showingAddDocument = true }
                }
            }
            .navigationTitle("Edit Vehicle")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) { Button("Cancel") { dismiss() } }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") {
                        vehicle.name = vehicleName; vehicle.registration = registration
                        vehicle.make = make;        vehicle.model = model
                        vehicle.year = Int(year) ?? vehicle.year
                        vehicle.odometer = Double(odometer) ?? vehicle.odometer
                        vehicle.vehicleType = selectedVehicleType
                        vehicle.status = selectedStatus
                        dismiss()
                    }
                }
            }
            .sheet(isPresented: $showingAddDocument) {
                NavigationStack {
                    Form {
                        Section("Document Information") {
                            TextField("Document Name", text: $newDocumentName)
                            Picker("Document Type", selection: $newDocumentType) {
                                ForEach(documentTypes, id: \.self) { Text($0).tag($0) }
                            }
                        }
                    }
                    .navigationTitle("Add Document")
                    .navigationBarTitleDisplayMode(.inline)
                    .toolbar {
                        ToolbarItem(placement: .cancellationAction) {
                            Button("Cancel") { newDocumentName = ""; showingAddDocument = false }
                        }
                        ToolbarItem(placement: .confirmationAction) {
                            Button("Add") {
                                documents.append((name: newDocumentName, type: newDocumentType, date: Date()))
                                newDocumentName = ""; showingAddDocument = false
                            }
                            .disabled(newDocumentName.isEmpty)
                        }
                    }
                }
            }
        }
        .onAppear {
            if documents.isEmpty {
                documents = [
                    (name: "Vehicle Registration", type: "Registration", date: Date().addingTimeInterval(-86_400*365)),
                    (name: "Insurance Policy",     type: "Insurance",     date: Date().addingTimeInterval(-86_400*180))
                ]
            }
        }
    }
}

// MARK: - Vehicle Tab

struct FleetManagerVehicleView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var vehicles: [Vehicle]
    @State private var query = ""
    @State private var selection: FleetStatus?
    @State private var selectedVehicle: Vehicle?

    private var filtered: [Vehicle] {
        vehicles.filter {
            (query.isEmpty || $0.name.localizedStandardContains(query) || $0.registration.localizedStandardContains(query))
            && (selection == nil || $0.status == selection)
        }
    }

    var body: some View {
        List {
            Section {
                Picker("Status", selection: $selection) {
                    Text("All").tag(FleetStatus?.none)
                    ForEach(FleetStatus.allCases, id: \.self) { Text($0.rawValue).tag(Optional($0)) }
                }
                .pickerStyle(.menu)
            }
            Section("Vehicles") {
                ForEach(filtered) { vehicle in
                    Button { selectedVehicle = vehicle } label: {
                        HStack(spacing: FleetSpacing.medium) {
                            Image(systemName: vehicle.vehicleType.symbolName)
                                .font(.title2).foregroundStyle(.brandPrimary)
                                .frame(width: 44, height: 44)
                                .background(.brandPrimary.opacity(0.12), in: .circle)
                                .accessibilityHidden(true)
                            VStack(alignment: .leading, spacing: FleetSpacing.xSmall) {
                                Text(vehicle.name).font(.headline)
                                Text(vehicle.registration).font(.subheadline).foregroundStyle(.secondary)
                                StatusBadge(status: vehicle.status)
                            }
                            Spacer()
                            Image(systemName: "chevron.right").foregroundStyle(.secondary)
                        }
                        .padding(.vertical, FleetSpacing.xSmall)
                    }
                    .buttonStyle(.plain)
                }
            }
        }
        .searchable(text: $query, prompt: "Vehicle or registration")
        .navigationTitle("Vehicle")
        .overlay {
            if filtered.isEmpty {
                EmptyStateView(title: "No vehicles found", message: "Try another search or clear the filter.", symbol: "car.2")
            }
        }
        .sheet(item: $selectedVehicle) { EditVehicleSheet(vehicle: $0) }
    }
}

// MARK: - Trip Tab

struct FleetManagerTripView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var trips: [FleetTrip]
    @State private var query = ""
    @State private var selection: FleetStatus?

    private var filtered: [FleetTrip] {
        trips.filter {
            (query.isEmpty || $0.title.localizedStandardContains(query) || $0.reference.localizedStandardContains(query))
            && (selection == nil || $0.status == selection)
        }
    }

    var body: some View {
        List {
            Section {
                Picker("Status", selection: $selection) {
                    Text("All").tag(FleetStatus?.none)
                    ForEach(FleetStatus.allCases, id: \.self) { Text($0.rawValue).tag(Optional($0)) }
                }
                .pickerStyle(.menu)
            }
            Section("Trips") {
                ForEach(filtered) { trip in
                    NavigationLink { TripDetailView(trip: trip) } label: { TripRow(trip: trip) }
                }
            }
        }
        .searchable(text: $query, prompt: "Trip or reference")
        .navigationTitle("Trip")
        .overlay {
            if filtered.isEmpty {
                EmptyStateView(title: "No trips found", message: "Try another search or clear the filter.",
                               symbol: "point.topleft.down.to.point.bottomright.curvepath")
            }
        }
    }
}

// MARK: - Communication Tab

struct FleetManagerCommunicationView: View {
    @Query private var drivers: [Driver]
    @Query private var maintenance: [MaintenancePersonnel]
    @State private var searchText = ""

    private let conversations = [
        ("Operations",       "Dock 4 is ready for arrival.",                  "2m",  true),
        ("Maintenance Team", "The inspection photos are attached.",            "1h",  false),
        ("Atlas 12 Driver",  "Traffic delay near Lonavala.",                   "3h",  true),
        ("Orion 07 Driver",  "Vehicle inspection completed successfully.",     "5h",  false),
        ("Nova 19 Driver",   "Starting trip to Pune DC.",                      "6h",  true),
        ("Suresh Mechanic",  "Brake parts ordered, arriving tomorrow.",        "1d",  false),
        ("Ravi Electrician", "Wiring issue resolved in Atlas 12.",             "2d",  false),
        ("Dispatch Team",    "Route optimization updated for TRP-101.",        "3h",  false)
    ]

    var body: some View {
        List {
            Section("Recent Conversations") {
                ForEach(conversations, id: \.0) { item in
                    NavigationLink { ChatDetailView(title: item.0) } label: {
                        HStack(spacing: FleetSpacing.medium) {
                            ZStack(alignment: .topTrailing) {
                                Image(systemName: "person.2.circle.fill")
                                    .font(.largeTitle).foregroundStyle(.brandSecondary)
                                if item.3 { Circle().fill(.blue).frame(width: 10, height: 10).accessibilityHidden(true) }
                            }
                            VStack(alignment: .leading, spacing: FleetSpacing.xSmall) {
                                HStack {
                                    Text(item.0).font(.headline)
                                    Spacer()
                                    Text(item.2).font(.caption).foregroundStyle(.secondary)
                                }
                                Text(item.1).font(.subheadline).foregroundStyle(.secondary).lineLimit(1)
                            }
                        }
                        .padding(.vertical, FleetSpacing.xSmall)
                        .accessibilityValue(item.3 ? "Unread" : "Read")
                    }
                }
            }
            Section("Quick Contacts – Maintenance") {
                ForEach(maintenance) { p in
                    ContactRow(name: p.name, phone: p.phone, detail: p.specialization,
                               status: p.status.rawValue, icon: "wrench.and.screwdriver")
                }
            }
            Section("Quick Contacts – Drivers") {
                ForEach(drivers) { d in
                    ContactRow(name: d.name, phone: d.phone, detail: d.licenseNumber,
                               status: d.status.rawValue, icon: "person.circle.fill")
                }
            }
        }
        .searchable(text: $searchText, prompt: "Search conversations")
        .navigationTitle("Communication")
    }
}

private struct ChatDetailView: View {
    let title: String
    @State private var message = ""

    var body: some View {
        VStack {
            ScrollView {
                VStack(alignment: .leading, spacing: FleetSpacing.medium) {
                    Text("Dock 4 is ready for arrival.")
                        .padding()
                        .background(.background.secondary, in: .rect(cornerRadius: FleetRadius.card))
                    Text("Thanks — estimated arrival is 2:10 PM.")
                        .padding().foregroundStyle(.white)
                        .background(.brandPrimary, in: .rect(cornerRadius: FleetRadius.card))
                        .frame(maxWidth: .infinity, alignment: .trailing)
                }
                .padding()
            }
            HStack {
                Button("", systemImage: "camera.fill") {}.accessibilityLabel("Attach photo")
                TextField("Message", text: $message).textFieldStyle(.roundedBorder)
                Button("", systemImage: "arrow.up.circle.fill") {}
                    .font(.title2).accessibilityLabel("Send").disabled(message.isEmpty)
            }
            .padding().background(.bar)
        }
        .navigationTitle(title)
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct ContactRow: View {
    let name: String
    let phone: String
    let detail: String
    let status: String
    let icon: String

    var body: some View {
        HStack(spacing: FleetSpacing.medium) {
            Image(systemName: icon).font(.title2).foregroundStyle(.brandPrimary)
                .frame(width: 44, height: 44).background(.brandPrimary.opacity(0.12), in: .circle)
            VStack(alignment: .leading, spacing: FleetSpacing.xSmall) {
                Text(name).font(.headline)
                Text(detail).font(.caption).foregroundStyle(.secondary)
            }
            Spacer()
            VStack(alignment: .trailing, spacing: FleetSpacing.xSmall) {
                Text(status).font(.caption).foregroundStyle(.secondary)
                Link(destination: URL(string: "tel:\(phone)")!) {
                    Image(systemName: "phone.fill").foregroundStyle(.brandPrimary)
                }
            }
        }
        .padding(.vertical, FleetSpacing.xSmall)
    }
}

// MARK: - List Sheets

struct DriversListSheet: View {
    let drivers: [Driver]
    @Environment(\.dismiss) private var dismiss
    @State private var selectedStatus: DriverStatus?

    private var filtered: [Driver] {
        selectedStatus == nil ? drivers : drivers.filter { $0.status == selectedStatus }
    }
    private func color(for s: DriverStatus) -> Color {
        switch s { case .available: .green; case .onTrip: .blue; case .offline: .gray }
    }

    var body: some View {
        NavigationStack {
            List {
                Section {
                    Picker("Filter by Status", selection: $selectedStatus) {
                        Text("All").tag(DriverStatus?.none)
                        ForEach(DriverStatus.allCases) { Text($0.rawValue).tag(Optional($0)) }
                    }.pickerStyle(.menu)
                }
                Section("Drivers") {
                    ForEach(filtered) { d in
                        HStack(spacing: FleetSpacing.medium) {
                            Image(systemName: "person.circle.fill").font(.title2).foregroundStyle(.brandPrimary)
                            VStack(alignment: .leading) {
                                Text(d.name).font(.headline)
                                Text(d.licenseNumber).font(.caption).foregroundStyle(.secondary)
                            }
                            Spacer()
                            StatusBadge(text: d.status.rawValue, color: color(for: d.status))
                        }
                    }
                }
            }
            .navigationTitle("Drivers").navigationBarTitleDisplayMode(.inline)
            .toolbar { ToolbarItem(placement: .cancellationAction) { Button("Close") { dismiss() } } }
        }
    }
}

struct VehiclesListSheet: View {
    let vehicles: [Vehicle]
    @Environment(\.dismiss) private var dismiss
    @State private var selectedStatus: FleetStatus?

    private var filtered: [Vehicle] {
        selectedStatus == nil ? vehicles : vehicles.filter { $0.status == selectedStatus }
    }

    var body: some View {
        NavigationStack {
            List {
                Section {
                    Picker("Filter by Status", selection: $selectedStatus) {
                        Text("All").tag(FleetStatus?.none)
                        ForEach(FleetStatus.allCases) { Text($0.rawValue).tag(Optional($0)) }
                    }.pickerStyle(.menu)
                }
                Section("Vehicles") {
                    ForEach(filtered, id: \.id) { v in
                        HStack(spacing: FleetSpacing.medium) {
                            Image(systemName: v.vehicleType.symbolName).font(.title2).foregroundStyle(.brandPrimary)
                            VStack(alignment: .leading) {
                                Text(v.name).font(.headline)
                                Text(v.registration).font(.caption).foregroundStyle(.secondary)
                            }
                            Spacer()
                            StatusBadge(status: v.status)
                        }
                    }
                }
            }
            .navigationTitle("Vehicles").navigationBarTitleDisplayMode(.inline)
            .toolbar { ToolbarItem(placement: .cancellationAction) { Button("Close") { dismiss() } } }
        }
    }
}

struct TripsListSheet: View {
    let trips: [FleetTrip]
    @Environment(\.dismiss) private var dismiss
    @State private var selectedStatus: FleetStatus?

    private var filtered: [FleetTrip] {
        selectedStatus == nil ? trips : trips.filter { $0.status == selectedStatus }
    }

    var body: some View {
        NavigationStack {
            List {
                Section {
                    Picker("Filter by Status", selection: $selectedStatus) {
                        Text("All").tag(FleetStatus?.none)
                        ForEach(FleetStatus.allCases) { Text($0.rawValue).tag(Optional($0)) }
                    }.pickerStyle(.menu)
                }
                Section("Trips") {
                    ForEach(filtered, id: \.id) { trip in
                        HStack(spacing: FleetSpacing.medium) {
                            Image(systemName: "point.topleft.down.to.point.bottomright.curvepath")
                                .font(.title2).foregroundStyle(.brandPrimary)
                            VStack(alignment: .leading) {
                                Text(trip.title).font(.headline)
                                Text("\(trip.origin) → \(trip.destination)").font(.caption).foregroundStyle(.secondary)
                            }
                            Spacer()
                            StatusBadge(status: trip.status)
                        }
                    }
                }
            }
            .navigationTitle("Trips").navigationBarTitleDisplayMode(.inline)
            .toolbar { ToolbarItem(placement: .cancellationAction) { Button("Close") { dismiss() } } }
        }
    }
}

struct MaintenanceListSheet: View {
    let maintenance: [MaintenancePersonnel]
    @Environment(\.dismiss) private var dismiss
    @State private var selectedStatus: MaintenanceStatus?

    private var filtered: [MaintenancePersonnel] {
        selectedStatus == nil ? maintenance : maintenance.filter { $0.status == selectedStatus }
    }
    private func color(for s: MaintenanceStatus) -> Color {
        switch s { case .available: .green; case .busy: .orange; case .offline: .gray }
    }

    var body: some View {
        NavigationStack {
            List {
                Section {
                    Picker("Filter by Status", selection: $selectedStatus) {
                        Text("All").tag(MaintenanceStatus?.none)
                        ForEach(MaintenanceStatus.allCases) { Text($0.rawValue).tag(Optional($0)) }
                    }.pickerStyle(.menu)
                }
                Section("Maintenance Personnel") {
                    ForEach(filtered) { p in
                        HStack(spacing: FleetSpacing.medium) {
                            Image(systemName: "wrench.and.screwdriver").font(.title2).foregroundStyle(.brandPrimary)
                            VStack(alignment: .leading) {
                                Text(p.name).font(.headline)
                                Text(p.specialization).font(.caption).foregroundStyle(.secondary)
                            }
                            Spacer()
                            StatusBadge(text: p.status.rawValue, color: color(for: p.status))
                        }
                    }
                }
            }
            .navigationTitle("Maintenance").navigationBarTitleDisplayMode(.inline)
            .toolbar { ToolbarItem(placement: .cancellationAction) { Button("Close") { dismiss() } } }
        }
    }
}

// MARK: - Profile

struct FleetManagerProfileView: View {
    @Environment(SessionStore.self) private var session

    var body: some View {
        @Bindable var session = session
        Form {
            Section("Profile") {
                HStack {
                    Image(systemName: "person.crop.circle.fill").font(.largeTitle).foregroundStyle(.brandPrimary)
                    VStack(alignment: .leading) {
                        Text("Fleet Manager").font(.headline)
                        Text("manager@fleetcare.com").font(.caption).foregroundStyle(.secondary)
                    }
                }
            }
            Section("Workspace") {
                Picker("Preview role", selection: $session.selectedRole) {
                    ForEach(UserRole.allCases) { Label($0.rawValue, systemImage: $0.symbol).tag($0) }
                }
                Toggle("Simulate offline mode", isOn: $session.isOffline)
            }
            Section("Security") {
                Label("Passkey enabled",          systemImage: "key.fill")
                Label("Face ID enabled",           systemImage: "faceid")
                Label("Data encrypted on device",  systemImage: "lock.shield.fill")
            }
            Section { Button("Sign Out", role: .destructive) { session.signOut() } }
        }
        .navigationTitle("Profile")
    }
}

// StatusBadge(text:color:) init is in SharedComponents.swift
