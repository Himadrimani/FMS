import SwiftUI

struct MessagesView: View {
    private let conversations = [
        ("Operations", "Dock 4 is ready for arrival.", "2m", true),
        ("Maintenance Team", "The inspection photos are attached.", "1h", false),
        ("Atlas 12 Driver", "Traffic delay near Lonavala.", "3h", true)
    ]

    var body: some View {
        List(conversations, id: \.0) { item in
            NavigationLink {
                ChatDetailView(title: item.0)
            } label: {
                HStack(spacing: FleetSpacing.medium) {
                    ZStack(alignment: .topTrailing) {
                        Image(systemName: "person.2.circle.fill")
                            .font(.largeTitle)
                            .foregroundStyle(.brandSecondary)
                        if item.3 {
                            Circle().fill(.blue).frame(width: 10, height: 10)
                                .accessibilityHidden(true)
                        }
                    }
                    VStack(alignment: .leading, spacing: FleetSpacing.xSmall) {
                        HStack {
                            Text(item.0).font(.headline)
                            Spacer()
                            Text(item.2).font(.caption).foregroundStyle(.secondary)
                        }
                        Text(item.1)
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                            .lineLimit(1)
                    }
                }
                .padding(.vertical, FleetSpacing.xSmall)
                .accessibilityValue(item.3 ? "Unread" : "Read")
            }
        }
        .searchable(text: .constant(""), prompt: "Search conversations")
        .navigationTitle("Messages")
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
                        .padding()
                        .foregroundStyle(.white)
                        .background(.brandPrimary, in: .rect(cornerRadius: FleetRadius.card))
                        .frame(maxWidth: .infinity, alignment: .trailing)
                }
                .padding()
            }
            HStack {
                Button("", systemImage: "camera.fill") {}
                    .accessibilityLabel("Attach photo")
                TextField("Message", text: $message)
                    .textFieldStyle(.roundedBorder)
                Button("", systemImage: "arrow.up.circle.fill") {}
                    .font(.title2)
                    .accessibilityLabel("Send message")
                    .disabled(message.isEmpty)
            }
            .padding()
            .background(.bar)
        }
        .navigationTitle(title)
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct MoreFeaturesView: View {
    let role: UserRole

    private var groups: [(String, [(String, String)])] {
        switch role {
        case .fleetManager:
            [
                ("Operations", [("User Management", "person.2"), ("Trip Management", "point.topleft.down.to.point.bottomright.curvepath"), ("Maintenance", "wrench.and.screwdriver"), ("Fuel Management", "fuelpump"), ("Geofences", "scope")]),
                ("Intelligence", [("Reports", "chart.bar"), ("AI Insights", "sparkles"), ("Messages", "message")])
            ]
        case .driver:
            [
                ("Trip tools", [("Pre-Trip Inspection", "checklist"), ("Defect Reporting", "exclamationmark.bubble"), ("Route Navigation", "map"), ("Voice Logging", "waveform"), ("Emergency Reporting", "sos.circle")]),
                ("History", [("Post-Trip Inspection", "checkmark.seal"), ("Trip Summaries", "doc.text")])
            ]
        case .maintenance:
            [
                ("Workshop", [("Vehicle Inspection", "checklist"), ("Repair Evidence", "camera"), ("Quality Inspection", "checkmark.seal"), ("Maintenance History", "clock.arrow.circlepath")]),
                ("Supply", [("Purchase Requests", "cart"), ("Communication Center", "message")])
            ]
        }
    }

    var body: some View {
        List {
            ForEach(groups, id: \.0) { group in
                Section(group.0) {
                    ForEach(group.1, id: \.0) { feature in
                        NavigationLink {
                            FeatureCollectionView(title: feature.0, role: role)
                        } label: {
                            Label(feature.0, systemImage: feature.1)
                        }
                    }
                }
            }
            Section {
                NavigationLink {
                    AccountView()
                } label: {
                    Label("Account", systemImage: "person.crop.circle")
                }
            }
        }
        .navigationTitle("More")
    }
}

struct FeatureCollectionView: View {
    let title: String
    let role: UserRole

    var body: some View {
        List {
            Section {
                Text(purpose)
                    .font(.body)
                    .foregroundStyle(.secondary)
            }
            Section("At a glance") {
                LabeledContent("Open", value: "4")
                LabeledContent("Due today", value: "2")
                LabeledContent("Completed this week", value: "18")
            }
            Section("Recent activity") {
                Label("Updated 12 minutes ago", systemImage: "clock")
                Label("Synced securely", systemImage: "checkmark.icloud")
            }
        }
        .navigationTitle(title)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button("Add", systemImage: "plus") {}
            }
        }
    }

    private var purpose: String {
        "\(title) is organized around the most urgent work for the \(role.rawValue.lowercased()) role. Search, filtering, empty, loading, error, and offline states use the shared system components."
    }
}

#Preview("Messages") {
    NavigationStack {
        MessagesView()
    }
}

#Preview("More - Maintenance") {
    NavigationStack {
        MoreFeaturesView(role: .maintenance)
    }
    .environment(SessionStore())
}

#Preview("Feature Collection") {
    NavigationStack {
        FeatureCollectionView(title: "Purchase Requests", role: .maintenance)
    }
}
