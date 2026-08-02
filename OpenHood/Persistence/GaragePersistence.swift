import Foundation

struct GarageArchive: Codable, Equatable {
    static let currentVersion = 1

    let version: Int
    let vehicles: [SavedVehicle]
    let activeVehicleID: UUID?

    init(
        version: Int = Self.currentVersion,
        vehicles: [SavedVehicle],
        activeVehicleID: UUID?
    ) {
        self.version = version
        self.vehicles = vehicles
        self.activeVehicleID = activeVehicleID
    }
}

protocol GaragePersisting {
    func load() -> GarageArchive?
    func save(_ archive: GarageArchive)
}

struct UserDefaultsGaragePersistence: GaragePersisting {
    static let storageKey = "openhood.garage.archive.v1"

    private let defaults: UserDefaults
    private let encoder: JSONEncoder
    private let decoder: JSONDecoder

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
        self.encoder = JSONEncoder()
        self.decoder = JSONDecoder()
    }

    func load() -> GarageArchive? {
        guard let data = defaults.data(forKey: Self.storageKey),
              let archive = try? decoder.decode(GarageArchive.self, from: data),
              archive.version == GarageArchive.currentVersion else {
            return nil
        }

        return archive
    }

    func save(_ archive: GarageArchive) {
        guard let data = try? encoder.encode(archive) else {
            return
        }

        defaults.set(data, forKey: Self.storageKey)
    }
}
