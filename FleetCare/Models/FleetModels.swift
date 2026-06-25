import Foundation
import SwiftData

enum FleetStatus: String, Codable, CaseIterable {
    case active = "Active"
    case attention = "Needs Attention"
    case scheduled = "Scheduled"
    case completed = "Completed"
    case offline = "Offline"
}

// NEW: drives which photo/icon the dashboard shows for a vehicle.
// Add image sets named vehicle_truck / vehicle_van / vehicle_car /
// vehicle_2wheeler in Assets.xcassets and they're used automatically.
enum VehicleType: String, Codable, CaseIterable {
    case truck, van, car, twoWheeler, bus, auto

    var assetName: String {
        switch self {
        case .truck:      return "vehicle_truck"
        case .van:        return "vehicle_van"
        case .car:        return "vehicle_car"
        case .twoWheeler: return "vehicle_2wheeler"
        case .bus:        return "vehicle_bus"
        case .auto:       return "vehicle_auto"
        }
    }

    // SF Symbol fallback. Verify names in the SF Symbols app.
    var symbolName: String {
        switch self {
        case .truck:      return "truck.box.fill"
        case .van:        return "box.truck.fill"
        case .car:        return "car.fill"
        case .twoWheeler: return "scooter"
        case .bus:        return "bus.fill"
        case .auto:       return "car.fill"
        }
    }
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

    // NEW fields. Property-level defaults keep existing stores migrating
    // cleanly and existing call sites compiling.
    var vehicleTypeRaw: String = VehicleType.truck.rawValue
    var assignedAt: Date = Date.now
    var imageURLString: String? = nil

    init(
        id: UUID = UUID(),
        name: String,
        registration: String,
        make: String,
        model: String,
        year: Int,
        odometer: Double,
        status: FleetStatus,
        vehicleType: VehicleType = .truck,
        assignedAt: Date = .now,
        imageURLString: String? = nil
    ) {
        self.id = id
        self.name = name
        self.registration = registration
        self.make = make
        self.model = model
        self.year = year
        self.odometer = odometer
        self.statusRaw = status.rawValue
        self.vehicleTypeRaw = vehicleType.rawValue
        self.assignedAt = assignedAt
        self.imageURLString = imageURLString
    }

    var status: FleetStatus {
        get { FleetStatus(rawValue: statusRaw) ?? .offline }
        set { statusRaw = newValue.rawValue }
    }

    var vehicleType: VehicleType {
        get { VehicleType(rawValue: vehicleTypeRaw) ?? .truck }
        set { vehicleTypeRaw = newValue.rawValue }
    }

    var imageURL: URL? {
        guard let imageURLString else { return nil }
        return URL(string: imageURLString)
    }
}

@Model
final class FleetTrip {
    @Attribute(.unique) var id: UUID
    var title: String
    var reference: String = ""          // NEW: "TRP-101"
    var origin: String
    var destination: String
    var scheduledAt: Date
    var statusRaw: String
    var distanceKilometers: Double

    init(
        id: UUID = UUID(),
        title: String,
        reference: String = "",
        origin: String,
        destination: String,
        scheduledAt: Date,
        status: FleetStatus,
        distanceKilometers: Double
    ) {
        self.id = id
        self.title = title
        self.reference = reference
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
