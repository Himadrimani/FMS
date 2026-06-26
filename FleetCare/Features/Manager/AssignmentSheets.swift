import SwiftUI

// MARK: - Assign Trip Sheet

struct AssignTripSheet: View {
    @ObservedObject var supabase: SupabaseService
    @Environment(\.dismiss) private var dismiss

    @State private var selectedVehicle: Vehicle?
    @State private var selectedDriver: PersonnelDTO?
    @State private var origin = ""
    @State private var destination = ""
    @State private var distanceText = ""
    @State private var isSubmitting = false
    @State private var errorMessage: String?
    @State private var showSuccess = false

    var body: some View {
        NavigationStack {
            Form {
                // MARK: Vehicle Picker
                Section("Vehicle") {
                    if supabase.vehicles.isEmpty {
                        Label("No vehicles available", systemImage: "exclamationmark.triangle")
                            .foregroundStyle(.secondary)
                    } else {
                        Picker("Select Vehicle", selection: $selectedVehicle) {
                            Text("Choose a vehicle").tag(nil as Vehicle?)
                            ForEach(supabase.vehicles) { vehicle in
                                Text("\(vehicle.name) — \(vehicle.registration)")
                                    .tag(vehicle as Vehicle?)
                            }
                        }
                    }
                }

                // MARK: Driver Picker
                Section("Driver") {
                    if supabase.drivers.isEmpty {
                        Label("No drivers found in database", systemImage: "exclamationmark.triangle")
                            .foregroundStyle(.secondary)
                    } else {
                        Picker("Select Driver", selection: $selectedDriver) {
                            Text("Choose a driver").tag(nil as PersonnelDTO?)
                            ForEach(supabase.drivers) { driver in
                                Text(driver.email)
                                    .tag(driver as PersonnelDTO?)
                            }
                        }
                    }
                }

                // MARK: Trip Details
                Section("Trip Details") {
                    TextField("Origin (e.g. Mumbai Hub)", text: $origin)
                    TextField("Destination (e.g. Pune DC)", text: $destination)
                    TextField("Distance (km)", text: $distanceText)
                        .keyboardType(.decimalPad)
                }

                // MARK: Error / Success
                if let error = errorMessage {
                    Section {
                        Label(error, systemImage: "xmark.circle.fill")
                            .foregroundStyle(.red)
                    }
                }

                if showSuccess {
                    Section {
                        Label("Trip assigned successfully!", systemImage: "checkmark.circle.fill")
                            .foregroundStyle(.green)
                    }
                }

                // MARK: Submit
                Section {
                    Button {
                        submit()
                    } label: {
                        HStack {
                            if isSubmitting {
                                ProgressView()
                                    .tint(.white)
                            }
                            Text(isSubmitting ? "Assigning…" : "Assign Trip")
                                .font(.headline)
                        }
                        .frame(maxWidth: .infinity)
                    }
                    .disabled(!isFormValid || isSubmitting)
                }
            }
            .navigationTitle("Assign Trip")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
            }
        }
    }

    private var isFormValid: Bool {
        selectedVehicle != nil &&
        selectedDriver != nil &&
        !origin.isEmpty &&
        !destination.isEmpty &&
        Double(distanceText) != nil
    }

    private func submit() {
        guard let vehicle = selectedVehicle,
              let driver = selectedDriver,
              let distance = Double(distanceText) else { return }

        isSubmitting = true
        errorMessage = nil

        Task {
            do {
                try await supabase.assignTrip(
                    driverId: driver.id,
                    vehicleId: vehicle.id,
                    vehicleClass: vehicle.dbVehicleClass,
                    origin: origin,
                    destination: destination,
                    distance: distance
                )
                await MainActor.run {
                    showSuccess = true
                    isSubmitting = false
                }
                try? await Task.sleep(for: .seconds(1.5))
                await MainActor.run { dismiss() }
            } catch {
                await MainActor.run {
                    errorMessage = "Failed: \(error.localizedDescription)"
                    isSubmitting = false
                }
            }
        }
    }
}

// MARK: - Create Work Order Sheet

struct CreateWorkOrderSheet: View {
    @ObservedObject var supabase: SupabaseService
    @Environment(\.dismiss) private var dismiss

    @State private var selectedVehicle: Vehicle?
    @State private var selectedTech: PersonnelDTO?
    @State private var descriptionText = ""
    @State private var isSubmitting = false
    @State private var errorMessage: String?
    @State private var showSuccess = false

    var body: some View {
        NavigationStack {
            Form {
                // MARK: Vehicle Picker
                Section("Vehicle") {
                    if supabase.vehicles.isEmpty {
                        Label("No vehicles available", systemImage: "exclamationmark.triangle")
                            .foregroundStyle(.secondary)
                    } else {
                        Picker("Select Vehicle", selection: $selectedVehicle) {
                            Text("Choose a vehicle").tag(nil as Vehicle?)
                            ForEach(supabase.vehicles) { vehicle in
                                Text("\(vehicle.name) — \(vehicle.registration)")
                                    .tag(vehicle as Vehicle?)
                            }
                        }
                    }
                }

                // MARK: Technician Picker
                Section("Technician") {
                    if supabase.technicians.isEmpty {
                        Label("No technicians found in database", systemImage: "exclamationmark.triangle")
                            .foregroundStyle(.secondary)
                    } else {
                        Picker("Select Technician", selection: $selectedTech) {
                            Text("Choose a technician").tag(nil as PersonnelDTO?)
                            ForEach(supabase.technicians) { tech in
                                Text(tech.email)
                                    .tag(tech as PersonnelDTO?)
                            }
                        }
                    }
                }

                // MARK: Description
                Section("Work Order Details") {
                    TextField("Description (e.g. Brake pad replacement)", text: $descriptionText, axis: .vertical)
                        .lineLimit(3...5)
                }

                // MARK: Error / Success
                if let error = errorMessage {
                    Section {
                        Label(error, systemImage: "xmark.circle.fill")
                            .foregroundStyle(.red)
                    }
                }

                if showSuccess {
                    Section {
                        Label("Work order created successfully!", systemImage: "checkmark.circle.fill")
                            .foregroundStyle(.green)
                    }
                }

                // MARK: Submit
                Section {
                    Button {
                        submit()
                    } label: {
                        HStack {
                            if isSubmitting {
                                ProgressView()
                                    .tint(.white)
                            }
                            Text(isSubmitting ? "Creating…" : "Create Work Order")
                                .font(.headline)
                        }
                        .frame(maxWidth: .infinity)
                    }
                    .disabled(!isFormValid || isSubmitting)
                }
            }
            .navigationTitle("Create Work Order")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
            }
        }
    }

    private var isFormValid: Bool {
        selectedVehicle != nil &&
        selectedTech != nil &&
        !descriptionText.isEmpty
    }

    private func submit() {
        guard let vehicle = selectedVehicle,
              let tech = selectedTech else { return }

        isSubmitting = true
        errorMessage = nil

        Task {
            do {
                try await supabase.createWorkOrder(
                    vehicleId: vehicle.id,
                    techId: tech.id,
                    description: descriptionText
                )
                await MainActor.run {
                    showSuccess = true
                    isSubmitting = false
                }
                try? await Task.sleep(for: .seconds(1.5))
                await MainActor.run { dismiss() }
            } catch {
                await MainActor.run {
                    errorMessage = "Failed: \(error.localizedDescription)"
                    isSubmitting = false
                }
            }
        }
    }
}
