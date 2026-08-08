import SwiftUI
import Combine

struct AppRootView: View {
    @StateObject private var garageStore = GarageStore()
    @StateObject private var incidentStore = IncidentStore()

    var body: some View {
        Group {
            if let activeVehicle = garageStore.activeVehicle {
                ActiveVehicleBridgeView(savedVehicle: activeVehicle)
            } else {
                OnboardingRootView()
            }
        }
        .environmentObject(garageStore)
        .environmentObject(incidentStore)
    }
}

private struct OnboardingRootView: View {
    @StateObject private var vehicle = VehicleOnboardingData()
    @StateObject private var session = OnboardingSession()

    var body: some View {
        NavigationStack {
            WelcomeView()
        }
        .environmentObject(vehicle)
        .environmentObject(session)
    }
}

private struct ActiveVehicleBridgeView: View {
    let savedVehicle: SavedVehicle

    @StateObject private var vehicle: VehicleOnboardingData

    init(savedVehicle: SavedVehicle) {
        self.savedVehicle = savedVehicle
        _vehicle = StateObject(
            wrappedValue: VehicleOnboardingData(savedVehicle: savedVehicle)
        )
    }

    var body: some View {
        MainTabView()
            .environmentObject(vehicle)
            .onChange(of: savedVehicle) { _, updatedVehicle in
                vehicle.load(updatedVehicle)
            }
    }
}

@MainActor
final class OnboardingSession: ObservableObject {
    let vehicleID: UUID

    /// When set, completing this session updates the existing saved vehicle
    /// instead of adding a new one — used by the "finish setting up this
    /// vehicle" flow reached from a vehicle's profile after onboarding.
    private let existingVehicleID: UUID?

    private(set) var hasCompleted = false
    @Published private(set) var completedVehicleID: UUID?

    init(existingVehicleID: UUID? = nil) {
        self.existingVehicleID = existingVehicleID
        self.vehicleID = existingVehicleID ?? UUID()
    }

    @discardableResult
    func complete(
        vehicle: VehicleOnboardingData,
        garageStore: GarageStore
    ) -> Bool {
        guard !hasCompleted else {
            return false
        }

        let savedVehicle = vehicle.savedVehicle(id: vehicleID)

        let didSave = existingVehicleID != nil
            ? garageStore.update(savedVehicle)
            : garageStore.add(savedVehicle)

        guard didSave else {
            return false
        }

        hasCompleted = true
        completedVehicleID = savedVehicle.id
        return true
    }
}
