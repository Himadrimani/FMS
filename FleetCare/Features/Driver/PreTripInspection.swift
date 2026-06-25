//
//  DetailedInspectionView.swift
//  FleetCare
//

import SwiftUI
import UIKit

// MARK: - Models

enum ItemInspectionStatus { case unselected, pass, fail }

struct InspectionItem: Identifiable {
    let id = UUID()
    let title: String
    let iconName: String
    let iconColor: Color
    var status: ItemInspectionStatus = .unselected
    var failureDetails: String = ""
    var attachedImages: [UIImage] = []
}

struct AvailableInspectionItem {
    let title: String
    let iconName: String
    let iconColor: Color
    var isDefault: Bool = true
}

let defaultInspectionItems: [AvailableInspectionItem] = [
    .init(title: "Brakes",     iconName: "slider.horizontal.3",        iconColor: Color(hex: "3B5BDB")),
    .init(title: "Tires",      iconName: "car.rear.and.tire.marks",    iconColor: Color(hex: "7048E8")),
    .init(title: "Headlights", iconName: "lightbulb.fill",             iconColor: Color(hex: "E67700")),
    .init(title: "Mirrors",    iconName: "rectangle.on.rectangle",     iconColor: Color(hex: "0C8599")),
    .init(title: "Engine",     iconName: "wrench.and.screwdriver.fill",iconColor: Color(hex: "5C7CFA")),
    .init(title: "Fuel",       iconName: "fuelpump.fill",              iconColor: Color(hex: "F59F00")),
]

let otherInspectionItems: [AvailableInspectionItem] = [
    .init(title: "Tail Lights", iconName: "light.beacon.max.fill",  iconColor: Color(hex: "C92A2A"), isDefault: false),
    .init(title: "Indicators",  iconName: "arrow.turn.up.right",    iconColor: Color(hex: "2F9E44"), isDefault: false),
    .init(title: "Windshield",  iconName: "car.window.right",       iconColor: Color(hex: "1098AD"), isDefault: false),
    .init(title: "Horn",        iconName: "speaker.wave.2.fill",    iconColor: Color(hex: "AE3EC9"), isDefault: false),
    .init(title: "Wipers",      iconName: "wiper.and.drop.fill",    iconColor: Color(hex: "2F9E44"), isDefault: false),
    .init(title: "Seatbelts",   iconName: "seatbelt",               iconColor: Color(hex: "E67700"), isDefault: false),
]

let allAvailableItems = defaultInspectionItems + otherInspectionItems

// MARK: - ViewModel

//class InspectionVM: ObservableObject {
//    @Published var items: [InspectionItem] = []
//    @Published var activeIndex: Int = 0
//    @Published var showSheet = false
//    @Published var showCamera = false
//    @Published var cameraTargetID: UUID? = nil
//
//    var completed: Int { items.filter { $0.status != .unselected }.count }
//    var total: Int { items.count }
//    var fraction: Double { total > 0 ? Double(completed) / Double(total) : 0 }
//    var percent: Int { Int(fraction * 100) }
//
//    func isAdded(_ title: String) -> Bool { items.contains { $0.title == title } }
//
//    func add(_ a: AvailableInspectionItem) {
//        guard !isAdded(a.title) else { return }
//        items.append(InspectionItem(title: a.title, iconName: a.iconName, iconColor: a.iconColor))
//    }
//}
class InspectionVM: ObservableObject {
    @Published var items: [InspectionItem]
    @Published var activeIndex: Int = 0
    @Published var showSheet = false
    @Published var showCamera = false
    @Published var cameraTargetID: UUID? = nil
    @Published var defectReports: Int = 0          // ← counts submitted defect reports
    @Published var navigateToSummary = false        // ← triggers Summary navigation

    init() {
        // Pre-load all 6 defaults on launch
        items = defaultInspectionItems.map {
            InspectionItem(title: $0.title, iconName: $0.iconName, iconColor: $0.iconColor)
        }
    }

    var completed: Int { items.filter { $0.status != .unselected }.count }
    var total: Int { items.count }
    var fraction: Double { total > 0 ? Double(completed) / Double(total) : 0 }
    var percent: Int { Int(fraction * 100) }

    func isAdded(_ title: String) -> Bool { items.contains { $0.title == title } }

    func add(_ a: AvailableInspectionItem) {
        guard !isAdded(a.title) else { return }
        items.append(InspectionItem(title: a.title, iconName: a.iconName, iconColor: a.iconColor))
    }
}
// MARK: - Main View

struct DetailedInspectionView: View {
    @StateObject private var vm = InspectionVM()
    @Environment(\.dismiss) private var dismiss
    var onDone: () -> Void = {}

//    var body: some View {
//        ZStack(alignment: .bottom) {
//            Color(.systemGroupedBackground).ignoresSafeArea()
//
//            VStack(spacing: 0) {
//                // Page header
//                VStack(alignment: .leading, spacing: 4) {
//                    Text("Pre-Trip Inspection")
//                        .font(.title.bold())
//                }
//                .frame(maxWidth: .infinity, alignment: .leading)
//                .padding(20)
//                .background(Color(.systemGroupedBackground))
//
//                ScrollView(showsIndicators: false) {
//                    VStack(alignment: .leading, spacing: 20) {
//
//                        // Checklist header
//                        HStack {
//                            Text("Inspection Checklist").font(.title2.bold())
//                            Spacer()
//                            Button { vm.showSheet = true } label: {
//                                Image(systemName: "plus")
//                                    .font(.title3.weight(.semibold))
//                                    .foregroundStyle(.white)
//                                    .frame(width: 40, height: 40)
//                                    .background(Color.blue, in: Circle())
//                            }
//                        }
//
//                        // Item cards
//                        if vm.items.isEmpty {
//                            emptyState
//                        } else {
//                            ForEach(vm.items.indices, id: \.self) { idx in
//                                InspectionItemCard(item: $vm.items[idx], onCameraTap: {
//                                    vm.cameraTargetID = vm.items[idx].id
//                                    vm.showCamera = true
//                                })
//                            }
//                        }
//
//                        // Summary table
//                        if vm.items.contains(where: { $0.status != .unselected }) {
//                            summaryTable
//                        }
//
//                        // Report Defect
//                        NavigationLink(destination: ReportDefectView()) {
//                            Label("Report Defect", systemImage: "exclamationmark.triangle.fill")
//                                .font(.subheadline.weight(.semibold))
//                                .foregroundStyle(.orange)
//                                .frame(maxWidth: .infinity)
//                                .padding(.vertical, 14)
//                                .background(Color.orange.opacity(0.10), in: RoundedRectangle(cornerRadius: 12))
//                                .overlay(RoundedRectangle(cornerRadius: 12)
//                                    .stroke(Color.orange.opacity(0.4), style: StrokeStyle(lineWidth: 1, dash: [5])))
//                        }
//
//                        Spacer(minLength: 100)
//                    }
//                    .padding(.horizontal, 20)
//                    .padding(.top, 8)
//                }
//            }
//
//            // Bottom submit bar
//            VStack(spacing: 0) {
//                Button {
//                    // submit logic
//                } label: {
//                    Text("Submit Inspection")
//                        .font(.headline).foregroundStyle(.white)
//                        .frame(maxWidth: .infinity).padding(.vertical, 16)
//                        .background(
//                            vm.completed == vm.total && vm.total > 0 ? Color.blue : Color.blue.opacity(0.35),
//                            in: RoundedRectangle(cornerRadius: 14))
//                }
//                .disabled(vm.completed != vm.total || vm.total == 0)
//            }
//            .padding(.horizontal, 20).padding(.vertical, 14)
//            .background(Color(.systemBackground).shadow(color: .black.opacity(0.07), radius: 8, x: 0, y: -3))
//        }
//        .navigationBarBackButtonHidden(true)
//        .navigationTitle("").navigationBarTitleDisplayMode(.inline)
//        .toolbar {
//            ToolbarItem(placement: .navigationBarLeading) {
//                Button { dismiss() } label: {
//                    HStack(spacing: 4) {
//                        Image(systemName: "chevron.left").fontWeight(.semibold)
//                        Text("Back")
//                    }.foregroundStyle(.blue)
//                }
//            }
//
//        }
//        .sheet(isPresented: $vm.showSheet) { AddItemSheet(vm: vm) }
//        .sheet(isPresented: $vm.showCamera) {
//            if let idx = vm.items.firstIndex(where: { $0.id == vm.cameraTargetID }) {
//                CameraPickerBridge(images: $vm.items[idx].attachedImages)
//            }
//        }
//    }
    
    var body: some View {
        ZStack(alignment: .bottom) {
            Color(.systemGroupedBackground).ignoresSafeArea()

            VStack(spacing: 0) {
                // Page header
                VStack(alignment: .leading, spacing: 4) {
                    Text("Pre-Trip Inspection")
                        .font(.title.bold())
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(20)
                .background(Color(.systemGroupedBackground))

                ScrollView(showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 20) {

                        // Checklist header — no + button anymore
                        Text("Inspection Checklist").font(.title2.bold())

                        // Item cards (always has items since defaults are pre-loaded)
                        ForEach(vm.items.indices, id: \.self) { idx in
                            InspectionItemCard(item: $vm.items[idx], onCameraTap: {
                                vm.cameraTargetID = vm.items[idx].id
                                vm.showCamera = true
                            })
                        }

                        // "Add More Items" button — replaces the old + in header
                        Button { vm.showSheet = true } label: {
                            Label("Add More Items", systemImage: "plus.circle.fill")
                                .font(.subheadline.weight(.semibold))
                                .foregroundStyle(.blue)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 14)
                                .background(Color.blue.opacity(0.08), in: RoundedRectangle(cornerRadius: 12))
                                .overlay(RoundedRectangle(cornerRadius: 12)
                                    .stroke(Color.blue.opacity(0.3), style: StrokeStyle(lineWidth: 1, dash: [5])))
                        }

                        // Summary table (shown once any item is checked)
//                        if vm.items.contains(where: { $0.status != .unselected }) {
//                            summaryTable
//                        }

                        // Report Defect row — shows badge if reports submitted
                        
                        NavigationLink(destination: ReportDefectView(vm: vm)) {
                            HStack {
                                Label("Report Defect", systemImage: "exclamationmark.triangle.fill")
                                    .font(.subheadline.weight(.semibold))
                                    .foregroundStyle(.orange)
                                Spacer()
                                if vm.defectReports > 0 {
                                    Text("\(vm.defectReports) reported")
                                        .font(.caption.weight(.semibold))
                                        .foregroundStyle(.white)
                                        .padding(.horizontal, 9).padding(.vertical, 4)
                                        .background(Color.orange, in: Capsule())
                                }
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 14)
                            .padding(.horizontal, 16)
                            .background(Color.orange.opacity(0.10), in: RoundedRectangle(cornerRadius: 12))
                            .overlay(RoundedRectangle(cornerRadius: 12)
                                .stroke(Color.orange.opacity(0.4), style: StrokeStyle(lineWidth: 1, dash: [5])))
                        }

                        Spacer(minLength: 100)
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 8)
                }
            }

            // Bottom submit bar
            VStack(spacing: 0) {
                // Hidden NavigationLink driven by vm.navigateToSummary
                NavigationLink(
                    destination: InspectionSummaryView(vm: vm, onDone: onDone),  // ← pass it
                    isActive: $vm.navigateToSummary
                ) { EmptyView() }
                Button {
                    vm.navigateToSummary = true
                } label: {
                    Text("Submit Inspection")
                        .font(.headline).foregroundStyle(.white)
                        .frame(maxWidth: .infinity).padding(.vertical, 16)
                        .background(
                            vm.completed == vm.total && vm.total > 0 ? Color.blue : Color.blue.opacity(0.35),
                            in: RoundedRectangle(cornerRadius: 14))
                }
                .disabled(vm.completed != vm.total || vm.total == 0)
            }
            .padding(.horizontal, 20).padding(.vertical, 14)
            .background(Color(.systemBackground).shadow(color: .black.opacity(0.07), radius: 8, x: 0, y: -3))
        }
        .navigationBarBackButtonHidden(true)
        .navigationTitle("").navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button { dismiss() } label: {
                    HStack(spacing: 4) {
                        Image(systemName: "chevron.left").fontWeight(.semibold)
                        Text("Back")
                    }.foregroundStyle(.blue)
                }
            }
        }
        .sheet(isPresented: $vm.showSheet) { AddItemSheet(vm: vm) }
        .sheet(isPresented: $vm.showCamera) {
            if let idx = vm.items.firstIndex(where: { $0.id == vm.cameraTargetID }) {
                CameraPickerBridge(images: $vm.items[idx].attachedImages)
            }
        }
    }

    // MARK: Empty state
    private var emptyState: some View {
        VStack(spacing: 10) {
            Image(systemName: "checklist").font(.system(size: 40)).foregroundStyle(.blue.opacity(0.35))
            Text("No items added yet").font(.headline).foregroundStyle(.secondary)
            Text("Tap + to build your checklist.").font(.subheadline).foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity).padding(40)
        .background(Color(.systemBackground), in: RoundedRectangle(cornerRadius: 16))
    }

    // MARK: Summary table
//    private var summaryTable: some View {
//        VStack(alignment: .leading, spacing: 0) {
//            Text("Inspection Summary").font(.title2.bold()).padding(.bottom, 12)
//
//            // Header row
//            HStack {
//                Text("ITEM NAME").frame(maxWidth: .infinity, alignment: .leading)
//                Text("STATUS").frame(width: 88, alignment: .center)
//                Text("ACTION").frame(width: 54, alignment: .trailing)
//            }
//            .font(.caption.weight(.bold)).foregroundStyle(.secondary)
//            .padding(.horizontal, 14).padding(.vertical, 9)
//            .background(Color(.systemGroupedBackground), in: RoundedRectangle(cornerRadius: 8))
//
//            let checked = vm.items.filter { $0.status != .unselected }
//            VStack(spacing: 0) {
//                ForEach(checked) { item in
//                    HStack {
//                        Text(item.title).frame(maxWidth: .infinity, alignment: .leading)
//
//                        HStack(spacing: 4) {
//                            Circle().fill(item.status == .pass ? Color.green : Color.red)
//                                .frame(width: 7, height: 7)
//                            Text(item.status == .pass ? "Passed" : "Failed")
//                                .font(.caption.weight(.semibold))
//                                .foregroundStyle(item.status == .pass ? .green : .red)
//                        }
//                        .padding(.horizontal, 8).padding(.vertical, 5)
//                        .background((item.status == .pass ? Color.green : Color.red).opacity(0.12), in: Capsule())
//                        .frame(width: 88)
//
//                        Button("View") {
//                            if let idx = vm.items.firstIndex(where: { $0.id == item.id }) {
//                                vm.activeIndex = idx
//                            }
//                        }
//                        .font(.subheadline.weight(.semibold)).foregroundStyle(.blue)
//                        .frame(width: 54, alignment: .trailing)
//                    }
//                    .padding(.horizontal, 14).padding(.vertical, 13)
//                    .background(Color(.systemBackground))
//
//                    if item.id != checked.last?.id { Divider().padding(.leading, 14) }
//                }
//            }
//            .clipShape(RoundedRectangle(cornerRadius: 12))
//            .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color(.systemGray5), lineWidth: 1))
//        }
//    }
}

// MARK: - Inspection Item Card

struct InspectionItemCard: View {
    @Binding var item: InspectionItem
    var onCameraTap: () -> Void

    var body: some View {
        VStack(spacing: 0) {
            // Title row
            HStack(spacing: 12) {
                ZStack {
                    RoundedRectangle(cornerRadius: 10)
                        .fill(item.iconColor.opacity(0.13))
                        .frame(width: 46, height: 46)
                    Image(systemName: item.iconName)
                        .font(.body)
                        .foregroundStyle(item.iconColor)
                        .frame(width: 24, height: 24)   // ← add this — constrains icon size
                }
                Text(item.title).font(.headline)
                Spacer()

                HStack(spacing: 8) {
                    passBtn
                    failBtn
                }
                .fixedSize()                            // ← add this — prevents vertical stretching
            }
            .padding(16)
            .frame(minHeight: 78)                      
            // Fail expansion
            if item.status == .fail {
                Divider().padding(.horizontal, 12)
                failSection
                    .transition(.opacity.combined(with: .move(edge: .top)))
            }
        }
        .background(Color(.systemBackground), in: RoundedRectangle(cornerRadius: 16))
        .shadow(color: .black.opacity(0.04), radius: 6, x: 0, y: 2)
        .animation(.spring(response: 0.3, dampingFraction: 0.8), value: item.status)
    }

    // Pass button — green when selected
    private var passBtn: some View {
        Button {
            withAnimation { item.status = item.status == .pass ? .unselected : .pass }
        } label: {
            HStack(spacing: 5) {
                Image(systemName: item.status == .pass ? "checkmark.circle.fill" : "checkmark.circle")
                Text("Pass").fontWeight(.semibold)
            }
            .font(.subheadline)
            .foregroundStyle(item.status == .pass ? .white : Color.green)
            .padding(.horizontal, 14).padding(.vertical, 8)
            .background(item.status == .pass ? Color.green : Color.green.opacity(0.10), in: Capsule())
            .overlay(Capsule().stroke(Color.green.opacity(item.status == .pass ? 0 : 0.5), lineWidth: 1))
        }
    }
    private var failBtn: some View {
        Button {
            withAnimation { item.status = item.status == .fail ? .unselected : .fail }
        } label: {
            HStack(spacing: 5) {
                Image(systemName: item.status == .fail ? "exclamationmark.circle.fill" : "exclamationmark.circle")
                Text("Fail").fontWeight(.semibold)
            }
            .font(.subheadline)
            .foregroundStyle(item.status == .fail ? .white : Color.red)
            .padding(.horizontal, 14).padding(.vertical, 8)
            .background(item.status == .fail ? Color.red : Color.red.opacity(0.08), in: Capsule())
            .overlay(Capsule().stroke(Color.red.opacity(item.status == .fail ? 0 : 0.5), lineWidth: 1))
        }
    }

    private var failSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Remarks
            VStack(alignment: .leading, spacing: 5) {
                Text("REMARKS").font(.caption.weight(.bold)).foregroundStyle(.secondary)
                TextField("Describe the issue...", text: $item.failureDetails, axis: .vertical)
                    .lineLimit(3...5).padding(10)
                    .background(Color(.systemGroupedBackground), in: RoundedRectangle(cornerRadius: 9))
                    .overlay(RoundedRectangle(cornerRadius: 9).stroke(Color(.systemGray4), lineWidth: 0.8))
            }

            // Photos
            VStack(alignment: .leading, spacing: 6) {
                Text("EVIDENCE PHOTOS").font(.caption.weight(.bold)).foregroundStyle(.secondary)
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 10) {
                        ForEach(item.attachedImages.indices, id: \.self) { i in
                            ZStack(alignment: .topTrailing) {
                                Image(uiImage: item.attachedImages[i])
                                    .resizable().scaledToFill()
                                    .frame(width: 76, height: 76)
                                    .clipShape(RoundedRectangle(cornerRadius: 9))
                                Button { item.attachedImages.remove(at: i) } label: {
                                    Image(systemName: "xmark.circle.fill")
                                        .foregroundStyle(.black)
                                        .background(Circle().fill(.white))
                                }.offset(x: 3, y: -3)
                            }.padding(.top, 3)
                        }
                        Button(action: onCameraTap) {
                            VStack(spacing: 5) {
                                Image(systemName: "camera.badge.plus").font(.title3).foregroundStyle(.blue)
                                Text("Add Photo").font(.caption2).foregroundStyle(.blue)
                            }
                            .frame(width: 76, height: 76)
                            .background(Color(.systemGroupedBackground), in: RoundedRectangle(cornerRadius: 9))
                            .overlay(RoundedRectangle(cornerRadius: 9)
                                .stroke(Color.blue.opacity(0.4), style: StrokeStyle(lineWidth: 1, dash: [4])))
                        }
                    }
                }
            }
        }
        .padding(14)
    }
}

// MARK: - Add Item Sheet (sections: Default / Other, multi-add, search)

struct AddItemSheet: View {
    @ObservedObject var vm: InspectionVM
    @Environment(\.dismiss) private var dismiss
    @State private var search = ""

//    var filtered: (defaults: [AvailableInspectionItem], others: [AvailableInspectionItem]) {
//        let q = search.trimmingCharacters(in: .whitespaces)
//        let all = q.isEmpty ? allAvailableItems : allAvailableItems.filter { $0.title.localizedCaseInsensitiveContains(q) }
//        return (all.filter { $0.isDefault }, all.filter { !$0.isDefault })
//    }
    var filtered: (defaults: [AvailableInspectionItem], others: [AvailableInspectionItem]) {
        let q = search.trimmingCharacters(in: .whitespaces)
        // Only show otherInspectionItems — defaults are already on the main screen
        let pool = q.isEmpty ? otherInspectionItems : otherInspectionItems.filter {
            $0.title.localizedCaseInsensitiveContains(q)
        }
        return ([], pool)   // defaults bucket always empty now
    }
//    var body: some View {
//        NavigationStack {
//            List {
//                if !filtered.defaults.isEmpty {
//                    Section("Default") { rows(filtered.defaults) }
//                }
//                if !filtered.others.isEmpty {
//                    Section("Other") { rows(filtered.others) }
//                }
//            }
//            .listStyle(.insetGrouped)
//            .searchable(text: $search, placement: .navigationBarDrawer(displayMode: .always),
//                        prompt: "Search items")
//            .navigationTitle("Add Inspection Item")
//            .navigationBarTitleDisplayMode(.inline)
//            .toolbar {
//                ToolbarItem(placement: .navigationBarTrailing) {
//                    Button("Done") { dismiss() }.fontWeight(.semibold)
//                }
//            }
//        }
//    }
    
    var body: some View {
        NavigationStack {
            List {
                // No "Default" section anymore
                if !filtered.others.isEmpty {
                    Section("Additional Items") { rows(filtered.others) }
                } else {
                    Section {
                        Text("No items found").foregroundStyle(.secondary)
                            .frame(maxWidth: .infinity, alignment: .center)
                            .padding()
                    }
                }
            }
            .listStyle(.insetGrouped)
            .searchable(text: $search,
                        placement: .navigationBarDrawer(displayMode: .always),
                        prompt: "Search items")
            .navigationTitle("Add More Items")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") { dismiss() }.fontWeight(.semibold)
                }
            }
        }
    }

    @ViewBuilder
    private func rows(_ items: [AvailableInspectionItem]) -> some View {
        ForEach(items, id: \.title) { a in
            let added = vm.isAdded(a.title)
            HStack(spacing: 12) {
                ZStack {
                    RoundedRectangle(cornerRadius: 8)
                        .fill(added ? Color(.systemGray4) : a.iconColor)
                        .frame(width: 36, height: 36)
                    Image(systemName: a.iconName).foregroundStyle(.white).font(.system(size: 15))
                }
                Text(a.title).foregroundStyle(added ? .secondary : .primary)
                Spacer()
                if added {
                    Text("Added").font(.caption.weight(.medium)).foregroundStyle(.secondary)
                        .padding(.horizontal, 9).padding(.vertical, 4)
                        .background(Color(.systemGray5), in: Capsule())
                } else {
                    Button {
                        vm.add(a)
                        // sheet stays open so driver can keep adding
                    } label: {
                        Text("Add").font(.subheadline.weight(.semibold)).foregroundStyle(.white)
                            .padding(.horizontal, 14).padding(.vertical, 6)
                            .background(Color.blue, in: Capsule())
                    }.buttonStyle(.plain)
                }
            }
            .listRowInsets(EdgeInsets(top: 8, leading: 16, bottom: 8, trailing: 16))
        }
    }
}

// MARK: - Supporting views



struct CameraPickerBridge: UIViewControllerRepresentable {
    @Binding var images: [UIImage]
    @Environment(\.dismiss) private var dismiss
    func makeUIViewController(context: Context) -> UIImagePickerController {
        let p = UIImagePickerController()
        p.delegate = context.coordinator
        p.sourceType = UIImagePickerController.isSourceTypeAvailable(.camera) ? .camera : .photoLibrary
        return p
    }
    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}
    func makeCoordinator() -> Coordinator { Coordinator(self) }
    class Coordinator: NSObject, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
        let parent: CameraPickerBridge
        init(_ parent: CameraPickerBridge) { self.parent = parent }
        func imagePickerController(_ picker: UIImagePickerController,
                                   didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
            if let img = info[.originalImage] as? UIImage { parent.images.append(img) }
            parent.dismiss()
        }
        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) { parent.dismiss() }
    }
}

extension Color {
    init(hex: String) {
        let h = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var n: UInt64 = 0; Scanner(string: h).scanHexInt64(&n)
        self.init(red: Double((n>>16)&0xFF)/255, green: Double((n>>8)&0xFF)/255, blue: Double(n&0xFF)/255)
    }
}

#Preview { NavigationStack { DetailedInspectionView() } }
