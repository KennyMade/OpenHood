import SwiftUI
import Combine

struct AppRootView: View {
    @StateObject private var garageStore = GarageStore()

    var body: some View {
        Group {
            if let activeVehicle = garageStore.activeVehicle {
                ActiveVehicleBridgeView(savedVehicle: activeVehicle)
            } else {
                OnboardingRootView()
            }
        }
        .environmentObject(garageStore)
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
    let vehicleID = UUID()

    private(set) var hasCompleted = false
    @Published private(set) var completedVehicleID: UUID?

    @discardableResult
    func complete(
        vehicle: VehicleOnboardingData,
        garageStore: GarageStore
    ) -> Bool {
        guard !hasCompleted else {
            return false
        }

        let savedVehicle = vehicle.savedVehicle(id: vehicleID)

        guard garageStore.add(savedVehicle) else {
            return false
        }

        hasCompleted = true
        completedVehicleID = savedVehicle.id
        return true
    }
}
