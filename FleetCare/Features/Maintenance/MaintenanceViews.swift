import SwiftUI

// MARK: - Maintenance Tab View (4 Tabs)

struct MaintenanceTabView: View {
    @State private var selectedTab = 0
    @StateObject private var supabase = SupabaseService.shared
    @Environment(SessionStore.self) private var session
    
    var body: some View {
        TabView(selection: $selectedTab) {
            Tab("Dashboard", systemImage: "square.grid.2x2.fill", value: 0) {
                NavigationStack { MaintenanceDashboardView(selectedTab: $selectedTab) }
            }
            Tab("Work Orders", systemImage: "wrench.and.screwdriver.fill", value: 1) {
                NavigationStack { MaintenanceWorkOrdersView() }
            }
            Tab("Inventory", systemImage: "shippingbox.fill", value: 2) {
                NavigationStack { MaintenanceInventoryView() }
            }
            Tab("Chat", systemImage: "bubble.left.and.bubble.right.fill", value: 3) {
                NavigationStack { MaintenanceChatView() }
            }
        }
        .task {
            // Fetch vehicles first (needed to resolve vehicle names in work orders)
            if supabase.vehicles.isEmpty { await supabase.fetchVehicles() }
            // Fetch only work orders assigned to THIS technician
            await supabase.fetchWorkOrders(forTechId: session.currentUserId)
            if supabase.inventoryParts.isEmpty { await supabase.fetchInventory() }
        }
    }
}


// MARK: - Work Order Detail View

struct WorkOrderDetailView: View {
    let order: WorkOrder
    @State private var isPhysicalRepairComplete = false
    @State private var isTestDriveComplete = false
    
    @State private var laborHoursInput: String = ""
    @State private var newPartInput: String = ""
    @State private var loggedParts: [String] = []
    @State private var technicianNotes: String = ""
    
    private var isReadyToComplete: Bool {
        isPhysicalRepairComplete && isTestDriveComplete
    }

    var body: some View {
        List {
            // MARK: Header
            Section {
                VStack(alignment: .leading, spacing: FleetSpacing.medium) {
                    Text(order.title)
                        .font(.title2.bold())
                    Text(order.vehicleName)
                        .font(.headline)
                        .foregroundStyle(.secondary)
                }
            }

            // MARK: Logging Data & Resources
            Section("Logging Data") {
                // Parts
                VStack(alignment: .leading, spacing: FleetSpacing.small) {
                    Text("Parts Used").font(.subheadline.bold())
                    ForEach(loggedParts, id: \.self) { part in
                        Label(part, systemImage: "shippingbox.fill")
                            .font(.caption)
                    }
                    HStack {
                        TextField("e.g. 2x brake pads", text: $newPartInput)
                            .textFieldStyle(.roundedBorder)
                        Button("Add") {
                            if !newPartInput.isEmpty {
                                loggedParts.append(newPartInput)
                                newPartInput = ""
                            }
                        }
                        .buttonStyle(.bordered)
                        .disabled(newPartInput.isEmpty)
                    }
                }
                .padding(.vertical, 4)

                // Labor
                HStack {
                    Text("Labor Hours").font(.subheadline.bold())
                    Spacer()
                    TextField("0.0", text: $laborHoursInput)
                        .keyboardType(.decimalPad)
                        .multilineTextAlignment(.trailing)
                        .frame(width: 80)
                }

                // Notes
                VStack(alignment: .leading) {
                    Text("Final Notes").font(.subheadline.bold())
                    TextField("Summary of resolution...", text: $technicianNotes, axis: .vertical)
                        .lineLimit(3...5)
                }
            }

            // MARK: Evidence (Photos)
            if order.isExternalRepair {
                Section("Photos (After Repair)") {
                    Button("Take Photo", systemImage: "camera.fill") {}
                    Button("Add from Photos", systemImage: "photo.on.rectangle") {}
                }
            }

            // MARK: Verification
            Section("Job Verification") {
                Button {
                    withAnimation(.snappy) {
                        isPhysicalRepairComplete.toggle()
                    }
                } label: {
                    Label {
                        Text("Physical repair complete")
                            .foregroundStyle(isPhysicalRepairComplete ? .secondary : .primary)
                    } icon: {
                        Image(systemName: isPhysicalRepairComplete ? "checkmark.circle.fill" : "circle")
                            .foregroundStyle(isPhysicalRepairComplete ? .green : .brandPrimary)
                    }
                }

                Button {
                    withAnimation(.snappy) {
                        isTestDriveComplete.toggle()
                    }
                } label: {
                    Label {
                        Text("Test drive verified")
                            .foregroundStyle(isTestDriveComplete ? .secondary : .primary)
                    } icon: {
                        Image(systemName: isTestDriveComplete ? "checkmark.circle.fill" : "circle")
                            .foregroundStyle(isTestDriveComplete ? .green : .brandPrimary)
                    }
                }
            }

            // MARK: Complete
            Section {
                Button {
                    completeWorkOrder()
                } label: {
                    Label(order.status == .completed ? "Completed" : "Complete Work Order", systemImage: "checkmark.seal.fill")
                        .font(.headline)
                        .foregroundStyle(order.status == .completed ? .green : .brandPrimary)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, FleetSpacing.small)
                }
                .disabled(!isReadyToComplete || order.status == .completed)
            }
        }
        .navigationTitle("Work Order")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            laborHoursInput = order.laborHours > 0 ? String(format: "%.1f", order.laborHours) : ""
            loggedParts = order.partsUsed
            technicianNotes = order.technicianNotes
        }
    }
    
    private func completeWorkOrder() {
        withAnimation {
            // Update WorkOrder Status
            order.status = .completed
            
            // Save Logs
            order.laborHours = Double(laborHoursInput) ?? 0.0
            order.partsUsed = loggedParts
            order.technicianNotes = technicianNotes
            
            // Mock Vehicle Analytics Update
            if let vehicle = SupabaseService.shared.vehicles.first(where: { $0.name == order.vehicleName }) {
                vehicle.status = .active // Available
                // Mock cost calc: $100/hr labor + flat $50 for parts
                let laborCost = order.laborHours * 100.0
                let partsCost = Double(loggedParts.count * 50)
                vehicle.totalCostOfOwnership += (laborCost + partsCost)
            }
        }
    }
}

#Preview {
    MaintenanceTabView()
}
