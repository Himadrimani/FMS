import SwiftUI

// MARK: - StatusBadge
// Two inits: one for FleetStatus (used by vehicle/trip lists),
// one generic (text + color) used by driver and maintenance status rows.
struct StatusBadge: View {
    let text: String
    let color: Color

    init(status: FleetStatus) {
        self.text = status.rawValue
        switch status {
        case .active, .completed: self.color = .green
        case .attention:          self.color = .red
        case .scheduled:          self.color = .orange
        case .offline:            self.color = .secondary
        }
    }

    init(text: String, color: Color) {
        self.text  = text
        self.color = color
    }

    var body: some View {
        Label(text, systemImage: "circle.fill")
            .font(.caption.weight(.semibold))
            .foregroundStyle(color)
            .labelStyle(.titleAndIcon)
            .accessibilityElement(children: .combine)
            .accessibilityLabel("Status: \(text)")
    }
}

// MARK: - MetricCard
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

// MARK: - InsightCard
struct InsightCard: View {
    let title: String
    let summary: String
    let score: Int
    let recommendation: String

    var body: some View {
        VStack(alignment: .leading, spacing: FleetSpacing.large) {
            HStack(alignment: .firstTextBaseline) {
                Label(title, systemImage: "sparkles")
                    .font(.headline).foregroundStyle(.brandPrimary)
                Spacer()
                Text("\(score)").font(.title.bold()).contentTransition(.numericText())
            }
            ProgressView(value: Double(score), total: 100)
                .tint(score > 70 ? .green : .orange)
                .accessibilityLabel("Confidence")
                .accessibilityValue("\(score) percent")
            Text(summary).font(.body)
            Label(recommendation, systemImage: "arrow.right.circle.fill")
                .font(.subheadline.weight(.semibold)).foregroundStyle(.secondary)
        }
        .fleetCard()
    }
}

// MARK: - SectionHeader
struct SectionHeader: View {
    let title: String
    var actionTitle: String?
    var action: (() -> Void)?

    var body: some View {
        HStack {
            Text(title).font(.title3.bold())
            Spacer()
            if let actionTitle, let action {
                Button(actionTitle, action: action).font(.subheadline.weight(.semibold))
            }
        }
        .accessibilityAddTraits(.isHeader)
    }
}

// MARK: - EmptyStateView
struct EmptyStateView: View {
    let title: String
    let message: String
    let symbol: String

    var body: some View {
        ContentUnavailableView(title, systemImage: symbol, description: Text(message))
            .accessibilityElement(children: .combine)
    }
}

// MARK: - OfflineBanner
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
