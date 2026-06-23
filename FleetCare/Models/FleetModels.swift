import Foundation
import SwiftData

enum FleetStatus: String, Codable, CaseIterable {
    case active = "Active"
    case attention = "Needs Attention"
    case scheduled = "Scheduled"
    case completed = "Completed"
    case offline = "Offline"
}

@Model
final class Vehicle {
    @Attribute(.unique) var id: UUID
    var name: String
    var registration: String
    var make: String
    var model: String
    var year: Int
    var odometer: Double
    var statusRaw: String

    init(
        id: UUID = UUID(),
        name: String,
        registration: String,
        make: String,
        model: String,
        year: Int,
        odometer: Double,
        status: FleetStatus
    ) {
        self.id = id
        self.name = name
        self.registration = registration
        self.make = make
        self.model = model
        self.year = year
        self.odometer = odometer
        self.statusRaw = status.rawValue
    }

    var status: FleetStatus {
        get { FleetStatus(rawValue: statusRaw) ?? .offline }
        set { statusRaw = newValue.rawValue }
    }
}

@Model
final class FleetTrip {
    @Attribute(.unique) var id: UUID
    var title: String
    var origin: String
    var destination: String
    var scheduledAt: Date
    var statusRaw: String
    var distanceKilometers: Double

    init(
        id: UUID = UUID(),
        title: String,
        origin: String,
        destination: String,
        scheduledAt: Date,
        status: FleetStatus,
        distanceKilometers: Double
    ) {
        self.id = id
        self.title = title
        self.origin = origin
        self.destination = destination
        self.scheduledAt = scheduledAt
        self.statusRaw = status.rawValue
        self.distanceKilometers = distanceKilometers
    }

    var status: FleetStatus {
        get { FleetStatus(rawValue: statusRaw) ?? .scheduled }
        set { statusRaw = newValue.rawValue }
    }
}

@Model
final class WorkOrder {
    @Attribute(.unique) var id: UUID
    var title: String
    var vehicleName: String
    var priority: Int
    var dueAt: Date
    var statusRaw: String

    init(
        id: UUID = UUID(),
        title: String,
        vehicleName: String,
        priority: Int,
        dueAt: Date,
        status: FleetStatus
    ) {
        self.id = id
        self.title = title
        self.vehicleName = vehicleName
        self.priority = priority
        self.dueAt = dueAt
        self.statusRaw = status.rawValue
    }

    var status: FleetStatus {
        get { FleetStatus(rawValue: statusRaw) ?? .scheduled }
        set { statusRaw = newValue.rawValue }
    }
}

@Model
final class FleetMessage {
    @Attribute(.unique) var id: UUID
    var sender: String
    var body: String
    var sentAt: Date
    var isUnread: Bool

    init(id: UUID = UUID(), sender: String, body: String, sentAt: Date, isUnread: Bool) {
        self.id = id
        self.sender = sender
        self.body = body
        self.sentAt = sentAt
        self.isUnread = isUnread
    }
}
