import Foundation

enum IncidentGuidanceKnowledge {
    static let contentVersion = 1

    static let records: [IncidentGuidanceKnowledgeRecord] = [
        record(
            id: "phase1.starting.engine-operation",
            family: .roughRunningStallingOrPostService,
            observations: [.startingOrRunningTrouble],
            support: [
                .observation(.startingOrRunningTrouble),
                .descriptionContains("rough"),
                .descriptionContains("misfire"),
                .descriptionContains("sputter"),
                .descriptionContains("will not stay running")
            ],
            contradict: [.descriptionContains("runs smoothly")],
            area: .engineAndCombustion,
            explanation: "Uneven operation or difficulty remaining running can involve combustion quality, but observations alone do not identify a failed component.",
            action: .professionalInspection,
            questions: [
                "Does it happen while starting, idling, or already moving?",
                "Was a warning light steady, flashing, or absent?"
            ]
        ),
        record(
            id: "phase1.starting.electrical",
            family: .roughRunningStallingOrPostService,
            observations: [.startingOrRunningTrouble, .warningLightOrMessage],
            support: [
                .observation(.startingOrRunningTrouble),
                .descriptionContains("no crank"),
                .descriptionContains("will not crank"),
                .descriptionContains("click")
            ],
            contradict: [.descriptionContains("cranks normally")],
            area: .startingAndElectrical,
            explanation: "A no-crank or limited-response start attempt can involve electrical power or starting control, but direct testing is still needed.",
            action: .professionalInspection,
            questions: [
                "Does the engine crank, click, or produce no response?",
                "What do the dash lights do during the start attempt?"
            ]
        ),
        record(
            id: "phase1.starting.fuel-ignition",
            family: .roughRunningStallingOrPostService,
            observations: [.startingOrRunningTrouble],
            support: [
                .observation(.startingOrRunningTrouble),
                .descriptionContains("cranks but"),
                .descriptionContains("turns over but"),
                .descriptionContains("misfire")
            ],
            contradict: [.descriptionContains("no crank")],
            area: .fuelAndIgnition,
            explanation: "Cranking without starting or misfire-like behavior can involve fuel delivery or ignition quality without pointing to one part.",
            action: .obtainCodeScan,
            questions: [
                "Does the engine crank at its usual speed?",
                "Is there a warning message or stored diagnostic code?"
            ]
        ),
        record(
            id: "phase1.cooling.temperature-control",
            family: .overheatingOrCooling,
            observations: [.visible, .warningLightOrMessage],
            support: [
                .descriptionContains("overheat"),
                .descriptionContains("temperature"),
                .descriptionContains("steam"),
                .descriptionContains("boiling coolant")
            ],
            contradict: [.descriptionContains("temperature stayed normal")],
            area: .cooling,
            explanation: "Temperature, steam, or boiling-coolant observations can involve coolant containment, circulation, airflow, or pressure control.",
            action: .professionalInspection,
            avoid: [
                "Do not open a hot cooling system.",
                "Do not touch hot or moving components."
            ],
            questions: [
                "What did the temperature gauge or warning message show?",
                "Was any fluid visible from a safe distance after the vehicle cooled?"
            ]
        ),
        record(
            id: "phase1.warning.record-code",
            family: .warningLightOrMessage,
            observations: [.warningLightOrMessage],
            required: [.observation(.warningLightOrMessage)],
            support: [
                .observation(.warningLightOrMessage),
                .descriptionContains("code"),
                .descriptionContains("warning light"),
                .descriptionContains("message")
            ],
            contradict: [.descriptionContains("no warning light")],
            area: .startingAndElectrical,
            explanation: "A warning or diagnostic code points toward an electronically monitored system, but the exact message or code is needed before narrowing the area.",
            action: .obtainCodeScan,
            questions: [
                "What was the exact warning message or symbol?",
                "Was the light steady or flashing?",
                "What exact diagnostic code was recorded, if any?"
            ]
        ),
        record(
            id: "phase1.warning.engine-information",
            family: .warningLightOrMessage,
            observations: [.warningLightOrMessage, .startingOrRunningTrouble],
            required: [.observation(.warningLightOrMessage)],
            support: [
                .observation(.warningLightOrMessage),
                .observation(.startingOrRunningTrouble)
            ],
            contradict: [],
            area: .engineAndCombustion,
            explanation: "A warning combined with a running change may involve engine-operation information, but an exact code and inspection are needed.",
            action: .obtainCodeScan,
            questions: [
                "What exact code or message was recorded?",
                "What running change occurred at the same time?"
            ]
        ),
        record(
            id: "phase1.fluid-smell.visible-fluid",
            family: .fluidLeakOrUnusualSmell,
            observations: [.visible, .smell],
            support: [
                .observation(.visible),
                .descriptionContains("leak"),
                .descriptionContains("fluid")
            ],
            contradict: [.descriptionContains("no visible fluid")],
            area: .leaksSmokeAndOdors,
            explanation: "Visible fluid or residue may involve a leak, spill, or normal drainage. Its location and appearance are worth documenting without touching it.",
            action: .professionalInspection,
            avoid: [
                "Do not touch or taste an unknown fluid.",
                "Do not go beneath an unsupported vehicle."
            ],
            questions: [
                "Where was the fluid visible from a safe standing position?",
                "What color or consistency was visible without touching it?"
            ]
        ),
        record(
            id: "phase1.fluid-smell.unusual-odor",
            family: .fluidLeakOrUnusualSmell,
            observations: [.smell, .visible],
            support: [
                .observation(.smell),
                .descriptionContains("burning"),
                .descriptionContains("sweet"),
                .descriptionContains("electrical"),
                .descriptionContains("exhaust")
            ],
            contradict: [.descriptionContains("no smell")],
            area: .leaksSmokeAndOdors,
            explanation: "An unusual odor can involve fluid contacting a hot surface, electrical heat, exhaust, or another source. The odor description and location help separate those possibilities.",
            action: .professionalInspection,
            avoid: [
                "Do not restart or reproduce an odor when smoke, fuel, or electrical heat may be involved.",
                "Do not touch hot or moving components."
            ],
            questions: [
                "Which odor description is closest?",
                "Where was it strongest, and was smoke or liquid visible?"
            ]
        )
    ]

    private static func record(
        id: String,
        family: IncidentWorkflowFamily,
        observations: [IncidentObservationType],
        required: [IncidentGuidanceEvidenceSignal] = [],
        support: [IncidentGuidanceEvidenceSignal],
        contradict: [IncidentGuidanceEvidenceSignal],
        area: IncidentSystemCategory,
        explanation: String,
        action: IncidentRecommendedAction,
        avoid: [String] = [
            "Do not reproduce a dangerous symptom.",
            "Do not touch hot or moving components or go under an unsupported vehicle."
        ],
        questions: [String]
    ) -> IncidentGuidanceKnowledgeRecord {
        IncidentGuidanceKnowledgeRecord(
            id: id,
            contentVersion: contentVersion,
            workflowFamily: family,
            applicableObservations: observations,
            requiredEvidence: required,
            supportingEvidence: support,
            contradictingEvidence: contradict,
            possibleArea: area,
            explanation: explanation,
            safeNextAction: action,
            actionsToAvoid: avoid,
            followUpQuestions: questions,
            applicabilityLimits: [
                "Universal guidance only; no inspection or component test has been performed.",
                "Vehicle-specific conclusions require reviewed, verified vehicle data."
            ],
            confidenceRules: IncidentGuidanceConfidenceRules(
                minimumScore: 3,
                supportedWording: "Possible area based on what you reported",
                limitedWording: "More information is needed"
            ),
            verificationState: .needsVerification,
            contentState: .unresolvedHypothesis,
            sourceReferences: [
                IncidentGuidanceSourceReference(
                    id: "source-placeholder-\(id)",
                    title: "Reviewed source reference needed",
                    location: nil,
                    isPlaceholder: true
                )
            ]
        )
    }
}
