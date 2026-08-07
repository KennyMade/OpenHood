import Foundation

enum IncidentWorkflowFamily: String, Codable, CaseIterable {
    case fluidLeakOrUnusualSmell
    case warningLightOrMessage
    case overheatingOrCooling
    case roughRunningStallingOrPostService
    case noiseVibrationOrSuspension
    case drivingChange
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
    case hydraulicBrakingSystem = "Hydraulic pressure or brake-fluid containment"
    case powerSteeringOrEPS = "Power-steering or EPS system"
    case steeringControlConcern = "Steering-control concern"
    case suspensionAndChassis = "Suspension or chassis"

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

/// One jargon term inside a record's possible-area list, shown as its own
/// tappable row (icon + name) that expands to a one-sentence plain-English
/// explanation. `typicalCostRange` is a display string, not a number, so
/// a record can say "varies significantly depending on X" instead of a
/// false-precision figure when the real range genuinely depends on
/// factors the record can't know (e.g. strut mounts).
struct IncidentPossibleAreaTerm: Identifiable, Codable, Equatable {
    let id: String
    let name: String
    let plainExplanation: String
    let typicalCostRange: String?
}

// MARK: - Evidence-gated claims (IncidentKnowledgePack-v1.2)
//
// Three independent axes per claim, matching the pack's evidence-governance
// model. These must never be collapsed into a single verification label —
// a claim can be a DIRECT quote from a VERIFIED_OEM_OR_GOVERNMENT source and
// still be scope-limited to one manufacturer/model/year, or be an internal
// OpenHood product-policy rule with no external source at all.

enum IncidentClaimSourceTier: String, Codable {
    case verifiedOEMOrGovernment
    case professionallySupportedGeneralGuidance
    case confirmedSolvedOwnerCase
    case communityReportedPattern
    case unresolvedHypothesis
    case noExternalSourceProductPolicy
}

enum IncidentClaimSupportType: String, Codable {
    case direct
    case inference
    case none
    case contradicted
}

/// Governs whether a claim may affect anything the user sees. Only
/// `.visibleGuidanceApproved`, `.visibleGuidanceScopeLimited` (when scope
/// matches), and `.productPolicy` may reach visible output — see
/// `IncidentClaimVisibility`.
enum IncidentClaimProductUseStatus: String, Codable {
    case visibleGuidanceApproved
    case visibleGuidanceScopeLimited
    case productPolicy
    case researchOnly
    case needsVerification
    case rejected
}

/// The applicability gate for a `.visibleGuidanceScopeLimited` claim.
/// A claim with a scope only ever fires for a vehicle matching every
/// non-nil field here — no fuzzy/substring matching, since the pack
/// explicitly forbids e.g. one Honda model's manual covering all Hondas.
struct IncidentClaimVehicleScope: Codable, Equatable {
    let makes: [String]?
    let models: [String]?
    let bodyStyles: [String]?
    let modelYears: ClosedRange<Int>?
    let excludedPowertrainKeywords: [String]?
    let requiresVerifiedProfile: Bool

    init(
        makes: [String]? = nil,
        models: [String]? = nil,
        bodyStyles: [String]? = nil,
        modelYears: ClosedRange<Int>? = nil,
        excludedPowertrainKeywords: [String]? = nil,
        requiresVerifiedProfile: Bool = true
    ) {
        self.makes = makes
        self.models = models
        self.bodyStyles = bodyStyles
        self.modelYears = modelYears
        self.excludedPowertrainKeywords = excludedPowertrainKeywords
        self.requiresVerifiedProfile = requiresVerifiedProfile
    }
}

struct IncidentClaim: Identifiable, Equatable {
    let id: String
    let exactClaim: String
    let sourceTier: IncidentClaimSourceTier
    let supportType: IncidentClaimSupportType
    let productUseStatus: IncidentClaimProductUseStatus
    let source: String
    let limitations: String?
    /// Required and consulted only when productUseStatus == .visibleGuidanceScopeLimited.
    let scope: IncidentClaimVehicleScope?

    init(
        id: String,
        exactClaim: String,
        sourceTier: IncidentClaimSourceTier,
        supportType: IncidentClaimSupportType,
        productUseStatus: IncidentClaimProductUseStatus,
        source: String,
        limitations: String? = nil,
        scope: IncidentClaimVehicleScope? = nil
    ) {
        self.id = id
        self.exactClaim = exactClaim
        self.sourceTier = sourceTier
        self.supportType = supportType
        self.productUseStatus = productUseStatus
        self.source = source
        self.limitations = limitations
        self.scope = scope
    }
}

/// Enforces the pack's exclusion rule structurally: callers can only ever
/// obtain claims that are eligible to affect visible output. There is no
/// path from a RESEARCH_ONLY/NEEDS_VERIFICATION/REJECTED claim into a
/// result field other than through here, and here they are always dropped.
enum IncidentClaimVisibility {
    static func matchesScope(
        _ scope: IncidentClaimVehicleScope,
        vehicle: SavedVehicle
    ) -> Bool {
        if scope.requiresVerifiedProfile,
           vehicle.profileVerification != .verified {
            return false
        }
        if let makes = scope.makes,
           !makes.contains(where: {
               $0.caseInsensitiveCompare(vehicle.make) == .orderedSame
           }) {
            return false
        }
        if let models = scope.models,
           !models.contains(where: {
               $0.caseInsensitiveCompare(vehicle.model) == .orderedSame
           }) {
            return false
        }
        if let bodyStyles = scope.bodyStyles {
            guard let vehicleBodyStyle = vehicle.bodyStyle,
                  bodyStyles.contains(where: {
                      $0.caseInsensitiveCompare(vehicleBodyStyle) == .orderedSame
                  }) else {
                return false
            }
        }
        if let years = scope.modelYears {
            guard let year = vehicle.year, years.contains(year) else {
                return false
            }
        }
        if let excludedKeywords = scope.excludedPowertrainKeywords,
           let powertrain = vehicle.powertrain,
           excludedKeywords.contains(where: {
               powertrain.localizedCaseInsensitiveContains($0)
           }) {
            return false
        }
        return true
    }

    static func isVisible(_ claim: IncidentClaim, vehicle: SavedVehicle) -> Bool {
        switch claim.productUseStatus {
        case .visibleGuidanceApproved, .productPolicy:
            return true
        case .visibleGuidanceScopeLimited:
            guard let scope = claim.scope else { return false }
            return matchesScope(scope, vehicle: vehicle)
        case .researchOnly, .needsVerification, .rejected:
            return false
        }
    }

    /// Resolves claim IDs against the registry and returns only the
    /// subset eligible to affect visible output for this vehicle, in the
    /// order the IDs were requested.
    static func visibleClaims(
        ids: [String],
        from registry: [IncidentClaim],
        vehicle: SavedVehicle
    ) -> [IncidentClaim] {
        let byID = Dictionary(uniqueKeysWithValues: registry.map { ($0.id, $0) })
        return ids.compactMap { byID[$0] }
            .filter { isVisible($0, vehicle: vehicle) }
    }
}

enum IncidentGuidanceEvidenceSignal: Codable, Equatable {
    case observation(IncidentObservationType)
    case safety(IncidentSafetySelection)
    case descriptionContains(String)
    case recentWork(IncidentRecentWorkResponse)
    /// A structured routine follow-up answer, e.g. IncidentNoiseAnswerKey
    /// answers on VehicleIncident.noiseFollowUpAnswers. Unlike
    /// descriptionContains, this only matches an exact recorded answer —
    /// no free-text keyword guessing.
    case noiseAnswer(key: String, value: String)
    /// Same idea as noiseAnswer, for the warning-light/message family —
    /// IncidentWarningAnswerKey answers on
    /// VehicleIncident.warningFollowUpAnswers. Kept as its own dictionary
    /// and its own signal case rather than reusing noiseAnswer so the two
    /// structured follow-up flows can't collide on key names.
    case warningAnswer(key: String, value: String)
    /// Same idea as noiseAnswer/warningAnswer, for the fluid-leak/
    /// unusual-odor family — IncidentFluidAnswerKey answers on
    /// VehicleIncident.fluidFollowUpAnswers. Its own dictionary and its
    /// own signal case for the same reason: keeps this flow from
    /// colliding on key names with the other two.
    case fluidAnswer(key: String, value: String)
    /// Same idea as noiseAnswer/warningAnswer/fluidAnswer, for the
    /// starting-trouble family (phase1.starting.electrical,
    /// phase1.starting.fuel-ignition) — IncidentStartingAnswerKey answers
    /// on VehicleIncident.startingFollowUpAnswers.
    case startingAnswer(key: String, value: String)
    /// Same idea as noiseAnswer/warningAnswer/fluidAnswer/startingAnswer,
    /// for the driving-change family (phase1.driving-change.*) —
    /// IncidentDrivingChangeAnswerKey answers on
    /// VehicleIncident.drivingChangeFollowUpAnswers.
    case drivingChangeAnswer(key: String, value: String)
}

/// Structured follow-up questions for the noise/vibration/suspension
/// record family (phase1.suspension.bump-noise) — asked instead of
/// relying on free-text description matching, since nobody types
/// "control arm bushing." Answers are stored in
/// VehicleIncident.noiseFollowUpAnswers and matched via
/// IncidentGuidanceEvidenceSignal.noiseAnswer.
enum IncidentNoiseAnswerKey {
    static let location = "noiseLocation"
    static let timing = "noiseTiming"
    static let sound = "noiseSound"
}

/// Structured follow-up question for the warning-light/message record
/// family (phase1.warning.record-code, phase1.warning.engine-information)
/// — same reasoning as IncidentNoiseAnswerKey above: asked instead of
/// relying on free-text description matching. Answers are stored in
/// VehicleIncident.warningFollowUpAnswers and matched via
/// IncidentGuidanceEvidenceSignal.warningAnswer.
enum IncidentWarningAnswerKey {
    static let light = "warningLight"
    /// OH-UIK gap fix (same tier as the odor-escalation and oil-pressure
    /// severity fixes): asked only as a follow-up when `light` is
    /// answered "Temperature warning light" — see
    /// SomethingHappenedView.warningQuestions/temperatureEscalation. Every
    /// answer to this follow-up escalates into the urgent
    /// .overheatingOrSteam path; it never contributes to an ordinary
    /// Phase 1 result.
    static let temperatureDetail = "warningTemperatureDetail"
    /// Asked only as a follow-up when `light` is answered "ABS or
    /// traction control light" — see SomethingHappenedView.warningQuestions
    /// /absTractionEscalation. Unlike temperatureDetail, this one DOES have
    /// a safe branch: "No, just this one" resolves to a real ordinary
    /// Phase 1 record (phase1.warning.abs-traction-alone) since ABS-alone
    /// means the anti-lock function may not work correctly while normal
    /// braking still works. "Yes, both are on" and "I'm not sure" escalate
    /// into the urgent .unsafeBrakesOrSteering path instead, since a
    /// regular brake warning light on at the same time (or an unconfirmed
    /// answer) is a real hydraulic-system possibility, not general content.
    static let absBrakeCheck = "warningABSBrakeCheck"
}

/// Structured follow-up questions for the fluid-leak/unusual-odor record
/// family (phase1.fluid-smell.visible-fluid, phase1.fluid-smell.unusual-
/// odor, phase1.exhaust-smoke.*) — same reasoning as
/// IncidentNoiseAnswerKey/IncidentWarningAnswerKey above. Answers are
/// stored in VehicleIncident.fluidFollowUpAnswers and matched via
/// IncidentGuidanceEvidenceSignal.fluidAnswer. Three separate keys (not
/// one) because a single incident can report a visible fluid, an unusual
/// odor, and exhaust smoke color, each answered independently.
enum IncidentFluidAnswerKey {
    static let whatWasVisible = "fluidWhatWasVisible"
    static let color = "fluidColor"
    static let odor = "fluidOdor"
    /// phase1.exhaust-smoke.* split — see SomethingHappenedView.
    /// fluidQuestions. Shares this dictionary/signal rather than getting
    /// its own answer-key enum: it's the same general "what did you
    /// notice" family as color/odor, just a third independent question,
    /// asked whenever either .visible or .smell is reported (unlike color/
    /// odor, which are each gated on their own single observation). All
    /// four answers are safe, ordinary Phase 1 content — no escalation,
    /// unlike odor's "Electrical or burning plastic"/"Exhaust".
    static let exhaustSmokeColor = "fluidExhaustSmokeColor"
}

/// Structured follow-up questions for the starting-trouble record family
/// (phase1.starting.electrical, phase1.starting.fuel-ignition,
/// phase1.starting.engine-operation, phase1.transmission) — same
/// reasoning as IncidentNoiseAnswerKey/IncidentWarningAnswerKey/
/// IncidentFluidAnswerKey above. Answers are stored in
/// VehicleIncident.startingFollowUpAnswers and matched via
/// IncidentGuidanceEvidenceSignal.startingAnswer. Four keys because a
/// no-crank/clicking report (crankBehavior), a cranks-but-won't-catch
/// report (crankClues), a post-start running-behavior report
/// (whatsHappening), and a transmission-behavior report
/// (transmissionBehavior) are asked independently, same reasoning as
/// IncidentFluidAnswerKey.color/.odor.
enum IncidentStartingAnswerKey {
    static let crankBehavior = "startingCrankBehavior"
    static let crankClues = "startingCrankClues"
    /// phase1.starting.engine-operation split — see
    /// SomethingHappenedView.startingQuestions/engineOperationEscalation
    /// and IncidentGuidanceKnowledge. "The engine actually shuts off or
    /// dies" never reaches a record keyed on this answer — it escalates
    /// into IncidentSafetySelection.engineWillNotStayRunning before
    /// Phase 1 evaluation ever runs, same mechanism as
    /// dangerousOdorEscalation/temperatureObservationEscalation.
    static let whatsHappening = "startingWhatsHappening"
    /// phase1.transmission split — see SomethingHappenedView.
    /// startingQuestions. Only "Shifting feels harsh or delayed..." and
    /// "I'm not sure" resolve to an ordinary Phase 1 record today.
    /// "Slipping" and "burning smell" are known-dangerous (real guidance:
    /// stop driving as soon as safely possible) but are DELIBERATELY NOT
    /// escalated as of this writing — none of the app's 7 existing
    /// IncidentSafetySelection categories fit without asking a misleading
    /// follow-up question (checked against each category's actual
    /// urgentQuestions wording, not just its name; see the review notes
    /// where this key was introduced). Until a product decision adds a
    /// category that fits, selecting either of those two answers falls
    /// through to an ordinary Phase 1 result with no matching record —
    /// a known, called-out gap, not an oversight.
    static let transmissionBehavior = "startingTransmissionBehavior"
}

/// Structured follow-up questions for the driving-change record family
/// (phase1.driving-change.pulls-to-one-side, phase1.driving-change.heavy-
/// steering, phase1.driving-change.sluggish-acceleration) — same reasoning
/// as IncidentStartingAnswerKey above. Answers are stored in
/// VehicleIncident.drivingChangeFollowUpAnswers and matched via
/// IncidentGuidanceEvidenceSignal.drivingChangeAnswer. pullingTiming and
/// steeringOnset are each asked only as a conditional follow-up once
/// whatChanged is answered "Pulls to one side" or "Steering feels heavier
/// than normal" respectively — see
/// SomethingHappenedView.drivingChangeQuestions/
/// drivingChangeQuestionDestination. "Mainly when braking" and "Suddenly"
/// both escalate into the urgent .unsafeBrakesOrSteering path rather than
/// ever reaching Phase 1 evaluation, same mechanism brakeGrindEscalation
/// already uses.
enum IncidentDrivingChangeAnswerKey {
    static let whatChanged = "drivingChangeWhatChanged"
    static let pullingTiming = "drivingChangePullingTiming"
    static let steeringOnset = "drivingChangeSteeringOnset"
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
    /// Individual tappable possible-area rows (item 3's tap-to-explain
    /// pattern). Empty for the 8 placeholder records, which have no
    /// reviewed per-term content yet — the UI falls back to a plain
    /// category list for those.
    let possibleAreaTerms: [IncidentPossibleAreaTerm]
    /// Pre-filled Maps search, e.g. "suspension repair" — nil when a
    /// record has no natural single-system repair search (or hasn't
    /// been given one yet).
    let repairSearchTerm: String?
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
    /// Defaulted (not Optional) because this type is never persisted —
    /// see IncidentGuidanceSnapshotArea for the Codable counterpart that
    /// does need true Optionals for safe decode of older saved incidents.
    let terms: [IncidentPossibleAreaTerm]
    let repairSearchTerm: String?
    /// True only when the backing record's verificationState is not
    /// .needsVerification — gates the "Reviewed automotive guidance, not
    /// a guess" trust line so it's never shown for placeholder content.
    let isReviewedGuidance: Bool

    init(
        recordID: String,
        category: IncidentSystemCategory,
        summary: String,
        confidenceWording: String,
        rationale: IncidentSupportingRationale,
        terms: [IncidentPossibleAreaTerm] = [],
        repairSearchTerm: String? = nil,
        isReviewedGuidance: Bool = false
    ) {
        self.recordID = recordID
        self.category = category
        self.summary = summary
        self.confidenceWording = confidenceWording
        self.rationale = rationale
        self.terms = terms
        self.repairSearchTerm = repairSearchTerm
        self.isReviewedGuidance = isReviewedGuidance
    }

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
    static let steeringControlLoss = "steeringControlLoss"
    /// CLM-STR-002: only asked when the vehicle scope-matches Honda
    /// HR-V 2025 — see the conditional question in
    /// SomethingHappenedView.urgentQuestions.
    static let hrvDoNotDriveMessage = "hrvDoNotDriveMessage"
    static let controlRecentWork = "controlRecentWork"
    static let runningDetail = "runningDetail"
    static let runningRecentWork = "runningRecentWork"
    static let runningWarning = "runningWarning"
    static let runningEvidence = "runningEvidence"
    static let restartEffect = "restartEffect"
    static let tireDamageObservation = "tireDamageObservation"
    static let tireAirStatus = "tireAirStatus"
}

struct IncidentGuidanceSnapshotArea: Codable, Equatable {
    let recordID: String
    let category: IncidentSystemCategory
    let confidenceWording: String
    let observedFact: String
    let explanation: String
    /// True Optionals (not defaulted, unlike IncidentPossibleContributor)
    /// because this struct is actually persisted to disk — a missing key
    /// on an Optional property decodes as nil for incidents saved before
    /// these fields existed; a defaulted non-Optional would not.
    let terms: [IncidentPossibleAreaTerm]?
    let repairSearchTerm: String?
    let isReviewedGuidance: Bool?
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
    /// Test 12 observation/fact/policy/uncertainty breakdown. Optional so
    /// incidents saved before these fields existed still decode — Swift's
    /// synthesized Decodable treats a missing key on an Optional property
    /// as nil, no custom init(from:) required.
    let factClaimIDs: [String]?
    let policyClaimIDs: [String]?
    let uncertaintyClaimIDs: [String]?
    /// The redesigned Phase 1 result screen's "Rear, over bumps"-style
    /// line (item 2) — nil for every incident that isn't backed by a
    /// record family with its own structured follow-up answers.
    let reportedContext: String?
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
    /// Test 12: a breakdown of `matchedRecordIDs`, not a replacement for
    /// it — every id in `matchedRecordIDs` that resolves to a claim in
    /// IncidentEvidenceGatedKnowledge.claims is classified by that
    /// claim's own product_use_status. `uncertaintyClaimIDs` is the
    /// static excluded_claim_ids set (pack section 5) for whichever
    /// Phase 1 record family fired this incident, independent of
    /// matchedRecordIDs.
    let factClaimIDs: [String]
    let policyClaimIDs: [String]
    let uncertaintyClaimIDs: [String]
    /// Not persisted directly — flows into
    /// IncidentGuidanceSnapshot.reportedContext, which is the Optional,
    /// decode-safe counterpart. Only the ordinary (non-urgent) path sets
    /// this to a non-nil value today.
    let reportedContext: String?

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
                    explanation: $0.rationale.explanation,
                    terms: $0.terms,
                    repairSearchTerm: $0.repairSearchTerm,
                    isReviewedGuidance: $0.isReviewedGuidance
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
            confirmationStep: confirmationStep,
            factClaimIDs: factClaimIDs,
            policyClaimIDs: policyClaimIDs,
            uncertaintyClaimIDs: uncertaintyClaimIDs,
            reportedContext: reportedContext
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
                explanation: "The original expanded explanation is unavailable in this older snapshot.",
                terms: nil,
                repairSearchTerm: nil,
                isReviewedGuidance: nil
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
                    ),
                    terms: $0.terms ?? [],
                    repairSearchTerm: $0.repairSearchTerm,
                    isReviewedGuidance: $0.isReviewedGuidance ?? false
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
                ?? "A qualified inspection may be needed.",
            factClaimIDs: snapshot.factClaimIDs ?? [],
            policyClaimIDs: snapshot.policyClaimIDs ?? [],
            uncertaintyClaimIDs: snapshot.uncertaintyClaimIDs ?? [],
            reportedContext: snapshot.reportedContext
        )
    }
}
