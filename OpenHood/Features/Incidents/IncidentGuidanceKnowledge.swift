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
        ),
        // Unlike the 8 records above, this one is not a needsVerification
        // placeholder — it's backed by professionally-supported
        // general-guidance content that was actually checked against
        // multiple independent sources, and is gated on the structured
        // noiseQuestions answers (IncidentNoiseAnswerKey) rather than
        // free-text description matching, since a driver describing
        // "rattling/grinding" in their own words won't type mechanic
        // terms like "control arm bushing." required requires the "Over
        // bumps" timing answer specifically because that's the exact
        // symptom this content addresses — a noise reported only while
        // turning or braking isn't in scope here.
        //
        // sourceReferences below are attributed to OpenHood, not to the
        // specific outlets consulted during research (JD Power, 1A Auto)
        // — both explicitly prohibit reproducing/redistributing their
        // content without written permission in their terms of use
        // (checked 2026-08-04), and the underlying facts (worn
        // bushings/links causing clunking, wear causing squealing) are
        // well-known, independently corroborated automotive knowledge,
        // not proprietary to either site. This is the same treatment
        // NO_EXTERNAL_SOURCE_PRODUCT_POLICY content gets elsewhere (e.g.
        // CLM-MIL-004 in IncidentEvidenceGatedKnowledge.swift: "OpenHood,
        // ..." rather than naming an external site) — reviewed content
        // OpenHood stands behind on its own authority, not a quotable
        // citation to a specific company. Apply the same check-before-
        // naming discipline to every future record: a source being
        // public doesn't make it citable on screen.
        record(
            id: "phase1.suspension.bump-noise",
            family: .noiseVibrationOrSuspension,
            observations: [.sound, .vibrationOrMovement],
            required: [
                .noiseAnswer(key: IncidentNoiseAnswerKey.timing, value: "Over bumps")
            ],
            support: [
                .observation(.sound),
                .observation(.vibrationOrMovement),
                .noiseAnswer(key: IncidentNoiseAnswerKey.timing, value: "Over bumps"),
                .noiseAnswer(key: IncidentNoiseAnswerKey.sound, value: "Rattle"),
                .noiseAnswer(key: IncidentNoiseAnswerKey.sound, value: "Clunk"),
                .noiseAnswer(key: IncidentNoiseAnswerKey.sound, value: "Grind"),
                .noiseAnswer(key: IncidentNoiseAnswerKey.location, value: "Front"),
                .noiseAnswer(key: IncidentNoiseAnswerKey.location, value: "Rear"),
                .noiseAnswer(key: IncidentNoiseAnswerKey.location, value: "All over")
            ],
            // No contradict signals: `required` above already pins timing
            // to exactly "Over bumps" (single-choice), so any other
            // timing value already excludes this record before scoring.
            contradict: [],
            area: .suspensionAndChassis,
            explanation: "This is consistent with suspension or chassis noise under load. Common sources include worn control-arm bushings, sway bar links or bushings, ball joints, or strut mounts — these are possible areas to have inspected, not a confirmed diagnosis.",
            action: .professionalInspection,
            questions: [
                "Does the noise happen on most bumps or only on sharp/hard ones?",
                "Is there any looseness, clunking when pressing the brake or gas, or visible play at the suspension corner where the noise happens?",
                "Has any suspension, steering, or wheel work been done recently?"
            ],
            verificationState: .reviewedGeneralPrinciple,
            contentState: .verifiedGeneralAutomotivePrinciple,
            sourceReferences: [
                IncidentGuidanceSourceReference(
                    id: "openhood-reviewed-suspension-noise-guidance",
                    title: "OpenHood, \"Reviewed General Automotive Guidance — Bump-Triggered Suspension Noise\"",
                    location: nil,
                    isPlaceholder: false
                )
            ],
            // Cost figures cross-checked across multiple independent
            // sources (Jerry, FIXD, RepairPal, AutoZone, repair-community
            // discussions) tonight, 2026-08-04 — not attributed to any
            // single named source, same reasoning as sourceReferences
            // above. Strut mounts intentionally has no number: mount-only
            // vs. full-strut replacement cost varies too much for a
            // range to mean anything without inspection.
            possibleAreaTerms: [
                IncidentPossibleAreaTerm(
                    id: "control-arm-bushings",
                    name: "Control-arm bushings",
                    plainExplanation: "Rubber cushions that let the suspension move quietly. When worn, parts can knock together.",
                    typicalCostRange: "Roughly $250–$450"
                ),
                IncidentPossibleAreaTerm(
                    id: "sway-bar-links-or-bushings",
                    name: "Sway bar links or bushings",
                    plainExplanation: "Small links and cushions that help keep the vehicle stable in turns. When worn, they can rattle or clunk.",
                    typicalCostRange: "Roughly $75–$300"
                ),
                IncidentPossibleAreaTerm(
                    id: "ball-joints",
                    name: "Ball joints",
                    plainExplanation: "Pivot joints that let the wheels turn and move with the suspension. When worn, they can cause a clunking noise or looseness.",
                    typicalCostRange: "Roughly $200–$400 each"
                ),
                IncidentPossibleAreaTerm(
                    id: "strut-mounts",
                    name: "Strut mounts",
                    plainExplanation: "Where the suspension attaches to the body of the car. When worn, it can cause noise over bumps.",
                    typicalCostRange: "Varies significantly depending on whether the full strut needs replacement"
                )
            ],
            repairSearchTerm: "suspension repair"
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
        questions: [String],
        verificationState: IncidentKnowledgeVerificationState = .needsVerification,
        contentState: IncidentKnowledgeContentState = .unresolvedHypothesis,
        sourceReferences: [IncidentGuidanceSourceReference]? = nil,
        possibleAreaTerms: [IncidentPossibleAreaTerm] = [],
        repairSearchTerm: String? = nil
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
            verificationState: verificationState,
            contentState: contentState,
            sourceReferences: sourceReferences ?? [
                IncidentGuidanceSourceReference(
                    id: "source-placeholder-\(id)",
                    title: "Reviewed source reference needed",
                    location: nil,
                    isPlaceholder: true
                )
            ],
            possibleAreaTerms: possibleAreaTerms,
            repairSearchTerm: repairSearchTerm
        )
    }
}
