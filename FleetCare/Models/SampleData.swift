import Foundation

enum SampleData {
    static let vehicles = [
        Vehicle(name: "Atlas 12", registration: "MH 12 AB 4821", make: "Tata", model: "Prima", year: 2024, odometer: 42_610, status: .active, vehicleType: .truck, assignedAt: .now.addingTimeInterval(-86_400 * 48)),
        Vehicle(name: "Orion 07", registration: "KA 01 MX 2084", make: "Ashok Leyland", model: "AVTR", year: 2023, odometer: 78_240, status: .attention, vehicleType: .truck, assignedAt: .now.addingTimeInterval(-86_400 * 120)),
        Vehicle(name: "Nova 19", registration: "DL 01 RT 9033", make: "Mahindra", model: "Furio", year: 2025, odometer: 16_090, status: .scheduled, vehicleType: .van, assignedAt: .now.addingTimeInterval(-86_400 * 10))
    ]

    static let trips = [
        FleetTrip(title: "Pune Distribution Run", reference: "TRP-101", origin: "Mumbai Hub", destination: "Pune DC", scheduledAt: .now.addingTimeInterval(3_600), status: .active, distanceKilometers: 151),
        FleetTrip(title: "Airport Cold Chain", reference: "TRP-102", origin: "Bengaluru Depot", destination: "Kempegowda Airport", scheduledAt: .now.addingTimeInterval(10_800), status: .scheduled, distanceKilometers: 39)
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

    static let inventoryParts: [(name: String, stock: Int, threshold: Int, unit: String)] = [
        ("Front brake pads", 8, 10, "pairs"),
        ("Oil filters", 24, 12, "pcs"),
        ("Cabin filters", 7, 6, "pcs"),
        ("Coolant, 5 L", 14, 8, "cans"),
        ("Wiper blades", 3, 5, "pairs"),
        ("Spark plugs", 18, 10, "pcs"),
        ("Air filters", 5, 8, "pcs"),
        ("Transmission fluid, 1 L", 11, 6, "bottles")
    ]

    static let inventoryItems = [
        InventoryItem(partID: "ENG-AF-1001", partName: "Air Filter", category: .engineParts, quantity: 18, minimumQuantity: 8, maximumQuantity: 40, reorderThreshold: 10, lastUpdated: .now.addingTimeInterval(-7_200)),
        InventoryItem(partID: "ENG-FF-1002", partName: "Fuel Filter", category: .engineParts, quantity: 9, minimumQuantity: 8, maximumQuantity: 32, reorderThreshold: 10, lastUpdated: .now.addingTimeInterval(-32_400)),
        InventoryItem(partID: "ENG-OF-1003", partName: "Oil Filter", category: .engineParts, quantity: 24, minimumQuantity: 12, maximumQuantity: 48, reorderThreshold: 14, lastUpdated: .now.addingTimeInterval(-86_400)),
        InventoryItem(partID: "ENG-SP-1004", partName: "Spark Plug", category: .engineParts, quantity: 30, minimumQuantity: 16, maximumQuantity: 64, reorderThreshold: 18, lastUpdated: .now.addingTimeInterval(-110_000)),
        InventoryItem(partID: "BRK-PD-2001", partName: "Brake Pads", category: .brakeParts, quantity: 8, minimumQuantity: 10, maximumQuantity: 44, reorderThreshold: 12, lastUpdated: .now.addingTimeInterval(-14_400)),
        InventoryItem(partID: "BRK-DC-2002", partName: "Brake Disc", category: .brakeParts, quantity: 6, minimumQuantity: 6, maximumQuantity: 24, reorderThreshold: 8, lastUpdated: .now.addingTimeInterval(-172_800)),
        InventoryItem(partID: "BRK-FL-2003", partName: "Brake Fluid", category: .brakeParts, quantity: 0, minimumQuantity: 8, maximumQuantity: 30, reorderThreshold: 8, lastUpdated: .now.addingTimeInterval(-21_600)),
        InventoryItem(partID: "TIR-FT-3001", partName: "Front Tire", category: .tires, quantity: 14, minimumQuantity: 8, maximumQuantity: 28, reorderThreshold: 8, lastUpdated: .now.addingTimeInterval(-54_000)),
        InventoryItem(partID: "TIR-RR-3002", partName: "Rear Tire", category: .tires, quantity: 7, minimumQuantity: 8, maximumQuantity: 28, reorderThreshold: 8, lastUpdated: .now.addingTimeInterval(-64_000)),
        InventoryItem(partID: "ELC-BT-4001", partName: "Battery", category: .electrical, quantity: 5, minimumQuantity: 4, maximumQuantity: 18, reorderThreshold: 5, lastUpdated: .now.addingTimeInterval(-18_000)),
        InventoryItem(partID: "ELC-HD-4004", partName: "Headlight", category: .electrical, quantity: 11, minimumQuantity: 6, maximumQuantity: 26, reorderThreshold: 8, lastUpdated: .now.addingTimeInterval(-96_000)),
        InventoryItem(partID: "FLD-EO-5001", partName: "Engine Oil", category: .fluids, quantity: 22, minimumQuantity: 12, maximumQuantity: 50, reorderThreshold: 16, lastUpdated: .now.addingTimeInterval(-8_000)),
        InventoryItem(partID: "FLD-CL-5002", partName: "Coolant", category: .fluids, quantity: 10, minimumQuantity: 8, maximumQuantity: 36, reorderThreshold: 10, lastUpdated: .now.addingTimeInterval(-70_000)),
        InventoryItem(partID: "GMT-BL-6003", partName: "Belts", category: .generalMaintenance, quantity: 13, minimumQuantity: 8, maximumQuantity: 30, reorderThreshold: 9, lastUpdated: .now.addingTimeInterval(-48_000)),
        InventoryItem(partID: "GMT-HS-6004", partName: "Hoses", category: .generalMaintenance, quantity: 4, minimumQuantity: 6, maximumQuantity: 24, reorderThreshold: 6, lastUpdated: .now.addingTimeInterval(-120_000))
    ]
}
