import SwiftUI

// MARK: - Inventory Tab

struct MaintenanceInventoryView: View {
    @StateObject private var viewModel = MaintenanceInventoryViewModel()
    @State private var selectedPart: InventoryPart?

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: FleetSpacing.large) {
                categoryHeader

                LazyVStack(spacing: FleetSpacing.medium) {
                    ForEach(viewModel.filteredParts) { part in
                        InventoryPartCard(part: part) {
                            selectedPart = part
                        }
                    }
                }
                .animation(.smooth, value: viewModel.selectedCategory)
                .transition(.opacity)
            }
            .padding(.horizontal)
            .padding(.top, FleetSpacing.medium)
            .padding(.bottom, FleetSpacing.xxLarge)
        }
        .background(Color.appBackground)
        .preferredColorScheme(.light)
        .navigationTitle("Inventory")
        .navigationBarTitleDisplayMode(.large)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                categoryMenu
            }
        }
        .sheet(item: $selectedPart) { part in
            InventoryPartDetailSheet(
                part: part,
                forecast: viewModel.forecast(for: part)
            )
            .presentationDetents([.medium, .large])
            .presentationDragIndicator(.visible)
        }
    }

    private var categoryHeader: some View {
        VStack(alignment: .leading, spacing: FleetSpacing.xSmall) {
            Text("Category")
                .font(.footnote.weight(.semibold))
                .foregroundStyle(.secondary)
                .textCase(.uppercase)

            Text(viewModel.selectedCategory.rawValue)
                .font(.title3.bold())
                .foregroundStyle(.brandPrimary)
                .contentTransition(.opacity)
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel("Category, \(viewModel.selectedCategory.rawValue)")
    }

    private var categoryMenu: some View {
        Menu {
            ForEach(viewModel.categories) { category in
                Button {
                    viewModel.select(category)
                } label: {
                    if category == viewModel.selectedCategory {
                        Label(category.rawValue, systemImage: "checkmark")
                    } else {
                        Text(category.rawValue)
                    }
                }
            }
        } label: {
            Image(systemName: "line.3.horizontal")
                .font(.headline)
        }
        .accessibilityLabel("Select inventory category")
    }
}

// MARK: - View Model

@MainActor
final class MaintenanceInventoryViewModel: ObservableObject {
    @Published private(set) var selectedCategory: InventoryCategory = .all

    let categories = InventoryCategory.allCases
    private let parts = SampleData.inventoryParts

    var filteredParts: [InventoryPart] {
        guard selectedCategory != .all else { return parts }
        return parts.filter { $0.category == selectedCategory }
    }

    func select(_ category: InventoryCategory) {
        withAnimation(.smooth) {
            selectedCategory = category
        }
    }

    func forecast(for part: InventoryPart) -> InventoryForecast {
        let stockPressure = max(0, part.reorderThreshold - part.currentQuantity)
        let currentUsage = max(1, part.monthlyConsumption - max(0, part.currentQuantity - part.reorderThreshold) / 4)
        let predictedUsage = max(
            currentUsage + stockPressure + 2,
            Int((Double(part.previousMonthUsage + currentUsage) / 2.0).rounded()) + 3
        )
        let targetStock = part.reorderThreshold + predictedUsage
        let recommendedQuantity = min(
            part.maximumQuantity,
            max(part.minimumQuantity, targetStock - part.currentQuantity)
        )

        return InventoryForecast(
            previousMonthUsage: part.previousMonthUsage,
            currentMonthUsage: currentUsage,
            predictedNextMonthUsage: predictedUsage,
            recommendedReorderQuantity: recommendedQuantity
        )
    }
}

struct InventoryForecast: Hashable {
    let previousMonthUsage: Int
    let currentMonthUsage: Int
    let predictedNextMonthUsage: Int
    let recommendedReorderQuantity: Int
}

// MARK: - Cards

private struct InventoryPartCard: View {
    let part: InventoryPart
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(alignment: .leading, spacing: FleetSpacing.medium) {
                HStack(alignment: .top, spacing: FleetSpacing.medium) {
                    VStack(alignment: .leading, spacing: FleetSpacing.xSmall) {
                        Text(part.name)
                            .font(.headline)
                            .foregroundStyle(.primary)
                            .lineLimit(2)

                        Text(part.id)
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }

                    Spacer(minLength: FleetSpacing.medium)

                    InventoryStatusBadge(status: part.stockStatus)
                }

                HStack(alignment: .firstTextBaseline) {
                    Text("Current Stock")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)

                    Spacer()

                    Text("\(part.currentQuantity) Units")
                        .font(.title3.bold())
                        .foregroundStyle(.primary)
                        .contentTransition(.numericText())
                }

                Text("Last Updated \(part.lastUpdated.formatted(date: .abbreviated, time: .omitted))")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            .padding(FleetSpacing.large)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(.white, in: .rect(cornerRadius: FleetRadius.card))
            .overlay {
                RoundedRectangle(cornerRadius: FleetRadius.card)
                    .stroke(Color.black.opacity(0.04), lineWidth: 1)
            }
            .shadow(color: .black.opacity(0.04), radius: 10, y: 4)
        }
        .buttonStyle(InventoryPressButtonStyle())
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(part.name), part ID \(part.id), current stock \(part.currentQuantity) units, \(part.stockStatus.rawValue), last updated \(part.lastUpdated.formatted(date: .abbreviated, time: .omitted))")
        .accessibilityHint("Opens part details")
    }
}

private struct InventoryPressButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.98 : 1)
            .animation(.snappy(duration: 0.16), value: configuration.isPressed)
    }
}

// MARK: - Detail Sheet

private struct InventoryPartDetailSheet: View {
    let part: InventoryPart
    let forecast: InventoryForecast

    @State private var showingReorderDialog = false
    @State private var showingSubmittedAlert = false

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: FleetSpacing.xLarge) {
                    sheetHeader
                    quantityDetails
                    forecastSection
                    requestButton
                }
                .padding()
                .padding(.bottom, FleetSpacing.large)
            }
            .background(Color.appBackground)
            .navigationBarTitleDisplayMode(.inline)
            .confirmationDialog(
                "Request Purchase for \(part.name) \(forecast.recommendedReorderQuantity) Units",
                isPresented: $showingReorderDialog,
                titleVisibility: .visible
            ) {
                Button("Confirm") {
                    showingSubmittedAlert = true
                }

                Button("Cancel", role: .cancel) {}
            }
            .alert("Purchase Request Submitted", isPresented: $showingSubmittedAlert) {
                Button("Done", role: .cancel) {}
            }
        }
    }

    private var sheetHeader: some View {
        VStack(alignment: .leading, spacing: FleetSpacing.medium) {
            HStack(alignment: .top, spacing: FleetSpacing.medium) {
                Text(part.name)
                    .font(.largeTitle.bold())
                    .foregroundStyle(.primary)
                    .lineLimit(2)
                    .minimumScaleFactor(0.82)

                Spacer(minLength: FleetSpacing.medium)

                InventoryStatusBadge(status: part.stockStatus)
                    .padding(.top, FleetSpacing.small)
            }

            VStack(alignment: .leading, spacing: FleetSpacing.xSmall) {
                DetailLine(title: "Part ID", value: part.id)
                DetailLine(title: "Category", value: part.category.rawValue)
            }
        }
        .padding(FleetSpacing.large)
        .background(.white, in: .rect(cornerRadius: FleetRadius.card))
    }

    private var quantityDetails: some View {
        VStack(alignment: .leading, spacing: FleetSpacing.medium) {
            Text("Stock Details")
                .font(.title3.bold())

            DetailLine(title: "Current Quantity", value: "\(part.currentQuantity) Units")
            DetailLine(title: "Minimum Quantity", value: "\(part.minimumQuantity) Units")
            DetailLine(title: "Maximum Quantity", value: "\(part.maximumQuantity) Units")
            DetailLine(title: "Reorder Threshold", value: "\(part.reorderThreshold) Units")
            DetailLine(title: "Last Updated", value: part.lastUpdated.formatted(date: .abbreviated, time: .omitted))
        }
        .padding(FleetSpacing.large)
        .background(.white, in: .rect(cornerRadius: FleetRadius.card))
    }

    private var forecastSection: some View {
        VStack(alignment: .leading, spacing: FleetSpacing.medium) {
            Text("Usage Forecast")
                .font(.title3.bold())

            DetailLine(title: "Previous Month Usage", value: "\(forecast.previousMonthUsage) Units")
            DetailLine(title: "Current Month Usage", value: "\(forecast.currentMonthUsage) Units")
            DetailLine(title: "Predicted Next Month Usage", value: "\(forecast.predictedNextMonthUsage) Units")
            DetailLine(title: "Recommended Reorder Quantity", value: "Order \(forecast.recommendedReorderQuantity) Additional Units")
        }
        .padding(FleetSpacing.large)
        .background(.white, in: .rect(cornerRadius: FleetRadius.card))
    }

    private var requestButton: some View {
        Button {
            showingReorderDialog = true
        } label: {
            Text("Request Reorder")
                .font(.headline)
                .frame(maxWidth: .infinity)
                .padding(.vertical, FleetSpacing.medium)
        }
        .buttonStyle(.borderedProminent)
        .tint(.brandPrimary)
        .accessibilityLabel("Request reorder for \(part.name)")
    }
}

private struct DetailLine: View {
    let title: String
    let value: String

    var body: some View {
        HStack(alignment: .firstTextBaseline, spacing: FleetSpacing.large) {
            Text(title)
                .font(.subheadline)
                .foregroundStyle(.secondary)

            Spacer(minLength: FleetSpacing.medium)

            Text(value)
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(.primary)
                .multilineTextAlignment(.trailing)
        }
        .accessibilityElement(children: .combine)
    }
}

private struct InventoryStatusBadge: View {
    let status: InventoryStockStatus

    private var color: Color {
        switch status {
        case .healthy:
            return .green
        case .lowStock:
            return .orange
        case .outOfStock:
            return .red
        }
    }

    var body: some View {
        Text(status.rawValue)
            .font(.caption.weight(.semibold))
            .foregroundStyle(color)
            .padding(.horizontal, FleetSpacing.medium)
            .padding(.vertical, FleetSpacing.small)
            .background(color.opacity(0.12), in: Capsule())
            .contentTransition(.opacity)
            .accessibilityLabel("Status \(status.rawValue)")
    }
}

#Preview {
    NavigationStack {
        MaintenanceInventoryView()
    }
}
