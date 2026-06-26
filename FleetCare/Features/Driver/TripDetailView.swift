//
//  TripDetailView.swift
//  FleetCare
//
//  Created by Purvanshi on 24/06/26.
//
import SwiftUI

struct TripDetailView: View {
    let trip: FleetTrip

    // Vehicles already live in memory after Supabase loads them.
    @ObservedObject private var supabase = SupabaseService.shared

    @State private var showInspection = false
    @State private var inspectionDone = false

    // Resolve the trip's vehicle by id from the loaded list.
    private var vehicle: Vehicle? {
        guard let vid = trip.vehicleId else { return nil }
        return supabase.vehicles.first { $0.id == vid }
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                headerCard
                vehicleSection
                routeCard
                infoCard
                inspectionCard
                actions
            }
            .padding(16)
        }
        .background(Color(.systemGroupedBackground))
        .navigationTitle("Trip Details")
        .navigationBarTitleDisplayMode(.inline)
        .task {
            // Make sure vehicles are available even if the user deep-links here.
            if supabase.vehicles.isEmpty { await supabase.fetchVehicles() }
        }
        .navigationDestination(isPresented: $showInspection) {
            DetailedInspectionView(onDone: {
                showInspection = false
                inspectionDone = true
            })
        }
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

    // MARK: Vehicle assigned (per trip)
    @ViewBuilder private var vehicleSection: some View {
        if let v = vehicle {
            vehicleCard(v)
        } else {
            vehicleUnavailableCard
        }
    }

    private func vehicleCard(_ v: Vehicle) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Vehicle Assigned")
                .font(.title3.weight(.bold))
                .foregroundStyle(.primary)

            VStack(alignment: .leading, spacing: 12) {
                HStack(alignment: .top, spacing: 12) {
                    Image(systemName: "car.fill")
                        .foregroundStyle(.blue)
                        .frame(width: 52, height: 52)
                        .background(Color.blue.opacity(0.12), in: Circle())

                    VStack(alignment: .leading, spacing: 6) {
                        Text(v.registration)
                            .font(.headline.weight(.semibold))
                            .lineLimit(1)
                        Text("\(v.make) \(v.model)")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                        StatusBadge(status: v.status)
                    }
                    Spacer()

                    VehicleImageView(vehicle: v)
                        .frame(width: 110, height: 70)
                }

                Divider()

                HStack {
                    Text("Assigned on \(v.assignedAt.formatted(.dateTime.day().month().year()))")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    Spacer()
                    NavigationLink {
                        DriverVehicleDetailView(vehicle: v)
                    } label: {
                        HStack(spacing: 2) {
                            Text("View Details").fontWeight(.semibold)
                            Image(systemName: "chevron.right")
                        }
                        .font(.subheadline)
                        .foregroundStyle(.blue)
                    }
                }
            }
            .cardStyle()
        }
    }

    private var vehicleUnavailableCard: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Vehicle Assigned")
                .font(.title3.weight(.bold))
                .foregroundStyle(.primary)

            HStack(spacing: 12) {
                Image(systemName: "car.fill")
                    .foregroundStyle(.secondary)
                    .frame(width: 52, height: 52)
                    .background(Color(.tertiarySystemFill), in: Circle())
                Text(trip.vehicleId == nil
                     ? "No vehicle assigned to this trip yet."
                     : "Loading vehicle…")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                Spacer()
            }
            .cardStyle()
        }
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

    // MARK: Pre-trip inspection (mandatory — gates Start Trip)
    private var inspectionCard: some View {
        let accent = inspectionDone ? Color.green : Color.orange
        return VStack(alignment: .leading, spacing: 14) {
            Text("PRE-TRIP INSPECTION (MANDATORY)")
                .font(.footnote.weight(.semibold))
                .foregroundStyle(accent)

            HStack(alignment: .top, spacing: 12) {
                Image(systemName: inspectionDone ? "checkmark.seal.fill" : "checklist")
                    .foregroundStyle(accent)
                    .frame(width: 52, height: 52)
                    .background(accent.opacity(0.15), in: Circle())

                VStack(alignment: .leading, spacing: 4) {
                    Text(inspectionDone ? "Status: Completed" : "Status: Pending")
                        .font(.headline)
                        .foregroundStyle(accent)
                }
                Spacer(minLength: 8)
            }

            if !inspectionDone {
                Button {
                    showInspection = true
                } label: {
                    HStack {
                        Text("Start Inspection").fontWeight(.semibold)
                        Image(systemName: "chevron.right")
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                    .foregroundStyle(.white)
                    .background(.orange, in: RoundedRectangle(cornerRadius: 12))
                }

                HStack(alignment: .top, spacing: 8) {
                    Image(systemName: "info.circle").foregroundStyle(.blue)
                    Text("You must complete the pre-trip inspection to start the trip.")
                        .font(.subheadline).foregroundStyle(.blue)
                }
                .padding(12)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(Color.blue.opacity(0.10), in: RoundedRectangle(cornerRadius: 10))
            }
        }
        .padding(16)
        .background(accent.opacity(0.10), in: RoundedRectangle(cornerRadius: 16))
        .overlay(RoundedRectangle(cornerRadius: 16).stroke(accent.opacity(0.25)))
    }

    // MARK: Actions — Start Trip locked until inspection passes
    private var actions: some View {
        VStack(spacing: 12) {
            Button { } label: {
                Label("Start Trip", systemImage: inspectionDone ? "play.fill" : "lock.fill")
                    .font(.headline)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
                    .foregroundStyle(.white)
                    .background(inspectionDone ? Color.blue : Color.gray,
                               in: RoundedRectangle(cornerRadius: 14))
            }
            .disabled(!inspectionDone || trip.status == .completed)

            if !inspectionDone {
                Text("Complete the pre-trip inspection to unlock.")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

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
        TripDetailView(trip: FleetTrip(title: "Demo Trip", reference: "TRP-DEMO01",
                                       origin: "Mumbai", destination: "Pune",
                                       scheduledAt: Date(), status: .active,
                                       distanceKilometers: 150.0))
    }
}
