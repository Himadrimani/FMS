//
//  DriverTripsView.swift
//  FleetCare
//
//  Created by Purvanshi on 24/06/26.
//
import SwiftUI
import UIKit

struct DriverTripsView: View {
    @StateObject private var supabase = SupabaseService.shared

    var body: some View {
        List(supabase.trips) { trip in
            NavigationLink {
                TripDetailView(trip: trip)
            } label: {
                TripRow(trip: trip)
            }
        }
        .navigationTitle("Assigned Trips")
    }
}

struct TripRow: View {
    let trip: FleetTrip

    var body: some View {
        VStack(alignment: .leading, spacing: FleetSpacing.small) {
            HStack {
                Text(trip.title).font(.headline)
                Spacer()
                StatusBadge(status: trip.status)
            }
            Text("\(trip.origin) → \(trip.destination)")
                .font(.subheadline)
                .foregroundStyle(.secondary)
            Text(trip.scheduledAt, format: .dateTime.weekday().hour().minute())
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .padding(.vertical, FleetSpacing.xSmall)
    }
}
