import SwiftUI

struct MaintenanceDashboardView: View {
    @Binding var selectedTab: Int
    @StateObject private var supabase = SupabaseService.shared
    
    private var totalWorkOrders: Int {
        supabase.workOrders.count
    }
    
    private var completedWorkOrders: Int {
        supabase.workOrders.filter { $0.status == .completed }.count
    }
    
    private var recentWorkOrders: [WorkOrder] {
        // Just take first 3 for recent
        Array(supabase.workOrders.prefix(3))
    }
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: FleetSpacing.xLarge) {
                
                // MARK: - Overview
                VStack(alignment: .leading, spacing: FleetSpacing.medium) {
                    Text("Overview")
                        .font(.title2.bold())
                        .padding(.horizontal)
                    
                    HStack(spacing: FleetSpacing.medium) {
                        overviewCard(
                            title: "Total",
                            count: totalWorkOrders,
                            subtitle: "All assigned",
                            icon: "doc.text.fill",
                            color: .secondary
                        )
                        overviewCard(
                            title: "Completed",
                            count: completedWorkOrders,
                            subtitle: "Since midnight",
                            icon: "checkmark.circle.fill",
                            color: .green
                        )
                    }
                    .padding(.horizontal)
                }
                

                // MARK: - Recent Work Orders
                VStack(alignment: .leading, spacing: FleetSpacing.medium) {
                    HStack {
                        Text("Recent Work Orders")
                            .font(.title2.bold())
                        Spacer()
                        Button("See All") {
                            selectedTab = 1 // Switch to Work Orders tab
                        }
                        .font(.subheadline)
                        .foregroundStyle(.brandPrimary)
                    }
                    .padding(.horizontal)
                    
                    LazyVStack(spacing: FleetSpacing.medium) {
                        ForEach(recentWorkOrders) { order in
                            NavigationLink {
                                WorkOrderDetailView(order: order)
                            } label: {
                                WorkOrderListCard(order: order)
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    .padding(.horizontal)
                }
            }
            .padding(.bottom, FleetSpacing.xxLarge)
        }
        .background(Color.appBackground)
        .navigationTitle("Dashboard")
        .navigationBarTitleDisplayMode(.large)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                NavigationLink(destination: AccountView()) {
                    Image(systemName: "person.crop.circle")
                }
                .accessibilityLabel("Account")
            }
        }
    }
    
    // MARK: - Subviews
    
    private func overviewCard(title: String, count: Int, subtitle: String, icon: String, color: Color) -> some View {
        VStack(alignment: .leading, spacing: FleetSpacing.small) {
            Image(systemName: icon)
                .foregroundStyle(color)
                .font(.title3)
                .padding(.bottom, 4)
            
            Text(title)
                .font(.subheadline)
                .foregroundStyle(.primary)
                .lineLimit(1)
            
            Text("\(count)")
                .font(.title.bold())
                .foregroundStyle(.primary)
            
            Text(subtitle)
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(.background.secondary, in: .rect(cornerRadius: FleetRadius.card))
    }

}

#Preview {
    NavigationStack {
        MaintenanceDashboardView(selectedTab: .constant(0))
    }
}
