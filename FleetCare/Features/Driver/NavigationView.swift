//
//  NavigationView.swift
//  FleetCare
//
//  Created by kanak gupta on 26/06/26.
//

import SwiftUI
import MapKit

struct TripNavigationView: View {
    let trip: FleetTrip
    @Environment(\.dismiss) private var dismiss

    // Map region centred on Pune
    @State private var position: MapCameraPosition = .region(
        MKCoordinateRegion(
            center: CLLocationCoordinate2D(latitude: 18.5204, longitude: 73.8567),
            span: MKCoordinateSpan(latitudeDelta: 0.15, longitudeDelta: 0.15)
        )
    )

    var body: some View {
        ZStack(alignment: .bottom) {

            // ── Full-screen map ──────────────────────────────────────
            Map(position: $position)
                .ignoresSafeArea()

            // ── Bottom sheet card ────────────────────────────────────
            VStack(spacing: 0) {
                // Drag handle
                Capsule()
                    .fill(Color(.systemGray4))
                    .frame(width: 36, height: 4)
                    .padding(.top, 10)
                    .padding(.bottom, 16)

                VStack(spacing: 16) {

                    // Destination + ETA row
                    HStack(alignment: .top) {
                        HStack(spacing: 12) {
                            ZStack {
                                Circle()
                                    .fill(Color.blue.opacity(0.12))
                                    .frame(width: 44, height: 44)
                                Image(systemName: "mappin.circle.fill")
                                    .font(.title2)
                                    .foregroundStyle(.blue)
                            }

                            VStack(alignment: .leading, spacing: 2) {
                                Text("CURRENT DESTINATION")
                                    .font(.caption2.weight(.semibold))
                                    .foregroundStyle(.secondary)
                                    .tracking(0.5)
                                Text(trip.destination)
                                    .font(.title3.weight(.semibold))
                            }
                        }

                        Spacer()

                        VStack(alignment: .trailing, spacing: 0) {
                            Text("ETA")
                                .font(.caption2.weight(.semibold))
                                .foregroundStyle(.secondary)
                            Text("12:45")
                                .font(.title2.weight(.bold))
                                .foregroundStyle(.blue)
                            Text("PM")
                                .font(.caption.weight(.semibold))
                                .foregroundStyle(.blue)
                        }
                    }

                    Divider()

                    // Stats row
                    HStack(spacing: 0) {
                        Label("4.2 km remaining", systemImage: "location.circle")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)

                        Spacer()

                        Label("12 mins", systemImage: "clock")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }

                    // Resume button
                    Button {
                        // Hook up real navigation action here
                    } label: {
                        Label("Resume Navigation", systemImage: "play.fill")
                            .font(.headline)
                            .foregroundStyle(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(.blue, in: RoundedRectangle(cornerRadius: 14))
                    }
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 32)
            }
            .background(
                Color(.systemBackground)
                    .clipShape(RoundedRectangle(cornerRadius: 24))
                    .shadow(color: .black.opacity(0.10), radius: 20, x: 0, y: -4)
            )
        }
        .navigationTitle("Navigation")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button {
                    dismiss()
                } label: {
                    Image(systemName: "chevron.left")
                        .font(.body.weight(.semibold))
                }
            }
        }
        .toolbarBackground(.visible, for: .navigationBar)
        .navigationBarBackButtonHidden(true)
    }
}

// MARK: - Preview
#Preview {
    NavigationStack {
        TripNavigationView(trip: FleetTrip(title: "Demo Trip", origin: "Mumbai", destination: "Pune", scheduledAt: Date(), status: .active, distanceKilometers: 150.0))
    }
}
