import Foundation

enum SampleData {
    static let vehicles = [
        Vehicle(name: "Atlas 12", registration: "MH 12 AB 4821", make: "Tata", model: "Prima", year: 2024, odometer: 42_610, status: .active, vehicleType: .truck, assignedAt: .now.addingTimeInterval(-86_400 * 24)),
        Vehicle(name: "Orion 07", registration: "KA 01 MX 2084", make: "Ashok Leyland", model: "AVTR", year: 2023, odometer: 78_240, status: .attention, vehicleType: .truck, assignedAt: .now.addingTimeInterval(-86_400 * 120)),
        Vehicle(name: "Nova 19", registration: "DL 01 RT 9033", make: "Mahindra", model: "Furio", year: 2025, odometer: 16_090, status: .scheduled, vehicleType: .van, assignedAt: .now.addingTimeInterval(-86_400 * 10)),
        Vehicle(name: "Titan 05", registration: "MH 14 CD 5678", make: "Eicher", model: "Pro 3019", year: 2024, odometer: 35_420, status: .active, vehicleType: .truck, assignedAt: .now.addingTimeInterval(-86_400 * 25)),
        Vehicle(name: "Stellar 23", registration: "TN 07 EF 9012", make: "Tata", model: "LPT 1613", year: 2023, odometer: 89_150, status: .active, vehicleType: .truck, assignedAt: .now.addingTimeInterval(-86_400 * 60)),
        Vehicle(name: "Phoenix 08", registration: "KA 05 GH 3456", make: "Mahindra", model: "Bolero Pickup", year: 2025, odometer: 8_750, status: .scheduled, vehicleType: .van, assignedAt: .now.addingTimeInterval(-86_400 * 5)),
        Vehicle(name: "Comet 15", registration: "GJ 01 IJ 7890", make: "Ashok Leyland", model: "Partner", year: 2024, odometer: 28_930, status: .active, vehicleType: .van, assignedAt: .now.addingTimeInterval(-86_400 * 35)),
        Vehicle(name: "Nebula 31", registration: "UP 32 KL 2345", make: "Tata", model: "Ace", year: 2025, odometer: 12_340, status: .offline, vehicleType: .twoWheeler, assignedAt: .now.addingTimeInterval(-86_400 * 15))
    ]

    static let trips = [
        FleetTrip(title: "Pune Distribution Run", reference: "TRP-101", origin: "Mumbai Hub", destination: "Pune DC", scheduledAt: .now.addingTimeInterval(3_600), status: .active, distanceKilometers: 151),
        FleetTrip(title: "Airport Cold Chain", reference: "TRP-102", origin: "Bengaluru Depot", destination: "Kempegowda Airport", scheduledAt: .now.addingTimeInterval(10_800), status: .scheduled, distanceKilometers: 39),
        FleetTrip(title: "Delhi Express Delivery", reference: "TRP-103", origin: "Gurgaon Warehouse", destination: "Connaught Place", scheduledAt: .now.addingTimeInterval(14_400), status: .scheduled, distanceKilometers: 28),
        FleetTrip(title: "Chennai Logistics", reference: "TRP-104", origin: "Chennai Port", destination: "Sriperumbudur Industrial Area", scheduledAt: .now.addingTimeInterval(21_600), status: .scheduled, distanceKilometers: 45),
        FleetTrip(title: "Hyderabad Inter-city", reference: "TRP-105", origin: "Hyderabad Depot", destination: "Secunderabad Station", scheduledAt: .now.addingTimeInterval(7_200), status: .active, distanceKilometers: 12),
        FleetTrip(title: "Kolkata Night Run", reference: "TRP-106", origin: "Kolkata Dock", destination: "Howrah Market", scheduledAt: .now.addingTimeInterval(28_800), status: .scheduled, distanceKilometers: 18)
    ]

    static let workOrders = [
        WorkOrder(title: "Inspect brake vibration", vehicleName: "Orion 07", priority: 1, dueAt: .now.addingTimeInterval(7_200), status: .attention),
        WorkOrder(title: "40,000 km service", vehicleName: "Atlas 12", priority: 2, dueAt: .now.addingTimeInterval(86_400), status: .scheduled),
        WorkOrder(title: "Replace cabin filter", vehicleName: "Nova 19", priority: 3, dueAt: .now.addingTimeInterval(172_800), status: .scheduled),
        WorkOrder(title: "Engine temp anomaly check", vehicleName: "Atlas 12", priority: 1, dueAt: .now.addingTimeInterval(14_400), status: .attention),
        WorkOrder(title: "Tire pressure sensor fix", vehicleName: "Orion 07", priority: 2, dueAt: .now.addingTimeInterval(-3_600), status: .active),
        WorkOrder(title: "Coolant flush", vehicleName: "Nova 19", priority: 3, dueAt: .now.addingTimeInterval(-86_400), status: .completed),
        WorkOrder(title: "Battery health assessment", vehicleName: "Atlas 12", priority: 2, dueAt: .now.addingTimeInterval(-172_800), status: .completed),
        WorkOrder(title: "Windshield replacement", vehicleName: "Nova 19", priority: 1, dueAt: .now.addingTimeInterval(3_600), status: .attention)
    ]

    static let inventoryParts: [InventoryPart] = [
        InventoryPart(id: "ENG-1001", name: "Air Filter", category: .engine, currentQuantity: 18, minimumQuantity: 8, maximumQuantity: 48, reorderThreshold: 10, monthlyConsumption: 9, previousMonthUsage: 11, lastUpdated: .now.addingTimeInterval(-86_400 * 1)),
        InventoryPart(id: "ENG-1002", name: "Fuel Filter", category: .engine, currentQuantity: 7, minimumQuantity: 6, maximumQuantity: 36, reorderThreshold: 8, monthlyConsumption: 10, previousMonthUsage: 12, lastUpdated: .now.addingTimeInterval(-86_400 * 3)),
        InventoryPart(id: "ENG-1003", name: "Oil Filter", category: .engine, currentQuantity: 24, minimumQuantity: 12, maximumQuantity: 72, reorderThreshold: 14, monthlyConsumption: 16, previousMonthUsage: 18, lastUpdated: .now.addingTimeInterval(-86_400 * 2)),
        InventoryPart(id: "ENG-1004", name: "Spark Plug", category: .engine, currentQuantity: 32, minimumQuantity: 16, maximumQuantity: 96, reorderThreshold: 20, monthlyConsumption: 22, previousMonthUsage: 25, lastUpdated: .now.addingTimeInterval(-86_400 * 4)),
        InventoryPart(id: "ENG-1005", name: "Radiator", category: .engine, currentQuantity: 4, minimumQuantity: 2, maximumQuantity: 12, reorderThreshold: 3, monthlyConsumption: 2, previousMonthUsage: 3, lastUpdated: .now.addingTimeInterval(-86_400 * 6)),
        InventoryPart(id: "ENG-1006", name: "Water Pump", category: .engine, currentQuantity: 0, minimumQuantity: 2, maximumQuantity: 10, reorderThreshold: 3, monthlyConsumption: 3, previousMonthUsage: 2, lastUpdated: .now.addingTimeInterval(-86_400 * 5)),

        InventoryPart(id: "BRK-2001", name: "Brake Pads", category: .brake, currentQuantity: 8, minimumQuantity: 6, maximumQuantity: 40, reorderThreshold: 10, monthlyConsumption: 14, previousMonthUsage: 15, lastUpdated: .now.addingTimeInterval(-86_400 * 1)),
        InventoryPart(id: "BRK-2002", name: "Brake Disc", category: .brake, currentQuantity: 14, minimumQuantity: 6, maximumQuantity: 32, reorderThreshold: 8, monthlyConsumption: 6, previousMonthUsage: 7, lastUpdated: .now.addingTimeInterval(-86_400 * 2)),
        InventoryPart(id: "BRK-2003", name: "Brake Fluid", category: .brake, currentQuantity: 22, minimumQuantity: 8, maximumQuantity: 60, reorderThreshold: 12, monthlyConsumption: 11, previousMonthUsage: 10, lastUpdated: .now.addingTimeInterval(-86_400 * 3)),
        InventoryPart(id: "BRK-2004", name: "Brake Caliper", category: .brake, currentQuantity: 5, minimumQuantity: 4, maximumQuantity: 20, reorderThreshold: 6, monthlyConsumption: 5, previousMonthUsage: 4, lastUpdated: .now.addingTimeInterval(-86_400 * 4)),

        InventoryPart(id: "TIR-3001", name: "Front Tire", category: .tires, currentQuantity: 16, minimumQuantity: 8, maximumQuantity: 48, reorderThreshold: 12, monthlyConsumption: 10, previousMonthUsage: 9, lastUpdated: .now.addingTimeInterval(-86_400 * 2)),
        InventoryPart(id: "TIR-3002", name: "Rear Tire", category: .tires, currentQuantity: 10, minimumQuantity: 8, maximumQuantity: 48, reorderThreshold: 12, monthlyConsumption: 12, previousMonthUsage: 13, lastUpdated: .now.addingTimeInterval(-86_400 * 1)),
        InventoryPart(id: "TIR-3003", name: "Wheel Rim", category: .tires, currentQuantity: 6, minimumQuantity: 3, maximumQuantity: 18, reorderThreshold: 4, monthlyConsumption: 3, previousMonthUsage: 2, lastUpdated: .now.addingTimeInterval(-86_400 * 7)),
        InventoryPart(id: "TIR-3004", name: "Wheel Bearing", category: .tires, currentQuantity: 4, minimumQuantity: 4, maximumQuantity: 24, reorderThreshold: 6, monthlyConsumption: 6, previousMonthUsage: 5, lastUpdated: .now.addingTimeInterval(-86_400 * 5)),

        InventoryPart(id: "ELE-4001", name: "Battery", category: .electrical, currentQuantity: 9, minimumQuantity: 5, maximumQuantity: 24, reorderThreshold: 7, monthlyConsumption: 5, previousMonthUsage: 6, lastUpdated: .now.addingTimeInterval(-86_400 * 1)),
        InventoryPart(id: "ELE-4002", name: "Alternator", category: .electrical, currentQuantity: 3, minimumQuantity: 2, maximumQuantity: 12, reorderThreshold: 3, monthlyConsumption: 2, previousMonthUsage: 3, lastUpdated: .now.addingTimeInterval(-86_400 * 8)),
        InventoryPart(id: "ELE-4003", name: "Starter Motor", category: .electrical, currentQuantity: 2, minimumQuantity: 2, maximumQuantity: 10, reorderThreshold: 3, monthlyConsumption: 3, previousMonthUsage: 2, lastUpdated: .now.addingTimeInterval(-86_400 * 4)),
        InventoryPart(id: "ELE-4004", name: "Headlight", category: .electrical, currentQuantity: 20, minimumQuantity: 8, maximumQuantity: 50, reorderThreshold: 12, monthlyConsumption: 9, previousMonthUsage: 10, lastUpdated: .now.addingTimeInterval(-86_400 * 2)),
        InventoryPart(id: "ELE-4005", name: "Fuse", category: .electrical, currentQuantity: 64, minimumQuantity: 25, maximumQuantity: 150, reorderThreshold: 30, monthlyConsumption: 28, previousMonthUsage: 30, lastUpdated: .now.addingTimeInterval(-86_400 * 3)),

        InventoryPart(id: "FLD-5001", name: "Engine Oil", category: .fluids, currentQuantity: 28, minimumQuantity: 16, maximumQuantity: 80, reorderThreshold: 20, monthlyConsumption: 18, previousMonthUsage: 20, lastUpdated: .now.addingTimeInterval(-86_400 * 1)),
        InventoryPart(id: "FLD-5002", name: "Coolant", category: .fluids, currentQuantity: 14, minimumQuantity: 8, maximumQuantity: 50, reorderThreshold: 10, monthlyConsumption: 8, previousMonthUsage: 9, lastUpdated: .now.addingTimeInterval(-86_400 * 2)),
        InventoryPart(id: "FLD-5003", name: "Transmission Oil", category: .fluids, currentQuantity: 6, minimumQuantity: 6, maximumQuantity: 36, reorderThreshold: 8, monthlyConsumption: 9, previousMonthUsage: 8, lastUpdated: .now.addingTimeInterval(-86_400 * 6)),
        InventoryPart(id: "FLD-5004", name: "Windshield Fluid", category: .fluids, currentQuantity: 18, minimumQuantity: 10, maximumQuantity: 60, reorderThreshold: 12, monthlyConsumption: 12, previousMonthUsage: 11, lastUpdated: .now.addingTimeInterval(-86_400 * 3)),

        InventoryPart(id: "GEN-6001", name: "Nuts", category: .generalMaintenance, currentQuantity: 120, minimumQuantity: 60, maximumQuantity: 300, reorderThreshold: 80, monthlyConsumption: 58, previousMonthUsage: 64, lastUpdated: .now.addingTimeInterval(-86_400 * 2)),
        InventoryPart(id: "GEN-6002", name: "Bolts", category: .generalMaintenance, currentQuantity: 96, minimumQuantity: 60, maximumQuantity: 300, reorderThreshold: 80, monthlyConsumption: 72, previousMonthUsage: 70, lastUpdated: .now.addingTimeInterval(-86_400 * 2)),
        InventoryPart(id: "GEN-6003", name: "Belts", category: .generalMaintenance, currentQuantity: 11, minimumQuantity: 6, maximumQuantity: 36, reorderThreshold: 8, monthlyConsumption: 7, previousMonthUsage: 8, lastUpdated: .now.addingTimeInterval(-86_400 * 4)),
        InventoryPart(id: "GEN-6004", name: "Hoses", category: .generalMaintenance, currentQuantity: 9, minimumQuantity: 8, maximumQuantity: 42, reorderThreshold: 10, monthlyConsumption: 10, previousMonthUsage: 9, lastUpdated: .now.addingTimeInterval(-86_400 * 5)),
        InventoryPart(id: "GEN-6005", name: "Clamps", category: .generalMaintenance, currentQuantity: 46, minimumQuantity: 24, maximumQuantity: 120, reorderThreshold: 30, monthlyConsumption: 24, previousMonthUsage: 27, lastUpdated: .now.addingTimeInterval(-86_400 * 1))
    ]
    
    static let maintenanceHistory: [MaintenanceRecord] = [
        MaintenanceRecord(
            title: "Oil Change",
            date: "12 Jun 2026"
        ),

        MaintenanceRecord(
            title: "Brake Inspection",
            date: "01 Jun 2026"
        ),

        MaintenanceRecord(
            title: "Tyre Replacement",
            date: "20 May 2026"
        ),

        MaintenanceRecord(
            title: "Battery Check",
            date: "05 May 2026"
        )
    ]

    static let drivers = [
        Driver(name: "Rajesh Kumar", phone: "+91 98765 43210", licenseNumber: "MH-2023-45678", status: .available),
        Driver(name: "Amit Singh", phone: "+91 98765 43211", licenseNumber: "MH-2023-45679", status: .onTrip, currentVehicleID: SampleData.vehicles[0].id, currentTripID: SampleData.trips[0].id, assignedAt: .now.addingTimeInterval(-3600)),
        Driver(name: "Priya Sharma", phone: "+91 98765 43212", licenseNumber: "MH-2023-45680", status: .available),
        Driver(name: "Vikram Patel", phone: "+91 98765 43213", licenseNumber: "MH-2023-45681", status: .offline),
        Driver(name: "Suresh Reddy", phone: "+91 98765 43214", licenseNumber: "KA-2023-45682", status: .onTrip, currentVehicleID: SampleData.vehicles[3].id, currentTripID: SampleData.trips[4].id, assignedAt: .now.addingTimeInterval(-7200)),
        Driver(name: "Anita Desai", phone: "+91 98765 43215", licenseNumber: "TN-2023-45683", status: .available),
        Driver(name: "Rahul Mehta", phone: "+91 98765 43216", licenseNumber: "DL-2023-45684", status: .onTrip, currentVehicleID: SampleData.vehicles[4].id, currentTripID: SampleData.trips[1].id, assignedAt: .now.addingTimeInterval(-5400)),
        Driver(name: "Kavita Nair", phone: "+91 98765 43217", licenseNumber: "GJ-2023-45685", status: .available)
    ]

    static let maintenancePersonnel = [
        MaintenancePersonnel(name: "Suresh Mechanic", phone: "+91 98765 43220", specialization: "Engine Repair", status: .available),
        MaintenancePersonnel(name: "Ravi Electrician", phone: "+91 98765 43221", specialization: "Electrical Systems", status: .busy),
        MaintenancePersonnel(name: "Deepak Technician", phone: "+91 98765 43222", specialization: "General Maintenance", status: .available),
        MaintenancePersonnel(name: "Mahesh Welder", phone: "+91 98765 43223", specialization: "Body Work", status: .available),
        MaintenancePersonnel(name: "Sunil Specialist", phone: "+91 98765 43224", specialization: "Hydraulics", status: .busy),
        MaintenancePersonnel(name: "Ramesh Painter", phone: "+91 98765 43225", specialization: "Paint & Finish", status: .available)
    ]
}


