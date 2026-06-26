import SwiftUI

// MARK: - Work Orders Tab

struct MaintenanceWorkOrdersView: View {
    @StateObject private var supabase = SupabaseService.shared
    @State private var selectedFilter: WorkOrderFilter = .pending
    @State private var searchText = ""

    private var filteredOrders: [WorkOrder] {
        let orders = supabase.workOrders
        let byFilter: [WorkOrder]
        switch selectedFilter {
        case .pending:
            byFilter = orders.filter { $0.status == .scheduled || $0.status == .attention }
        case .inProgress:
            byFilter = orders.filter { $0.status == .active }
        case .completed:
            byFilter = orders.filter { $0.status == .completed }
        case .urgent:
            byFilter = orders.filter { $0.status == .attention }
        }
        
        if searchText.isEmpty { return byFilter }
        return byFilter.filter {
            $0.title.localizedCaseInsensitiveContains(searchText) ||
            $0.vehicleName.localizedCaseInsensitiveContains(searchText)
        }
    }

    var body: some View {
        ScrollView {
            LazyVStack(alignment: .leading, spacing: FleetSpacing.xLarge) {

                // MARK: Filter Segments
                filterPicker

                // MARK: Urgent Banner
                if selectedFilter != .urgent {
                    urgentBanner
                }

                // MARK: Work Order List
                if filteredOrders.isEmpty {
                    emptyState
                } else {
                    workOrderList
                }
            }
            .padding()
        }
        .searchable(text: $searchText, prompt: "Search work orders")
        .background(Color.appBackground)
        .navigationTitle("Work Orders")
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
    private var filterPicker: some View {
        Picker("Filter", selection: $selectedFilter) {
            Text("Pending").tag(WorkOrderFilter.pending)
            Text("In Progress").tag(WorkOrderFilter.inProgress)
            Text("Completed").tag(WorkOrderFilter.completed)
        }
        .pickerStyle(.segmented)
    }

    // MARK: - Urgent Banner
    private var urgentBanner: some View {
        let count = supabase.workOrders.filter { $0.status == .attention }.count
        return Group {
            if count > 0 {
                Button {
                    selectedFilter = .urgent
                } label: {
                    HStack(spacing: FleetSpacing.medium) {
                        Text("\(count)")
                            .font(.title3.bold())
                            .foregroundStyle(.red)
                            .frame(width: 40, height: 40)
                            .overlay(
                                Circle().stroke(.red, lineWidth: 2)
                            )
                        
                        VStack(alignment: .leading, spacing: 2) {
                            Text("Urgent work orders")
                                .font(.headline)
                                .foregroundStyle(.red)
                            Text("Tap to review now")
                                .font(.subheadline)
                                .foregroundStyle(.red.opacity(0.8))
                        }
                        Spacer()
                        Image(systemName: "chevron.right")
                            .foregroundStyle(.red)
                            .font(.caption.bold())
                    }
                    .padding()
                    .background(Color.red.opacity(0.15), in: .rect(cornerRadius: FleetRadius.card))
                    .overlay(
                        RoundedRectangle(cornerRadius: FleetRadius.card)
                            .stroke(Color.red.opacity(0.3), lineWidth: 1)
                    )
                }
                .buttonStyle(.plain)
            }
        }
    }

    // MARK: - Work Order List

    private var workOrderList: some View {
        ForEach(filteredOrders) { order in
            NavigationLink {
                WorkOrderDetailView(order: order)
            } label: {
                WorkOrderListCard(order: order)
            }
            .buttonStyle(.plain)
        }
    }

    // MARK: - Empty State

    private var emptyState: some View {
        ContentUnavailableView(
            "No work orders",
            systemImage: "wrench.and.screwdriver",
            description: Text("No work orders match the current filter.")
        )
        .frame(minHeight: 200)
    }
}

// MARK: - Filter Enum

enum WorkOrderFilter: String, CaseIterable, Identifiable {
    case pending = "Pending"
    case inProgress = "In Progress"
    case completed = "Completed"
    case urgent = "Urgent"

    var id: String { rawValue }
}

// MARK: - Work Order List Card

struct WorkOrderListCard: View {
    let order: WorkOrder

    var body: some View {
        HStack(spacing: 0) {
            VStack(alignment: .leading, spacing: FleetSpacing.small) {
                VStack(alignment: .leading, spacing: FleetSpacing.xSmall) {
                    Text(order.title)
                        .font(.headline)
                    Text(order.vehicleName)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
            }
            .padding(FleetSpacing.large)
            Spacer()
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(.background.secondary, in: .rect(cornerRadius: FleetRadius.card))
        .accessibilityElement(children: .combine)
    }
}

#Preview {
    NavigationStack {
        MaintenanceWorkOrdersView()
    }
}
