import Foundation

struct SavedVehicle: Identifiable, Codable, Equatable {
    let id: UUID
    var make: String
    var model: String
    var year: Int?
    var bodyStyle: String?
    var powertrain: String?
    var drivetrain: String?
    var drivetrainSystem: String?
    var transmission: String?
    var trim: String?
    var mileage: Int?
    var profileVerification: VehicleProfileVerification

    init(
        id: UUID = UUID(),
        make: String,
        model: String,
        year: Int? = nil,
        bodyStyle: String? = nil,
        powertrain: String? = nil,
        drivetrain: String? = nil,
        drivetrainSystem: String? = nil,
        transmission: String? = nil,
        trim: String? = nil,
        mileage: Int? = nil,
        profileVerification: VehicleProfileVerification
    ) {
        self.id = id
        self.make = make
        self.model = model
        self.year = year
        self.bodyStyle = bodyStyle
        self.powertrain = powertrain
        self.drivetrain = drivetrain
        self.drivetrainSystem = drivetrainSystem
        self.transmission = transmission
        self.trim = trim
        self.mileage = mileage
        self.profileVerification = profileVerification
    }
}

extension SavedVehicle {
    init(id: UUID = UUID(), draft: VehicleOnboardingData) {
        self.init(
            id: id,
            make: draft.manufacturer,
            model: draft.model,
            year: Int(draft.year),
            bodyStyle: Self.knownValue(draft.bodyStyle),
            powertrain: Self.knownValue(draft.powertrain),
            drivetrain: Self.knownValue(draft.drivetrain),
            drivetrainSystem: Self.knownValue(draft.drivetrainSystem),
            transmission: Self.knownValue(draft.transmission),
            trim: Self.knownValue(draft.trim),
            mileage: Int(draft.mileage.filter(\.isNumber)),
            profileVerification: draft.profileVerification
        )
    }

    private static func knownValue(_ value: String) -> String? {
        let cleaned = value.trimmingCharacters(in: .whitespacesAndNewlines)

        guard !cleaned.isEmpty, cleaned != "Not confirmed" else {
            return nil
        }

        return cleaned
    }
}

extension VehicleOnboardingData {
    convenience init(savedVehicle: SavedVehicle) {
        self.init()
        load(savedVehicle)
    }

    func load(_ savedVehicle: SavedVehicle) {
        manufacturer = savedVehicle.make
        model = savedVehicle.model
        year = savedVehicle.year.map(String.init) ?? ""
        bodyStyle = savedVehicle.bodyStyle ?? ""
        powertrain = savedVehicle.powertrain ?? ""
        drivetrain = savedVehicle.drivetrain ?? ""
        drivetrainSystem = savedVehicle.drivetrainSystem ?? ""
        transmission = savedVehicle.transmission ?? ""
        trim = savedVehicle.trim ?? ""
        mileage = savedVehicle.mileage?.formatted() ?? ""
        profileVerification = savedVehicle.profileVerification
    }

    func savedVehicle(id: UUID = UUID()) -> SavedVehicle {
        SavedVehicle(id: id, draft: self)
    }
}
