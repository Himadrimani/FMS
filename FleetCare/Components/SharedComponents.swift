import SwiftUI

struct StatusBadge: View {
    let status: FleetStatus

    private var color: Color {
        switch status {
        case .active, .completed: .green
        case .attention: .red
        case .scheduled: .orange
        case .offline: .secondary
        }
    }

    var body: some View {
        Label(status.rawValue, systemImage: "circle.fill")
            .font(.caption.weight(.semibold))
            .foregroundStyle(color)
            .labelStyle(.titleAndIcon)
            .accessibilityElement(children: .combine)
            .accessibilityLabel("Status: \(status.rawValue)")
    }
}

struct StockHealthBadge: View {
    let health: StockHealth

    private var color: Color {
        switch health {
        case .healthy: .green
        case .lowStock: .orange
        case .outOfStock: .red
        }
    }

    private var symbol: String {
        "circle.fill"
    }

    var body: some View {
        Label(health.rawValue, systemImage: symbol)
            .font(.caption.weight(.semibold))
            .foregroundStyle(color)
            .accessibilityElement(children: .combine)
            .accessibilityLabel("Stock status: \(health.rawValue)")
    }
}

struct MetricCard: View {
    let title: String
    let value: String
    let detail: String
    let symbol: String
    var tint: Color = .brandPrimary

    var body: some View {
        VStack(alignment: .leading, spacing: FleetSpacing.medium) {
            Image(systemName: symbol)
                .font(.title2)
                .foregroundStyle(tint)
                .symbolRenderingMode(.hierarchical)
                .accessibilityHidden(true)
            Text(value)
                .font(.title2.bold())
                .contentTransition(.numericText())
            Text(title)
                .font(.headline)
            Text(detail)
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .fleetCard()
        .accessibilityElement(children: .combine)
    }
}

struct InsightCard: View {
    let title: String
    let summary: String
    let score: Int
    let recommendation: String

    var body: some View {
        VStack(alignment: .leading, spacing: FleetSpacing.large) {
            HStack(alignment: .firstTextBaseline) {
                Label(title, systemImage: "sparkles")
                    .font(.headline)
                    .foregroundStyle(.brandPrimary)
                Spacer()
                Text("\(score)")
                    .font(.title.bold())
                    .contentTransition(.numericText())
            }
            ProgressView(value: Double(score), total: 100)
                .tint(score > 70 ? .green : .orange)
                .accessibilityLabel("Confidence")
                .accessibilityValue("\(score) percent")
            Text(summary)
                .font(.body)
            Label(recommendation, systemImage: "arrow.right.circle.fill")
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(.secondary)
        }
        .fleetCard()
    }
}

struct SectionHeader: View {
    let title: String
    var actionTitle: String?
    var action: (() -> Void)?

    var body: some View {
        HStack {
            Text(title)
                .font(.title3.bold())
            Spacer()
            if let actionTitle, let action {
                Button(actionTitle, action: action)
                    .font(.subheadline.weight(.semibold))
            }
        }
        .accessibilityAddTraits(.isHeader)
    }
}

struct EmptyStateView: View {
    let title: String
    let message: String
    let symbol: String

    var body: some View {
        ContentUnavailableView(title, systemImage: symbol, description: Text(message))
            .accessibilityElement(children: .combine)
    }
}

struct OfflineBanner: View {
    var body: some View {
        Label("Offline — changes will sync automatically", systemImage: "wifi.slash")
            .font(.footnote.weight(.semibold))
            .frame(maxWidth: .infinity)
            .padding(.vertical, FleetSpacing.small)
            .foregroundStyle(.white)
            .background(.orange)
            .accessibilityLabel("Offline. Changes will sync automatically.")
    }
}

#Preview("Shared Components") {
    ScrollView {
        VStack(alignment: .leading, spacing: FleetSpacing.large) {
            StatusBadge(status: .active)
            StockHealthBadge(health: .lowStock)
            MetricCard(title: "Due today", value: "4", detail: "1 urgent", symbol: "calendar.badge.exclamationmark", tint: .orange)
            InsightCard(title: "Inventory forecast", summary: "Brake pad stock may reach minimum level in 18 days.", score: 82, recommendation: "Create purchase request")
            SectionHeader(title: "Section", actionTitle: "View All") {}
            EmptyStateView(title: "No records", message: "New activity will appear here.", symbol: "tray")
            OfflineBanner()
        }
        .padding()
    }
    .background(Color.appBackground)
}
