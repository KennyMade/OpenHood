import Foundation

enum IncidentStatus: String, Codable {
    case draft
    case submitted
}

enum IncidentUrgency: String, Codable {
    case urgent
    case caution
    case routine
}

enum IncidentSafetySelection: String, Codable, CaseIterable, Identifiable {
    case smokeOrFire
    case strongFuelSmell
    case overheatingOrSteam
    case flashingWarningLight
    case unsafeBrakesOrSteering
    case visibleTireDamage
    case engineWillNotStayRunning
    // Added alongside the transmission-question escalation fix in
    // SomethingHappenedView (see the doc comment on
    // IncidentStartingAnswerKey.transmissionBehavior) — previously
    // "engine revs but the car doesn't speed up" and "burning smell"
    // were known-dangerous but had no honest fit among the 7 categories
    // above, so they were left unescalated on purpose. This is the 8th
    // category, added the same way the previous 7 were: a real,
    // dangerous, plausible symptom that deserves its own STOP DRIVING
    // treatment rather than an ordinary Phase 1 result.
    case transmissionSlippingOrBurningSmell
    case noneOfThese
    case unsure

    var id: String { rawValue }

    var title: String {
        switch self {
        case .smokeOrFire: "Smoke or fire"
        case .strongFuelSmell: "Strong fuel smell"
        case .overheatingOrSteam: "Overheating or steam"
        case .flashingWarningLight: "Flashing warning light"
        case .unsafeBrakesOrSteering: "Brakes or steering feel unsafe"
        case .visibleTireDamage: "Visible tire damage"
        case .engineWillNotStayRunning: "The engine will not stay running"
        case .transmissionSlippingOrBurningSmell: "Transmission slipping, or a burning smell"
        case .noneOfThese: "None of these"
        case .unsure: "I’m not sure"
        }
    }

    var urgency: IncidentUrgency {
        switch self {
        case .smokeOrFire,
             .strongFuelSmell,
             .overheatingOrSteam,
             .flashingWarningLight,
             .unsafeBrakesOrSteering,
             .visibleTireDamage,
             .engineWillNotStayRunning,
             .transmissionSlippingOrBurningSmell:
            .urgent
        case .unsure:
            .caution
        case .noneOfThese:
            .routine
        }
    }
}

enum IncidentObservationType: String, Codable, CaseIterable, Identifiable {
    case sound
    case vibrationOrMovement
    case smell
    case visible
    case warningLightOrMessage
    case drivingChange
    case startingOrRunningTrouble
    case somethingElse

    var id: String { rawValue }

    var title: String {
        switch self {
        case .sound: "A sound"
        case .vibrationOrMovement: "Vibration or shaking"
        case .smell: "An unusual smell"
        case .visible: "Something visible"
        case .warningLightOrMessage: "A warning light"
        case .drivingChange: "It drives differently"
        case .startingOrRunningTrouble: "Trouble starting or staying running"
        case .somethingElse: "Something else"
        }
    }
}

enum IncidentRecentWorkResponse: String, Codable, CaseIterable, Identifiable {
    case yes
    case no
    case unsure

    var id: String { rawValue }

    var title: String {
        switch self {
        case .yes: "Yes"
        case .no: "No"
        case .unsure: "I’m not sure"
        }
    }
}

struct VehicleIncident: Identifiable, Codable, Equatable {
    let id: UUID
    let vehicleID: UUID
    let createdAt: Date
    var updatedAt: Date
    var status: IncidentStatus
    var safetySelection: IncidentSafetySelection?
    var observationTypes: [IncidentObservationType]
    var userDescription: String
    var recentWorkResponse: IncidentRecentWorkResponse?
    var recentWorkNotes: String
    var guidanceSnapshot: IncidentGuidanceSnapshot?
    var urgentFollowUpAnswers: [String: String]?
    var noiseFollowUpAnswers: [String: String]?
    var warningFollowUpAnswers: [String: String]?
    var fluidFollowUpAnswers: [String: String]?
    var startingFollowUpAnswers: [String: String]?
    var drivingChangeFollowUpAnswers: [String: String]?

    var urgency: IncidentUrgency? {
        safetySelection?.urgency
    }

    init(
        id: UUID = UUID(),
        vehicleID: UUID,
        createdAt: Date = Date(),
        updatedAt: Date = Date(),
        status: IncidentStatus = .draft,
        safetySelection: IncidentSafetySelection? = nil,
        observationTypes: [IncidentObservationType] = [],
        userDescription: String = "",
        recentWorkResponse: IncidentRecentWorkResponse? = nil,
        recentWorkNotes: String = "",
        guidanceSnapshot: IncidentGuidanceSnapshot? = nil,
        urgentFollowUpAnswers: [String: String]? = nil,
        noiseFollowUpAnswers: [String: String]? = nil,
        warningFollowUpAnswers: [String: String]? = nil,
        fluidFollowUpAnswers: [String: String]? = nil,
        startingFollowUpAnswers: [String: String]? = nil,
        drivingChangeFollowUpAnswers: [String: String]? = nil
    ) {
        self.id = id
        self.vehicleID = vehicleID
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        self.status = status
        self.safetySelection = safetySelection
        self.observationTypes = observationTypes
        self.userDescription = userDescription
        self.recentWorkResponse = recentWorkResponse
        self.recentWorkNotes = recentWorkNotes
        self.guidanceSnapshot = guidanceSnapshot
        self.urgentFollowUpAnswers = urgentFollowUpAnswers
        self.noiseFollowUpAnswers = noiseFollowUpAnswers
        self.warningFollowUpAnswers = warningFollowUpAnswers
        self.fluidFollowUpAnswers = fluidFollowUpAnswers
        self.startingFollowUpAnswers = startingFollowUpAnswers
        self.drivingChangeFollowUpAnswers = drivingChangeFollowUpAnswers
    }
}
