//
//  AssignedTripViews.swift
//  FleetCare
//
//  Created by kanak gupta on 24/06/26.
//
import SwiftUI

// MARK: - Trip Status Enum
enum MockTripStatus: String {
    case active = "Active"
    case scheduled = "Scheduled"
    case completed = "Completed"
    
    var color: Color {
        switch self {
        case .active: return .green
        case .scheduled: return .orange
        case .completed: return .gray
        }
    }
}

// MARK: - Mock Trip Model
struct MockDriverTrip: Identifiable {
    let id = UUID()
    let title: String
    let origin: String
    let destination: String
    let scheduledTime: String
    let status: MockTripStatus
}

struct AssignedTripsView: View {
    // Current/Upcoming Trips Data
    @State private var currentTrips = [
        MockDriverTrip(title: "Pune Distribution Run", origin: "Mumbai Hub", destination: "Pune DC", scheduledTime: "Wed, 1:18 PM", status: .active),
        MockDriverTrip(title: "Airport Cold Chain", origin: "Bengaluru Depot", destination: "Kempegowda Airport", scheduledTime: "Wed, 3:18 PM", status: .scheduled)
    ]
    
    // History/Previous Trips Data
    @State private var previousTrips = [
        MockDriverTrip(title: "Local Delivery Sector 4", origin: "Mumbai Hub", destination: "Thane Whse", scheduledTime: "Yesterday, 10:30 AM", status: .completed),
        MockDriverTrip(title: "Interstate Logistics", origin: "Surat Hub", destination: "Mumbai Hub", scheduledTime: "22 Jun, 4:15 PM", status: .completed)
    ]
    
    var body: some View {
        VStack(spacing: 0) {
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    
                    // Large Page Title
                    Text("Assigned Trips")
                        .font(.system(size: 34, weight: .bold))
                        .padding(.top, 16)
                        .padding(.horizontal, 4)
                    
                    // SECTION 1: Active & Upcoming Trips Card
                    VStack(alignment: .leading, spacing: 12) {
                        Text("CURRENT & UPCOMING")
                            .font(.caption2)
                            .fontWeight(.bold)
                            .foregroundColor(.secondary)
                            .padding(.horizontal, 4)
                        
                        VStack(spacing: 0) {
                            ForEach(currentTrips.indices, id: \.self) { index in
                                TripListRow(trip: currentTrips[index])
                                
                                if index < currentTrips.count - 1 {
                                    Divider()
                                        .padding(.horizontal, 16)
                                }
                            }
                        }
                        .background(Color(.systemBackground))
                        .cornerRadius(20)
                        .shadow(color: Color.black.opacity(0.03), radius: 8, x: 0, y: 4)
                    }
                    
                    // SECTION 2: Previous Trips History Card
                    VStack(alignment: .leading, spacing: 12) {
                        Text("PREVIOUS TRIPS")
                            .font(.caption2)
                            .fontWeight(.bold)
                            .foregroundColor(.secondary)
                            .padding(.horizontal, 4)
                        
                        VStack(spacing: 0) {
                            ForEach(previousTrips.indices, id: \.self) { index in
                                TripListRow(trip: previousTrips[index])
                                
                                if index < previousTrips.count - 1 {
                                    Divider()
                                        .padding(.horizontal, 16)
                                }
                            }
                        }
                        .background(Color(.systemBackground))
                        .cornerRadius(20)
                        .shadow(color: Color.black.opacity(0.03), radius: 8, x: 0, y: 4)
                    }
                }
                .padding()
            }
            .background(Color(.systemGroupedBackground).opacity(0.4))
        }
    }
}

// MARK: - Reusable Row Component
struct TripListRow: View {
    let trip: MockDriverTrip
    
    var body: some View {
        Button(action: {
            // Action to navigate to the detailed Trip View screen
        }) {
            VStack(alignment: .leading, spacing: 8) {
                // Title and Status Bullet
                HStack(alignment: .center) {
                    Text(trip.title)
                        .font(.headline)
                        .foregroundColor(.primary)
                    
                    Spacer()
                    
                    HStack(spacing: 6) {
                        Circle()
                            .fill(trip.status.color)
                            .frame(width: 8, height: 8)
                        Text(trip.status.rawValue)
                            .font(.subheadline)
                            .foregroundColor(trip.status.color)
                    }
                }
                
                // Route and Navigation Arrow Indicator
                HStack {
                    Text("\(trip.origin) → \(trip.destination)")
                        .font(.body)
                        .foregroundColor(.secondary)
                    
                    Spacer()
                    
                    Image(systemName: "chevron.right")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(.gray.opacity(0.5))
                }
                
                // Scheduled Date & Time
                Text(trip.scheduledTime)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            .padding(.all, 16)
            .contentShape(Rectangle()) // Ensures entire card is clickable
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Preview Setup
struct AssignedTripsView_Previews: PreviewProvider {
    static var previews: some View {
        AssignedTripsView()
    }
}
