import Combine
import Foundation

@MainActor
final class IncidentStore: ObservableObject {
    @Published private(set) var incidents: [VehicleIncident]

    private let persistence: any IncidentPersisting

    convenience init() {
        self.init(persistence: UserDefaultsIncidentPersistence())
    }

    init(persistence: any IncidentPersisting) {
        self.persistence = persistence
        incidents = Self.removingDuplicateIDs(
            from: persistence.load()?.incidents ?? []
        )
    }

    func draft(for vehicleID: UUID) -> VehicleIncident? {
        incidents.first {
            $0.vehicleID == vehicleID && $0.status == .draft
        }
    }

    func startNewDraft(for vehicleID: UUID) -> VehicleIncident {
        incidents.removeAll {
            $0.vehicleID == vehicleID && $0.status == .draft
        }

        let incident = VehicleIncident(vehicleID: vehicleID)
        incidents.append(incident)
        persist()
        return incident
    }

    func saveDraft(_ incident: VehicleIncident) {
        var updatedIncident = incident
        updatedIncident.status = .draft
        updatedIncident.updatedAt = Date()
        upsert(updatedIncident)
    }

    func submit(_ incident: VehicleIncident) {
        var submittedIncident = incident
        submittedIncident.status = .submitted
        submittedIncident.updatedAt = Date()
        upsert(submittedIncident)
    }

    func discardDraft(for vehicleID: UUID) {
        incidents.removeAll {
            $0.vehicleID == vehicleID && $0.status == .draft
        }
        persist()
    }

    private func upsert(_ incident: VehicleIncident) {
        if let index = incidents.firstIndex(where: { $0.id == incident.id }) {
            incidents[index] = incident
        } else {
            incidents.append(incident)
        }
        persist()
    }

    private func persist() {
        persistence.save(IncidentArchive(incidents: incidents))
    }

    private static func removingDuplicateIDs(
        from incidents: [VehicleIncident]
    ) -> [VehicleIncident] {
        var seenIDs = Set<UUID>()
        return incidents.filter { seenIDs.insert($0.id).inserted }
    }
}
