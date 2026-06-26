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
    var body: some View {
        TabView {
            Tab("Today", systemImage: "steeringwheel") {
                NavigationStack {
                    // SampleData for now — swap for SessionStore driver
                    // and the @Query'd assigned vehicle / current trip.
                    DriverDashboardView(
                        vehicle: SampleData.vehicles[0],
                        trip: SampleData.trips[0]
                    )
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
    }
}
