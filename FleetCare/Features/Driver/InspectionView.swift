//
//  InspectionView.swift
//  FleetCare
//
//  Created by Purvanshi on 24/06/26.
//
import SwiftUI
import UIKit

struct InspectionView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var checked = Set<String>()

    private let checks = ["Tyres and wheels", "Lights and indicators", "Brakes", "Mirrors and glass", "Fluids and leaks", "Safety equipment"]

    var body: some View {
        NavigationStack {
            List {
                Section {
                    Text("Walk around the vehicle and confirm each safety item. Report anything uncertain.")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                Section("Safety checks") {
                    ForEach(checks, id: \.self) { check in
                        Button {
                            if checked.contains(check) { checked.remove(check) } else { checked.insert(check) }
                        } label: {
                            Label(check, systemImage: checked.contains(check) ? "checkmark.circle.fill" : "circle")
                                .foregroundStyle(checked.contains(check) ? .green : .primary)
                                .frame(minHeight: 44)
                        }
                        .accessibilityValue(checked.contains(check) ? "Checked" : "Not checked")
                    }
                }
                Section {
                    Button("Report a Defect", systemImage: "camera.fill", role: .destructive) {}
                }
            }
            .navigationTitle("Pre-Trip Inspection")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Close") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Complete") { dismiss() }
                        .disabled(checked.count != checks.count)
                }
            }
        }
    }
}
