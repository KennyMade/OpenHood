import Foundation

/// One piece of work the owner remembers having done.
///
/// `timeframe` is the point of this type. Knowing that brakes were done
/// says very little on its own — brakes done last month and brakes done
/// six years ago mean opposite things, and almost every maintenance
/// interval is defined by time or distance rather than by whether the job
/// was ever performed. The maintenance screens previously captured only
/// the "what", which is the half that can't be acted on.
///
/// Deliberately a coarse timeframe rather than an exact date: people
/// genuinely do not remember the day they had spark plugs done, and
/// forcing a date picker would either stall them or collect a confident
/// answer that isn't true. A range they can actually stand behind is more
/// useful than a precise number they guessed at.
struct VehicleServiceRecord: Identifiable, Codable, Equatable, Hashable {
    let id: UUID
    /// Display name of the work, e.g. "Brakes". Stored as text rather than
    /// as the MaintenanceService enum so a record survives that list being
    /// reordered or renamed later, and so free-text entries fit here too.
    var service: String
    /// Coarse, owner-reportable timeframe. Nil means they told us the work
    /// was done but not when — still worth keeping, and worth showing as
    /// "timing not recorded" rather than silently implying it was recent.
    var timeframe: String?
    /// Odometer reading when the work was done, if the owner knows it.
    ///
    /// This is the field that makes intervals computable rather than just
    /// displayable. A timeframe tells you roughly how long ago something
    /// happened; the mileage tells you how far the car has travelled since,
    /// which is what almost every maintenance interval is actually defined
    /// against. Together they also let OpenHood ask a genuinely useful
    /// question later — "you last logged an oil change at 158,000 miles,
    /// what are you at now?" — instead of nagging on a calendar.
    ///
    /// Optional because plenty of people remember roughly when a job was
    /// done but not the odometer reading, and demanding it would either
    /// stall them or collect a made-up number.
    var mileage: Int?
    /// Free-text detail, used by the "I know most of it" screen where
    /// people describe several jobs in their own words.
    var note: String?

    init(
        id: UUID = UUID(),
        service: String,
        timeframe: String? = nil,
        mileage: Int? = nil,
        note: String? = nil
    ) {
        self.id = id
        self.service = service
        self.timeframe = timeframe
        self.mileage = mileage
        self.note = note
    }

    /// The choices offered for `timeframe`, ordered newest to oldest.
    /// "I don't remember" is a real, first-class answer here for the same
    /// reason it is throughout the diagnostic flow — an honest unknown
    /// beats a pressured guess.
    static let timeframeOptions = [
        "Within the last 6 months",
        "6 to 12 months ago",
        "1 to 2 years ago",
        "More than 2 years ago",
        "I don't remember"
    ]

    /// How this reads in a list. Keeps the "when" attached to the "what"
    /// everywhere it's displayed, so the two can't drift apart in the UI.
    var displayLine: String {
        var detail: [String] = []

        if let timeframe, !timeframe.isEmpty {
            detail.append(timeframe)
        }
        if let mileage {
            detail.append("at \(mileage.formatted()) mi")
        }

        guard !detail.isEmpty else {
            return "\(service) — timing not recorded"
        }
        return "\(service) — \(detail.joined(separator: ", "))"
    }
}

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
    /// Work the owner told OpenHood about during setup.
    ///
    /// This existed nowhere before. The maintenance screens asked "how much
    /// do you know about its recent maintenance?", let people type notes or
    /// tick off services, and then discarded every answer — the selections
    /// were local view state, `SavedVehicle` had no field to put them in,
    /// and the Continue button did exactly what Skip did. That is why a
    /// person could never see what they had selected: it was never saved.
    ///
    /// Optional rather than a defaulted array on purpose: Swift's
    /// synthesized `Decodable` does not fall back to a property's default
    /// when a key is missing, so a non-Optional here would fail to decode
    /// every vehicle saved before this field existed. Same pattern the
    /// incident snapshot uses for its added fields.
    var serviceHistory: [VehicleServiceRecord]?
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
        serviceHistory: [VehicleServiceRecord]? = nil,
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
        self.serviceHistory = serviceHistory
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
            serviceHistory: draft.serviceHistory.isEmpty ? nil : draft.serviceHistory,
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
        serviceHistory = savedVehicle.serviceHistory ?? []
        profileVerification = savedVehicle.profileVerification
    }

    func savedVehicle(id: UUID = UUID()) -> SavedVehicle {
        SavedVehicle(id: id, draft: self)
    }
}
