import Foundation
import Supabase

// MARK: - Data Transfer Objects (DTOs) matching your Supabase tables

struct SupabaseVehicle: Codable, Identifiable {
    let id: UUID
    let vin: String
    let plate_number: String
    let make: String
    let model: String
    let vehicle_class: String
    let manufacturing_year: Int
    let current_odometer: Double
    let status: String
}

struct SupabaseTrip: Codable, Identifiable {
    let id: UUID
    let driver_id: UUID?
    let vehicle_id: UUID?
    let origin: String
    let destination: String
    let started_at: Date
    let status: String
    let distance_km: Double?
}

struct SupabaseWorkOrder: Codable, Identifiable {
    let id: UUID
    let vehicle_id: UUID?
    let tech_id: UUID?
    let description: String?
    let status: String
    let created_at: Date
}

struct SupabaseInventory: Codable, Identifiable {
    let id: UUID
    let part_name: String
    let current_quantity: Int
    let minimum_threshold: Int
}

// MARK: - Insert DTOs (for writing TO Supabase)

struct SupabaseTripInsert: Encodable {
    let driver_id: UUID
    let vehicle_id: UUID
    let origin: String
    let destination: String
    let required_vehicle_class: String
    let started_at: String   // ISO8601
    let status: String       // "ASSIGNED"
}

struct SupabaseWorkOrderInsert: Encodable {
    let vehicle_id: UUID
    let tech_id: UUID
    let status: String       // "PENDING"
}

// MARK: - Personnel DTO (for reading users by role)

struct PersonnelDTO: Codable, Identifiable, Hashable {
    let id: UUID
    let email: String
    let role: String
}

// MARK: - Status Mapping Helpers

private func mapTripStatus(_ dbStatus: String) -> FleetStatus {
    switch dbStatus {
    case "ASSIGNED":    return .scheduled
    case "IN_PROGRESS": return .active
    case "COMPLETED":   return .completed
    default:            return .scheduled
    }
}

private func mapWorkOrderStatus(_ dbStatus: String) -> FleetStatus {
    switch dbStatus {
    case "PENDING":     return .scheduled
    case "IN_PROGRESS": return .active
    case "RESOLVED":    return .completed
    default:            return .scheduled
    }
}

private func mapVehicleStatus(_ dbStatus: String) -> FleetStatus {
    switch dbStatus {
    case "ACTIVE":         return .active
    case "IN_MAINTENANCE": return .attention
    case "ARCHIVED":       return .offline
    default:               return .active
    }
}

// MARK: - Supabase Service

@MainActor
class SupabaseService: ObservableObject {
    static let shared = SupabaseService()
    
    @Published var vehicles: [Vehicle] = []
    @Published var trips: [FleetTrip] = []
    @Published var inventoryParts: [InventoryPart] = []
    @Published var workOrders: [WorkOrder] = []
    @Published var drivers: [PersonnelDTO] = []
    @Published var technicians: [PersonnelDTO] = []
    @Published var isLoading = false
    @Published var isTripsLoading = false
    
    // MARK: - Fetch Vehicles
    
    func fetchVehicles() async {
        isLoading = true
        defer { isLoading = false }
        do {
            let dtos: [SupabaseVehicle] = try await SupabaseConfig.client
                .from("vehicles")
                .select()
                .execute()
                .value
            
            self.vehicles = dtos.map { dto in
                let v = Vehicle(
                    id: dto.id,
                    name: "\(dto.make) \(dto.model)",
                    registration: dto.plate_number,
                    make: dto.make,
                    model: dto.model,
                    year: dto.manufacturing_year,
                    odometer: dto.current_odometer,
                    status: mapVehicleStatus(dto.status),
                    vehicleType: .truck
                )
                v.dbVehicleClass = dto.vehicle_class
                return v
            }
            print("✅ Successfully fetched \(dtos.count) vehicles from Supabase")
        } catch {
            print("❌ Failed to fetch vehicles from Supabase: \(error)")
            self.vehicles = []
        }
    }
    
    // MARK: - Fetch Trips
    
    func fetchTrips(forDriverId driverId: UUID? = nil) async {
        isTripsLoading = true
        defer { isTripsLoading = false }
        do {
            var query = SupabaseConfig.client
                .from("trips")
                .select()
            
            // TEMPORARY DEBUG: Fetch ALL trips to see if they exist
            print("🔍 fetchTrips is fetching ALL trips (Bypassing filter for debugging)")
            // if let driverId = driverId {
            //     query = query.eq("driver_id", value: driverId.uuidString.lowercased())
            // }
            
            let dtos: [SupabaseTrip] = try await query
                .execute()
                .value
            
            self.trips = dtos.map { dto in
                let ref = String(dto.id.uuidString.prefix(8)).uppercased()
                return FleetTrip(
                    id: dto.id,
                    title: "\(dto.origin) to \(dto.destination)",
                    reference: "TRP-\(ref)",
                    origin: dto.origin,
                    destination: dto.destination,
                    scheduledAt: dto.started_at,
                    status: mapTripStatus(dto.status),
                    distanceKilometers: dto.distance_km ?? 0.0,
                    driverId: dto.driver_id,
                    vehicleId: dto.vehicle_id
                )
            }
            print("✅ Successfully fetched \(dtos.count) trips from Supabase")
        } catch {
            print("❌ Failed to fetch trips from Supabase: \(error)")
            self.trips = []
        }
    }

    // MARK: - Fetch Inventory
    
    func fetchInventory() async {
        do {
            let dtos: [SupabaseInventory] = try await SupabaseConfig.client
                .from("inventory")
                .select()
                .execute()
                .value
            
            self.inventoryParts = dtos.map { dto in
                InventoryPart(
                    id: dto.id.uuidString,
                    name: dto.part_name,
                    category: .engine, // Default
                    currentQuantity: dto.current_quantity,
                    minimumQuantity: dto.minimum_threshold,
                    maximumQuantity: dto.minimum_threshold * 3,
                    reorderThreshold: dto.minimum_threshold + 5,
                    monthlyConsumption: 0,
                    previousMonthUsage: 0,
                    lastUpdated: Date()
                )
            }
            print("✅ Successfully fetched \(dtos.count) inventory parts")
        } catch {
            print("❌ Failed to fetch inventory: \(error)")
            self.inventoryParts = []
        }
    }
    
    // MARK: - Fetch Work Orders
    
    func fetchWorkOrders(forTechId techId: UUID? = nil) async {
        do {
            var query = SupabaseConfig.client
                .from("work_orders")
                .select()
            
            // Filter by technician if a specific techId is provided
            if let techId = techId {
                query = query.eq("tech_id", value: techId.uuidString)
            }
            
            let dtos: [SupabaseWorkOrder] = try await query
                .execute()
                .value
                
            self.workOrders = dtos.map { dto in
                // Try to find the matching vehicle name
                let vehicleName = vehicles.first(where: { $0.id == dto.vehicle_id })?.name ?? "Vehicle"
                
                return WorkOrder(
                    id: dto.id,
                    title: dto.description ?? "Work Order #\(dto.id.uuidString.prefix(6))",
                    vehicleName: vehicleName,
                    priority: 2,
                    dueAt: dto.created_at.addingTimeInterval(86400 * 3), // +3 days
                    status: mapWorkOrderStatus(dto.status),
                    techId: dto.tech_id,
                    vehicleId: dto.vehicle_id
                )
            }
            print("✅ Successfully fetched \(dtos.count) work orders")
        } catch {
            print("❌ Failed to fetch work orders: \(error)")
            self.workOrders = []
        }
    }
    
    // MARK: - Fetch Personnel (Drivers / Technicians)
    
    func fetchDrivers() async {
        do {
            let dtos: [PersonnelDTO] = try await SupabaseConfig.client
                .from("users")
                .select("id, email, role")
                .eq("role", value: "DRIVER")
                .execute()
                .value
            self.drivers = dtos
            print("✅ Fetched \(dtos.count) drivers")
        } catch {
            print("❌ Failed to fetch drivers: \(error)")
            self.drivers = []
        }
    }
    
    func fetchTechnicians() async {
        do {
            let dtos: [PersonnelDTO] = try await SupabaseConfig.client
                .from("users")
                .select("id, email, role")
                .eq("role", value: "TECH")
                .execute()
                .value
            self.technicians = dtos
            print("✅ Fetched \(dtos.count) technicians")
        } catch {
            print("❌ Failed to fetch technicians: \(error)")
            self.technicians = []
        }
    }
    
    // MARK: - Assign Trip (Insert)
    
    func assignTrip(
        driverId: UUID,
        vehicleId: UUID,
        vehicleClass: String,
        origin: String,
        destination: String,
        distance: Double
    ) async throws {
        let formatter = ISO8601DateFormatter()
        let insertDTO = SupabaseTripInsert(
            driver_id: driverId,
            vehicle_id: vehicleId,
            origin: origin,
            destination: destination,
            required_vehicle_class: vehicleClass,
            started_at: formatter.string(from: Date()),
            status: "ASSIGNED"
        )
        
        try await SupabaseConfig.client
            .from("trips")
            .insert(insertDTO)
            .execute()
        
        print("✅ Trip assigned successfully")
        
        // Refresh trips list
        await fetchTrips()
    }
    
    // MARK: - Create Work Order (Insert)
    
    func createWorkOrder(
        vehicleId: UUID,
        techId: UUID,
        description: String
    ) async throws {
        let insertDTO = SupabaseWorkOrderInsert(
            vehicle_id: vehicleId,
            tech_id: techId,
            status: "PENDING"
        )
        
        try await SupabaseConfig.client
            .from("work_orders")
            .insert(insertDTO)
            .execute()
        
        print("✅ Work order created successfully")
        
        // Refresh work orders list
        await fetchWorkOrders()
    }
}
