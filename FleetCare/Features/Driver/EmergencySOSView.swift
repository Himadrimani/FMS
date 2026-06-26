//
//  EmergencySOSView.swift
//  FleetCare
//
//  Created by kanak gupta on 26/06/26.
//
//
//
//  EmergencySOSView.swift
//  FleetCare
//

import SwiftUI

struct EmergencySOSView: View {
    @Environment(\.dismiss) private var dismiss

    private let sosRed = Color(red: 0.78, green: 0.08, blue: 0.08)

    var body: some View {
        ZStack {

            // ── Full-screen grey background ──────────────────────────
            Color(.systemGroupedBackground)
                .ignoresSafeArea()

            VStack(spacing: 0) {

                Spacer()

                // ── SOS Circle ───────────────────────────────────────
                ZStack {
                    Circle()
                        .fill(sosRed.opacity(0.12))
                        .frame(width: 190, height: 190)

                    Circle()
                        .fill(sosRed)
                        .frame(width: 150, height: 150)

                    VStack(spacing: 6) {

                        Text("SOS")
                            .font(.system(size: 50, weight: .black, design: .rounded))
                            .foregroundStyle(.white)
                            .tracking(4)
                    }
                }

                Spacer().frame(height: 28)

                // ── Status text ──────────────────────────────────────
                Text("Emergency SOS Activated")
                    .font(.title3.weight(.bold))
                    .foregroundStyle(sosRed)
                    .multilineTextAlignment(.center)

                Text("Your current location and vehicle status\nwill be broadcast to emergency teams.")
                    .font(.subheadline)
                    .foregroundStyle(Color(.systemGray))
                    .multilineTextAlignment(.center)
                    .padding(.top, 8)
                    .padding(.horizontal, 32)

                Spacer()

                // ── Action card ──────────────────────────────────────
                VStack(spacing: 0) {
                    ActionRow(
                        icon: "headphones",
                        iconBg: Color.blue.opacity(0.12),
                        iconFg: .blue,
                        title: "Call Dispatch",
                        titleColor: .primary,
                        trailingIcon: ""
                    ) { }

                    Divider().padding(.leading, 64)

                    ActionRow(
                        icon: "shield.lefthalf.filled",
                        iconBg: sosRed.opacity(0.10),
                        iconFg: sosRed,
                        title: "Call Emergency Services (911)",
                        titleColor: sosRed,
                        trailingIcon: ""
                    ) {
                        if let url = URL(string: "tel://911") {
                            UIApplication.shared.open(url)
                        }
                    }

                    Divider().padding(.leading, 64)

                    ActionRow(
                        icon: "location.circle",
                        iconBg: Color(.systemGray5),
                        iconFg: Color(.systemGray),
                        title: "Share Live Location",
                        titleColor: .primary,
                        trailingIcon: ""
                    ) { }
                }
                .background(Color(.systemBackground))
                .clipShape(RoundedRectangle(cornerRadius: 20))
                .shadow(color: .black.opacity(0.07), radius: 14, x: 0, y: 4)
                .padding(.horizontal, 20)
            }
        }
        .navigationTitle("Emergency SOS")
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button {
                    dismiss()
                } label: {
                    Image(systemName: "chevron.left")
                        .font(.body.weight(.semibold))
                        .foregroundStyle(.blue)
                }
            }
        }
        .toolbarBackground(Color(.systemGroupedBackground), for: .navigationBar)
        .toolbarBackground(.visible, for: .navigationBar)
    }
}

// MARK: - Action Row
private struct ActionRow: View {
    let icon: String
    let iconBg: Color
    let iconFg: Color
    let title: String
    let titleColor: Color
    let trailingIcon: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 14) {
                ZStack {
                    Circle()
                        .fill(iconBg)
                        .frame(width: 40, height: 40)
                    Image(systemName: icon)
                        .font(.system(size: 17))
                        .foregroundStyle(iconFg)
                }
                Text(title)
                    .font(.body.weight(.medium))
                    .foregroundStyle(titleColor)
                Spacer()
                Image(systemName: trailingIcon)
                    .font(.system(size: 14, weight: .medium))
                    .foregroundStyle(Color(.systemGray3))
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 15)
        }
    }
}

// MARK: - Preview
#Preview {
    NavigationStack {
        EmergencySOSView()
    }
}
