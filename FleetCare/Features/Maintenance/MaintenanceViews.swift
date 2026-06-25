import Observation
import SwiftData
import SwiftUI

// MARK: - Maintenance Tab View (4 Tabs)

struct MaintenanceTabView: View {
    @State private var selectedTab = 0
    
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
    }
}

<<<<<<< HEAD
=======
struct MaintenanceDashboardView: View {
    var body: some View {
        ScrollView {
            LazyVStack(alignment: .leading, spacing: FleetSpacing.xLarge) {
                Text("Today’s work")
                    .font(.largeTitle.bold())
                HStack(spacing: FleetSpacing.medium) {
                    MetricCard(title: "Due today", value: "4", detail: "1 urgent", symbol: "calendar.badge.exclamationmark", tint: .orange)
                    MetricCard(title: "Completed", value: "3", detail: "On schedule", symbol: "checkmark.circle.fill", tint: .green)
                }
                SectionHeader(title: "Next up")
                if let order = SampleData.workOrders.first {
                    NavigationLink {
                        WorkOrderDetailView(order: order)
                    } label: {
                        WorkOrderCard(order: order)
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding()
        }
        .background(Color.appBackground)
        .navigationTitle("Work")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                NavigationLink(destination: AccountView()) {
                    Image(systemName: "person.crop.circle")
                }
                .accessibilityLabel("Account")
            }
        }
    }
}
>>>>>>> 7fe1e3a (commit ds)

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
<<<<<<< HEAD
    
    private func completeWorkOrder() {
        withAnimation {
            // Update WorkOrder Status
            order.status = .completed
            
            // Save Logs
            order.laborHours = Double(laborHoursInput) ?? 0.0
            order.partsUsed = loggedParts
            order.technicianNotes = technicianNotes
            
            // Mock Vehicle Analytics Update
            if let vehicle = SampleData.vehicles.first(where: { $0.name == order.vehicleName }) {
                vehicle.status = .active // Available
                // Mock cost calc: $100/hr labor + flat $50 for parts
                let laborCost = order.laborHours * 100.0
                let partsCost = Double(loggedParts.count * 50)
                vehicle.totalCostOfOwnership += (laborCost + partsCost)
            }
=======
}

struct InventoryView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \InventoryItem.partName) private var storedItems: [InventoryItem]
    @State private var viewModel = InventoryViewModel()
    @State private var selectedItem: InventoryItem?

    private var items: [InventoryItem] {
        storedItems.isEmpty ? SampleData.inventoryItems : storedItems
    }

    private var filteredItems: [InventoryItem] {
        viewModel.filteredItems(from: items)
    }

    var body: some View {
        ScrollView {
            LazyVStack(alignment: .leading, spacing: FleetSpacing.xLarge) {
                Text("Category: \(viewModel.selectedCategoryLabel)")
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(.secondary)
                if filteredItems.isEmpty {
                    EmptyStateView(title: "No parts found", message: "No inventory items match the selected category.", symbol: "shippingbox")
                } else {
                    ForEach(filteredItems) { item in
                        Button {
                            selectedItem = item
                        } label: {
                            InventoryItemCard(item: item)
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
            .padding()
        }
        .background(Color.appBackground)
        .navigationTitle("Inventory")
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Menu {
                    ForEach(InventoryCategoryFilter.allCases) { category in
                        Button(category.rawValue) {
                            viewModel.selectedCategory = category
                        }
                    }
                } label: {
                    Image(systemName: "line.3.horizontal")
                }
                .accessibilityLabel("Categories")
            }
        }
        .sheet(item: $selectedItem) { item in
            InventoryItemDetailSheet(
                item: item,
                viewModel: viewModel
            ) { request in
                modelContext.insert(request)
            }
        }
    }
}

@Observable
final class InventoryViewModel {
    var selectedCategory: InventoryCategoryFilter = .allParts

    func filteredItems(from items: [InventoryItem]) -> [InventoryItem] {
        let filtered = selectedCategory.inventoryCategory.map { category in
            items.filter { $0.category == category }
        } ?? items

        return filtered.sorted { $0.partName < $1.partName }
    }

    var selectedCategoryLabel: String {
        selectedCategory.rawValue
    }

    func previousMonthUsage(for item: InventoryItem) -> Int {
        max(1, item.minimumQuantity + item.reorderThreshold / 2 + item.quantity / 3)
    }

    func currentMonthUsage(for item: InventoryItem) -> Int {
        max(1, previousMonthUsage(for: item) - max(1, (item.quantity + item.reorderThreshold) / 5))
    }

    func averageMonthlyUsage(for item: InventoryItem) -> Int {
        (previousMonthUsage(for: item) + currentMonthUsage(for: item)) / 2
    }

    func predictedUsageNextMonth(for item: InventoryItem) -> Int {
        max(currentMonthUsage(for: item) + max(2, item.reorderThreshold / 3), item.reorderThreshold + max(1, item.minimumQuantity / 2))
    }

    func recommendedOrderQuantity(for item: InventoryItem) -> Int {
        let targetStock = min(item.maximumQuantity, max(item.reorderThreshold * 2, predictedUsageNextMonth(for: item) + item.minimumQuantity / 2))
        return max(1, targetStock - item.quantity)
    }
}

enum InventoryCategoryFilter: String, CaseIterable, Identifiable {
    case allParts = "All Parts"
    case engineParts = "Engine Parts"
    case brakeParts = "Brake Parts"
    case tires = "Tires"
    case electrical = "Electrical"
    case fluids = "Fluids"
    case generalMaintenance = "General Maintenance"

    var id: Self { self }

    var inventoryCategory: InventoryCategory? {
        switch self {
        case .allParts:
            nil
        case .engineParts:
            .engineParts
        case .brakeParts:
            .brakeParts
        case .tires:
            .tires
        case .electrical:
            .electrical
        case .fluids:
            .fluids
        case .generalMaintenance:
            .generalMaintenance
        }
    }
}

private struct InventoryItemCard: View {
    let item: InventoryItem

    var body: some View {
        VStack(alignment: .leading, spacing: FleetSpacing.small) {
            Text(item.partName)
                .font(.headline)
            HStack(alignment: .firstTextBaseline, spacing: FleetSpacing.medium) {
                StockHealthBadge(health: item.stockHealth)
                Text("\(item.quantity) Units")
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(.secondary)
                Spacer()
                Image(systemName: "chevron.up.chevron.down")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(.tertiary)
            }
        }
        .fleetCard()
    }
}

private struct InventoryItemDetailSheet: View {
    let item: InventoryItem
    let viewModel: InventoryViewModel
    let onSubmit: (PurchaseRequest) -> Void
    @State private var isPresentingPurchaseRequest = false

    var body: some View {
        NavigationStack {
            List {
                Section {
                    VStack(alignment: .leading, spacing: FleetSpacing.small) {
                        Text(item.partName)
                            .font(.title2.bold())
                        StockHealthBadge(health: item.stockHealth)
                    }
                    .padding(.vertical, FleetSpacing.xSmall)
                }

                Section("Part Information") {
                    InventoryDetailRow(title: "Part ID", value: item.partID)
                    InventoryDetailRow(title: "Category", value: item.category.rawValue)
                    InventoryDetailRow(title: "Current Quantity", value: "\(item.quantity)")
                    InventoryDetailRow(title: "Minimum Quantity", value: "\(item.minimumQuantity)")
                    InventoryDetailRow(title: "Maximum Quantity", value: "\(item.maximumQuantity)")
                    InventoryDetailRow(title: "Reorder Threshold", value: "\(item.reorderThreshold)")
                    InventoryDetailRow(title: "Last Updated", value: item.lastUpdated, format: .dateTime.month().day().hour().minute())
                }

                Section("Usage Forecast") {
                    InventoryDetailRow(title: "Previous Month Usage", value: "\(viewModel.previousMonthUsage(for: item))")
                    InventoryDetailRow(title: "Current Month Usage", value: "\(viewModel.currentMonthUsage(for: item))")
                    InventoryDetailRow(title: "Predicted Next Month Usage", value: "\(viewModel.predictedUsageNextMonth(for: item))")
                    InventoryDetailRow(title: "Recommended Reorder Quantity", value: "\(viewModel.recommendedOrderQuantity(for: item)) Additional Units")
                }

                Section {
                    Button("Create Purchase Request", systemImage: "cart.badge.plus") {
                        isPresentingPurchaseRequest = true
                    }
                }
            }
            .navigationTitle("Part Details")
            .navigationBarTitleDisplayMode(.inline)
        }
        .presentationDetents([.medium, .large])
        .presentationDragIndicator(.visible)
        .sheet(isPresented: $isPresentingPurchaseRequest) {
            PurchaseRequestSheet(item: item, recommendedQuantity: viewModel.recommendedOrderQuantity(for: item), onSubmit: onSubmit)
>>>>>>> 7fe1e3a (commit ds)
        }
    }
}

<<<<<<< HEAD
#Preview {
    MaintenanceTabView()
=======
private struct InventoryDetailRow: View {
    let title: String
    let value: String

    init(title: String, value: String) {
        self.title = title
        self.value = value
    }

    init(title: String, value: Date, format: Date.FormatStyle) {
        self.title = title
        self.value = value.formatted(format)
    }

    var body: some View {
        LabeledContent(title, value: value)
    }
}

private struct PurchaseRequestSheet: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(SessionStore.self) private var session
    let item: InventoryItem
    let onSubmit: (PurchaseRequest) -> Void
    @State private var quantity: Int

    init(item: InventoryItem, recommendedQuantity: Int, onSubmit: @escaping (PurchaseRequest) -> Void) {
        self.item = item
        self.onSubmit = onSubmit
        _quantity = State(initialValue: max(1, recommendedQuantity))
    }

    var body: some View {
        NavigationStack {
            Form {
                Section("Part") {
                    LabeledContent("Part", value: item.partName)
                    LabeledContent("Part ID", value: item.partID)
                    StockHealthBadge(health: item.stockHealth)
                }
                Section {
                    Stepper("Quantity: \(quantity)", value: $quantity, in: 1...max(item.maximumQuantity, 1))
                } header: {
                    Text("Request")
                } footer: {
                    Text("The Fleet Manager must approve this request before inventory is restocked.")
                }
            }
            .navigationTitle("Purchase Request")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Submit") {
                        onSubmit(PurchaseRequest(partName: item.partName, quantity: quantity, requestedByEmail: session.signedInEmail))
                        dismiss()
                    }
                }
            }
        }
        .presentationDetents([.medium, .large])
    }
}

#Preview("Maintenance Inventory") {
    NavigationStack {
        InventoryView()
    }
    .environment(SessionStore())
    .modelContainer(for: [
        InventoryItem.self,
        PurchaseRequest.self
    ], inMemory: true)
}

#Preview("Maintenance Tab") {
    let session = SessionStore()
    _ = session.authenticate(email: "maintenance@fleetcare.example", password: "password", users: [])
    return MaintenanceTabView()
        .environment(session)
        .modelContainer(for: [
            InventoryItem.self,
            PurchaseRequest.self
        ], inMemory: true)
}

#Preview("Maintenance Dashboard") {
    NavigationStack {
        MaintenanceDashboardView()
    }
    .environment(SessionStore())
    .modelContainer(for: [
        InventoryItem.self,
        PurchaseRequest.self
    ], inMemory: true)
}

#Preview("Work Orders") {
    NavigationStack {
        WorkOrdersView()
    }
}

#Preview("Work Order Detail") {
    NavigationStack {
        WorkOrderDetailView(order: SampleData.workOrders[0])
    }
}

#Preview("Inventory Purchase Request") {
    let session = SessionStore()
    _ = session.authenticate(email: "maintenance@fleetcare.example", password: "password", users: [])
    return PurchaseRequestSheet(item: SampleData.inventoryItems[4], recommendedQuantity: 20) { _ in }
        .environment(session)
>>>>>>> 7fe1e3a (commit ds)
}
