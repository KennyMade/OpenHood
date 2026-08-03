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
                    )
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
                hasMatches: hasMatches
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
            matchedRecordIDs: matchedRecords.map(\.id),
            confidenceLabel: hasMatches
                ? "Limited confidence — consistent with your observations"
                : "Not enough information yet",
            knowledgeStatus: "Universal guidance · Knowledge version \(knowledgeVersion) · Source review pending",
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
                hasMatches: hasMatches
            ),
            confirmationStep: evidenceRequests(
                records: matchedRecords,
                incident: incident
            ).first?.prompt ?? "A qualified inspection may be needed to collect direct evidence."
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
        }
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

    func actionExplanation(
        action: IncidentRecommendedAction,
        hasMatches: Bool
    ) -> String {
        switch action {
        case .moreInformation:
            "Record the unanswered details below. The current answers do not support one of the four Phase 1 families strongly enough."
        case .safeObservation:
            "Collect only information that is visible or available without recreating the concern."
        case .obtainCodeScan:
            "Record the exact warning or code without treating it as proof of a failed component."
        case .contactRecentRepairShop:
            "The timing makes the recently serviced area useful context to recheck, but it does not prove the work caused the concern."
        case .professionalInspection:
            hasMatches
                ? "A qualified inspection may be needed to separate the possible areas using direct evidence."
                : "More information is needed before selecting an inspection area."
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
        immediateDanger: Bool
    ) -> IncidentDriveRecommendation {
        if immediateDanger { return .doNotRestart }
        let answers = incident.urgentFollowUpAnswers ?? [:]
        switch incident.safetySelection {
        case .smokeOrFire, .strongFuelSmell, .overheatingOrSteam,
             .engineWillNotStayRunning:
            return .doNotRestart
        case .unsafeBrakesOrSteering:
            return .stopDriving
        case .flashingWarningLight:
            if answers[IncidentUrgentAnswerKey.warningSymbol] == "Check engine",
               answers[IncidentUrgentAnswerKey.warningState] == "Still flashing",
               let behavior = answers[IncidentUrgentAnswerKey.engineBehavior],
               ["Shaking", "Lost power", "Stalled"].contains(behavior) {
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

    func urgentAssessment(
        incident: VehicleIncident,
        immediateDanger: Bool
    ) -> String {
        let answers = incident.urgentFollowUpAnswers ?? [:]
        if immediateDanger {
            return "This pattern indicates an immediate fire, smoke, or fuel-related danger. OpenHood has not confirmed the source."
        }
        switch incident.safetySelection {
        case .flashingWarningLight:
            let symbol = answers[IncidentUrgentAnswerKey.warningSymbol]
            let state = answers[IncidentUrgentAnswerKey.warningState]
            let behavior = answers[IncidentUrgentAnswerKey.engineBehavior]
            if symbol == "Check engine",
               state == "Still flashing",
               behavior == "Shaking" {
                return "This most strongly fits an active engine misfire."
            }
            if symbol == "Check engine", state == "Now steady",
               behavior == "Behaved normally" {
                return "This most strongly suggests a monitored engine or emissions-system concern that needs diagnostic information."
            }
            if symbol == "Tire pressure" {
                return "This most strongly suggests a tire-pressure or pressure-monitoring concern, not an engine fault."
            }
            if symbol == "I’m not sure" {
                return "The warning system cannot be narrowed down until the symbol or message is identified."
            }
            return "The warning points to the selected monitored system, but the symbol alone does not confirm a cause."
        case .overheatingOrSteam:
            return "This most strongly suggests a cooling-system temperature, circulation, pressure, or fluid-containment concern."
        case .strongFuelSmell:
            let description = answers[IncidentUrgentAnswerKey.smellDescription]
                ?? "unidentified"
            return "The \(description.lowercased()) odor most strongly suggests the related fluid, electrical, exhaust, or heat-source family shown below."
        case .smokeOrFire:
            return "This most strongly suggests a heat, electrical, or fluid-related smoke source that requires inspection."
        case .unsafeBrakesOrSteering:
            return "This most strongly suggests a braking, steering, tire, wheel, or related control concern."
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

    func urgentImmediateAction(
        incident: VehicleIncident,
        action: IncidentRecommendedAction,
        immediateDanger: Bool
    ) -> String {
        let answers = incident.urgentFollowUpAnswers ?? [:]
        if immediateDanger {
            return "Stay away from the vehicle and contact emergency services. Do not restart it or approach an active hazard."
        }
        if incident.safetySelection == .flashingWarningLight,
           answers[IncidentUrgentAnswerKey.warningSymbol] == "Check engine",
           answers[IncidentUrgentAnswerKey.warningState] == "Still flashing",
           answers[IncidentUrgentAnswerKey.engineBehavior] == "Shaking" {
            return "Shut the engine off once safely stopped. Do not keep driving or rev the engine. Arrange roadside assistance or towing."
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
            return "Shut the engine off once safely stopped. Do not restart it or open the hot cooling system. Arrange roadside assistance or towing."
        }
        if incident.safetySelection == .engineWillNotStayRunning,
           action == .contactRecentRepairShop {
            return "Do not keep restarting the engine. Contact the recent repair shop with the symptoms and invoice, and arrange transport if needed."
        }
        return actionExplanation(action: action, hasMatches: true)
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
            : urgentContributors(for: incident)
        let action = urgentRecommendedAction(
            incident: incident,
            immediateDanger: immediateDanger
        )
        let uncertainty = [
            "OpenHood has not inspected the vehicle and has not confirmed the cause.",
            "Immediate safety action remains more important than narrowing the possible areas."
        ]

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
            actionsToAvoid: urgentActionsToAvoid(for: incident.safetySelection),
            mechanicReadySummary: mechanicSummary(
                incident: incident,
                vehicle: vehicle,
                uncertainty: uncertainty
            ),
            knowledgeVersion: knowledgeVersion,
            matchedRecordIDs: contributors.map(\.recordID),
            confidenceLabel: contributors.isEmpty
                ? "Not enough information yet"
                : "Limited confidence — based on what you reported",
            knowledgeStatus: "Universal guidance · Knowledge version \(knowledgeVersion) · Source review pending",
            driveRecommendation: urgentDriveRecommendation(
                incident: incident,
                immediateDanger: immediateDanger
            ),
            plainLanguageAssessment: urgentAssessment(
                incident: incident,
                immediateDanger: immediateDanger
            ),
            immediateAction: urgentImmediateAction(
                incident: incident,
                action: action,
                immediateDanger: immediateDanger
            ),
            confirmationStep: urgentEvidenceRequests(for: incident).first?.prompt
                ?? "Emergency responders or a qualified inspector must evaluate the vehicle before further action."
        )
    }

    func urgentContributors(
        for incident: VehicleIncident
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
            return [
                urgentContributor(id: "urgent.cooling-temperature", area: .cooling, fact: "The reported gauge or warning answer was \(answer[IncidentUrgentAnswerKey.temperatureIndication] ?? "not known").", explanation: "This pattern may involve cooling-system temperature control, circulation, airflow, or pressure."),
                urgentContributor(id: "urgent.cooling-fluid", area: .leaksSmokeAndOdors, fact: "The visible cooling sign was \(answer[IncidentUrgentAnswerKey.coolingEvidence] ?? "not identified").", explanation: "Steam, bubbling, or leaking fluid is worth documenting after the vehicle is fully cool; it does not confirm the source.")
            ]
        case .flashingWarningLight:
            if answer[IncidentUrgentAnswerKey.warningSymbol] == "Check engine",
               answer[IncidentUrgentAnswerKey.warningState] == "Still flashing",
               answer[IncidentUrgentAnswerKey.engineBehavior] == "Shaking" {
                let reason = "A flashing check-engine light together with shaking or rough running is consistent with an active misfire that can cause further damage."
                return [
                    urgentContributor(id: "urgent.misfire-ignition", area: .ignition, fact: reason, explanation: "Ignition is one possible system area; this does not identify a failed coil, plug, or other part."),
                    urgentContributor(id: "urgent.misfire-fuel", area: .fuelDelivery, fact: reason, explanation: "Fuel delivery is another possible system area that requires scan data and testing."),
                    urgentContributor(id: "urgent.misfire-air", area: .airOrVacuum, fact: reason, explanation: "Air or vacuum information may be relevant when supported by direct evidence."),
                    urgentContributor(id: "urgent.misfire-mechanical", area: .mechanicalOrCompression, fact: reason, explanation: "A mechanical or compression condition is a possible category, not a confirmed failure.")
                ]
            }
            return urgentWarningContributors(
                symbol: answer[IncidentUrgentAnswerKey.warningSymbol]
            )
        case .unsafeBrakesOrSteering:
            return [
                urgentContributor(id: "urgent.brake-steering", area: .brakesAndSteering, fact: "You identified \(answer[IncidentUrgentAnswerKey.concernType] ?? "a brake or steering concern") with \(answer[IncidentUrgentAnswerKey.controlBehavior] ?? "an unclear change").", explanation: "This pattern may involve braking operation, steering control, or related suspension hardware and requires qualified inspection."),
                urgentContributor(id: "urgent.control-wheel", area: .tiresWheelsAndPressure, fact: "The concern occurred \(answer[IncidentUrgentAnswerKey.occurrenceContext] ?? "under an unknown condition").", explanation: "Tire, wheel, or alignment condition can sometimes contribute to pull, shake, wobble, or inconsistent control and is worth checking professionally.")
            ]
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
        case "Check engine":
            return [urgentContributor(
                id: "urgent.warning-engine",
                area: .engineAndCombustion,
                fact: "You identified a check-engine warning.",
                explanation: "This may involve an electronically monitored engine system. The exact code is needed to narrow it down."
            ), urgentContributor(id: "urgent.warning-engine-control", area: .fuelAndIgnition, fact: "The engine behavior was recorded alongside the warning.", explanation: "Fuel or ignition control is one possible system family when supported by scan codes and inspection.")]
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
        if incident.safetySelection == .flashingWarningLight,
           answers[IncidentUrgentAnswerKey.warningSymbol] == "Check engine",
           answers[IncidentUrgentAnswerKey.warningState] == "Still flashing",
           answers[IncidentUrgentAnswerKey.engineBehavior] == "Shaking" {
            return [
                IncidentEvidenceRequest("Obtain an OBD-II diagnostic scan and record the exact codes and freeze-frame information when available."),
                IncidentEvidenceRequest("Record every warning that appeared and the shaking already experienced; do not restart to reproduce it.")
            ]
        }
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
            return [
                IncidentEvidenceRequest("Record the temperature warning or gauge behavior already observed before shutdown."),
                IncidentEvidenceRequest("After the vehicle is fully cool, photograph visible fluid location from a safe standing position."),
                IncidentEvidenceRequest("Keep records of recent coolant additions or cooling-system work.")
            ]
        case .flashingWarningLight:
            return [
                IncidentEvidenceRequest("Record the exact symbol and whether it flashed, became steady, or disappeared."),
                IncidentEvidenceRequest("Request a scan-code report when applicable; keep the exact codes rather than a parts recommendation."),
                IncidentEvidenceRequest("Record any other warning and the engine behavior that occurred at the same time.")
            ]
        case .unsafeBrakesOrSteering:
            return [
                IncidentEvidenceRequest("Record the brake or steering behavior already experienced and the speed or maneuver when it occurred."),
                IncidentEvidenceRequest("Photograph any warning message while parked, without driving to reproduce it."),
                IncidentEvidenceRequest("Keep invoices for recent tire, brake, suspension, alignment, or steering work.")
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
        for selection: IncidentSafetySelection?
    ) -> [String] {
        var actions = ["Do not continue driving or reproduce the concern."]
        if selection == .overheatingOrSteam {
            actions.append("Do not open a hot cooling system or touch hot components.")
        }
        if selection == .strongFuelSmell || selection == .smokeOrFire {
            actions.append("Do not approach with flames, sparks, or ignition sources.")
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
