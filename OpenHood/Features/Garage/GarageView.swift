import SwiftUI

struct GarageView: View {
    @EnvironmentObject private var garageStore: GarageStore

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                Text("My Garage")
                    .font(.largeTitle)
                    .fontWeight(.bold)

                ForEach(garageStore.vehicles) { vehicle in
                    GarageVehicleCard(
                        vehicle: vehicle,
                        isActive: vehicle.id == garageStore.activeVehicleID
                    )
                }

                Text("Vehicle management is coming next.")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding(.top, 4)
            }
            .padding(20)
        }
        .background(Color(.systemGroupedBackground))
        .navigationTitle("Garage")
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct GarageVehicleCard: View {
    let vehicle: SavedVehicle
    let isActive: Bool

    private var vehicleName: String {
        [vehicle.year.map(String.init), vehicle.make, vehicle.model]
            .compactMap { value in
                guard let value, !value.isEmpty else { return nil }
                return value
            }
            .joined(separator: " ")
    }

    private var verificationText: String {
        switch vehicle.profileVerification {
        case .verified:
            return "Verified configuration"
        case .basicUnverified:
            return "Basic profile · Configuration details unverified"
        }
    }

    private var statusText: String {
        guard !vehicle.make.isEmpty,
              !vehicle.model.isEmpty,
              vehicle.year != nil else {
            return "Information needed"
        }

        switch vehicle.profileVerification {
        case .verified:
            return "Profile ready"
        case .basicUnverified:
            return "Basic profile"
        }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack(alignment: .top, spacing: 14) {
                Image(systemName: "car.side.fill")
                    .font(.system(size: 28))
                    .frame(width: 48, height: 48)
                    .background(Color.primary.opacity(0.08))
                    .clipShape(RoundedRectangle(cornerRadius: 14))

                VStack(alignment: .leading, spacing: 5) {
                    Text(vehicleName.isEmpty ? "Vehicle" : vehicleName)
                        .font(.title3)
                        .fontWeight(.bold)

                    Text(vehicle.trim ?? "Trim not confirmed")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }

                Spacer()

                if isActive {
                    Label("Active", systemImage: "checkmark.circle.fill")
                        .font(.caption)
                        .fontWeight(.semibold)
                        .foregroundStyle(.green)
                }
            }

            Divider()

            VStack(alignment: .leading, spacing: 6) {
                Text(statusText)
                    .font(.headline)

                Text(verificationText)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
        }
        .padding(18)
        .background(Color(.secondarySystemGroupedBackground))
        .clipShape(RoundedRectangle(cornerRadius: 22))
        .overlay {
            RoundedRectangle(cornerRadius: 22)
                .stroke(
                    isActive ? Color.green.opacity(0.45) : Color.secondary.opacity(0.12),
                    lineWidth: isActive ? 1.5 : 1
                )
        }
    }
}
