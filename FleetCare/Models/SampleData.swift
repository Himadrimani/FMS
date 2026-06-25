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
}
