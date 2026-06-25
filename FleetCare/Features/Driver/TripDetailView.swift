//
//  TripDetailView.swift
//  FleetCare
//
//  Created by Purvanshi on 24/06/26.
//
import SwiftUI
import UIKit

struct TripDetailView: View {
    let trip: FleetTrip

    var body: some View {
        List {
            Section {
                VStack(alignment: .leading, spacing: FleetSpacing.medium) {
                    Text(trip.title).font(.title.bold())
                    StatusBadge(status: trip.status)
                }
                .padding(.vertical, FleetSpacing.small)
            }
            Section("Route") {
                LabeledContent("From", value: trip.origin)
                LabeledContent("To", value: trip.destination)
                LabeledContent("Distance", value: trip.distanceKilometers.formatted(.number) + " km")
                LabeledContent("Departure", value: trip.scheduledAt, format: .dateTime.weekday().hour().minute())
            }
            Section {
                Button("Start Trip", systemImage: "play.fill") {}
                    .disabled(trip.status == .completed)
                Button("Log by Voice", systemImage: "waveform") {}
                Button("Report Delay", systemImage: "exclamationmark.bubble") {}
            }
        }
        .navigationTitle("Trip")
        .navigationBarTitleDisplayMode(.inline)
    }
}
