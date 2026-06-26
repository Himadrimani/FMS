//
//  TripDetailView.swift
//  FleetCare
//
//  Created by Purvanshi on 24/06/26.
//
import SwiftUI

struct TripDetailView: View {
    let trip: FleetTrip

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                headerCard
                routeCard
                infoCard
                actions
            }
            .padding(16)
        }
        .background(Color(.systemGroupedBackground))
        .navigationTitle("Trip Details")
        .navigationBarTitleDisplayMode(.inline)
    }

    // MARK: Header — reference, status, title
    private var headerCard: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Text(trip.reference)
                    .font(.headline.weight(.semibold))
                    .foregroundStyle(.blue)
                Spacer()
                StatusBadge(status: trip.status)
            }
            Text(trip.title)
                .font(.title2.bold())
        }
        .cardStyle()
    }

    // MARK: Route — timeline + scheduled
    private var routeCard: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("ROUTE")
                .font(.footnote.weight(.semibold))
                .foregroundStyle(.secondary)

            HStack(alignment: .top, spacing: 14) {

                VStack(alignment: .leading, spacing: 0) {
                    HStack(alignment: .top, spacing: 14) {
                        VStack(spacing: 4) {
                            Circle()
                                .stroke(.blue, lineWidth: 3)
                                .frame(width: 16, height: 16)
                            DetailLine()
                                .stroke(style: StrokeStyle(lineWidth: 2, dash: [3, 3]))
                                .foregroundStyle(.secondary.opacity(0.6))
                                .frame(width: 2, height: 40)
                        }
                        .frame(width: 16)

                        VStack(alignment: .leading, spacing: 2) {
                            Text("Departure")
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                            Text(trip.origin)
                                .font(.title3.weight(.semibold))
                        }
                    }

                    HStack(alignment: .top, spacing: 14) {
                        Circle()
                            .fill(.blue)
                            .frame(width: 16, height: 16)
                        VStack(alignment: .leading, spacing: 2) {
                            Text("Destination")
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                            Text(trip.destination)
                                .font(.title3.weight(.semibold))
                        }
                    }
                }

                Spacer(minLength: 12)

                VStack(alignment: .trailing, spacing: 2) {
                    Text("Scheduled")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                    Text(trip.scheduledAt, format: .dateTime.hour().minute())
                        .font(.title3.weight(.bold))
                        .foregroundStyle(.blue)
                    Text(trip.scheduledAt, format: .dateTime.day().month().year())
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                }
                .frame(maxHeight: .infinity, alignment: .center)
            }
        }
        .cardStyle()
    }

    // MARK: Info — distance, drive time, arrival
    private var infoCard: some View {
        VStack(spacing: 0) {
            infoRow("Distance", "\(trip.distanceKilometers.formatted(.number)) km")
            Divider()
            infoRow("Est. drive time", estimatedDuration)
            Divider()
            infoRow("Est. arrival", estimatedArrival)
        }
        .cardStyle()
    }

    private func infoRow(_ label: String, _ value: String) -> some View {
        HStack {
            Text(label).foregroundStyle(.secondary)
            Spacer()
            Text(value).fontWeight(.medium)
        }
        .font(.subheadline)
        .padding(.vertical, 12)
    }

    // MARK: Actions (kept from your original)
    private var actions: some View {
        VStack(spacing: 12) {
            Button { } label: {
                Label("Start Trip", systemImage: "play.fill")
                    .font(.headline)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
                    .foregroundStyle(.white)
                    .background(.blue, in: RoundedRectangle(cornerRadius: 14))
            }
            .disabled(trip.status == .completed)

            HStack(spacing: 12) {
                Button { } label: {
                    Label("Log by Voice", systemImage: "waveform")
                        .font(.subheadline.weight(.medium))
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                        .background(Color(.secondarySystemGroupedBackground),
                                   in: RoundedRectangle(cornerRadius: 12))
                }
                Button { } label: {
                    Label("Report Delay", systemImage: "exclamationmark.bubble")
                        .font(.subheadline.weight(.medium))
                        .foregroundStyle(.orange)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                        .background(Color.orange.opacity(0.12),
                                   in: RoundedRectangle(cornerRadius: 12))
                }
            }
        }
        .padding(.top, 4)
    }

    // MARK: Estimates (assume ~45 km/h average — swap for real routing later)
    private var estimatedDuration: String {
        let totalMinutes = Int((trip.distanceKilometers / 45.0 * 60).rounded())
        let h = totalMinutes / 60, m = totalMinutes % 60
        return h > 0 ? "\(h) hr \(m) min" : "\(m) min"
    }
    private var estimatedArrival: String {
        let seconds = trip.distanceKilometers / 45.0 * 3600
        return trip.scheduledAt.addingTimeInterval(seconds)
            .formatted(.dateTime.hour().minute())
    }
}

// Local helpers — move into Components/SharedComponents later to dedupe
// with the dashboard's copies.
private extension View {
    func cardStyle() -> some View {
        padding(16)
            .background(Color(.secondarySystemGroupedBackground),
                       in: RoundedRectangle(cornerRadius: 16))
    }
}

private struct DetailLine: Shape {
    func path(in rect: CGRect) -> Path {
        var p = Path()
        p.move(to: CGPoint(x: rect.midX, y: rect.minY))
        p.addLine(to: CGPoint(x: rect.midX, y: rect.maxY))
        return p
    }
}

#Preview {
    NavigationStack {
        TripDetailView(trip: FleetTrip(title: "Demo Trip", origin: "Mumbai", destination: "Pune", scheduledAt: Date(), status: .active, distanceKilometers: 150.0))
    }
}
