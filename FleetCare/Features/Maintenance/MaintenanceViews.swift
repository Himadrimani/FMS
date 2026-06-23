import SwiftUI

struct MaintenanceTabView: View {
    var body: some View {
        TabView {
            Tab("Work", systemImage: "wrench.and.screwdriver.fill") {
                NavigationStack { MaintenanceDashboardView() }
            }
            Tab("Orders", systemImage: "list.bullet.clipboard.fill") {
                NavigationStack { WorkOrdersView() }
            }
            Tab("Inventory", systemImage: "shippingbox.fill") {
                NavigationStack { InventoryView() }
            }
            Tab("Messages", systemImage: "message.fill") {
                NavigationStack { MessagesView() }
            }
            Tab("More", systemImage: "ellipsis") {
                NavigationStack { MoreFeaturesView(role: .maintenance) }
            }
        }
    }
}

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
                SectionHeader(title: "Parts watch")
                InsightCard(title: "Inventory forecast", summary: "Front brake pad stock may reach minimum level in 18 days.", score: 82, recommendation: "Create purchase request")
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

struct WorkOrdersView: View {
    var body: some View {
        List(SampleData.workOrders) { order in
            NavigationLink {
                WorkOrderDetailView(order: order)
            } label: {
                WorkOrderCard(order: order)
            }
        }
        .navigationTitle("Work Orders")
    }
}

private struct WorkOrderCard: View {
    let order: WorkOrder

    var body: some View {
        VStack(alignment: .leading, spacing: FleetSpacing.small) {
            HStack {
                Text(order.title).font(.headline)
                Spacer()
                StatusBadge(status: order.status)
            }
            Text(order.vehicleName)
                .font(.subheadline)
                .foregroundStyle(.secondary)
            Text("Due \(order.dueAt, format: .relative(presentation: .named))")
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .padding(.vertical, FleetSpacing.xSmall)
    }
}

struct WorkOrderDetailView: View {
    let order: WorkOrder
    @State private var notes = ""
    @State private var completedSteps = Set<Int>()

    private let steps = ["Confirm reported symptom", "Photograph condition", "Complete repair", "Record parts and labor", "Quality inspection"]

    var body: some View {
        List {
            Section {
                Text(order.title).font(.title.bold())
                Text(order.vehicleName).foregroundStyle(.secondary)
                StatusBadge(status: order.status)
            }
            Section("Repair workflow") {
                ForEach(steps.indices, id: \.self) { index in
                    Button {
                        if completedSteps.contains(index) { completedSteps.remove(index) } else { completedSteps.insert(index) }
                    } label: {
                        Label(steps[index], systemImage: completedSteps.contains(index) ? "checkmark.circle.fill" : "\(index + 1).circle")
                            .frame(minHeight: 44)
                    }
                    .accessibilityValue(completedSteps.contains(index) ? "Completed" : "Not completed")
                }
            }
            Section("Evidence") {
                Button("Take Photo", systemImage: "camera.fill") {}
                Button("Add from Photos", systemImage: "photo.on.rectangle") {}
            }
            Section("Technician notes") {
                TextField("Add a short note", text: $notes, axis: .vertical)
                    .lineLimit(3...6)
            }
            Section {
                Button("Complete Work Order", systemImage: "checkmark.seal.fill") {}
                    .disabled(completedSteps.count != steps.count)
            }
        }
        .navigationTitle("Work Order")
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct InventoryView: View {
    private let parts = [
        ("Front brake pads", 8, 10),
        ("Oil filters", 24, 12),
        ("Cabin filters", 7, 6),
        ("Coolant, 5 L", 14, 8)
    ]

    var body: some View {
        List {
            Section("Parts") {
                ForEach(parts, id: \.0) { part in
                    VStack(alignment: .leading, spacing: FleetSpacing.small) {
                        HStack {
                            Text(part.0).font(.headline)
                            Spacer()
                            Text("\(part.1) in stock")
                                .foregroundStyle(part.1 <= part.2 ? .orange : .secondary)
                        }
                        ProgressView(value: Double(part.1), total: Double(max(part.2 * 2, part.1)))
                            .tint(part.1 <= part.2 ? .orange : .brandPrimary)
                    }
                    .padding(.vertical, FleetSpacing.xSmall)
                }
            }
            Section {
                Button("New Purchase Request", systemImage: "cart.badge.plus") {}
            }
        }
        .navigationTitle("Inventory")
    }
}
