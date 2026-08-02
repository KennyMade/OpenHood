import SwiftUI

struct GarageView: View {
    @EnvironmentObject private var garageStore: GarageStore
    @State private var isAddingVehicle = false
    @State private var vehiclePendingActivation: UUID?

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                Text("My Garage")
                    .font(.largeTitle)
                    .fontWeight(.bold)

                ForEach(garageStore.vehicles) { vehicle in
                    NavigationLink {
                        GarageVehicleOverview(vehicle: vehicle)
                    } label: {
                        GarageVehicleCard(
                            vehicle: vehicle,
                            isActive: vehicle.id == garageStore.activeVehicleID
                        )
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(20)
        }
        .background(Color(.systemGroupedBackground))
        .navigationTitle("Garage")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    isAddingVehicle = true
                } label: {
                    Image(systemName: "plus")
                }
                .accessibilityLabel("Add vehicle")
            }
        }
        .fullScreenCover(isPresented: $isAddingVehicle) {
            AddVehicleOnboardingView { vehicleID in
                vehiclePendingActivation = vehicleID
            }
        }
        .confirmationDialog(
            "Make this your active vehicle?",
            isPresented: activationConfirmationIsPresented,
            titleVisibility: .visible
        ) {
            Button("Make Active") {
                if let vehiclePendingActivation {
                    garageStore.selectVehicle(id: vehiclePendingActivation)
                }
                vehiclePendingActivation = nil
            }

            Button("Not Now", role: .cancel) {
                vehiclePendingActivation = nil
            }
        } message: {
            Text("Home, Help, Plan, and Learn use the active vehicle.")
        }
    }

    private var activationConfirmationIsPresented: Binding<Bool> {
        Binding(
            get: { vehiclePendingActivation != nil },
            set: { isPresented in
                if !isPresented {
                    vehiclePendingActivation = nil
                }
            }
        )
    }
}

struct AddVehicleOnboardingView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var vehicle = VehicleOnboardingData()
    @StateObject private var onboardingSession = OnboardingSession()

    let onVehicleAdded: (UUID) -> Void

    var body: some View {
        NavigationStack {
            AddVehicleView()
                .navigationTitle("Add Vehicle")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .cancellationAction) {
                        Button("Cancel") {
                            dismiss()
                        }
                    }
                }
        }
        .environmentObject(vehicle)
        .environmentObject(onboardingSession)
        .onChange(of: onboardingSession.completedVehicleID) { _, vehicleID in
            guard let vehicleID else { return }
            onVehicleAdded(vehicleID)
            dismiss()
        }
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

struct GarageVehicleOverview: View {
    @EnvironmentObject private var garageStore: GarageStore

    let vehicle: SavedVehicle

    private var isActive: Bool {
        garageStore.activeVehicleID == vehicle.id
    }

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

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                VStack(alignment: .leading, spacing: 6) {
                    Text(vehicleName.isEmpty ? "Vehicle" : vehicleName)
                        .font(.largeTitle)
                        .fontWeight(.bold)

                    if isActive {
                        Label("Active", systemImage: "checkmark.circle.fill")
                            .font(.subheadline)
                            .fontWeight(.semibold)
                            .foregroundStyle(.green)
                    }
                }

                VStack(spacing: 0) {
                    GarageDetailRow(title: "Trim", value: vehicle.trim ?? "Not confirmed")
                    Divider()
                    GarageDetailRow(
                        title: "Transmission",
                        value: vehicle.transmission ?? "Not confirmed"
                    )
                    Divider()
                    GarageDetailRow(
                        title: "Mileage",
                        value: vehicle.mileage.map { "\($0.formatted()) mi" } ?? "Not entered"
                    )
                    Divider()
                    GarageDetailRow(title: "Profile", value: verificationText)
                }
                .background(Color(.secondarySystemGroupedBackground))
                .clipShape(RoundedRectangle(cornerRadius: 22))

                if !isActive {
                    Button {
                        garageStore.selectVehicle(id: vehicle.id)
                    } label: {
                        Text("Set as Active")
                            .font(.headline)
                            .frame(maxWidth: .infinity)
                            .padding()
                    }
                    .buttonStyle(.borderedProminent)
                }
            }
            .padding(20)
        }
        .background(Color(.systemGroupedBackground))
        .navigationTitle("Vehicle")
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct GarageDetailRow: View {
    let title: String
    let value: String

    var body: some View {
        HStack(alignment: .firstTextBaseline, spacing: 16) {
            Text(title)
                .foregroundStyle(.secondary)

            Spacer()

            Text(value)
                .multilineTextAlignment(.trailing)
        }
        .padding(16)
    }
}
