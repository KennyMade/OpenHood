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
                        VehicleDetailView(vehicle: vehicle)
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

    /// Describes where this vehicle's details came from, which is the only
    /// thing `profileVerification` actually records — it is set once, when a
    /// year is picked, purely by whether VehicleCatalog had a confirmed
    /// configuration for that make/model/year.
    ///
    /// The old wording ("Verified configuration" vs "Basic profile · Some
    /// details self-reported") read as a score, so a person who carefully
    /// filled in every field by hand saw "Basic profile" and reasonably
    /// concluded the app thought their work didn't count — while a vehicle
    /// they'd entered nothing for showed "Verified". Nothing was wrong with
    /// their profile; the catalog simply had no entry for that year.
    ///
    /// The distinction is worth keeping, because catalog-confirmed and
    /// owner-entered details genuinely differ in reliability. It just has to
    /// say that plainly instead of implying one of them is deficient.
    private var verificationText: String {
        switch vehicle.profileVerification {
        case .verified:
            return "Details confirmed from catalog"
        case .basicUnverified:
            return "Details you entered yourself"
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

struct VehicleDetailView: View {
    @EnvironmentObject private var garageStore: GarageStore
    @Environment(\.dismiss) private var dismiss
    @Environment(\.openURL) private var openURL
    @State private var isConfirmingRemoval = false
    @State private var isFinishingSetup = false

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

    /// Describes where this vehicle's details came from, which is the only
    /// thing `profileVerification` actually records — it is set once, when a
    /// year is picked, purely by whether VehicleCatalog had a confirmed
    /// configuration for that make/model/year.
    ///
    /// The old wording ("Verified configuration" vs "Basic profile · Some
    /// details self-reported") read as a score, so a person who carefully
    /// filled in every field by hand saw "Basic profile" and reasonably
    /// concluded the app thought their work didn't count — while a vehicle
    /// they'd entered nothing for showed "Verified". Nothing was wrong with
    /// their profile; the catalog simply had no entry for that year.
    ///
    /// The distinction is worth keeping, because catalog-confirmed and
    /// owner-entered details genuinely differ in reliability. It just has to
    /// say that plainly instead of implying one of them is deficient.
    private var verificationText: String {
        switch vehicle.profileVerification {
        case .verified:
            return "Details confirmed from catalog"
        case .basicUnverified:
            return "Details you entered yourself"
        }
    }

    private var completedFieldCount: Int {
        var count = 0
        if !vehicle.make.isEmpty { count += 1 }
        if !vehicle.model.isEmpty { count += 1 }
        if vehicle.year != nil { count += 1 }
        if vehicle.transmission != nil { count += 1 }
        if vehicle.trim != nil { count += 1 }
        if vehicle.mileage != nil { count += 1 }
        return count
    }

    private var profileCompletion: Double {
        Double(completedFieldCount) / 6.0
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

                VehicleDetailProfileCard(completion: profileCompletion) {
                    isFinishingSetup = true
                }

                // Where a person can finally see what they told OpenHood
                // during setup. Until now those answers were discarded on
                // the way in and had no screen on the way out.
                VStack(alignment: .leading, spacing: 10) {
                    Text("Service history")
                        .font(.headline)

                    ServiceHistoryCard(records: vehicle.serviceHistory ?? [])
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

                    if vehicle.profileVerification == .basicUnverified {
                        Text("Mileage, trim, and transmission were entered by you and haven't been checked against a catalog. This doesn't affect the accuracy of driving guidance.")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                            .padding(.horizontal, 16)
                            .padding(.bottom, 16)
                    }
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

                Button("Remove Vehicle", role: .destructive) {
                    isConfirmingRemoval = true
                }
                .font(.headline)
                .frame(maxWidth: .infinity)
                .padding()
                .buttonStyle(.bordered)

                HomeSectionHeader(
                    title: "Help nearby",
                    subtitle: "Find the right place for the problem"
                )

                Button {
                    if let url = MapsHandoff.url(searchingFor: MapsHandoff.genericRepairSearchTerm) {
                        openURL(url)
                    }
                } label: {
                    NearbyShopsCard()
                }
                .buttonStyle(.plain)
            }
            .padding(20)
        }
        .background(Color(.systemGroupedBackground))
        .navigationTitle("Vehicle")
        .navigationBarTitleDisplayMode(.inline)
        .confirmationDialog(
            "Remove \(vehicleName.isEmpty ? "this vehicle" : vehicleName)?",
            isPresented: $isConfirmingRemoval,
            titleVisibility: .visible
        ) {
            Button("Remove Vehicle", role: .destructive) {
                if garageStore.removeVehicle(id: vehicle.id) != nil {
                    dismiss()
                }
            }

            Button("Cancel", role: .cancel) {}
        } message: {
            Text("This removes the vehicle from OpenHood on this device.")
        }
        .fullScreenCover(isPresented: $isFinishingSetup) {
            FinishVehicleSetupView(savedVehicle: vehicle)
        }
    }
}

struct FinishVehicleSetupView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var vehicle: VehicleOnboardingData
    @StateObject private var setupSession: OnboardingSession

    init(savedVehicle: SavedVehicle) {
        _vehicle = StateObject(
            wrappedValue: VehicleOnboardingData(savedVehicle: savedVehicle)
        )
        _setupSession = StateObject(
            wrappedValue: OnboardingSession(existingVehicleID: savedVehicle.id)
        )
    }

    var body: some View {
        NavigationStack {
            MileageView()
                .toolbar {
                    ToolbarItem(placement: .cancellationAction) {
                        Button("Cancel") {
                            dismiss()
                        }
                    }
                }
        }
        .environmentObject(vehicle)
        .environmentObject(setupSession)
        .onChange(of: setupSession.completedVehicleID) { _, vehicleID in
            guard vehicleID != nil else { return }
            dismiss()
        }
    }
}

/// The profile card and the "Finish setting up this vehicle" button used to
/// be two separate things stacked on top of each other, both saying the same
/// thing in different words. They're one control now: the card itself is the
/// button while anything is missing, and it settles into a finished state
/// once the profile is complete rather than simply vanishing — a progress
/// indicator that disappears at 100% never actually shows you that you
/// finished.
private struct VehicleDetailProfileCard: View {
    let completion: Double
    var onFinishSetup: (() -> Void)?

    private var completionPercentage: Int {
        Int(completion * 100)
    }

    private var isComplete: Bool {
        completion >= 1.0
    }

    var body: some View {
        if isComplete || onFinishSetup == nil {
            cardBody
        } else {
            Button {
                onFinishSetup?()
            } label: {
                cardBody
            }
            .buttonStyle(.plain)
        }
    }

    private var cardBody: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Vehicle profile")
                        .font(.headline)

                    Text(isComplete ? "Complete" : "\(completionPercentage)% complete")
                        .font(.subheadline)
                        .foregroundStyle(isComplete ? .green : .secondary)
                }

                Spacer()

                if isComplete {
                    Image(systemName: "checkmark.seal.fill")
                        .font(.title2)
                        .foregroundStyle(.green)
                } else {
                    HStack(spacing: 6) {
                        Text("Finish setup")
                            .font(.subheadline)
                            .fontWeight(.semibold)

                        Image(systemName: "chevron.right")
                            .font(.caption)
                    }
                    .foregroundStyle(Color.accentColor)
                }
            }

            ProgressView(value: completion)
                .tint(isComplete ? .green : Color.accentColor)

            Text(
                isComplete
                    ? "OpenHood has everything it asks for about this vehicle. You can still update mileage and service history anytime."
                    : "A more complete profile helps OpenHood provide more relevant maintenance and diagnostic guidance."
            )
            .font(.caption)
            .foregroundStyle(.secondary)
        }
        .padding(20)
        .background(Color(.secondarySystemGroupedBackground))
        .clipShape(
            RoundedRectangle(cornerRadius: 22)
        )
        .overlay {
            RoundedRectangle(cornerRadius: 22)
                .stroke(
                    Color.secondary.opacity(0.12),
                    lineWidth: 1
                )
        }
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
