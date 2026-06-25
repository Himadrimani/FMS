//
//  InspectionSummaryView.swift
//  FleetCare
//

import SwiftUI
struct InspectionSummaryView: View {
    @ObservedObject var vm: InspectionVM
    var onDone: () -> Void
    private var passedItems: [InspectionItem] { vm.items.filter { $0.status == .pass } }
    private var failedItems: [InspectionItem] { vm.items.filter { $0.status == .fail } }
    private var allPassed: Bool { failedItems.isEmpty && !vm.items.isEmpty }

    var body: some View {
        ZStack(alignment: .bottom) {
            Color(.systemGroupedBackground).ignoresSafeArea()

            ScrollView(showsIndicators: false) {
                VStack(spacing: 20) {
                    heroCard
                    statsRow

                    if vm.defectReports > 0 {
                        defectReportsBanner
                    }

                    if !failedItems.isEmpty {
                        itemSection(title: "Failed Items", items: failedItems, accentColor: .red)
                    }

                    if !passedItems.isEmpty {
                        itemSection(title: "Passed Items", items: passedItems, accentColor: .green)
                    }

                    Spacer(minLength: 100)
                }
                .padding(20)
                .padding(.top, 8)
            }

            // ── Done button ───────────────────────────────────────────────
            VStack(spacing: 0) {
                Button {
                    onDone()
                } label: {
                    Text("Done")
                        .font(.headline)
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(Color.blue, in: RoundedRectangle(cornerRadius: 14))
                }
            }
            .padding(.horizontal, 20).padding(.vertical, 14)
            .background(
                Color(.systemBackground)
                    .shadow(color: .black.opacity(0.07), radius: 8, x: 0, y: -3)
            )
        }
        .navigationTitle("Inspection Summary")
        .navigationBarTitleDisplayMode(.inline)
    }

    // MARK: - Hero card

    private var heroCard: some View {
        VStack(spacing: 16) {
            ZStack {
                Circle()
                    .fill(allPassed ? Color.green.opacity(0.12) : Color.red.opacity(0.10))
                    .frame(width: 90, height: 90)
                Image(systemName: allPassed ? "checkmark.seal.fill" : "exclamationmark.triangle.fill")
                    .font(.system(size: 40))
                    .foregroundStyle(allPassed ? .green : .red)
            }

            VStack(spacing: 6) {
                Text(allPassed ? "All Clear!" : "Issues Found")
                    .font(.title.bold())
                Text(allPassed
                     ? "Vehicle passed all inspection checks."
                     : "Some items require attention before departure.")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
            }

            Text("Submitted \(formattedNow())")
                .font(.caption)
                .foregroundStyle(.tertiary)
                .padding(.horizontal, 12).padding(.vertical, 5)
                .background(Color(.systemGroupedBackground), in: Capsule())
        }
        .frame(maxWidth: .infinity)
        .padding(24)
        .background(Color(.systemBackground), in: RoundedRectangle(cornerRadius: 20))
        .shadow(color: .black.opacity(0.04), radius: 8, x: 0, y: 2)
    }

    // MARK: - Stats row

    private var statsRow: some View {
        HStack(spacing: 12) {
            statTile(value: "\(vm.total)",          label: "Checked", icon: "checklist",            color: .blue)
            statTile(value: "\(passedItems.count)", label: "Passed",  icon: "checkmark.circle.fill", color: .green)
            statTile(value: "\(failedItems.count)", label: "Failed",  icon: "xmark.circle.fill",     color: failedItems.isEmpty ? .secondary : .red)
        }
    }

    private func statTile(value: String, label: String, icon: String, color: Color) -> some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundStyle(color)
            Text(value)
                .font(.title2.bold())
            Text(label)
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 18)
        .background(Color(.systemBackground), in: RoundedRectangle(cornerRadius: 14))
        .shadow(color: .black.opacity(0.03), radius: 6, x: 0, y: 2)
    }

    // MARK: - Defect reports banner

    private var defectReportsBanner: some View {
        HStack(spacing: 12) {
            Image(systemName: "exclamationmark.triangle.fill")
                .foregroundStyle(.orange)
                .font(.title3)
            VStack(alignment: .leading, spacing: 2) {
                Text("\(vm.defectReports) Defect Report\(vm.defectReports > 1 ? "s" : "") Submitted")
                    .font(.subheadline.weight(.semibold))
                Text("Sent to Dispatch & Fleet HQ")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            Spacer()
            Image(systemName: "checkmark.circle.fill")
                .foregroundStyle(.green)
        }
        .padding(16)
        .background(Color.orange.opacity(0.10), in: RoundedRectangle(cornerRadius: 14))
        .overlay(
            RoundedRectangle(cornerRadius: 14)
                .stroke(Color.orange.opacity(0.3), lineWidth: 1)
        )
    }

    // MARK: - Item section

    private func itemSection(title: String, items: [InspectionItem], accentColor: Color) -> some View {
        VStack(alignment: .leading, spacing: 0) {

            HStack {
                Text(title).font(.title3.bold())
                Spacer()
                Text("\(items.count)")
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(.white)
                    .padding(.horizontal, 10).padding(.vertical, 4)
                    .background(accentColor, in: Capsule())
            }
            .padding(.bottom, 10)

            VStack(spacing: 0) {
                ForEach(items) { item in
                    HStack(spacing: 12) {
                        ZStack {
                            RoundedRectangle(cornerRadius: 8)
                                .fill(item.iconColor.opacity(0.13))
                                .frame(width: 38, height: 38)
                            Image(systemName: item.iconName)
                                .font(.system(size: 15))
                                .foregroundStyle(item.iconColor)
                        }

                        VStack(alignment: .leading, spacing: 3) {
                            Text(item.title).font(.subheadline.weight(.semibold))
                            if item.status == .fail, !item.failureDetails.isEmpty {
                                Text(item.failureDetails)
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                                    .lineLimit(2)
                            }
                            if !item.attachedImages.isEmpty {
                                HStack(spacing: 4) {
                                    Image(systemName: "photo.fill").font(.caption2)
                                    Text("\(item.attachedImages.count) photo\(item.attachedImages.count > 1 ? "s" : "")")
                                        .font(.caption2)
                                }
                                .foregroundStyle(.blue)
                            }
                        }

                        Spacer()

                        HStack(spacing: 4) {
                            Circle().fill(accentColor).frame(width: 6, height: 6)
                            Text(item.status == .pass ? "Pass" : "Fail")
                                .font(.caption.weight(.bold))
                                .foregroundStyle(accentColor)
                        }
                        .padding(.horizontal, 9).padding(.vertical, 5)
                        .background(accentColor.opacity(0.12), in: Capsule())
                    }
                    .padding(.horizontal, 14).padding(.vertical, 13)
                    .background(Color(.systemBackground))

                    if item.id != items.last?.id {
                        Divider().padding(.leading, 62)
                    }
                }
            }
            .clipShape(RoundedRectangle(cornerRadius: 14))
            .overlay(
                RoundedRectangle(cornerRadius: 14)
                    .stroke(Color(.systemGray5), lineWidth: 1)
            )
        }
    }

    // MARK: - Helpers

    private func formattedNow() -> String {
        let f = DateFormatter()
        f.dateFormat = "dd MMM yyyy, hh:mm a"
        return f.string(from: Date())
    }
}

#Preview {
    NavigationStack {
        InspectionSummaryView(vm: InspectionVM(), onDone: {})
    }
}
