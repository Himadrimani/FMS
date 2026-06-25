//
//  VehicleImageView.swift
//  FleetCare
//
//  Created by Purvanshi on 24/06/26.
//
import SwiftUI
import UIKit

struct VehicleImageView: View {
    let vehicle: Vehicle

    var body: some View {
        if let url = vehicle.imageURL {
            AsyncImage(url: url) { phase in
                switch phase {
                case .success(let image): image.resizable().scaledToFit()
                case .empty:              ProgressView()
                case .failure:            localFallback
                @unknown default:         localFallback
                }
            }
        } else {
            localFallback
        }
    }

    @ViewBuilder
    private var localFallback: some View {
        if UIImage(named: vehicle.vehicleType.assetName) != nil {
            Image(vehicle.vehicleType.assetName).resizable().scaledToFit()
        } else {
            Image(systemName: vehicle.vehicleType.symbolName)
                .resizable().scaledToFit().padding(6).foregroundStyle(.secondary)
        }
    }
}
