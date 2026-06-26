//
//  VehicleDetailView.swift
//  FleetCare
//
//  Created by Purvanshi on 25/06/26.
//

import SwiftUI

struct DriverVehicleDetailView: View {

    let vehicle: Vehicle

    var body: some View {
        ScrollView {
            VStack(spacing: 16) {

                // MARK: Vehicle Header

                VStack(alignment: .leading, spacing: 12) {

                    HStack {

                        VehicleImageView(vehicle: vehicle)
                            .frame(width: 100, height: 70)

                        Spacer()

                        VStack(alignment: .trailing, spacing: 6) {

                            Text(vehicle.registration)
                                .font(.headline.bold())

                            Text("\(vehicle.make) \(vehicle.model)")
                                .foregroundStyle(.secondary)

                            Text(vehicle.status.rawValue)
                                .font(.caption.weight(.medium))
                                .padding(.horizontal, 10)
                                .padding(.vertical, 4)
                                .background(Color.green.opacity(0.15))
                                .foregroundStyle(.green)
                                .clipShape(Capsule())
                        }
                    }
                }
                .cardStyle()

                // MARK: Vehicle Information

                VStack(alignment: .leading, spacing: 12) {

                    Text("VEHICLE INFORMATION")
                        .font(.footnote.weight(.semibold))
                        .foregroundStyle(.secondary)

                    detailRow(
                        title: "Registration",
                        value: vehicle.registration
                    )

                    detailRow(
                        title: "Manufacturer",
                        value: vehicle.make
                    )

                    detailRow(
                        title: "Model",
                        value: vehicle.model
                    )

                    detailRow(
                        title: "Year",
                        value: "\(vehicle.year)"
                    )

                    detailRow(
                        title: "Odometer",
                        value: "\(Int(vehicle.odometer)) km"
                    )

                }
                .cardStyle()

                // MARK: Maintenance History

                VStack(alignment: .leading, spacing: 12) {

                    Text("MAINTENANCE HISTORY")
                        .font(.footnote.weight(.semibold))
                        .foregroundStyle(.secondary)

                    ForEach([MaintenanceRecord]()) { record in
                        MaintenanceRow(
                            title: record.title,
                            date: record.date
                        )
                    }
                }
                .cardStyle()
            }
            .padding()
        }
        .background(Color(.systemGroupedBackground))
        .navigationTitle("Vehicle Details")
        .navigationBarTitleDisplayMode(.inline)
    }

    private func detailRow(
        title: String,
        value: String
    ) -> some View {
        HStack {
            Text(title)
                .foregroundStyle(.secondary)

            Spacer()

            Text(value)
                .fontWeight(.medium)
        }
    }
}

// MARK: - Maintenance Row

private struct MaintenanceRow: View {

    let title: String
    let date: String

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {

            Text(title)
                .fontWeight(.medium)

            Text(date)
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.vertical, 4)
    }
}

private let dateFormatter: DateFormatter = {
    let f = DateFormatter()
    f.dateFormat = "dd MMM yyyy"
    return f
}()

#Preview {
    NavigationStack {
        DriverVehicleDetailView(
            vehicle: Vehicle(name: "Demo Vehicle", registration: "MH01AB1234", make: "Toyota", model: "Hilux", year: 2024, odometer: 1000, status: .active, vehicleType: .truck)
        )
    }
}
private extension View {
    func cardStyle() -> some View {
        self
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 24)
                    .fill(.background)
            )
    }
}
