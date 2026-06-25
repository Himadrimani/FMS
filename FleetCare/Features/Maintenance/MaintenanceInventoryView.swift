import SwiftUI

// MARK: - Inventory Tab

struct MaintenanceInventoryView: View {
    @State private var searchText = ""
    @State private var showingScanSheet = false
    @State private var showingPhotoPickerFor: String?

    private var lowStockParts: [(name: String, stock: Int, threshold: Int, unit: String)] {
        SampleData.inventoryParts.filter { $0.stock <= $0.threshold }
    }

    private var filteredParts: [(name: String, stock: Int, threshold: Int, unit: String)] {
        if searchText.isEmpty { return SampleData.inventoryParts }
        return SampleData.inventoryParts.filter {
            $0.name.localizedCaseInsensitiveContains(searchText)
        }
    }

    var body: some View {
        List {
            // MARK: Low Stock Alert
            if !lowStockParts.isEmpty {
                Section {
                    lowStockAlert
                }
                .listRowBackground(Color.orange.opacity(0.08))
            }

            // MARK: AI Forecast
            Section {
                InsightCard(
                    title: "Inventory forecast",
                    summary: "Front brake pad stock may reach minimum level in 18 days. Wiper blades critically low.",
                    score: 72,
                    recommendation: "Create purchase request"
                )
            }
            .listRowInsets(EdgeInsets())
            .listRowBackground(Color.clear)

            // MARK: Parts List
            Section("Parts & Stock") {
                ForEach(filteredParts, id: \.name) { part in
                    InventoryPartRow(part: part) {
                        showingPhotoPickerFor = part.name
                    }
                }
            }

            // MARK: Actions
            Section {
                Button {
                    // Purchase request action
                } label: {
                    Label("New Purchase Request", systemImage: "cart.badge.plus")
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, FleetSpacing.small)
                }
                .tint(.brandPrimary)
            }
        }
        .searchable(text: $searchText, prompt: "Search parts")
        .navigationTitle("Inventory")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    showingScanSheet = true
                } label: {
                    Image(systemName: "barcode.viewfinder")
                }
                .accessibilityLabel("Scan barcode")
            }
            ToolbarItem(placement: .topBarTrailing) {
                NavigationLink(destination: AccountView()) {
                    Image(systemName: "person.crop.circle")
                }
                .accessibilityLabel("Account")
            }
        }
        .sheet(isPresented: $showingScanSheet) {
            scannerSheet
        }
        .sheet(item: $showingPhotoPickerFor) { partName in
            photoUploadSheet(for: partName)
        }
    }

    // MARK: - Low Stock Alert

    private var lowStockAlert: some View {
        VStack(alignment: .leading, spacing: FleetSpacing.small) {
            Label("Low Stock Alert", systemImage: "exclamationmark.triangle.fill")
                .font(.headline)
                .foregroundStyle(.orange)

            Text("\(lowStockParts.count) item\(lowStockParts.count == 1 ? "" : "s") below minimum threshold")
                .font(.subheadline)
                .foregroundStyle(.secondary)

            ForEach(lowStockParts, id: \.name) { part in
                HStack {
                    Text(part.name)
                        .font(.caption.weight(.semibold))
                    Spacer()
                    Text("\(part.stock) / \(part.threshold) \(part.unit)")
                        .font(.caption)
                        .foregroundStyle(.orange)
                }
            }
        }
        .padding(.vertical, FleetSpacing.small)
    }

    // MARK: - Scanner Sheet

    private var scannerSheet: some View {
        NavigationStack {
            VStack(spacing: FleetSpacing.xLarge) {
                Spacer()
                Image(systemName: "barcode.viewfinder")
                    .font(.system(size: 80))
                    .foregroundStyle(.brandPrimary)
                    .symbolEffect(.pulse, options: .repeating)
                Text("Point camera at barcode")
                    .font(.title3.weight(.semibold))
                Text("Scan a part barcode or QR code to quickly update stock levels.")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
                Spacer()
            }
            .navigationTitle("Scan Part")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { showingScanSheet = false }
                }
            }
        }
    }

    // MARK: - Photo Upload Sheet

    private func photoUploadSheet(for partName: String) -> some View {
        NavigationStack {
            VStack(spacing: FleetSpacing.xLarge) {
                Spacer()
                Image(systemName: "camera.on.rectangle.fill")
                    .font(.system(size: 60))
                    .foregroundStyle(.brandPrimary)
                Text("Upload photo for \(partName)")
                    .font(.title3.weight(.semibold))
                HStack(spacing: FleetSpacing.large) {
                    Button {
                        showingPhotoPickerFor = nil
                    } label: {
                        Label("Take Photo", systemImage: "camera.fill")
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.borderedProminent)

                    Button {
                        showingPhotoPickerFor = nil
                    } label: {
                        Label("Choose Photo", systemImage: "photo.on.rectangle")
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.bordered)
                }
                .padding(.horizontal)
                Text("Upload a part photo or receipt for audit purposes.")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                Spacer()
            }
            .navigationTitle("Part Photo")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { showingPhotoPickerFor = nil }
                }
            }
        }
    }
}

// MARK: - Make String Identifiable for sheet(item:)

extension String: @retroactive Identifiable {
    public var id: String { self }
}

// MARK: - Inventory Part Row

private struct InventoryPartRow: View {
    let part: (name: String, stock: Int, threshold: Int, unit: String)
    let onUploadPhoto: () -> Void

    private var isLowStock: Bool { part.stock <= part.threshold }

    var body: some View {
        VStack(alignment: .leading, spacing: FleetSpacing.small) {
            HStack {
                VStack(alignment: .leading, spacing: FleetSpacing.xSmall) {
                    Text(part.name)
                        .font(.headline)
                    Text("\(part.stock) \(part.unit) in stock")
                        .font(.subheadline)
                        .foregroundStyle(isLowStock ? .orange : .secondary)
                }
                Spacer()
                if isLowStock {
                    Image(systemName: "exclamationmark.triangle.fill")
                        .foregroundStyle(.orange)
                        .accessibilityLabel("Low stock")
                }
            }

            ProgressView(
                value: Double(part.stock),
                total: Double(max(part.threshold * 2, part.stock))
            )
            .tint(isLowStock ? .orange : .brandPrimary)

            HStack {
                Text("Threshold: \(part.threshold) \(part.unit)")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                Spacer()
                Button {
                    onUploadPhoto()
                } label: {
                    Label("Photo", systemImage: "camera.fill")
                        .font(.caption.weight(.semibold))
                }
                .buttonStyle(.bordered)
                .controlSize(.mini)
            }
        }
        .padding(.vertical, FleetSpacing.xSmall)
        .accessibilityElement(children: .combine)
    }
}

#Preview {
    NavigationStack {
        MaintenanceInventoryView()
    }
}
