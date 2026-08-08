import Foundation

struct IncidentGuidanceEngine {
    let knowledgeVersion: Int
    let records: [IncidentGuidanceKnowledgeRecord]

    init(
        knowledgeVersion: Int = IncidentGuidanceKnowledge.contentVersion,
        records: [IncidentGuidanceKnowledgeRecord] = IncidentGuidanceKnowledge.records
    ) {
        self.knowledgeVersion = knowledgeVersion
        self.records = records
    }

    func evaluate(
        incident: VehicleIncident,
        vehicle: SavedVehicle
    ) -> IncidentGuidanceResult {
        if incident.urgency == .urgent {
            return urgentResult(incident: incident, vehicle: vehicle)
        }

        let ranked = rankedRecords(for: incident)
        let selected = selectDistinctAreas(from: ranked)
        let matchedRecords = selected.map(\.record)
        let hasMatches = !matchedRecords.isEmpty
        let recentWorkChangesAction = incident.recentWorkResponse == .yes
            && matchedRecords.contains {
                $0.workflowFamily == .roughRunningStallingOrPostService
            }
        let action = recentWorkChangesAction
            ? IncidentRecommendedAction.contactRecentRepairShop
            : matchedRecords.first?.safeNextAction ?? .moreInformation
        let uncertainty = uncertaintyStatements(
            incident: incident,
            vehicle: vehicle,
            ranked: ranked,
            hasMatches: hasMatches
        )
        let matchedIDs = matchedRecords.map(\.id)
        let claimBreakdown = claimIDBreakdown(matchedRecordIDs: matchedIDs)
        // "Do this now" wording fix: name the top possible area instead of
        // a single static sentence reused across every record. Falls back
        // to the generic wording inside actionExplanation when the top
        // match has no possibleAreaTerms yet (e.g. the "I'm not sure"
        // branches that intentionally have none).
        let topPossibleAreaTermName = selected.first?.record.possibleAreaTerms.first?.name

        return IncidentGuidanceResult(
            safetyStatus: safetyStatus(for: incident.safetySelection),
            isUrgent: false,
            urgency: incident.urgency,
            reportedSummary: reportedSummary(for: incident),
            possibleContributors: selected.map { match in
                IncidentPossibleContributor(
                    recordID: match.record.id,
                    category: match.record.possibleArea,
                    summary: "Possible area",
                    confidenceWording: match.record.confidenceRules.supportedWording,
                    rationale: IncidentSupportingRationale(
                        observedFact: matchedEvidenceSummary(
                            for: match,
                            incident: incident
                        ),
                        explanation: "This may fit because \(match.record.explanation) This does not confirm a cause."
                    ),
                    terms: match.record.possibleAreaTerms,
                    repairSearchTerm: match.record.repairSearchTerm,
                    isReviewedGuidance: match.record.verificationState != .needsVerification
                )
            },
            uncertaintyStatements: uncertainty,
            evidenceRequests: evidenceRequests(
                records: matchedRecords,
                incident: incident
            ),
            recommendedAction: action,
            actionExplanation: actionExplanation(
                action: action,
                hasMatches: hasMatches,
                topPossibleAreaTermName: topPossibleAreaTermName
            ),
            actionsToAvoid: actionsToAvoid(
                records: matchedRecords,
                incident: incident
            ),
            mechanicReadySummary: mechanicSummary(
                incident: incident,
                vehicle: vehicle,
                uncertainty: uncertainty
            ),
            knowledgeVersion: knowledgeVersion,
            matchedRecordIDs: matchedIDs,
            confidenceLabel: hasMatches
                ? "Limited confidence — consistent with your observations"
                : "Not enough information yet",
            knowledgeStatus: "Universal guidance · Knowledge version \(knowledgeVersion)",
            driveRecommendation: ordinaryDriveRecommendation(
                incident: incident,
                hasMatches: hasMatches
            ),
            plainLanguageAssessment: ordinaryAssessment(
                contributors: selected,
                hasMatches: hasMatches
            ),
            immediateAction: actionExplanation(
                action: action,
                hasMatches: hasMatches,
                topPossibleAreaTermName: topPossibleAreaTermName
            ),
            confirmationStep: evidenceRequests(
                records: matchedRecords,
                incident: incident
            ).first?.prompt ?? "A qualified inspection may be needed to collect direct evidence.",
            factClaimIDs: claimBreakdown.fact,
            policyClaimIDs: claimBreakdown.policy,
            uncertaintyClaimIDs: [],
            reportedContext: reportedContext(for: incident)
        )
    }
}

private extension IncidentGuidanceEngine {
    struct RankedRecord {
        let record: IncidentGuidanceKnowledgeRecord
        let score: Int
        let supportingMatches: Int
        let contradictingMatches: Int
    }

    func rankedRecords(for incident: VehicleIncident) -> [RankedRecord] {
        records.compactMap { record in
            let requiredSatisfied = record.requiredEvidence.allSatisfy {
                matches($0, incident: incident)
            }
            guard requiredSatisfied else { return nil }

            let observationMatches = record.applicableObservations.filter {
                incident.observationTypes.contains($0)
            }.count
            let supportingMatches = record.supportingEvidence.filter {
                matches($0, incident: incident)
            }.count
            let recordContradictions = record.contradictingEvidence.filter {
                matches($0, incident: incident)
            }.count
            let familyContradictions = records
                .filter { $0.workflowFamily == record.workflowFamily }
                .flatMap(\.contradictingEvidence)
                .filter { matches($0, incident: incident) }
                .count
            let contradictingMatches = max(
                recordContradictions,
                familyContradictions
            )
            let score = observationMatches
                + (supportingMatches * 2)
                - (contradictingMatches * 3)

            guard score >= record.confidenceRules.minimumScore else {
                return nil
            }

            return RankedRecord(
                record: record,
                score: score,
                supportingMatches: supportingMatches,
                contradictingMatches: contradictingMatches
            )
        }
        .sorted {
            if $0.score == $1.score {
                return $0.record.id < $1.record.id
            }
            return $0.score > $1.score
        }
    }

    func selectDistinctAreas(
        from ranked: [RankedRecord]
    ) -> [RankedRecord] {
        var areas = Set<IncidentSystemCategory>()
        var selected: [RankedRecord] = []

        for match in ranked where areas.insert(match.record.possibleArea).inserted {
            selected.append(match)
            if selected.count == 3 { break }
        }

        return selected
    }

    func matches(
        _ signal: IncidentGuidanceEvidenceSignal,
        incident: VehicleIncident
    ) -> Bool {
        switch signal {
        case .observation(let observation):
            incident.observationTypes.contains(observation)
        case .safety(let safety):
            incident.safetySelection == safety
        case .descriptionContains(let text):
            incident.userDescription.localizedCaseInsensitiveContains(text)
        case .recentWork(let response):
            incident.recentWorkResponse == response
        case .noiseAnswer(let key, let value):
            incident.noiseFollowUpAnswers?[key] == value
        case .warningAnswer(let key, let value):
            incident.warningFollowUpAnswers?[key] == value
        case .fluidAnswer(let key, let value):
            incident.fluidFollowUpAnswers?[key] == value
        case .startingAnswer(let key, let value):
            incident.startingFollowUpAnswers?[key] == value
        case .drivingChangeAnswer(let key, let value):
            incident.drivingChangeFollowUpAnswers?[key] == value
        }
    }

    /// The redesigned Phase 1 result screen's "Rear, over bumps"-style
    /// line, shown near the top instead of a car diagram — the user
    /// already picked these from a menu, this just plays them back.
    /// Only populated when structured noise answers exist; nil for
    /// every other Phase 1 record family today.
    func reportedContext(for incident: VehicleIncident) -> String? {
        guard let answers = incident.noiseFollowUpAnswers else { return nil }
        let pieces = [
            answers[IncidentNoiseAnswerKey.location],
            answers[IncidentNoiseAnswerKey.timing]
        ]
        .compactMap { $0 }
        .filter { $0 != "I’m not sure" }
        guard !pieces.isEmpty else { return nil }
        let joined = pieces.joined(separator: ", ").lowercased()
        return joined.prefix(1).uppercased() + joined.dropFirst()
    }

    func matchedEvidenceSummary(
        for match: RankedRecord,
        incident: VehicleIncident
    ) -> String {
        let observations = incident.observationTypes
            .filter { match.record.applicableObservations.contains($0) }
            .map(\.title)
        if !observations.isEmpty {
            return "Based on what you reported: \(observations.joined(separator: ", "))."
        }
        return "Based on the description you provided."
    }

    func uncertaintyStatements(
        incident: VehicleIncident,
        vehicle: SavedVehicle,
        ranked: [RankedRecord],
        hasMatches: Bool
    ) -> [String] {
        var statements: [String] = []

        if !hasMatches {
            statements.append(
                "More information is needed before this Phase 1 guidance can identify a possible area."
            )
        }
        if vehicle.profileVerification == .basicUnverified {
            statements.append(
                "Detailed configuration information for this vehicle profile is not verified."
            )
        }
        if ranked.contains(where: { $0.contradictingMatches > 0 }) {
            statements.append(
                "Some recorded details do not fit the same pattern, so a stronger conclusion would be misleading."
            )
        }
        if ranked.contains(where: {
            $0.record.verificationState == .needsVerification
                || $0.record.sourceReferences.contains(where: \.isPlaceholder)
        }) {
            statements.append(
                "The matched prototype guidance still needs reviewed source verification and is not OEM-specific information."
            )
        }
        if incident.observationTypes.contains(.warningLightOrMessage) {
            statements.append(
                "The exact warning message or diagnostic code has not been recorded as structured evidence."
            )
        }

        if statements.isEmpty {
            statements.append(
                "OpenHood cannot confirm the cause from these observations alone. A qualified inspection may be needed."
            )
        }

        return Array(statements.prefix(3))
    }

    func evidenceRequests(
        records: [IncidentGuidanceKnowledgeRecord],
        incident: VehicleIncident
    ) -> [IncidentEvidenceRequest] {
        var questions = records.flatMap(\.followUpQuestions)

        if records.isEmpty {
            questions = [
                "Does the concern involve starting or rough running, temperature, a warning or code, or braking or steering?",
                "When did it occur, and what changed immediately beforehand?"
            ]
        }
        if incident.recentWorkResponse == .unsure {
            questions.append(
                "Do service records show work shortly before the concern began?"
            )
        }

        var seen = Set<String>()
        return questions
            .filter { seen.insert($0).inserted }
            .prefix(4)
            .map { IncidentEvidenceRequest($0) }
    }

    func actionsToAvoid(
        records: [IncidentGuidanceKnowledgeRecord],
        incident: VehicleIncident
    ) -> [String] {
        var actions = records.flatMap(\.actionsToAvoid)
        if actions.isEmpty {
            actions = [
                "Do not reproduce a dangerous symptom.",
                "Do not touch hot or moving components or go under an unsupported vehicle."
            ]
        }
        if incident.observationTypes.contains(.warningLightOrMessage) {
            actions.append(
                "Do not translate an unknown warning or code into a failed part without inspection evidence."
            )
        }

        var seen = Set<String>()
        return Array(actions.filter { seen.insert($0).inserted }.prefix(3))
    }

    /// "Do this now" wording fix (quick, high-leverage — touches every
    /// result screen): the old .professionalInspection wording was a
    /// single static sentence reused across every record regardless of
    /// what was actually found. When the top-ranked match has a real
    /// possibleAreaTerm, name it instead — data the result already has,
    /// ordered, at this point (selectDistinctAreas already ranked it
    /// first). Falls back to the old generic sentence when there's no
    /// term to name (e.g. the "I'm not sure" branches that intentionally
    /// ship with an empty possibleAreaTerms list) or for the urgent path's
    /// rare fallback use of this function, which doesn't pass one.
    func actionExplanation(
        action: IncidentRecommendedAction,
        hasMatches: Bool,
        topPossibleAreaTermName: String? = nil
    ) -> String {
        switch action {
        case .moreInformation:
            "OpenHood doesn't have a specific match for this yet. Record what you noticed below, and use Find a Shop if you'd rather have it looked at directly."
        case .safeObservation:
            "Collect only information that is visible or available without recreating the concern."
        case .obtainCodeScan:
            "Record the exact warning or code without treating it as proof of a failed component."
        case .contactRecentRepairShop:
            "The timing makes the recently serviced area useful context to recheck, but it does not prove the work caused the concern."
        case .professionalInspection:
            if hasMatches, let topPossibleAreaTermName {
                "A shop can start by checking \(topPossibleAreaTermName) — that's usually the fastest way to narrow this down."
            } else if hasMatches {
                "A qualified inspection may be needed to separate the possible areas using direct evidence."
            } else {
                "More information is needed before selecting an inspection area."
            }
        case .roadsideAssistance:
            "Stop driving and arrange transport for the vehicle."
        case .emergencyServices:
            "Move away when appropriate and contact emergency services for immediate danger."
        }
    }

    func ordinaryDriveRecommendation(
        incident: VehicleIncident,
        hasMatches: Bool
    ) -> IncidentDriveRecommendation {
        if incident.observationTypes.contains(.drivingChange) {
            return .checkBeforeDriving
        }
        if incident.observationTypes.contains(.warningLightOrMessage)
            || incident.observationTypes.contains(.startingOrRunningTrouble) {
            return .serviceSoon
        }
        return hasMatches ? .serviceSoon : .monitor
    }

    func ordinaryAssessment(
        contributors: [RankedRecord],
        hasMatches: Bool
    ) -> String {
        guard hasMatches, let first = contributors.first else {
            return "There is not enough information yet to identify one system-level pattern."
        }
        return "This most strongly suggests a concern involving \(first.record.possibleArea.rawValue.lowercased()). This does not identify a failed part."
    }

    func urgentDriveRecommendation(
        incident: VehicleIncident,
        vehicle: SavedVehicle,
        immediateDanger: Bool
    ) -> IncidentDriveRecommendation {
        if immediateDanger { return .doNotRestart }
        let answers = incident.urgentFollowUpAnswers ?? [:]
        switch incident.safetySelection {
        case .smokeOrFire, .strongFuelSmell, .overheatingOrSteam,
             .engineWillNotStayRunning:
            return .doNotRestart
        case .unsafeBrakesOrSteering:
            return unsafeBrakesOrSteeringDriveRecommendation(answers: answers, vehicle: vehicle)
        case .visibleTireDamage:
            // A damaged tire can fail suddenly regardless of how it
            // answers any follow-up question, so this is an unconditional
            // STOP DRIVING — same treatment as unsafeBrakesOrSteering's
            // braking branch, not .doNotRestart (that's reserved for the
            // engine-already-off, don't-restart cases like fire or
            // overheating).
            return .stopDriving
        case .transmissionSlippingOrBurningSmell:
            // Same reasoning as visibleTireDamage: whether the cause turns
            // out to be low fluid, a failing solenoid, or a torque
            // converter/clutch pack problem can't be told apart from these
            // answers, and every one of those causes carries real risk of
            // getting stranded or, in more advanced cases, a sudden loss of
            // power. Unconditional STOP DRIVING rather than .doNotRestart —
            // the vehicle is still running and driveable when this is
            // reported, so the instruction is to stop driving as soon as
            // it's safely possible, not "don't restart."
            return .stopDriving
        case .flashingWarningLight:
            if answers[IncidentUrgentAnswerKey.warningSymbol] == "Check engine" {
                // OH-UIK-001: default gate is CHECK BEFORE DRIVING
                // (CLM-MIL-005), but the record's own smartest_next_step
                // explicitly escalates "severe active shaking...or major
                // power loss" to STOP DRIVING — see milHasSevereActiveSymptom.
                return milHasSevereActiveSymptom(answers: answers)
                    ? .stopDriving
                    : .checkBeforeDriving
            }
            if answers[IncidentUrgentAnswerKey.warningSymbol] == "Oil pressure" {
                // CLM-OIL-001: a continuously illuminated oil-pressure
                // warning while driving indicates possible loss of oil
                // pressure — continuing to drive risks engine damage, so
                // this gets its own deliberate STOP DRIVING decision
                // instead of falling through to the generic CHECK BEFORE
                // DRIVING default an unexamined symbol would get.
                return .stopDriving
            }
            if answers[IncidentUrgentAnswerKey.warningSymbol] == "Tire pressure" {
                return .checkBeforeDriving
            }
            if answers[IncidentUrgentAnswerKey.warningState] == "Now steady" {
                return .serviceSoon
            }
            return .checkBeforeDriving
        case .noneOfThese, .unsure, nil:
            return .checkBeforeDriving
        }
    }

    /// OH-UIK-011/OH-UIK-013: braking is an unconditional STOP DRIVING
    /// (CLM-BRK-005). Steering defaults to CHECK BEFORE DRIVING
    /// (CLM-STR-001/002/003) and escalates to STOP DRIVING on a reported
    /// loss of directional control (CLM-STR-005P) or on the exact HR-V
    /// "Do not drive" message (CLM-STR-002, acceptance test 10) — the
    /// latter overrides the generic EPS-warning gate even when steering
    /// still feels controllable, per the pack's own distinction between
    /// the EPS indicator alone and the separate "Do not drive" message.
    func unsafeBrakesOrSteeringDriveRecommendation(
        answers: [String: String],
        vehicle: SavedVehicle
    ) -> IncidentDriveRecommendation {
        guard answers[IncidentUrgentAnswerKey.concernType] == "Steering" else {
            return .stopDriving
        }
        if hrvDoNotDriveMessageConfirmed(answers: answers, vehicle: vehicle) {
            return .stopDriving
        }
        if answers[IncidentUrgentAnswerKey.steeringControlLoss] == "No" {
            return .stopDriving
        }
        return .checkBeforeDriving
    }

    /// CLM-STR-002 acceptance-test-10 gate: true only when the user
    /// confirmed the exact HR-V "Do not drive" message AND the vehicle
    /// still scope-matches the claim (Honda HR-V 2025, verified profile)
    /// through the same evidenceClaims chokepoint every other OEM claim
    /// goes through — the view only gates *asking* the question on
    /// make/model/year, so this is the actual enforcement point.
    func hrvDoNotDriveMessageConfirmed(
        answers: [String: String],
        vehicle: SavedVehicle
    ) -> Bool {
        answers[IncidentUrgentAnswerKey.hrvDoNotDriveMessage] == "Yes"
            && !evidenceClaims("CLM-STR-002", vehicle: vehicle).isEmpty
    }

    func urgentAssessment(
        incident: VehicleIncident,
        vehicle: SavedVehicle,
        immediateDanger: Bool
    ) -> String {
        let answers = incident.urgentFollowUpAnswers ?? [:]
        if immediateDanger {
            return "This pattern indicates an immediate fire, smoke, or fuel-related danger. OpenHood has not confirmed the source."
        }
        switch incident.safetySelection {
        case .flashingWarningLight:
            let symbol = answers[IncidentUrgentAnswerKey.warningSymbol]
            if symbol == "Check engine" {
                return milAssessment(
                    vehicle: vehicle,
                    severeActiveSymptom: milHasSevereActiveSymptom(answers: answers)
                )
            }
            if symbol == "Tire pressure" {
                return "This most strongly suggests a tire-pressure or pressure-monitoring concern, not an engine fault."
            }
            if symbol == "I’m not sure" {
                return "The warning system cannot be narrowed down until the symbol or message is identified."
            }
            return "The warning points to the selected monitored system, but the symbol alone does not confirm a cause."
        case .overheatingOrSteam:
            // OH-UIK-006: CLM-OHT-005 (PRODUCT_POLICY) is the only claim
            // eligible to back this sentence — OEM-specific claims
            // (CLM-OHT-001..004) support immediate_action/actions_to_avoid
            // instead, never the plain-language cause assessment.
            return "This pattern is consistent with a possible high-temperature or pressurized cooling-system event. OpenHood has not independently confirmed the cause."
        case .strongFuelSmell:
            let description = answers[IncidentUrgentAnswerKey.smellDescription]
                ?? "unidentified"
            return "The \(description.lowercased()) odor most strongly suggests the related fluid, electrical, exhaust, or heat-source family shown below."
        case .smokeOrFire:
            return "This most strongly suggests a heat, electrical, or fluid-related smoke source that requires inspection."
        case .unsafeBrakesOrSteering:
            return brakesOrSteeringAssessment(answers: answers, vehicle: vehicle)
        case .visibleTireDamage:
            return "This most strongly suggests tire damage that can fail without warning while driving. OpenHood has not confirmed whether the tire can be repaired or must be replaced."
        case .transmissionSlippingOrBurningSmell:
            let concern = answers[IncidentUrgentAnswerKey.transmissionConcernType]
            if concern == "A burning smell" {
                return "A burning smell from the transmission most strongly suggests the fluid is overheating, which risks permanent internal damage the longer driving continues. OpenHood has not confirmed the exact cause."
            }
            return "This most strongly suggests the transmission isn't reliably transferring engine power to the wheels — low or worn fluid, a failing solenoid, or a torque converter/clutch pack problem are all possible. OpenHood has not confirmed the exact cause."
        case .engineWillNotStayRunning:
            if let recent = answers[IncidentUrgentAnswerKey.runningRecentWork],
               ["Service", "Battery work", "A repair"].contains(recent) {
                return "This most strongly suggests a running or control problem after recent work. Recently disturbed connections, hoses, or components are worth checking."
            }
            return "This most strongly suggests a rough-running or stalling pattern involving engine operation, fuel, ignition, or air measurement."
        case .noneOfThese, .unsure, nil:
            return "There is not enough information yet to identify one system-level pattern."
        }
    }

    /// Test 12: classifies a `matchedRecordIDs` list against the claim
    /// registry by product_use_status. This is a breakdown of IDs
    /// already present in matchedRecordIDs, not a separate scan of
    /// everything that shaped the visible text — an id that isn't a
    /// CLM-* claim (a knowledge-record id like "OH-UIK-001", or an
    /// urgent-contributor id like "urgent.smoke-source") simply doesn't
    /// resolve against the registry and is dropped from both lists.
    func claimIDBreakdown(
        matchedRecordIDs: [String]
    ) -> (fact: [String], policy: [String]) {
        let byID = Dictionary(
            uniqueKeysWithValues: IncidentEvidenceGatedKnowledge.claims.map { ($0.id, $0) }
        )
        var fact: [String] = []
        var policy: [String] = []
        for id in matchedRecordIDs {
            guard let claim = byID[id] else { continue }
            switch claim.productUseStatus {
            case .visibleGuidanceApproved, .visibleGuidanceScopeLimited:
                fact.append(id)
            case .productPolicy:
                policy.append(id)
            case .researchOnly, .needsVerification, .rejected:
                break
            }
        }
        return (fact, policy)
    }

    /// Test 12 `uncertaintyClaimIDs`: the pack's section 5 excluded_claim_ids
    /// are a fixed set per Phase 1 record family — not derived from what
    /// matched, since excluded claims never appear in matchedRecordIDs in
    /// the first place. Only applies to the urgent/evidence-gated path;
    /// the ordinary (non-urgent) path matches separate prototype records
    /// that aren't part of any OH-UIK family, so it never has one of
    /// these to report.
    func urgentUncertaintyClaimIDs(
        incident: VehicleIncident,
        answers: [String: String]
    ) -> [String] {
        if incident.safetySelection == .flashingWarningLight,
           answers[IncidentUrgentAnswerKey.warningSymbol] == "Check engine" {
            return ["CLM-MIL-006"]
        }
        if incident.safetySelection == .overheatingOrSteam {
            return ["CLM-OHT-006", "CLM-OHT-007"]
        }
        if incident.safetySelection == .unsafeBrakesOrSteering {
            return answers[IncidentUrgentAnswerKey.concernType] == "Steering"
                ? ["CLM-STR-005", "CLM-STR-006"]
                : ["CLM-BRK-006", "CLM-BRK-007"]
        }
        return []
    }

    /// Resolves evidence-gated claim IDs against IncidentEvidenceGatedKnowledge
    /// and returns only those eligible to affect visible output for this
    /// vehicle — the single choke point RESEARCH_ONLY/NEEDS_VERIFICATION/
    /// REJECTED claims cannot pass through.
    func evidenceClaims(_ ids: String..., vehicle: SavedVehicle) -> [IncidentClaim] {
        IncidentClaimVisibility.visibleClaims(
            ids: ids,
            from: IncidentEvidenceGatedKnowledge.claims,
            vehicle: vehicle
        )
    }

    /// OH-UIK-001 follow_up_questions/smartest_next_step: severe active
    /// shaking or major power loss is the escalation trigger this app can
    /// actually answer (via the existing `engineBehavior` question, which
    /// doubles as MIL-Q3). MIL-Q4 (smoke/raw-fuel odor/overheating/red
    /// oil warning) is not separately asked here — those symptoms are
    /// each their own top-level safety selection (.smokeOrFire,
    /// .strongFuelSmell, .overheatingOrSteam) that a user would normally
    /// pick instead of "Flashing warning light" as the primary concern,
    /// so MIL-Q4 is not wired into this path.
    func milHasSevereActiveSymptom(answers: [String: String]) -> Bool {
        guard let behavior = answers[IncidentUrgentAnswerKey.engineBehavior] else {
            return false
        }
        return ["Shaking", "Lost power", "Stalled"].contains(behavior)
    }

    func milAssessment(vehicle: SavedVehicle, severeActiveSymptom: Bool) -> String {
        if severeActiveSymptom {
            return "This pattern is consistent with an active engine misfire causing shaking, power loss, or stalling. It does not identify the failed part."
        }
        let visible = evidenceClaims("CLM-MIL-001", vehicle: vehicle)
        if visible.contains(where: { $0.id == "CLM-MIL-001" }) {
            return "A flashing check-engine light with shaking or rough running can be associated with a misfire condition on this vehicle, per its cited owner's manual. It does not identify the failed part."
        }
        return "A flashing check-engine light with shaking or rough running can be associated with a misfire condition on some vehicles. It does not identify the failed part."
    }

    /// STR-001/002/003 (EPS-specific OEM claims) require confirming the
    /// exact EPS/power-steering warning, which the current intake only
    /// approximates via `controlWarning` ("did a warning appear?"). Using
    /// that as the confirmation signal is a deliberate simplification —
    /// flagged for review rather than silently treated as equivalent.
    func brakesOrSteeringAssessment(
        answers: [String: String],
        vehicle: SavedVehicle
    ) -> String {
        guard answers[IncidentUrgentAnswerKey.concernType] == "Steering" else {
            // OH-UIK-011: CLM-BRK-001/002 need the exact brake-warning
            // text, which this intake does not collect, so only the
            // always-visible CLM-BRK-003/004 back this sentence.
            return "The braking system is not behaving normally. A soft or spongy pedal may be associated with air in the brake lines or a hydraulic-system leak, but this does not confirm a specific failed component."
        }
        if hrvDoNotDriveMessageConfirmed(answers: answers, vehicle: vehicle) {
            return "The dashboard is showing the exact \"Do not drive\" message described in the cited HR-V owner's manual, which the manual treats as more serious than the EPS indicator alone."
        }
        let warningConfirmed = answers[IncidentUrgentAnswerKey.controlWarning] == "Yes"
        let visible = warningConfirmed
            ? evidenceClaims("CLM-STR-001", "CLM-STR-003", vehicle: vehicle)
            : []
        if !visible.isEmpty {
            return "The vehicle may have a steering-assistance or steering-control problem. The warning identifies an EPS-system concern for this vehicle, per its cited owner's manual, not the failed component."
        }
        return "The vehicle may have a steering-assistance or steering-control problem. A warning identifies a system-level concern, not the failed component."
    }

    func urgentImmediateAction(
        incident: VehicleIncident,
        vehicle: SavedVehicle,
        action: IncidentRecommendedAction,
        immediateDanger: Bool
    ) -> String {
        let answers = incident.urgentFollowUpAnswers ?? [:]
        if immediateDanger {
            return "Stay away from the vehicle and contact emergency services. Do not restart it or approach an active hazard."
        }
        if incident.safetySelection == .flashingWarningLight,
           answers[IncidentUrgentAnswerKey.warningSymbol] == "Check engine" {
            return milImmediateAction(
                vehicle: vehicle,
                severeActiveSymptom: milHasSevereActiveSymptom(answers: answers)
            )
        }
        if incident.safetySelection == .flashingWarningLight,
           answers[IncidentUrgentAnswerKey.warningSymbol] == "Tire pressure" {
            return "Before driving, inspect the tires from a safe parked position and have their pressures and condition checked."
        }
        if incident.safetySelection == .flashingWarningLight,
           answers[IncidentUrgentAnswerKey.warningState] == "Now steady" {
            return "Arrange a diagnostic scan and service. If operation changes or the light begins flashing again, stop and seek roadside help."
        }
        if incident.safetySelection == .overheatingOrSteam {
            return overheatingImmediateAction(answers: answers, vehicle: vehicle)
        }
        if incident.safetySelection == .unsafeBrakesOrSteering {
            return brakesOrSteeringImmediateAction(answers: answers, vehicle: vehicle)
        }
        if incident.safetySelection == .engineWillNotStayRunning,
           action == .contactRecentRepairShop {
            return "Do not keep restarting the engine. Contact the recent repair shop with the symptoms and invoice, and arrange transport if needed."
        }
        return actionExplanation(action: action, hasMatches: true)
    }

    /// OH-UIK-001: fires for any confirmed "Check engine" flashing symbol,
    /// not only the shaking sub-case — MIL-Q1..Q4 in the pack progressively
    /// narrow severity from that same starting point. CLM-MIL-002 (Ford)
    /// and CLM-MIL-003 (Honda Civic Coupe) are mutually exclusive scope
    /// matches; CLM-MIL-005 (PRODUCT_POLICY) is the always-visible floor.
    /// When severeActiveSymptom is true this must stay consistent with
    /// the STOP DRIVING gate from milHasSevereActiveSymptom — advising
    /// "move to a safe place, decide later whether to keep driving" next
    /// to a STOP DRIVING banner would contradict it.
    func milImmediateAction(vehicle: SavedVehicle, severeActiveSymptom: Bool) -> String {
        if severeActiveSymptom {
            return "Shut the engine off once safely stopped. Do not keep driving or rev the engine. Arrange roadside assistance or towing."
        }
        let visible = evidenceClaims("CLM-MIL-002", "CLM-MIL-003", vehicle: vehicle)
        let manualCheck = "Use the exact owner's manual before deciding whether the vehicle may be moved again."
        if visible.contains(where: { $0.id == "CLM-MIL-002" }) {
            return "Avoid heavy acceleration and deceleration while the light is flashing, per the cited Ford guidance. \(manualCheck)"
        }
        if visible.contains(where: { $0.id == "CLM-MIL-003" }) {
            return "Stop in a safe place, per the cited Honda guidance. \(manualCheck)"
        }
        return "If moving, avoid hard acceleration and move to a safe place. \(manualCheck)"
    }

    /// OH-UIK-006: CLM-OHT-002 (Honda)/CLM-OHT-003 (Toyota RAV4) only
    /// apply when steam/spray is actually reported (coolingEvidence),
    /// matching acceptance test 4's principle that a claim's condition
    /// must be confirmed, not just its vehicle scope.
    func overheatingImmediateAction(
        answers: [String: String],
        vehicle: SavedVehicle
    ) -> String {
        let steamLikely = ["Steam", "Bubbling", "More than one"]
            .contains(answers[IncidentUrgentAnswerKey.coolingEvidence] ?? "")
        let visible = steamLikely
            ? evidenceClaims("CLM-OHT-002", "CLM-OHT-003", vehicle: vehicle)
            : []
        let base = "Shut the engine off once safely stopped. Do not open the cooling system while it is hot. Use the exact owner's manual before inspection or restart."
        if visible.contains(where: { $0.id == "CLM-OHT-002" }) {
            return "Do not open the hood while steam is actively coming from the engine compartment, per the cited Honda manual. \(base)"
        }
        if visible.contains(where: { $0.id == "CLM-OHT-003" }) {
            return "Do not loosen the coolant-reservoir or radiator cap while hot — hot coolant or steam may spray out, per the cited Toyota manual. \(base)"
        }
        if steamLikely {
            return "Steam or spray from an overheated engine can cause serious scalding; keep away from it. \(base)"
        }
        return base
    }

    /// OH-UIK-011/OH-UIK-013.
    func brakesOrSteeringImmediateAction(
        answers: [String: String],
        vehicle: SavedVehicle
    ) -> String {
        guard answers[IncidentUrgentAnswerKey.concernType] == "Steering" else {
            return "If the vehicle cannot slow or stop normally, stop using it and do not road-test it. Confirm any dashboard warning through the exact owner's manual."
        }
        if hrvDoNotDriveMessageConfirmed(answers: answers, vehicle: vehicle) {
            return "Stop as soon as safely possible and contact a Honda dealer, per the cited HR-V owner's manual \"Do not drive\" message. Do not continue driving or attempt to road-test the steering."
        }
        if answers[IncidentUrgentAnswerKey.steeringControlLoss] == "No" {
            return "Stop as soon as safely possible. Do not continue driving or attempt to road-test the steering."
        }
        return "First determine whether this is only a warning or whether the vehicle can no longer be directed normally. Confirm the exact warning or message before applying manufacturer-specific continuation guidance."
    }

    func urgentResult(
        incident: VehicleIncident,
        vehicle: SavedVehicle
    ) -> IncidentGuidanceResult {
        let answers = incident.urgentFollowUpAnswers ?? [:]
        let immediateDanger = answers[IncidentUrgentAnswerKey.activeFlame] == "activeFire"
            || answers[IncidentUrgentAnswerKey.smokePresent] == "continuingSmoke"
            || (answers[IncidentUrgentAnswerKey.smellDescription] == "Gasoline"
                && answers[IncidentUrgentAnswerKey.visibleEvidence] == "Liquid")
        let contributors = immediateDanger
            ? []
            : urgentContributors(for: incident, vehicle: vehicle)
        let action = urgentRecommendedAction(
            incident: incident,
            immediateDanger: immediateDanger
        )
        let uncertainty = [
            "OpenHood has not inspected the vehicle and has not confirmed the cause.",
            "Immediate safety action remains more important than narrowing the possible areas."
        ]
        // Despite the name, urgentPolicyClaimIDs also returns scope-limited
        // OEM facts (e.g. CLM-STR-001/CLM-STR-002) alongside PRODUCT_POLICY
        // ids — claimIDBreakdown below is what actually separates the two
        // for factClaimIDs/policyClaimIDs (test 12).
        let citedClaimIDs = immediateDanger
            ? []
            : urgentPolicyClaimIDs(incident: incident, vehicle: vehicle)
        let matchedIDs = contributors.map(\.recordID) + citedClaimIDs
        let claimBreakdown = claimIDBreakdown(matchedRecordIDs: matchedIDs)
        let uncertaintyIDs = immediateDanger
            ? []
            : urgentUncertaintyClaimIDs(incident: incident, answers: answers)

        return IncidentGuidanceResult(
            safetyStatus: safetyStatus(for: incident.safetySelection),
            isUrgent: true,
            urgency: incident.urgency,
            reportedSummary: reportedSummary(for: incident),
            possibleContributors: contributors,
            uncertaintyStatements: uncertainty,
            evidenceRequests: immediateDanger
                ? []
                : urgentEvidenceRequests(for: incident),
            recommendedAction: action,
            actionExplanation: actionExplanation(action: action, hasMatches: false),
            actionsToAvoid: urgentActionsToAvoid(incident: incident),
            mechanicReadySummary: mechanicSummary(
                incident: incident,
                vehicle: vehicle,
                uncertainty: uncertainty
            ),
            knowledgeVersion: knowledgeVersion,
            matchedRecordIDs: matchedIDs,
            confidenceLabel: contributors.isEmpty
                ? "Not enough information yet"
                : "Limited confidence — based on what you reported",
            knowledgeStatus: "Universal guidance · Knowledge version \(knowledgeVersion)",
            driveRecommendation: urgentDriveRecommendation(
                incident: incident,
                vehicle: vehicle,
                immediateDanger: immediateDanger
            ),
            plainLanguageAssessment: urgentAssessment(
                incident: incident,
                vehicle: vehicle,
                immediateDanger: immediateDanger
            ),
            immediateAction: urgentImmediateAction(
                incident: incident,
                vehicle: vehicle,
                action: action,
                immediateDanger: immediateDanger
            ),
            confirmationStep: urgentEvidenceRequests(for: incident).first?.prompt
                ?? "Emergency responders or a qualified inspector must evaluate the vehicle before further action.",
            factClaimIDs: claimBreakdown.fact,
            policyClaimIDs: claimBreakdown.policy,
            uncertaintyClaimIDs: uncertaintyIDs,
            reportedContext: nil
        )
    }

    /// Claim IDs that actually governed this incident's driving
    /// status/immediate action — mostly PRODUCT_POLICY claims (always
    /// visible regardless of vehicle), plus the scope-limited OEM facts
    /// that can themselves drive the outcome (CLM-STR-001, and now
    /// CLM-STR-002 for the HR-V "Do not drive" escalation). Resolving
    /// all of them through evidenceClaims() keeps them on the single
    /// enforcement chokepoint (if one were ever downgraded to
    /// RESEARCH_ONLY/NEEDS_VERIFICATION in the registry, it would stop
    /// appearing here automatically) and surfaces them in
    /// matchedRecordIDs / "Sources and confidence" instead of being an
    /// invisible code-level decision — per acceptance test 12's
    /// requirement that policy- and fact-driven output carry its own
    /// claim IDs. The caller (urgentResult) further splits this list
    /// into factClaimIDs/policyClaimIDs by each claim's actual
    /// product_use_status.
    func urgentPolicyClaimIDs(
        incident: VehicleIncident,
        vehicle: SavedVehicle
    ) -> [String] {
        let answers = incident.urgentFollowUpAnswers ?? [:]
        var ids: [String] = []

        if incident.safetySelection == .flashingWarningLight,
           answers[IncidentUrgentAnswerKey.warningSymbol] == "Check engine" {
            ids += evidenceClaims("CLM-MIL-005", vehicle: vehicle).map(\.id)
            if milHasSevereActiveSymptom(answers: answers) {
                ids += evidenceClaims("CLM-MIL-005S", vehicle: vehicle).map(\.id)
            }
        }
        if incident.safetySelection == .flashingWarningLight,
           answers[IncidentUrgentAnswerKey.warningSymbol] == "Oil pressure" {
            ids += evidenceClaims("CLM-OIL-001", vehicle: vehicle).map(\.id)
        }
        if incident.safetySelection == .overheatingOrSteam {
            ids += evidenceClaims("CLM-OHT-005", vehicle: vehicle).map(\.id)
        }
        if incident.safetySelection == .unsafeBrakesOrSteering {
            if answers[IncidentUrgentAnswerKey.concernType] == "Steering" {
                ids += evidenceClaims("CLM-STR-001", vehicle: vehicle).map(\.id)
                if hrvDoNotDriveMessageConfirmed(answers: answers, vehicle: vehicle) {
                    ids += evidenceClaims("CLM-STR-002", vehicle: vehicle).map(\.id)
                }
                if answers[IncidentUrgentAnswerKey.steeringControlLoss] == "No" {
                    ids += evidenceClaims("CLM-STR-005P", vehicle: vehicle).map(\.id)
                }
            } else {
                ids += evidenceClaims("CLM-BRK-005", vehicle: vehicle).map(\.id)
            }
        }
        return ids
    }

    func urgentContributors(
        for incident: VehicleIncident,
        vehicle: SavedVehicle
    ) -> [IncidentPossibleContributor] {
        let answer = incident.urgentFollowUpAnswers ?? [:]

        switch incident.safetySelection {
        case .smokeOrFire:
            var areas = [urgentContributor(
                id: "urgent.smoke-source",
                area: .leaksSmokeAndOdors,
                fact: "Smoke or fire was reported near \(answer[IncidentUrgentAnswerKey.smokeSource] ?? "an unknown area").",
                explanation: "Smoke is consistent with heat affecting a fluid, material, or component, but it does not identify the source."
            )]
            if answer[IncidentUrgentAnswerKey.smokeOdor] == "Electrical or plastic" {
                areas.append(urgentContributor(id: "urgent.smoke-electrical", area: .electricalAndWiring, fact: "An electrical or plastic odor was reported.", explanation: "This may involve overheated wiring, insulation, or another electrical heat source."))
            } else if answer[IncidentUrgentAnswerKey.smokeOdor] == "Sweet or coolant-like" {
                areas.append(urgentContributor(id: "urgent.smoke-cooling", area: .cooling, fact: "A sweet or coolant-like odor was reported with smoke.", explanation: "This may involve hot cooling-system fluid or vapor and is worth checking after the vehicle is fully cool."))
            } else {
                areas.append(urgentContributor(id: "urgent.smoke-heat", area: .engineAndCombustion, fact: "The smoke source has not been confirmed.", explanation: "A hot operating area is possible, but OpenHood cannot distinguish combustion, friction, or fluid contact from these answers."))
            }
            return areas
        case .strongFuelSmell:
            return smellContributors(answers: answer)
        case .overheatingOrSteam:
            return overheatingContributors()
        case .flashingWarningLight:
            if answer[IncidentUrgentAnswerKey.warningSymbol] == "Check engine" {
                return milContributors(
                    vehicle: vehicle,
                    severeActiveSymptom: milHasSevereActiveSymptom(answers: answer)
                )
            }
            return urgentWarningContributors(
                symbol: answer[IncidentUrgentAnswerKey.warningSymbol]
            )
        case .unsafeBrakesOrSteering:
            return brakesOrSteeringContributors(answers: answer)
        case .visibleTireDamage:
            return [
                urgentContributor(
                    id: "urgent.tire-damage",
                    area: .tiresWheelsAndPressure,
                    fact: "You reported \(answer[IncidentUrgentAnswerKey.tireDamageObservation] ?? "visible tire damage").",
                    explanation: "Sidewall bulges and cracks cannot be safely repaired and require replacement. A puncture in the tread is sometimes repairable, but should be evaluated by a professional before continuing to drive on it."
                )
            ]
        case .transmissionSlippingOrBurningSmell:
            var areas = [urgentContributor(
                id: "urgent.transmission-power-delivery",
                area: .mechanicalOrCompression,
                fact: "You reported \(answer[IncidentUrgentAnswerKey.transmissionConcernType]?.lowercased() ?? "a transmission concern").",
                explanation: "Low or worn transmission fluid, a failing shift solenoid, or a torque converter/clutch pack problem can all produce this pattern. Direct inspection is needed to tell them apart."
            )]
            if answer[IncidentUrgentAnswerKey.transmissionTrigger] == "Yes, after towing or a heavy load" {
                areas.append(urgentContributor(id: "urgent.transmission-heat-load", area: .mechanicalOrCompression, fact: "This began after towing or a heavy load.", explanation: "Towing or heavy loads raise transmission fluid temperature significantly, which can push already-marginal fluid or a solenoid past the point of reliable operation."))
            }
            return areas
        case .engineWillNotStayRunning:
            return [
                urgentContributor(
                    id: "urgent.running-operation",
                    area: .engineAndCombustion,
                    fact: "You reported that the engine starts but will not stay running.",
                    explanation: "This pattern can involve engine operation or control, but it does not confirm one cause."
                ),
                urgentContributor(
                    id: "urgent.running-fuel-ignition",
                    area: .fuelAndIgnition,
                    fact: "You reported \(answer[IncidentUrgentAnswerKey.runningDetail] ?? "a running or stalling change").",
                    explanation: "Fuel delivery or ignition quality is a possible inspection area when supported by direct testing."
                ),
                urgentContributor(
                    id: "urgent.running-air",
                    area: .intakeAndAirMeasurement,
                    fact: "The concern began after \(answer[IncidentUrgentAnswerKey.runningRecentWork] ?? "an unknown event").",
                    explanation: "Intake or air-measurement information is another possible inspection area, not a confirmed cause."
                )
            ]
        case .noneOfThese, .unsure, nil:
            return []
        }
    }

    /// OH-UIK-001: fires for any confirmed "Check engine" flashing symbol.
    /// CLM-MIL-001 (Ford, scope-limited) is the only claim eligible to
    /// upgrade this from the generic to the vehicle-specific phrasing.
    func milContributors(
        vehicle: SavedVehicle,
        severeActiveSymptom: Bool
    ) -> [IncidentPossibleContributor] {
        let visible = evidenceClaims("CLM-MIL-001", vehicle: vehicle)
        let scopeMatched = visible.contains(where: { $0.id == "CLM-MIL-001" })
        let fact: String
        if severeActiveSymptom {
            fact = scopeMatched
                ? "A flashing check-engine light together with shaking, power loss, or stalling is consistent with an active misfire on this vehicle, per its cited owner's manual, and can cause further damage."
                : "A flashing check-engine light together with shaking, power loss, or stalling is consistent with an active misfire that can cause further damage."
        } else {
            fact = scopeMatched
                ? "A flashing check-engine light with shaking or rough running is consistent with an active misfire on this vehicle, per its cited owner's manual."
                : "A flashing check-engine light with shaking or rough running can be associated with a misfire condition on some vehicles."
        }
        return [
            urgentContributor(
                id: "OH-UIK-001",
                area: .engineAndCombustion,
                fact: fact,
                explanation: "This does not identify the failed coil, plug, injector, or other component; a code scan and inspection are needed."
            )
        ]
    }

    /// OH-UIK-006: CLM-OHT-005 (PRODUCT_POLICY) is the only claim
    /// eligible to back the possible-area text itself; OEM claims apply
    /// to immediate_action/actions_to_avoid instead (see
    /// overheatingImmediateAction).
    func overheatingContributors() -> [IncidentPossibleContributor] {
        [
            urgentContributor(
                id: "OH-UIK-006",
                area: .cooling,
                fact: "You reported a temperature warning, gauge reading, or visible steam consistent with an overheating event.",
                explanation: "This may involve cooling-system temperature control, circulation, airflow, or pressure. OpenHood has not confirmed the cause."
            )
        ]
    }

    /// OH-UIK-011/OH-UIK-013: braking and steering are now separate
    /// contributor sets selected by the reported concernType, rather than
    /// always returning one merged brakes-and-steering answer.
    func brakesOrSteeringContributors(
        answers: [String: String]
    ) -> [IncidentPossibleContributor] {
        guard answers[IncidentUrgentAnswerKey.concernType] == "Steering" else {
            return [
                urgentContributor(
                    id: "OH-UIK-011.hydraulic",
                    area: .hydraulicBrakingSystem,
                    fact: "You identified \(answers[IncidentUrgentAnswerKey.controlBehavior] ?? "abnormal braking").",
                    explanation: "A soft or spongy pedal may be associated with air in the brake lines or a hydraulic-system leak, but this does not confirm a specific failed component."
                ),
                urgentContributor(
                    id: "OH-UIK-011.other",
                    area: .brakesAndSteering,
                    fact: "The concern occurred \(answers[IncidentUrgentAnswerKey.occurrenceContext] ?? "under an unknown condition").",
                    explanation: "OpenHood cannot confirm the failed system from pedal feel alone."
                )
            ]
        }
        return [
            urgentContributor(
                id: "OH-UIK-013.assist",
                area: .powerSteeringOrEPS,
                fact: "You reported \(answers[IncidentUrgentAnswerKey.controlBehavior] ?? "a steering concern").",
                explanation: "A warning may involve a system-level power-steering or EPS concern, but it does not identify the failed component."
            ),
            urgentContributor(
                id: "OH-UIK-013.control",
                area: .steeringControlConcern,
                fact: "The concern occurred \(answers[IncidentUrgentAnswerKey.occurrenceContext] ?? "under an unknown condition").",
                explanation: "Whether this is a warning only or an actual loss of directional control determines the safe next step."
            )
        ]
    }

    func urgentWarningContributors(
        symbol: String?
    ) -> [IncidentPossibleContributor] {
        switch symbol {
        case "Temperature":
            return [urgentContributor(
                id: "urgent.warning-temperature",
                area: .cooling,
                fact: "You identified a temperature warning.",
                explanation: "This may involve the cooling system, but the symbol alone does not confirm the cause."
            ), urgentContributor(id: "urgent.warning-temperature-monitoring", area: .startingAndElectrical, fact: "A monitored temperature warning appeared.", explanation: "The warning circuit or stored vehicle information is worth documenting along with the physical temperature symptoms.")]
        case "Brake":
            return [urgentContributor(
                id: "urgent.warning-brake",
                area: .brakesAndSteering,
                fact: "You identified a brake warning.",
                explanation: "This may involve a braking-system warning condition that requires qualified inspection."
            ), urgentContributor(id: "urgent.warning-brake-monitoring", area: .startingAndElectrical, fact: "The vehicle displayed a brake-system warning.", explanation: "The exact warning wording is worth recording because a symbol alone does not identify the condition.")]
        case "Charging or battery":
            return [urgentContributor(
                id: "urgent.warning-battery",
                area: .startingAndElectrical,
                fact: "You identified a battery or charging symbol.",
                explanation: "This may involve electrical power or charging information, but the symbol does not identify a failed component."
            ), urgentContributor(id: "urgent.warning-wiring", area: .electricalAndWiring, fact: "A charging warning was reported.", explanation: "Connections, wiring, or charging-system operation are possible areas for qualified testing.")]
        // "Check engine" is handled entirely by milContributors(vehicle:)
        // in urgentContributors(for:vehicle:) before this function is
        // called — OH-UIK-001 supersedes the generic fallback here.
        case "Oil pressure":
            return [urgentContributor(
                id: "urgent.warning-oil",
                area: .lubricationAndOilPressure,
                fact: "You identified an oil-pressure-style warning symbol.",
                explanation: "This may involve engine lubrication information and needs immediate professional evaluation."
            ), urgentContributor(id: "urgent.warning-oil-engine", area: .engineAndCombustion, fact: "An oil-pressure warning appeared while the engine was operating.", explanation: "Engine operation is affected by lubrication conditions, but the symbol alone does not confirm a mechanical failure.")]
        case "Tire pressure":
            return [urgentContributor(id: "urgent.warning-tire", area: .tiresWheelsAndPressure, fact: "You identified a tire-pressure warning.", explanation: "This may involve tire pressure, a tire condition, or pressure-monitoring information and is worth checking safely."), urgentContributor(id: "urgent.warning-tire-monitoring", area: .startingAndElectrical, fact: "A monitored tire-pressure symbol appeared.", explanation: "The pressure-monitoring system is a possible information source, but it does not replace a physical tire inspection.")]
        default:
            return [urgentContributor(
                id: "urgent.warning-unknown",
                area: .startingAndElectrical,
                fact: "A flashing or unfamiliar warning was reported, but the symbol is not identified.",
                explanation: "Vehicle warning information is a possible area to document. More information is needed before narrowing the system."
            ), urgentContributor(id: "urgent.warning-observed-system", area: .engineAndCombustion, fact: "The warning symbol remains unidentified.", explanation: "An electronically monitored operating system may be involved, but there is not enough information yet to identify which one.")]
        }
    }

    func smellContributors(
        answers: [String: String]
    ) -> [IncidentPossibleContributor] {
        let smell = answers[IncidentUrgentAnswerKey.smellDescription] ?? "I’m not sure"
        let location = answers[IncidentUrgentAnswerKey.smellLocation] ?? "an unknown location"
        let visible = answers[IncidentUrgentAnswerKey.visibleEvidence] ?? "unknown visible evidence"
        let sharedFact = "You described \(smell.lowercased()) near \(location.lowercased()), with \(visible.lowercased())."

        switch smell {
        case "Gasoline":
            return [urgentContributor(id: "urgent.smell-fuel", area: .fuelAndIgnition, fact: sharedFact, explanation: "A gasoline-like odor may involve fuel vapor, containment, or delivery and requires professional inspection."), urgentContributor(id: "urgent.smell-fuel-leak", area: .leaksSmokeAndOdors, fact: sharedFact, explanation: "Visible liquid or persistent odor is consistent with a possible leak or vapor source, not a confirmed location.")]
        case "Burning oil":
            return [urgentContributor(id: "urgent.smell-oil", area: .lubricationAndOilPressure, fact: sharedFact, explanation: "A burning-oil description may involve oil or residue reaching a hot area."), urgentContributor(id: "urgent.smell-oil-leak", area: .leaksSmokeAndOdors, fact: sharedFact, explanation: "Smoke or residue is consistent with a possible fluid source, but OpenHood has not confirmed the fluid or origin.")]
        case "Sweet or coolant-like":
            return [urgentContributor(id: "urgent.smell-coolant", area: .cooling, fact: sharedFact, explanation: "A sweet or coolant-like description may involve cooling-system fluid or vapor."), urgentContributor(id: "urgent.smell-coolant-leak", area: .leaksSmokeAndOdors, fact: sharedFact, explanation: "Visible liquid or vapor may be consistent with a leak, spill, or another source and needs inspection.")]
        case "Electrical or plastic":
            return [urgentContributor(id: "urgent.smell-electrical", area: .electricalAndWiring, fact: sharedFact, explanation: "An electrical or plastic odor may involve overheated wiring, insulation, or another heat source."), urgentContributor(id: "urgent.smell-electrical-heat", area: .leaksSmokeAndOdors, fact: sharedFact, explanation: "Smoke or vapor can accompany heat damage, but the answers do not identify the source.")]
        case "Exhaust":
            return [urgentContributor(id: "urgent.smell-exhaust", area: .exhaustAndVentilation, fact: sharedFact, explanation: "An exhaust-like odor may involve exhaust routing or cabin ventilation and warrants inspection."), urgentContributor(id: "urgent.smell-exhaust-engine", area: .engineAndCombustion, fact: sharedFact, explanation: "Engine operation can affect exhaust odor, but this does not confirm an engine problem.")]
        default:
            return [urgentContributor(id: "urgent.smell-unknown", area: .leaksSmokeAndOdors, fact: sharedFact, explanation: "The odor family is not identified, so the source remains broad."), urgentContributor(id: "urgent.smell-unknown-heat", area: .electricalAndWiring, fact: sharedFact, explanation: "Electrical heat is one possible area among several; more information is needed.")]
        }
    }

    func urgentRecommendedAction(
        incident: VehicleIncident,
        immediateDanger: Bool
    ) -> IncidentRecommendedAction {
        if immediateDanger { return .emergencyServices }
        let answers = incident.urgentFollowUpAnswers ?? [:]
        let recentAnswers = [
            answers[IncidentUrgentAnswerKey.recentTrigger],
            answers[IncidentUrgentAnswerKey.coolingRecentWork],
            answers[IncidentUrgentAnswerKey.controlRecentWork],
            answers[IncidentUrgentAnswerKey.runningRecentWork]
        ].compactMap { $0 }
        if recentAnswers.contains(where: { $0 == "Service" || $0 == "A recent repair" || $0 == "A repair" || $0.contains("work") }) {
            return .contactRecentRepairShop
        }
        if incident.safetySelection == .flashingWarningLight,
           answers[IncidentUrgentAnswerKey.warningSymbol] == "Tire pressure",
           answers[IncidentUrgentAnswerKey.engineBehavior] == "Behaved normally" {
            return .professionalInspection
        }
        if incident.safetySelection == .flashingWarningLight {
            return .obtainCodeScan
        }
        return .roadsideAssistance
    }

    func urgentContributor(
        id: String,
        area: IncidentSystemCategory,
        fact: String,
        explanation: String
    ) -> IncidentPossibleContributor {
        IncidentPossibleContributor(
            recordID: id,
            category: area,
            summary: "Possible area",
            confidenceWording: "Based on what you reported",
            rationale: IncidentSupportingRationale(
                observedFact: fact,
                explanation: explanation
            )
        )
    }

    func urgentEvidenceRequests(
        for incident: VehicleIncident
    ) -> [IncidentEvidenceRequest] {
        let answers = incident.urgentFollowUpAnswers ?? [:]
        switch incident.safetySelection {
        case .smokeOrFire:
            return [
                IncidentEvidenceRequest("From a safe distance, photograph the area where smoke appeared only if no flame or smoke remains."),
                IncidentEvidenceRequest("Record the odor description and where the smoke appeared to originate."),
                IncidentEvidenceRequest("Keep any recent service invoice available for the inspector.")
            ]
        case .strongFuelSmell:
            return [
                IncidentEvidenceRequest("Record the odor description, strongest location, and whether liquid, smoke, or vapor was visible."),
                IncidentEvidenceRequest("From a safe distance, photograph visible residue only if no immediate danger remains."),
                IncidentEvidenceRequest("Keep the refueling receipt or recent service invoice if the timing is relevant.")
            ]
        case .overheatingOrSteam:
            // OH-UIK-006 confirmation_step: confirm the warning/gauge,
            // confirm active steam vs. smoke/unknown vapor, confirm
            // vehicle identity and exact owner's manual.
            return [
                IncidentEvidenceRequest("Record the temperature warning or gauge behavior already observed before shutdown."),
                IncidentEvidenceRequest("Confirm whether the visible material was steam, smoke, or another vapor."),
                IncidentEvidenceRequest("After the vehicle is fully cool, photograph visible fluid location from a safe standing position."),
                IncidentEvidenceRequest("Keep records of recent coolant additions or cooling-system work.")
            ]
        case .flashingWarningLight:
            if answers[IncidentUrgentAnswerKey.warningSymbol] == "Check engine" {
                // OH-UIK-001 confirmation_step: confirm exact symbol,
                // confirm vehicle identity, confirm whether active now.
                return [
                    IncidentEvidenceRequest("Confirm the exact symbol is the engine-shaped check-engine indicator, not a different warning."),
                    IncidentEvidenceRequest("Obtain an OBD-II diagnostic scan and record the exact codes and freeze-frame information when available."),
                    IncidentEvidenceRequest("Record whether the light is currently flashing, steady, or off, and any shaking or power loss already experienced without restarting to reproduce it."),
                    IncidentEvidenceRequest("Confirm the vehicle's exact make, model, model year, and market before applying manufacturer-specific continuation guidance.")
                ]
            }
            return [
                IncidentEvidenceRequest("Record the exact symbol and whether it flashed, became steady, or disappeared."),
                IncidentEvidenceRequest("Request a scan-code report when applicable; keep the exact codes rather than a parts recommendation."),
                IncidentEvidenceRequest("Record any other warning and the engine behavior that occurred at the same time.")
            ]
        case .unsafeBrakesOrSteering:
            if answers[IncidentUrgentAnswerKey.concernType] == "Steering" {
                // OH-UIK-013 confirmation_step: confirm exact warning,
                // confirm vehicle identity, confirm whether steering
                // control is actually impaired.
                return [
                    IncidentEvidenceRequest("Confirm the exact warning or message and whether steering control is actually impaired, not just heavy or unfamiliar."),
                    IncidentEvidenceRequest("Describe steering behavior without conducting a road test."),
                    IncidentEvidenceRequest("Record recent impact, tire service, battery issue, or steering repair."),
                    IncidentEvidenceRequest("Confirm the vehicle's exact make, model, model year, and market before applying manufacturer-specific continuation guidance.")
                ]
            }
            // OH-UIK-011 confirmation_step: confirm whether stopping
            // ability changed, confirm exact warning symbol, confirm
            // whether active now.
            return [
                IncidentEvidenceRequest("Confirm whether stopping ability changed and whether the incident is active now."),
                IncidentEvidenceRequest("Photograph any warning message while parked, without driving to reproduce it."),
                IncidentEvidenceRequest("Keep invoices for recent tire, brake, suspension, alignment, or steering work.")
            ]
        case .visibleTireDamage:
            return [
                IncidentEvidenceRequest("From a safe distance, photograph the damaged area of the tire."),
                IncidentEvidenceRequest("Note which tire (position) is affected and what kind of damage was visible."),
                IncidentEvidenceRequest("If a spare was installed, keep the damaged tire available for the shop to inspect.")
            ]
        case .transmissionSlippingOrBurningSmell:
            return [
                IncidentEvidenceRequest("Record whether it's slipping, a burning smell, or both, and whether it's continuous or comes and goes."),
                IncidentEvidenceRequest("Note the mileage and when the transmission fluid was last checked or changed, if known."),
                IncidentEvidenceRequest("Record whether this began after towing, a heavy load, or extended stop-and-go traffic."),
                IncidentEvidenceRequest("Confirm the vehicle's exact make, model, and transmission type (automatic, CVT, or manual) before applying vehicle-specific guidance.")
            ]
        case .engineWillNotStayRunning:
            return [
                IncidentEvidenceRequest("Record when the engine stopped running based only on what already happened."),
                IncidentEvidenceRequest("Request a scan-code report and keep its exact wording."),
                IncidentEvidenceRequest("Photograph a visible disconnected component only with the engine off and without touching it."),
                IncidentEvidenceRequest("Keep the invoice for any service, battery work, fueling, or repair immediately beforehand.")
            ]
        case .noneOfThese, .unsure, nil:
            return []
        }
    }

    func urgentActionsToAvoid(
        incident: VehicleIncident
    ) -> [String] {
        let selection = incident.safetySelection
        let answers = incident.urgentFollowUpAnswers ?? [:]
        var actions = ["Do not continue driving or reproduce the concern."]
        if selection == .overheatingOrSteam {
            actions.append("Do not open a hot cooling system or touch hot components.")
        }
        if selection == .strongFuelSmell || selection == .smokeOrFire {
            actions.append("Do not approach with flames, sparks, or ignition sources.")
        }
        if selection == .flashingWarningLight,
           answers[IncidentUrgentAnswerKey.warningSymbol] == "Check engine" {
            // CLM-MIL-002/CLM-MIL-004
            actions.append("Do not use heavy acceleration to test the problem.")
            actions.append("Do not treat the warning as confirming a specific failed coil, plug, injector, or sensor.")
        }
        if selection == .unsafeBrakesOrSteering {
            if answers[IncidentUrgentAnswerKey.concernType] == "Steering" {
                // CLM-STR-004
                actions.append("Do not identify a steering rack, motor, pump, module, or sensor as failed from the warning alone.")
            } else {
                // CLM-BRK-004/CLM-BRK-005
                actions.append("Do not road-test a vehicle reported to have reduced braking.")
                actions.append("Do not name a master cylinder, booster, caliper, hose, or ABS unit as failed from pedal feel alone.")
            }
        }
        return actions
    }

    func safetyStatus(
        for selection: IncidentSafetySelection?
    ) -> String {
        switch selection?.urgency {
        case .urgent:
            "Stop driving. Follow the immediate safety instructions shown before this screen."
        case .caution:
            "Use caution. If the vehicle feels unsafe, do not continue driving."
        case .routine:
            "No urgent warning identified from your answers."
        case nil:
            "More information is needed about immediate safety."
        }
    }

    func reportedSummary(for incident: VehicleIncident) -> String {
        if let answers = incident.urgentFollowUpAnswers,
           !answers.isEmpty {
            let labels: [(String, String)] = [
                (IncidentUrgentAnswerKey.activeFlame, "Active flame"),
                (IncidentUrgentAnswerKey.smokePresent, "Smoke after shutdown"),
                (IncidentUrgentAnswerKey.smokeSource, "Smoke location"),
                (IncidentUrgentAnswerKey.smokeOdor, "Odor"),
                (IncidentUrgentAnswerKey.smellDescription, "Smell description"),
                (IncidentUrgentAnswerKey.smellLocation, "Smell location"),
                (IncidentUrgentAnswerKey.visibleEvidence, "Visible evidence"),
                (IncidentUrgentAnswerKey.recentTrigger, "Recent event"),
                (IncidentUrgentAnswerKey.temperatureIndication, "Temperature indication"),
                (IncidentUrgentAnswerKey.coolingEvidence, "Cooling observation"),
                (IncidentUrgentAnswerKey.cabinHeat, "Cabin heat"),
                (IncidentUrgentAnswerKey.drivingCondition, "When it happened"),
                (IncidentUrgentAnswerKey.coolingRecentWork, "Recent cooling work"),
                (IncidentUrgentAnswerKey.warningSymbol, "Warning"),
                (IncidentUrgentAnswerKey.warningState, "Warning state"),
                (IncidentUrgentAnswerKey.engineBehavior, "Engine behavior"),
                (IncidentUrgentAnswerKey.additionalWarning, "Another warning"),
                (IncidentUrgentAnswerKey.concernType, "Control concern"),
                (IncidentUrgentAnswerKey.controlBehavior, "Behavior"),
                (IncidentUrgentAnswerKey.occurrenceContext, "When it occurred"),
                (IncidentUrgentAnswerKey.controlWarning, "Warning appeared"),
                (IncidentUrgentAnswerKey.controlRecentWork, "Recent related work"),
                (IncidentUrgentAnswerKey.runningDetail, "Running behavior"),
                (IncidentUrgentAnswerKey.runningRecentWork, "Recent event"),
                (IncidentUrgentAnswerKey.runningWarning, "Warning state"),
                (IncidentUrgentAnswerKey.runningEvidence, "Other observation"),
                (IncidentUrgentAnswerKey.restartEffect, "Restart result")
            ]
            let details = labels.compactMap { key, label in
                answers[key].map { "\(label): \($0)" }
            }
            return (["Safety concern: \(incident.safetySelection?.title ?? "Unknown")"] + details)
                .joined(separator: ". ") + "."
        }

        let observations = incident.observationTypes.map(\.title).joined(separator: ", ")
        let recentWork = incident.recentWorkResponse?.title ?? "Not answered"
        let notes = incident.recentWorkNotes.trimmingCharacters(in: .whitespacesAndNewlines)

        return "Observations: \(observations.isEmpty ? "Not provided" : observations). Description: \(incident.userDescription.isEmpty ? "Not provided" : incident.userDescription). Recent work: \(recentWork)\(notes.isEmpty ? "" : " — \(notes)")."
    }

    func mechanicSummary(
        incident: VehicleIncident,
        vehicle: SavedVehicle,
        uncertainty: [String]
    ) -> String {
        let vehicleName = [vehicle.year.map(String.init), vehicle.make, vehicle.model, vehicle.trim]
            .compactMap { value in
                guard let value, !value.isEmpty else { return nil }
                return value
            }
            .joined(separator: " ")
        let observations = incident.observationTypes.map(\.title).joined(separator: ", ")
        let recentWork = incident.recentWorkResponse?.title ?? "Unknown"
        let notes = incident.recentWorkNotes.trimmingCharacters(in: .whitespacesAndNewlines)

        return "Vehicle: \(vehicleName.isEmpty ? "Unconfirmed vehicle" : vehicleName). Observations: \(observations.isEmpty ? "Not provided" : observations). Owner description: \(incident.userDescription.isEmpty ? "Not provided" : incident.userDescription). Safety answer: \(incident.safetySelection?.title ?? "Unknown"). Recent work: \(recentWork)\(notes.isEmpty ? "" : " — \(notes)"). Unresolved: \(uncertainty.joined(separator: " "))"
    }
}
