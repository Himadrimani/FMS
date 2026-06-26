//
//  DriverTabView.swift
//  FleetCare
//
//  Created by Purvanshi on 24/06/26.
//

import SwiftUI
import UIKit

// =====================================================================
// MARK: - Tab container
// =====================================================================

struct DriverTabView: View {
    @StateObject private var supabase = SupabaseService.shared
    @Environment(SessionStore.self) private var session

    var body: some View {
        TabView {
            Tab("Today", systemImage: "steeringwheel") {
                NavigationStack {
                    if let trip = supabase.trips.first {
                        // Find the vehicle assigned to this trip, or fall back to any vehicle
                        let vehicle = supabase.vehicles.first(where: { $0.id == trip.vehicleId })
                            ?? supabase.vehicles.first
                        if let vehicle = vehicle {
                            DriverDashboardView(vehicle: vehicle, trips: supabase.trips)
                        } else {
                            DriverDashboardView(
                                vehicle: Vehicle(name: "Assigned Vehicle", registration: "—", make: "—", model: "—", year: 2024, odometer: 0, status: .active),
                                trips: supabase.trips
                            )
                        }
                    } else if supabase.isLoading || supabase.isTripsLoading {
                        ProgressView("Loading your assignments...")
                    } else {
                        VStack(spacing: 16) {
                            Image(systemName: "steeringwheel.slash")
                                .font(.system(size: 48))
                                .foregroundColor(.secondary)
                            Text("No assignments today.")
                                .font(.headline)
                            Text("Your fleet manager hasn't assigned any trips yet.")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                    }
                }
            }
            Tab("Trips", systemImage: "point.topleft.down.to.point.bottomright.curvepath") {
                NavigationStack {
                    DriverTripsView()
                }
            }
            Tab("Messages", systemImage: "message.fill") {
                NavigationStack { MessagesView() }
            }
            Tab("More", systemImage: "ellipsis") {
                NavigationStack { MoreFeaturesView(role: .driver) }
            }
        }
        .task {
            if supabase.vehicles.isEmpty { await supabase.fetchVehicles() }
            // Fetch only trips assigned to THIS driver
            await supabase.fetchTrips(forDriverId: session.currentUserId)
        }
    }
}

