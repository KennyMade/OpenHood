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

struct VehicleDetailView: View {
    @EnvironmentObject private var garageStore: GarageStore
    @Environment(\.dismiss) private var dismiss
    @State private var isConfirmingRemoval = false

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

                VehicleDetailProfileCard(completion: profileCompletion)

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

                Button("Remove Vehicle", role: .destructive) {
                    isConfirmingRemoval = true
                }
                .font(.headline)
                .frame(maxWidth: .infinity)
                .padding()
                .buttonStyle(.bordered)

                HomeSectionHeader(
                    title: "Vehicle health",
                    subtitle: "What OpenHood currently knows"
                )

                NavigationLink {
                    PlaceholderDestinationView(
                        title: "Vehicle Health",
                        message: "Your vehicle-health baseline will appear here after you confirm service history, symptoms, and inspection information."
                    )
                } label: {
                    VehicleHealthCard()
                }
                .buttonStyle(.plain)

                HomeSectionHeader(
                    title: "Maintenance",
                    subtitle: "Stay ahead of what comes next"
                )

                NavigationLink {
                    PlaceholderDestinationView(
                        title: "Maintenance Plan",
                        message: "OpenHood will build a maintenance plan using your mileage, vehicle configuration, service history, and factory guidance."
                    )
                } label: {
                    MaintenanceSummaryCard()
                }
                .buttonStyle(.plain)

                HomeSectionHeader(
                    title: "Service history",
                    subtitle: "Everything done to your vehicle"
                )

                NavigationLink {
                    PlaceholderDestinationView(
                        title: "Service History",
                        message: "Add repairs, maintenance, inspections, receipts, dates, mileage, parts, and shop information here."
                    )
                } label: {
                    ServiceHistoryCard()
                }
                .buttonStyle(.plain)

                HomeSectionHeader(
                    title: "Help nearby",
                    subtitle: "Find the right place for the problem"
                )

                NavigationLink {
                    PlaceholderDestinationView(
                        title: "Nearby Shops",
                        message: "OpenHood will match nearby repair shops and service centers to your vehicle and selected problem."
                    )
                } label: {
                    NearbyShopsCard()
                }
                .buttonStyle(.plain)

                HomeSectionHeader(
                    title: "Vehicle resources",
                    subtitle: "Knowledge, documents, and ownership tools"
                )

                LazyVGrid(
                    columns: [
                        GridItem(.flexible()),
                        GridItem(.flexible())
                    ],
                    spacing: 14
                ) {
                    NavigationLink {
                        PlaceholderDestinationView(
                            title: "Specifications",
                            message: "Engine, drivetrain, fluids, capacities, tires, and factory specifications will live here."
                        )
                    } label: {
                        CompactHomeCard(
                            icon: "gauge.with.dots.needle.50percent",
                            title: "Specs",
                            subtitle: "Factory information"
                        )
                    }
                    .buttonStyle(.plain)

                    NavigationLink {
                        PlaceholderDestinationView(
                            title: "Documents",
                            message: "Receipts, inspections, manuals, estimates, warranties, and reports will live here."
                        )
                    } label: {
                        CompactHomeCard(
                            icon: "doc.text.fill",
                            title: "Documents",
                            subtitle: "Keep every record"
                        )
                    }
                    .buttonStyle(.plain)

                    NavigationLink {
                        PlaceholderDestinationView(
                            title: "Known Concerns",
                            message: "Known concerns and inspection-first guidance for your \(vehicle.model) will live here."
                        )
                    } label: {
                        CompactHomeCard(
                            icon: "exclamationmark.triangle.fill",
                            title: "Concerns",
                            subtitle: "Know what to inspect"
                        )
                    }
                    .buttonStyle(.plain)

                    NavigationLink {
                        PlaceholderDestinationView(
                            title: "Owner Resources",
                            message: "Owner manuals, recall resources, and factory publications will live here."
                        )
                    } label: {
                        CompactHomeCard(
                            icon: "books.vertical.fill",
                            title: "Resources",
                            subtitle: "Manuals and recalls"
                        )
                    }
                    .buttonStyle(.plain)
                }
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
    }
}

private struct VehicleDetailProfileCard: View {
    let completion: Double

    private var completionPercentage: Int {
        Int(completion * 100)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Vehicle profile")
                        .font(.headline)

                    Text("\(completionPercentage)% complete")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }

                Spacer()

                Image(systemName: "checklist")
                    .font(.title2)
            }

            ProgressView(value: completion)
                .tint(.primary)

            Text(
                "A more complete profile helps OpenHood provide more relevant maintenance and diagnostic guidance."
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
