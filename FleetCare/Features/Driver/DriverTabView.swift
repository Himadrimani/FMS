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
                        if !supabase.trips.isEmpty {
                            DriverDashboardView(trips: supabase.trips)
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
    //            Tab("More", systemImage: "ellipsis") {
    //                NavigationStack { MoreFeaturesView(role: .driver) }
    //            }
            }
            .task {
                if supabase.vehicles.isEmpty { await supabase.fetchVehicles() }
                // Fetch only trips assigned to THIS driver
                await supabase.fetchTrips(forDriverId: session.currentUserId)
            }
        }
    }
