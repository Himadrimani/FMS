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

enum ApprovalStatus: String, Codable, CaseIterable {
    case pending = "Pending"
    case approved = "Approved"
    case rejected = "Rejected"
}

enum InventoryCategory: String, Codable, CaseIterable, Identifiable {
    case engineParts = "Engine Parts"
    case brakeParts = "Brake Parts"
    case tires = "Tires"
    case electrical = "Electrical"
    case fluids = "Fluids"
    case generalMaintenance = "General Maintenance"
    
    var id: Self { self }
}

enum StockHealth: String, CaseIterable, Identifiable {
    case healthy = "Healthy"
    case lowStock = "Low Stock"
    case outOfStock = "Out of Stock"
    
    var id: Self { self }
}

@Model
final class FleetUser {
    @Attribute(.unique) var id: UUID
    @Attribute(.unique) var email: String
    var fullName: String
    var roleRaw: String
    var isActivated: Bool
    var hasTemporaryPassword: Bool
    
    init(
        id: UUID = UUID(),
        email: String,
        fullName: String,
        role: UserRole,
        isActivated: Bool = false,
        hasTemporaryPassword: Bool = true
    ) {
        self.id = id
        self.email = email
        self.fullName = fullName
        self.roleRaw = role.rawValue
        self.isActivated = isActivated
        self.hasTemporaryPassword = hasTemporaryPassword
    }
    
    var role: UserRole {
        get { UserRole(rawValue: roleRaw) ?? .driver }
        set { roleRaw = newValue.rawValue }
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
    var totalCostOfOwnership: Double = 0.0
    
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
        self.totalCostOfOwnership = 0.0
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
    var assignedDriverEmail: String
    var assignedVehicleRegistration: String
    var scheduledAt: Date
    var statusRaw: String
    var distanceKilometers: Double
    
    init(
        id: UUID = UUID(),
        title: String,
        reference: String = "",
        origin: String,
        destination: String,
        assignedDriverEmail: String = "",
        assignedVehicleRegistration: String = "",
        scheduledAt: Date,
        status: FleetStatus,
        distanceKilometers: Double
    ) {
        self.id = id
        self.title = title
        self.reference = reference
        self.origin = origin
        self.destination = destination
        self.assignedDriverEmail = assignedDriverEmail
        self.assignedVehicleRegistration = assignedVehicleRegistration
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
    var assignedTechnicianEmail: String
    var priority: Int
    var dueAt: Date
    var statusRaw: String
    
    var isExternalRepair: Bool = false
    var laborHours: Double = 0.0
    var partsUsed: [String] = []
    var technicianNotes: String = ""
    
    init(
        id: UUID = UUID(),
        title: String,
        vehicleName: String,
        assignedTechnicianEmail: String = "",
        priority: Int,
        dueAt: Date,
        status: FleetStatus,
        isExternalRepair: Bool = false,
        laborHours: Double = 0.0,
        partsUsed: [String] = [],
        technicianNotes: String = ""
    ) {
        self.id = id
        self.title = title
        self.vehicleName = vehicleName
        self.assignedTechnicianEmail = assignedTechnicianEmail
        self.priority = priority
        self.dueAt = dueAt
        self.statusRaw = status.rawValue
        self.isExternalRepair = isExternalRepair
        self.laborHours = laborHours
        self.partsUsed = partsUsed
        self.technicianNotes = technicianNotes
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
    var recipient: String
    var body: String
    var sentAt: Date
    var isUnread: Bool
    
    init(id: UUID = UUID(), sender: String, recipient: String = "", body: String, sentAt: Date, isUnread: Bool) {
        self.id = id
        self.sender = sender
        self.recipient = recipient
        self.body = body
        self.sentAt = sentAt
        self.isUnread = isUnread
    }
}

@Model
final class Inspection {
    @Attribute(.unique) var id: UUID
    var vehicleRegistration: String
    var tripTitle: String
    var type: String
    var passed: Bool
    var submittedByEmail: String
    var submittedAt: Date
    
    init(id: UUID = UUID(), vehicleRegistration: String, tripTitle: String, type: String, passed: Bool, submittedByEmail: String, submittedAt: Date = .now) {
        self.id = id
        self.vehicleRegistration = vehicleRegistration
        self.tripTitle = tripTitle
        self.type = type
        self.passed = passed
        self.submittedByEmail = submittedByEmail
        self.submittedAt = submittedAt
    }
}

@Model
final class DefectReport {
    @Attribute(.unique) var id: UUID
    var vehicleRegistration: String
    var reportedByEmail: String
    var severity: Int
    var summary: String
    var reviewStatusRaw: String
    var createdAt: Date
    
    init(id: UUID = UUID(), vehicleRegistration: String, reportedByEmail: String, severity: Int, summary: String, reviewStatus: ApprovalStatus = .pending, createdAt: Date = .now) {
        self.id = id
        self.vehicleRegistration = vehicleRegistration
        self.reportedByEmail = reportedByEmail
        self.severity = severity
        self.summary = summary
        self.reviewStatusRaw = reviewStatus.rawValue
        self.createdAt = createdAt
    }
    
    var reviewStatus: ApprovalStatus {
        get { ApprovalStatus(rawValue: reviewStatusRaw) ?? .pending }
        set { reviewStatusRaw = newValue.rawValue }
    }
}

@Model
final class MaintenanceTask {
    @Attribute(.unique) var id: UUID
    var workOrderTitle: String
    var title: String
    var isComplete: Bool
    var notes: String
    
    init(id: UUID = UUID(), workOrderTitle: String, title: String, isComplete: Bool = false, notes: String = "") {
        self.id = id
        self.workOrderTitle = workOrderTitle
        self.title = title
        self.isComplete = isComplete
        self.notes = notes
    }
}

@Model
final class MaintenanceHistory {
    @Attribute(.unique) var id: UUID
    var vehicleRegistration: String
    var workOrderTitle: String
    var technicianEmail: String
    var completedAt: Date
    var summary: String
    
    init(id: UUID = UUID(), vehicleRegistration: String, workOrderTitle: String, technicianEmail: String, completedAt: Date = .now, summary: String) {
        self.id = id
        self.vehicleRegistration = vehicleRegistration
        self.workOrderTitle = workOrderTitle
        self.technicianEmail = technicianEmail
        self.completedAt = completedAt
        self.summary = summary
    }
}

@Model
final class InventoryItem {
    @Attribute(.unique) var id: UUID
    var partID: String
    var partName: String
    var categoryRaw: String
    var quantity: Int
    var minimumQuantity: Int
    var maximumQuantity: Int
    var reorderThreshold: Int
    var lastUpdated: Date
    
    init(
        id: UUID = UUID(),
        partID: String,
        partName: String,
        category: InventoryCategory,
        quantity: Int,
        minimumQuantity: Int,
        maximumQuantity: Int,
        reorderThreshold: Int,
        lastUpdated: Date = .now
    ) {
        self.id = id
        self.partID = partID
        self.partName = partName
        self.categoryRaw = category.rawValue
        self.quantity = quantity
        self.minimumQuantity = minimumQuantity
        self.maximumQuantity = maximumQuantity
        self.reorderThreshold = reorderThreshold
        self.lastUpdated = lastUpdated
    }
    
    var category: InventoryCategory {
        get { InventoryCategory(rawValue: categoryRaw) ?? .generalMaintenance }
        set { categoryRaw = newValue.rawValue }
    }
    
    var stockHealth: StockHealth {
        if quantity == 0 {
            return .outOfStock
        }
        if quantity <= reorderThreshold {
            return .lowStock
        }
        return .healthy
    }
}

@Model
final class PurchaseRequest {
    @Attribute(.unique) var id: UUID
    var partName: String
    var quantity: Int
    var requestedByEmail: String
    var approvalStatusRaw: String
    var createdAt: Date
    
    init(id: UUID = UUID(), partName: String, quantity: Int, requestedByEmail: String, approvalStatus: ApprovalStatus = .pending, createdAt: Date = .now) {
        self.id = id
        self.partName = partName
        self.quantity = quantity
        self.requestedByEmail = requestedByEmail
        self.approvalStatusRaw = approvalStatus.rawValue
        self.createdAt = createdAt
    }
    
    var approvalStatus: ApprovalStatus {
        get { ApprovalStatus(rawValue: approvalStatusRaw) ?? .pending }
        set { approvalStatusRaw = newValue.rawValue }
    }
}

@Model
final class FuelLog {
    @Attribute(.unique) var id: UUID
    var vehicleRegistration: String
    var tripTitle: String
    var liters: Double
    var cost: Double
    var odometer: Double
    var loggedAt: Date
    
    init(id: UUID = UUID(), vehicleRegistration: String, tripTitle: String, liters: Double, cost: Double, odometer: Double, loggedAt: Date = .now) {
        self.id = id
        self.vehicleRegistration = vehicleRegistration
        self.tripTitle = tripTitle
        self.liters = liters
        self.cost = cost
        self.odometer = odometer
        self.loggedAt = loggedAt
    }
}

@Model
final class FleetNotification {
    @Attribute(.unique) var id: UUID
    var recipientEmail: String
    var trigger: String
    var title: String
    var body: String
    var isRead: Bool
    var createdAt: Date
    
    init(id: UUID = UUID(), recipientEmail: String, trigger: String, title: String, body: String, isRead: Bool = false, createdAt: Date = .now) {
        self.id = id
        self.recipientEmail = recipientEmail
        self.trigger = trigger
        self.title = title
        self.body = body
        self.isRead = isRead
        self.createdAt = createdAt
    }
}

@Model
final class ComplianceDocument {
    @Attribute(.unique) var id: UUID
    var vehicleRegistration: String
    var documentType: String
    var expiresAt: Date
    var statusRaw: String
    
    init(id: UUID = UUID(), vehicleRegistration: String, documentType: String, expiresAt: Date, status: FleetStatus) {
        self.id = id
        self.vehicleRegistration = vehicleRegistration
        self.documentType = documentType
        self.expiresAt = expiresAt
        self.statusRaw = status.rawValue
    }
}

@Model
final class AIAlert {
    @Attribute(.unique) var id: UUID
    var alertType: String
    var subject: String
    var score: Int
    var confidence: Double
    var recommendation: String
    var isReviewed: Bool
    var createdAt: Date
    
    init(id: UUID = UUID(), alertType: String, subject: String, score: Int, confidence: Double, recommendation: String, isReviewed: Bool = false, createdAt: Date = .now) {
        self.id = id
        self.alertType = alertType
        self.subject = subject
        self.score = score
        self.confidence = confidence
        self.recommendation = recommendation
        self.isReviewed = isReviewed
        self.createdAt = createdAt
    }
}
