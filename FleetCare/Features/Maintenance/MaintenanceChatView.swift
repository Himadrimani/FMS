import SwiftUI

// MARK: - Chat Tab

struct MaintenanceChatView: View {
    var body: some View {
        ScrollView {
            LazyVStack(spacing: FleetSpacing.large) {
                // MARK: Fleet Manager Channel
                NavigationLink {
                    MaintenanceChatDetailView(channel: .fleetManager)
                } label: {
                    ChatChannelCard(
                        title: "Fleet Manager",
                        subtitle: "Work orders · Parts approval · Escalations",
                        lastMessage: "Brake pads approved for Orion 07. Proceed with replacement.",
                        time: "12m",
                        unreadCount: 2,
                        accentColor: .blue,
                        symbol: "person.badge.shield.checkmark.fill"
                    )
                }
                .buttonStyle(.plain)

                // MARK: Driver Channel
                NavigationLink {
                    MaintenanceChatDetailView(channel: .driver)
                } label: {
                    ChatChannelCard(
                        title: "Driver",
                        subtitle: "Defect clarifications · Repair confirmations",
                        lastMessage: "Vibration is most noticeable at 60+ km/h on highway.",
                        time: "1h",
                        unreadCount: 1,
                        accentColor: .green,
                        symbol: "steeringwheel.and.hands"
                    )
                }
                .buttonStyle(.plain)
            }
            .padding()
        }
        .background(Color.appBackground)
        .navigationTitle("Chat")
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
}

// MARK: - Chat Channel Card

private struct ChatChannelCard: View {
    let title: String
    let subtitle: String
    let lastMessage: String
    let time: String
    let unreadCount: Int
    let accentColor: Color
    let symbol: String

    var body: some View {
        HStack(alignment: .center, spacing: FleetSpacing.medium) {
            // Avatar
            ZStack {
                Circle()
                    .fill(Color(uiColor: .systemGray6))
                    .frame(width: 56, height: 56)
                Image(systemName: symbol)
                    .font(.title2)
                    .foregroundStyle(.secondary)
            }

            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text(title)
                        .font(.title3.weight(.semibold))
                    Spacer()
                    Text(time)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                    Image(systemName: "chevron.right")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                
                HStack {
                    Text(lastMessage)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .lineLimit(1)
                    
                    Spacer()
                    
                    if unreadCount > 0 {
                        Text("\(unreadCount)")
                            .font(.caption2.weight(.bold))
                            .foregroundStyle(.white)
                            .frame(width: 20, height: 20)
                            .background(Color.red, in: Circle())
                    }
                }
            }
        }
        .padding(.vertical, 4)
        .accessibilityElement(children: .combine)
    }
}

// MARK: - Chat Channel Enum

enum ChatChannel: String, Identifiable {
    case fleetManager = "Fleet Manager"
    case driver = "Driver"

    var id: String { rawValue }

    var symbol: String {
        switch self {
        case .fleetManager: "person.badge.shield.checkmark.fill"
        case .driver: "steeringwheel.and.hands"
        }
    }

    var accentColor: Color {
        switch self {
        case .fleetManager: .blue
        case .driver: .green
        }
    }
}

// MARK: - Chat Detail View

struct MaintenanceChatDetailView: View {
    let channel: ChatChannel
    @State private var messageText = ""

    private var sampleMessages: [(text: String, isOutgoing: Bool, time: String)] {
        switch channel {
        case .fleetManager:
            [
                ("Work order #WO-1042 assigned: Inspect brake vibration on Orion 07.", false, "9:15 AM"),
                ("Acknowledged. Starting inspection now.", true, "9:18 AM"),
                ("Front brake pads worn to 2mm. Need replacement parts.", true, "9:45 AM"),
                ("Brake pads approved for Orion 07. Proceed with replacement.", false, "9:58 AM"),
                ("Confirmed. Will update once done.", true, "10:01 AM")
            ]
        case .driver:
            [
                ("I noticed vibration when braking at high speed.", false, "8:30 AM"),
                ("Can you tell me which wheel it seems to come from?", true, "8:32 AM"),
                ("Vibration is most noticeable at 60+ km/h on highway.", false, "8:45 AM"),
                ("Thanks, I'll check the front discs during inspection.", true, "8:47 AM")
            ]
        }
    }

    private var quickReplies: [String] {
        switch channel {
        case .fleetManager:
            ["Parts needed", "Work complete", "Need approval", "Escalation"]
        case .driver:
            ["Vehicle ready", "Need more info", "Under repair", "Inspection done"]
        }
    }

    var body: some View {
        VStack(spacing: 0) {
            // MARK: Messages
            ScrollView {
                LazyVStack(spacing: FleetSpacing.medium) {
                    ForEach(sampleMessages.indices, id: \.self) { index in
                        let msg = sampleMessages[index]
                        ChatBubble(
                            text: msg.text,
                            time: msg.time,
                            isOutgoing: msg.isOutgoing,
                            accentColor: channel.accentColor
                        )
                    }
                }
                .padding()
            }

            Divider()

            // MARK: Quick Replies
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: FleetSpacing.small) {
                    ForEach(quickReplies, id: \.self) { reply in
                        Button {
                            messageText = reply
                        } label: {
                            Text(reply)
                                .font(.caption.weight(.semibold))
                                .padding(.horizontal, FleetSpacing.medium)
                                .padding(.vertical, FleetSpacing.small)
                                .background(.brandPrimary.opacity(0.1), in: Capsule())
                                .foregroundStyle(.brandPrimary)
                        }
                    }
                }
                .padding(.horizontal)
                .padding(.vertical, FleetSpacing.small)
            }

            Divider()

            // MARK: Input Bar
            HStack(spacing: FleetSpacing.medium) {
                Button {
                    // Camera action
                } label: {
                    Image(systemName: "camera.fill")
                        .font(.title3)
                        .foregroundStyle(.secondary)
                }
                .accessibilityLabel("Attach photo")

                TextField("Message", text: $messageText)
                    .textFieldStyle(.roundedBorder)

                Button {
                    messageText = ""
                } label: {
                    Image(systemName: "arrow.up.circle.fill")
                        .font(.title2)
                        .foregroundStyle(messageText.isEmpty ? Color.secondary : Color.brandPrimary)
                }
                .disabled(messageText.isEmpty)
                .accessibilityLabel("Send message")
            }
            .padding()
            .background(.bar)
        }
        .navigationTitle(channel.rawValue)
        .navigationBarTitleDisplayMode(.inline)
    }
}

// MARK: - Chat Bubble

private struct ChatBubble: View {
    let text: String
    let time: String
    let isOutgoing: Bool
    let accentColor: Color

    var body: some View {
        HStack {
            if isOutgoing { Spacer(minLength: 60) }

            VStack(alignment: isOutgoing ? .trailing : .leading, spacing: FleetSpacing.xSmall) {
                Text(text)
                    .font(.body)
                    .padding(FleetSpacing.medium)
                    .foregroundStyle(isOutgoing ? .white : .primary)
                    .background {
                        RoundedRectangle(cornerRadius: FleetRadius.card, style: .continuous)
                            .fill(isOutgoing ? Color.brandPrimary : Color(.secondarySystemGroupedBackground))
                    }

                Text(time)
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }

            if !isOutgoing { Spacer(minLength: 60) }
        }
        .accessibilityElement(children: .combine)
    }
}

#Preview("Chat List") {
    NavigationStack {
        MaintenanceChatView()
    }
}

#Preview("Chat Detail - Fleet Manager") {
    NavigationStack {
        MaintenanceChatDetailView(channel: .fleetManager)
    }
}




