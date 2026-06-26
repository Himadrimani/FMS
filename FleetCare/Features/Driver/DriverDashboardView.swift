//
//  DriverDashboardView.swift
//  FleetCare
//
//  Created by Purvanshi on 24/06/26.
//
import SwiftUI

struct DriverDashboardView: View {
    let trips: [FleetTrip]                       // vehicle is now per-trip, lives in TripDetailView

    @StateObject private var inspectionVM = InspectionVM()
    @State private var showReportDefect = false
    @State private var showNavigation = false
    @State private var showEmergencySOS = false

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 12) {
                topBar
                tripsList
                quickActions
            }
            .padding(16)
        }
        .background(Color(.systemGroupedBackground))
        .toolbar(.hidden, for: .navigationBar)
    }

    private var topBar: some View {
        HStack {
            Text("FleetSync")
                .font(.title2.weight(.bold))

            Spacer()

            Image(systemName: "bell")
                .font(.title3)
                .overlay(alignment: .topTrailing) {
                    Circle()
                        .fill(.red)
                        .frame(width: 8, height: 8)
                        .offset(x: 2, y: -2)
                }

            NavigationLink {
                AccountView()
            } label: {
                Image(systemName: "person.crop.circle.fill")
                    .font(.largeTitle)
                    .foregroundStyle(.blue)
                    .overlay(alignment: .bottomTrailing) {
                        Circle()
                            .fill(.green)
                            .frame(width: 14, height: 14)
                            .overlay {
                                Circle()
                                    .stroke(Color(.systemBackground), lineWidth: 2)
                            }
                    }
            }
            .accessibilityLabel("Account")
        }
        .padding(.leading, 8)
        .padding(.trailing, 16)
        .padding(.top, 8)
        .padding(.bottom, 4)
    }

    private var tripsList: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Upcoming Trips")
                .font(.title3.weight(.bold))
                .foregroundStyle(.primary)

            if trips.isEmpty {
                Text("No upcoming trips assigned.")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.vertical, 24)
            } else {
                ForEach(trips.prefix(5)) { trip in
                    TripCardView(trip: trip)
                }

                if trips.count > 5 {
                    NavigationLink {
                        DriverTripsView()
                    } label: {
                        HStack {
                            Text("See More Options")
                                .fontWeight(.semibold)
                            Image(systemName: "arrow.right")
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .foregroundStyle(.blue)
                        .background(Color.blue.opacity(0.1), in: RoundedRectangle(cornerRadius: 12))
                    }
                    .padding(.top, 4)
                }
            }
        }
    }

    private var quickActions: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("QUICK ACTIONS")
                .font(.footnote.weight(.semibold))
                .foregroundStyle(.secondary)

            HStack(spacing: 12) {
                QuickAction(title: "Report Defect") {
                    Image(systemName: "exclamationmark.triangle.fill")
                        .foregroundStyle(.white)
                        .frame(width: 40, height: 40)
                        .background(.red, in: Circle())
                } action: {
                    showReportDefect = true
                }

                QuickAction(title: "Resume Navigation") {
                    Image(systemName: "location.fill")
                        .foregroundStyle(.green)
                        .frame(width: 40, height: 40)
                        .background(Color.green.opacity(0.18), in: Circle())
                } action: {
                    showNavigation = true
                }

                QuickAction(title: "Emergency SOS") {
                    Text("SOS")
                        .font(.caption.bold())
                        .foregroundStyle(.white)
                        .frame(width: 40, height: 40)
                        .background(.red, in: Circle())
                } action: {
                    showEmergencySOS = true
                }
            }
            .navigationDestination(isPresented: $showReportDefect) {
                ReportDefectView(vm: inspectionVM)
            }
            .navigationDestination(isPresented: $showNavigation) {
                if let firstTrip = trips.first {
                    TripNavigationView(trip: firstTrip)
                }
            }
            .navigationDestination(isPresented: $showEmergencySOS) {
                EmergencySOSView()
            }
        }
        .padding(.top, 4)
    }
}

private struct TripCardView: View {
    let trip: FleetTrip
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {

            Text(trip.reference)
                .font(.headline.weight(.semibold))
                .foregroundStyle(.blue)

            HStack(alignment: .top, spacing: 14) {

                VStack(alignment: .leading, spacing: 0) {
                    HStack(alignment: .top, spacing: 14) {
                        VStack(spacing: 4) {
                            Circle()
                                .stroke(.blue, lineWidth: 3)
                                .frame(width: 16, height: 16)
                            Line()
                                .stroke(style: StrokeStyle(lineWidth: 2, dash: [3, 3]))
                                .foregroundStyle(.secondary.opacity(0.6))
                                .frame(width: 2, height: 48)
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
                    Text(timeFormatter.string(from: trip.scheduledAt))
                        .font(.title3.weight(.bold))
                        .foregroundStyle(.blue)
                    Text(dateFormatter.string(from: trip.scheduledAt))
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                }
                .frame(maxHeight: .infinity, alignment: .center)
            }

            Divider()

            HStack {
                Spacer()
                NavigationLink {
                    TripDetailView(trip: trip)
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

private struct CardBackground: ViewModifier {
    func body(content: Content) -> some View {
        content
            .padding(16)
            .background(Color(.secondarySystemGroupedBackground),
                       in: RoundedRectangle(cornerRadius: 16))
    }
}
private extension View {
    func cardStyle() -> some View { modifier(CardBackground()) }
}

private struct QuickAction<Icon: View>: View {
    let title: String
    @ViewBuilder let icon: () -> Icon
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                icon()
                Text(title)
                    .font(.caption)
                    .multilineTextAlignment(.center)
                    .foregroundStyle(.primary)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 14)
            .background(Color(.secondarySystemGroupedBackground),
                       in: RoundedRectangle(cornerRadius: 12))
        }
    }
}

private struct Line: Shape {
    func path(in rect: CGRect) -> Path {
        var p = Path()
        p.move(to: CGPoint(x: rect.midX, y: rect.minY))
        p.addLine(to: CGPoint(x: rect.midX, y: rect.maxY))
        return p
    }
}

private let timeFormatter: DateFormatter = {
    let f = DateFormatter(); f.dateFormat = "hh:mm a"; return f
}()
private let dateFormatter: DateFormatter = {
    let f = DateFormatter(); f.dateFormat = "dd MMM yyyy"; return f
}()

#Preview {
    NavigationStack {
        DriverDashboardView(
            trips: [
                FleetTrip(title: "Demo Trip", reference: "TRP-DEMO01",
                          origin: "Mumbai", destination: "Pune",
                          scheduledAt: Date(), status: .active, distanceKilometers: 150.0)
            ]
        )
    }
}
