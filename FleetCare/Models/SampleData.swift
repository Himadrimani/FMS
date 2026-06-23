import Foundation

enum SampleData {
    static let vehicles = [
        Vehicle(name: "Atlas 12", registration: "MH 12 AB 4821", make: "Tata", model: "Prima", year: 2024, odometer: 42_610, status: .active),
        Vehicle(name: "Orion 07", registration: "KA 01 MX 2084", make: "Ashok Leyland", model: "AVTR", year: 2023, odometer: 78_240, status: .attention),
        Vehicle(name: "Nova 19", registration: "DL 01 RT 9033", make: "Mahindra", model: "Furio", year: 2025, odometer: 16_090, status: .scheduled)
    ]

    static let trips = [
        FleetTrip(title: "Pune Distribution Run", origin: "Mumbai Hub", destination: "Pune DC", scheduledAt: .now.addingTimeInterval(3_600), status: .active, distanceKilometers: 151),
        FleetTrip(title: "Airport Cold Chain", origin: "Bengaluru Depot", destination: "Kempegowda Airport", scheduledAt: .now.addingTimeInterval(10_800), status: .scheduled, distanceKilometers: 39)
    ]

    static let workOrders = [
        WorkOrder(title: "Inspect brake vibration", vehicleName: "Orion 07", priority: 1, dueAt: .now.addingTimeInterval(7_200), status: .attention),
        WorkOrder(title: "40,000 km service", vehicleName: "Atlas 12", priority: 2, dueAt: .now.addingTimeInterval(86_400), status: .scheduled),
        WorkOrder(title: "Replace cabin filter", vehicleName: "Nova 19", priority: 3, dueAt: .now.addingTimeInterval(172_800), status: .scheduled)
    ]
}
