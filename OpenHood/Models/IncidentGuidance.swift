import Foundation

enum IncidentWorkflowFamily: String, Codable, CaseIterable {
    case fluidLeakOrUnusualSmell
    case warningLightOrMessage
    case overheatingOrCooling
    case roughRunningStallingOrPostService
}

enum IncidentSystemCategory: String, Codable, CaseIterable, Identifiable {
    case engineAndCombustion = "Engine and combustion"
    case startingAndElectrical = "Starting and electrical"
    case fuelAndIgnition = "Fuel and ignition"
    case intakeAndAirMeasurement = "Intake and air measurement"
    case cooling = "Cooling-system pressure or circulation"
    case brakesAndSteering = "Braking hardware, hydraulic operation, or steering"
    case leaksSmokeAndOdors = "Leaks, smoke, and odors"
    case electricalAndWiring = "Electrical wiring or heat source"
    case exhaustAndVentilation = "Exhaust or cabin ventilation"
    case tiresWheelsAndPressure = "Tires, wheels, or pressure monitoring"
    case lubricationAndOilPressure = "Lubrication or oil-pressure monitoring"
    case ignition = "Ignition"
    case fuelDelivery = "Fuel delivery"
    case airOrVacuum = "Air or vacuum"
    case mechanicalOrCompression = "Mechanical or compression condition"

    var id: String { rawValue }
}

enum IncidentKnowledgeContentState: String, Codable {
    case verifiedGeneralAutomotivePrinciple
    case verifiedOEMOrGovernmentInformation
    case confirmedSolvedOwnerCase
    case communityReportedPattern
    case unresolvedHypothesis
}

enum IncidentKnowledgeVerificationState: String, Codable {
    case reviewedGeneralPrinciple
    case verifiedOEMOrGovernment
    case needsVerification
}

struct IncidentGuidanceSourceReference: Codable, Equatable {
    let id: String
    let title: String
    let location: String?
    let isPlaceholder: Bool
}

enum IncidentGuidanceEvidenceSignal: Codable, Equatable {
    case observation(IncidentObservationType)
    case safety(IncidentSafetySelection)
    case descriptionContains(String)
    case recentWork(IncidentRecentWorkResponse)
}

struct IncidentGuidanceConfidenceRules: Codable, Equatable {
    let minimumScore: Int
    let supportedWording: String
    let limitedWording: String
}

struct IncidentGuidanceKnowledgeRecord: Identifiable, Codable, Equatable {
    let id: String
    let contentVersion: Int
    let workflowFamily: IncidentWorkflowFamily
    let applicableObservations: [IncidentObservationType]
    let requiredEvidence: [IncidentGuidanceEvidenceSignal]
    let supportingEvidence: [IncidentGuidanceEvidenceSignal]
    let contradictingEvidence: [IncidentGuidanceEvidenceSignal]
    let possibleArea: IncidentSystemCategory
    let explanation: String
    let safeNextAction: IncidentRecommendedAction
    let actionsToAvoid: [String]
    let followUpQuestions: [String]
    let applicabilityLimits: [String]
    let confidenceRules: IncidentGuidanceConfidenceRules
    let verificationState: IncidentKnowledgeVerificationState
    let contentState: IncidentKnowledgeContentState
    let sourceReferences: [IncidentGuidanceSourceReference]
}

struct IncidentSupportingRationale: Equatable {
    let observedFact: String
    let explanation: String
}

struct IncidentPossibleContributor: Identifiable, Equatable {
    let recordID: String
    let category: IncidentSystemCategory
    let summary: String
    let confidenceWording: String
    let rationale: IncidentSupportingRationale

    var id: String { recordID }
}

struct IncidentEvidenceRequest: Identifiable, Equatable {
    let id: String
    let prompt: String

    init(_ prompt: String) {
        self.id = prompt
        self.prompt = prompt
    }
}

enum IncidentRecommendedAction: String, Codable, Equatable {
    case moreInformation = "More information needed"
    case safeObservation = "Record a safe observation"
    case obtainCodeScan = "Obtain a diagnostic code scan"
    case contactRecentRepairShop = "Contact the recent repair shop"
    case professionalInspection = "Request a qualified inspection"
    case roadsideAssistance = "Arrange roadside assistance"
    case emergencyServices = "Contact emergency services"
}

enum IncidentDriveRecommendation: String, Codable, Equatable {
    case stopDriving = "STOP DRIVING"
    case doNotRestart = "DO NOT RESTART"
    case serviceSoon = "SERVICE SOON"
    case checkBeforeDriving = "CHECK BEFORE DRIVING"
    case monitor = "MONITOR"
}

enum IncidentUrgentAnswerKey {
    static let immediateCondition = "immediateCondition"
    static let activeFlame = "activeFlame"
    static let smokePresent = "smokePresent"
    static let smokeSource = "smokeSource"
    static let smokeOdor = "smokeOdor"
    static let smellDescription = "smellDescription"
    static let smellLocation = "smellLocation"
    static let visibleEvidence = "visibleEvidence"
    static let recentTrigger = "recentTrigger"
    static let temperatureIndication = "temperatureIndication"
    static let coolingEvidence = "coolingEvidence"
    static let cabinHeat = "cabinHeat"
    static let drivingCondition = "drivingCondition"
    static let coolingRecentWork = "coolingRecentWork"
    static let warningSymbol = "warningSymbol"
    static let warningState = "warningState"
    static let engineBehavior = "engineBehavior"
    static let additionalWarning = "additionalWarning"
    static let concernType = "brakeOrSteering"
    static let brakeDetail = "brakeDetail"
    static let steeringDetail = "steeringDetail"
    static let controlBehavior = "controlBehavior"
    static let occurrenceContext = "occurrenceContext"
    static let controlWarning = "controlWarning"
    static let controlRecentWork = "controlRecentWork"
    static let runningDetail = "runningDetail"
    static let runningRecentWork = "runningRecentWork"
    static let runningWarning = "runningWarning"
    static let runningEvidence = "runningEvidence"
    static let restartEffect = "restartEffect"
}

struct IncidentGuidanceSnapshotArea: Codable, Equatable {
    let recordID: String
    let category: IncidentSystemCategory
    let confidenceWording: String
    let observedFact: String
    let explanation: String
}

struct IncidentGuidanceSnapshot: Codable, Equatable {
    let knowledgeVersion: Int
    let matchedRecordIDs: [String]
    let resultTimestamp: Date
    let urgency: IncidentUrgency?
    let possibleAreasShown: [IncidentSystemCategory]
    let recommendedNextAction: IncidentRecommendedAction
    let uncertaintyStatement: String
    let safetyStatus: String?
    let reportedSummary: String?
    let displayedAreas: [IncidentGuidanceSnapshotArea]?
    let actionExplanation: String?
    let safeEvidenceRequests: [String]?
    let actionsToAvoid: [String]?
    let mechanicReadySummary: String?
    let displayedUncertaintyStatements: [String]?
    let confidenceLabel: String?
    let knowledgeStatus: String?
    let driveRecommendation: IncidentDriveRecommendation?
    let plainLanguageAssessment: String?
    let immediateAction: String?
    let confirmationStep: String?
}

struct IncidentGuidanceResult: Equatable {
    let safetyStatus: String
    let isUrgent: Bool
    let urgency: IncidentUrgency?
    let reportedSummary: String
    let possibleContributors: [IncidentPossibleContributor]
    let uncertaintyStatements: [String]
    let evidenceRequests: [IncidentEvidenceRequest]
    let recommendedAction: IncidentRecommendedAction
    let actionExplanation: String
    let actionsToAvoid: [String]
    let mechanicReadySummary: String
    let knowledgeVersion: Int
    let matchedRecordIDs: [String]
    let confidenceLabel: String
    let knowledgeStatus: String
    let driveRecommendation: IncidentDriveRecommendation
    let plainLanguageAssessment: String
    let immediateAction: String
    let confirmationStep: String

    var snapshot: IncidentGuidanceSnapshot {
        IncidentGuidanceSnapshot(
            knowledgeVersion: knowledgeVersion,
            matchedRecordIDs: matchedRecordIDs,
            resultTimestamp: Date(),
            urgency: urgency,
            possibleAreasShown: possibleContributors.map(\.category),
            recommendedNextAction: recommendedAction,
            uncertaintyStatement: uncertaintyStatements.joined(separator: " "),
            safetyStatus: safetyStatus,
            reportedSummary: reportedSummary,
            displayedAreas: possibleContributors.map {
                IncidentGuidanceSnapshotArea(
                    recordID: $0.recordID,
                    category: $0.category,
                    confidenceWording: $0.confidenceWording,
                    observedFact: $0.rationale.observedFact,
                    explanation: $0.rationale.explanation
                )
            },
            actionExplanation: actionExplanation,
            safeEvidenceRequests: evidenceRequests.map(\.prompt),
            actionsToAvoid: actionsToAvoid,
            mechanicReadySummary: mechanicReadySummary,
            displayedUncertaintyStatements: uncertaintyStatements,
            confidenceLabel: confidenceLabel,
            knowledgeStatus: knowledgeStatus,
            driveRecommendation: driveRecommendation,
            plainLanguageAssessment: plainLanguageAssessment,
            immediateAction: immediateAction,
            confirmationStep: confirmationStep
        )
    }
}

extension IncidentGuidanceResult {
    init(snapshot: IncidentGuidanceSnapshot) {
        let areas = snapshot.displayedAreas ?? snapshot.possibleAreasShown.map {
            IncidentGuidanceSnapshotArea(
                recordID: "saved.unknown",
                category: $0,
                confidenceWording: "Saved possible area",
                observedFact: "Saved with the incident",
                explanation: "The original expanded explanation is unavailable in this older snapshot."
            )
        }

        self.init(
            safetyStatus: snapshot.safetyStatus ?? "Saved safety status unavailable",
            isUrgent: snapshot.urgency == .urgent,
            urgency: snapshot.urgency,
            reportedSummary: snapshot.reportedSummary ?? "Saved report unavailable",
            possibleContributors: areas.map {
                IncidentPossibleContributor(
                    recordID: $0.recordID,
                    category: $0.category,
                    summary: "Possible area",
                    confidenceWording: $0.confidenceWording,
                    rationale: IncidentSupportingRationale(
                        observedFact: $0.observedFact,
                        explanation: $0.explanation
                    )
                )
            },
            uncertaintyStatements: snapshot.displayedUncertaintyStatements
                ?? [snapshot.uncertaintyStatement],
            evidenceRequests: (snapshot.safeEvidenceRequests ?? [])
                .map { IncidentEvidenceRequest($0) },
            recommendedAction: snapshot.recommendedNextAction,
            actionExplanation: snapshot.actionExplanation
                ?? "Saved next-action details unavailable",
            actionsToAvoid: snapshot.actionsToAvoid ?? [],
            mechanicReadySummary: snapshot.mechanicReadySummary
                ?? "Saved mechanic information unavailable",
            knowledgeVersion: snapshot.knowledgeVersion,
            matchedRecordIDs: snapshot.matchedRecordIDs,
            confidenceLabel: snapshot.confidenceLabel ?? "Not enough information yet",
            knowledgeStatus: snapshot.knowledgeStatus ?? "Saved knowledge status unavailable",
            driveRecommendation: snapshot.driveRecommendation ?? .checkBeforeDriving,
            plainLanguageAssessment: snapshot.plainLanguageAssessment
                ?? "The saved result identifies possible systems, not a confirmed cause.",
            immediateAction: snapshot.immediateAction
                ?? snapshot.actionExplanation
                ?? "Arrange an appropriate inspection.",
            confirmationStep: snapshot.confirmationStep
                ?? snapshot.safeEvidenceRequests?.first
                ?? "A qualified inspection may be needed."
        )
    }
}
