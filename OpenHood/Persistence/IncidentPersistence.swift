import Foundation

struct IncidentArchive: Codable, Equatable {
    static let currentVersion = 1

    let version: Int
    let incidents: [VehicleIncident]

    init(
        version: Int = Self.currentVersion,
        incidents: [VehicleIncident]
    ) {
        self.version = version
        self.incidents = incidents
    }
}

protocol IncidentPersisting {
    func load() -> IncidentArchive?
    func save(_ archive: IncidentArchive)
}

struct UserDefaultsIncidentPersistence: IncidentPersisting {
    static let storageKey = "openhood.incidents.archive.v1"

    private let defaults: UserDefaults
    private let encoder = JSONEncoder()
    private let decoder = JSONDecoder()

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
    }

    func load() -> IncidentArchive? {
        guard let data = defaults.data(forKey: Self.storageKey),
              let archive = try? decoder.decode(IncidentArchive.self, from: data),
              archive.version == IncidentArchive.currentVersion else {
            return nil
        }

        return archive
    }

    func save(_ archive: IncidentArchive) {
        guard let data = try? encoder.encode(archive) else {
            return
        }

        defaults.set(data, forKey: Self.storageKey)
    }
}
