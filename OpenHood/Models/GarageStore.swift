import Combine
import Foundation

@MainActor
final class GarageStore: ObservableObject {
    @Published private(set) var vehicles: [SavedVehicle]
    @Published private(set) var activeVehicleID: UUID?

    private let persistence: any GaragePersisting

    var activeVehicle: SavedVehicle? {
        guard let activeVehicleID else {
            return nil
        }

        return vehicles.first { $0.id == activeVehicleID }
    }

    convenience init() {
        self.init(persistence: UserDefaultsGaragePersistence())
    }

    init(persistence: any GaragePersisting) {
        self.persistence = persistence

        let archive = persistence.load()
        self.vehicles = Self.removingDuplicateIDs(from: archive?.vehicles ?? [])

        if let storedID = archive?.activeVehicleID,
           vehicles.contains(where: { $0.id == storedID }) {
            self.activeVehicleID = storedID
        } else {
            self.activeVehicleID = vehicles.first?.id
        }
    }

    @discardableResult
    func add(_ vehicle: SavedVehicle) -> Bool {
        guard !vehicles.contains(where: { $0.id == vehicle.id }) else {
            return false
        }

        vehicles.append(vehicle)

        if activeVehicleID == nil {
            activeVehicleID = vehicle.id
        }

        persist()
        return true
    }

    @discardableResult
    func update(_ vehicle: SavedVehicle) -> Bool {
        guard let index = vehicles.firstIndex(where: { $0.id == vehicle.id }) else {
            return false
        }

        vehicles[index] = vehicle
        persist()
        return true
    }

    @discardableResult
    func selectVehicle(id: UUID) -> Bool {
        guard vehicles.contains(where: { $0.id == id }) else {
            return false
        }

        guard activeVehicleID != id else {
            return true
        }

        activeVehicleID = id
        persist()
        return true
    }

    @discardableResult
    func removeVehicle(id: UUID) -> SavedVehicle? {
        guard let removedIndex = vehicles.firstIndex(where: { $0.id == id }) else {
            return nil
        }

        let removedVehicle = vehicles.remove(at: removedIndex)

        if activeVehicleID == id {
            if vehicles.indices.contains(removedIndex) {
                activeVehicleID = vehicles[removedIndex].id
            } else {
                activeVehicleID = vehicles.last?.id
            }
        }

        if vehicles.isEmpty {
            activeVehicleID = nil
        }

        persist()
        return removedVehicle
    }

    func eraseAll() {
        vehicles = []
        activeVehicleID = nil
        persist()
    }

    private func persist() {
        persistence.save(
            GarageArchive(
                vehicles: vehicles,
                activeVehicleID: activeVehicleID
            )
        )
    }

    private static func removingDuplicateIDs(
        from vehicles: [SavedVehicle]
    ) -> [SavedVehicle] {
        var seenIDs = Set<UUID>()

        return vehicles.filter { vehicle in
            seenIDs.insert(vehicle.id).inserted
        }
    }
}
