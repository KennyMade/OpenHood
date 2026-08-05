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
        // Same tier as phase1.suspension.bump-noise and
        // phase1.brakes.squeal-while-braking above — reviewed
        // general-guidance content, not needsVerification placeholders.
        // These two records used to be free-text-only ("an exact code and
        // inspection are needed" with open follow-up questions and no
        // real content) — the same failure mode the noise records fixed:
        // nobody types the terms that would make free-text matching work.
        // Both are now gated on the structured "Which light or message
        // came on?" question (IncidentWarningAnswerKey, asked in
        // SomethingHappenedView.warningQuestions) instead, same pattern
        // as the noise/timing/sound structured follow-up. The free-text
        // description step still runs afterward for everyone regardless
        // of answer — nothing was removed, this is additive.
        //
        // Scope note: warning lights are not one severity level. A
        // flashing check-engine light and an oil-pressure light that
        // stays on are a different, more urgent category — real guidance
        // for both is closer to STOP DRIVING, which this Phase 1 engine
        // cannot represent yet (ordinaryDriveRecommendation only ever
        // returns SERVICE SOON, CHECK BEFORE DRIVING, or MONITOR).
        // Deliberately not handled here; being handled in a separate
        // pass. A user who picks "I'm not sure which one" here, or
        // reports a flashing/oil-pressure light, gets the existing
        // generic MONITOR-style result — that's the correct behavior
        // until that separate pass lands, not a bug.
        //
        // sourceReferences below are attributed to OpenHood, not to the
        // specific outlets consulted, for the same reason given above the
        // suspension-noise record: a source being public doesn't make it
        // citable on screen. The explanations and cost figures were
        // cross-checked across multiple independent automotive-reference
        // sources tonight, 2026-08-05 — the underlying facts (gas
        // cap/O2 sensor/spark plugs for a steady check-engine light;
        // battery/alternator/connections for a charging-system light) are
        // well-known, independently corroborated automotive knowledge,
        // not proprietary to any one site.
        record(
            id: "phase1.warning.record-code",
            family: .warningLightOrMessage,
            observations: [.warningLightOrMessage],
            required: [
                .observation(.warningLightOrMessage),
                .warningAnswer(key: IncidentWarningAnswerKey.light, value: "Check engine light (steady)")
            ],
            support: [
                .observation(.warningLightOrMessage),
                .warningAnswer(key: IncidentWarningAnswerKey.light, value: "Check engine light (steady)")
            ],
            contradict: [],
            area: .engineAndCombustion,
            explanation: "A steady check engine light most often points to something like a loose or damaged gas cap, a worn oxygen sensor, or aging spark plugs. It does not mean stop driving, but it should be scanned for the exact code soon so the cause can be narrowed down.",
            action: .obtainCodeScan,
            questions: [
                "Has the gas cap been checked or tightened recently?",
                "Is a diagnostic code available from a scan?",
                "Has fuel economy or engine performance changed?"
            ],
            verificationState: .reviewedGeneralPrinciple,
            contentState: .verifiedGeneralAutomotivePrinciple,
            sourceReferences: [
                IncidentGuidanceSourceReference(
                    id: "openhood-reviewed-check-engine-steady-guidance",
                    title: "OpenHood, \"Reviewed General Automotive Guidance — Steady Check Engine Light\"",
                    location: nil,
                    isPlaceholder: false
                )
            ],
            possibleAreaTerms: [
                IncidentPossibleAreaTerm(
                    id: "gas-cap",
                    name: "Gas cap",
                    plainExplanation: "A loose, cracked, or missing gas cap can let fuel vapor escape and is one of the most common, cheapest causes of this light.",
                    typicalCostRange: "Usually free to fix — tighten or replace the cap, roughly $10–$20 if it needs replacing"
                ),
                IncidentPossibleAreaTerm(
                    id: "oxygen-sensor",
                    name: "Oxygen sensor",
                    plainExplanation: "A sensor that measures exhaust to keep the engine running efficiently. When it wears out, the engine can run less efficiently and trigger this light.",
                    typicalCostRange: "Roughly $150–$400 including labor"
                ),
                IncidentPossibleAreaTerm(
                    id: "spark-plugs",
                    name: "Spark plugs",
                    plainExplanation: "Worn spark plugs can cause misfiring or rough running, which can trigger this light.",
                    typicalCostRange: "Roughly $100–$300 for a full set including labor"
                )
            ],
            repairSearchTerm: "check engine diagnostic"
        ),
        record(
            id: "phase1.warning.engine-information",
            family: .warningLightOrMessage,
            observations: [.warningLightOrMessage],
            required: [
                .observation(.warningLightOrMessage),
                .warningAnswer(key: IncidentWarningAnswerKey.light, value: "Battery or charging symbol")
            ],
            support: [
                .observation(.warningLightOrMessage),
                .warningAnswer(key: IncidentWarningAnswerKey.light, value: "Battery or charging symbol")
            ],
            contradict: [],
            area: .startingAndElectrical,
            explanation: "This usually means the charging system isn't keeping the battery topped up, most often the alternator or the battery itself. It's not usually an immediate stop-driving situation, but the vehicle can lose electrical power or stall if ignored.",
            action: .obtainCodeScan,
            questions: [
                "Is the battery original, or has it been replaced recently?",
                "Are the battery terminals clean, tight, and free of corrosion?",
                "Has the vehicle had any trouble starting recently?"
            ],
            verificationState: .reviewedGeneralPrinciple,
            contentState: .verifiedGeneralAutomotivePrinciple,
            sourceReferences: [
                IncidentGuidanceSourceReference(
                    id: "openhood-reviewed-battery-charging-light-guidance",
                    title: "OpenHood, \"Reviewed General Automotive Guidance — Battery or Charging Warning Light\"",
                    location: nil,
                    isPlaceholder: false
                )
            ],
            possibleAreaTerms: [
                IncidentPossibleAreaTerm(
                    id: "battery",
                    name: "Battery",
                    plainExplanation: "The battery itself may be old, damaged, or not holding a charge.",
                    typicalCostRange: "Roughly $100–$250 including installation"
                ),
                IncidentPossibleAreaTerm(
                    id: "alternator",
                    name: "Alternator",
                    plainExplanation: "The alternator recharges the battery while the engine runs. When it fails, the battery drains even while driving.",
                    typicalCostRange: "Roughly $400–$700 including labor"
                ),
                IncidentPossibleAreaTerm(
                    id: "battery-terminals-or-cables",
                    name: "Battery terminals or cables",
                    plainExplanation: "Loose, corroded, or damaged connections can interrupt charging even when the battery and alternator are fine.",
                    typicalCostRange: "Roughly $20–$150 to clean or replace"
                )
            ],
            repairSearchTerm: "auto electrical repair"
        ),
        // Same tier as phase1.warning.record-code/phase1.warning.engine-
        // information and the noise/brake records above — reviewed
        // general-guidance content, not needsVerification placeholders,
        // for the five color/odor-specific records below. Both
        // phase1.fluid-smell.visible-fluid and phase1.fluid-smell.
        // unusual-odor used to be free-text-only ("may involve a leak,
        // spill, or normal drainage" with no real content) — the same
        // failure mode fixed elsewhere: nobody types the exact words that
        // would make free-text matching work. Each is now split into one
        // record per structured answer (IncidentFluidAnswerKey, asked in
        // SomethingHappenedView.fluidQuestions), mirroring the check-
        // engine/battery-light split above. Unlike that split, the
        // original free-text descriptionContains matching is kept,
        // additive, on the two generic "I'm not sure" records below (not
        // removed) — a deliberate difference from the warning-light
        // rework, not an oversight.
        //
        // Scope note, deliberately not handled here: "electrical or
        // burning plastic" and "exhaust" are NOT offered as odor choices,
        // on purpose — electrical/burning-plastic smell is a real
        // fire-risk precursor and exhaust smell inside the cabin is a
        // real carbon-monoxide risk, both genuinely more dangerous than
        // this Phase 1 engine can represent (ordinaryDriveRecommendation
        // only ever returns SERVICE SOON, CHECK BEFORE DRIVING, or
        // MONITOR — no path to STOP DRIVING). Those two stay exclusively
        // in the urgent path (IncidentSafetySelection.smokeOrFire /
        // .strongFuelSmell, which already default to DO NOT RESTART
        // regardless of the exact smell reported) — being handled in a
        // separate pass, not folded in here.
        //
        // sourceReferences below are attributed to OpenHood, not to the
        // specific outlets consulted, for the same reason given above the
        // suspension-noise record: a source being public doesn't make it
        // citable on screen. Cost figures and explanations were cross-
        // checked across multiple independent automotive-reference
        // sources tonight, 2026-08-05 — the underlying facts (coolant
        // color varying by brand, oil puddle color/location, red fluid
        // being transmission-or-power-steering, AC condensation being
        // normal, musty smell being cabin-filter/moisture related) are
        // well-known, independently corroborated automotive knowledge,
        // not proprietary to any one site.
        record(
            id: "phase1.fluid-smell.visible-fluid",
            family: .fluidLeakOrUnusualSmell,
            observations: [.visible, .smell],
            required: [
                .observation(.visible),
                .fluidAnswer(key: IncidentFluidAnswerKey.color, value: "I’m not sure")
            ],
            support: [
                .observation(.visible),
                .fluidAnswer(key: IncidentFluidAnswerKey.color, value: "I’m not sure"),
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
            id: "phase1.fluid-smell.visible-fluid.coolant",
            family: .fluidLeakOrUnusualSmell,
            observations: [.visible],
            required: [
                .observation(.visible),
                .fluidAnswer(key: IncidentFluidAnswerKey.color, value: "Green, orange, pink, or yellow")
            ],
            support: [
                .observation(.visible),
                .fluidAnswer(key: IncidentFluidAnswerKey.color, value: "Green, orange, pink, or yellow")
            ],
            contradict: [],
            area: .cooling,
            explanation: "This color range usually points to coolant (antifreeze). Color varies by brand — green, orange, pink, and yellow are all normal coolant colors depending on the manufacturer. A coolant leak is worth having inspected soon, and worth watching for overheating in the meantime.",
            action: .professionalInspection,
            questions: [
                "Has the coolant level been checked recently?",
                "Has there been any sign of overheating?"
            ],
            verificationState: .reviewedGeneralPrinciple,
            contentState: .verifiedGeneralAutomotivePrinciple,
            sourceReferences: [
                IncidentGuidanceSourceReference(
                    id: "openhood-reviewed-visible-fluid-coolant-guidance",
                    title: "OpenHood, \"Reviewed General Automotive Guidance — Coolant-Colored Visible Fluid\"",
                    location: nil,
                    isPlaceholder: false
                )
            ],
            possibleAreaTerms: [
                IncidentPossibleAreaTerm(
                    id: "radiator-or-hose",
                    name: "Radiator or hose",
                    plainExplanation: "A cracked radiator or a worn, split coolant hose is one of the most common sources of a coolant leak.",
                    typicalCostRange: "Roughly $150–$450"
                ),
                IncidentPossibleAreaTerm(
                    id: "water-pump",
                    name: "Water pump",
                    plainExplanation: "The water pump circulates coolant through the engine. A worn seal or bearing can let coolant seep out.",
                    typicalCostRange: "Roughly $300–$750 including labor"
                ),
                IncidentPossibleAreaTerm(
                    id: "radiator-cap-or-reservoir",
                    name: "Radiator cap or reservoir",
                    plainExplanation: "A worn cap or a cracked overflow reservoir can let coolant escape, especially under pressure.",
                    typicalCostRange: "Roughly $20–$100"
                )
            ],
            repairSearchTerm: "coolant leak repair"
        ),
        record(
            id: "phase1.fluid-smell.visible-fluid.oil",
            family: .fluidLeakOrUnusualSmell,
            observations: [.visible],
            required: [
                .observation(.visible),
                .fluidAnswer(key: IncidentFluidAnswerKey.color, value: "Brown or black")
            ],
            support: [
                .observation(.visible),
                .fluidAnswer(key: IncidentFluidAnswerKey.color, value: "Brown or black")
            ],
            contradict: [],
            area: .lubricationAndOilPressure,
            explanation: "This usually points to engine oil — lighter brown if newer, darker if older. A puddle typically shows up near the center of the vehicle, under the engine.",
            action: .professionalInspection,
            questions: [
                "Where under the vehicle was the puddle, if any?",
                "Has the oil level been checked recently?"
            ],
            verificationState: .reviewedGeneralPrinciple,
            contentState: .verifiedGeneralAutomotivePrinciple,
            sourceReferences: [
                IncidentGuidanceSourceReference(
                    id: "openhood-reviewed-visible-fluid-oil-guidance",
                    title: "OpenHood, \"Reviewed General Automotive Guidance — Oil-Colored Visible Fluid\"",
                    location: nil,
                    isPlaceholder: false
                )
            ],
            possibleAreaTerms: [
                IncidentPossibleAreaTerm(
                    id: "oil-pan-gasket-or-drain-plug",
                    name: "Oil pan gasket or drain plug",
                    plainExplanation: "A worn oil pan gasket or a loose drain plug is one of the most common sources of an oil leak.",
                    typicalCostRange: "Roughly $100–$300"
                ),
                IncidentPossibleAreaTerm(
                    id: "valve-cover-gasket",
                    name: "Valve cover gasket",
                    plainExplanation: "A hardened or worn valve cover gasket can let oil seep out along the top of the engine.",
                    typicalCostRange: "Roughly $150–$400"
                ),
                IncidentPossibleAreaTerm(
                    id: "oil-filter-or-seal",
                    name: "Oil filter or seal",
                    plainExplanation: "A loose or improperly seated oil filter or seal can leak, especially soon after a service.",
                    typicalCostRange: "Roughly $50–$150"
                )
            ],
            repairSearchTerm: "oil leak repair"
        ),
        record(
            id: "phase1.fluid-smell.visible-fluid.red",
            family: .fluidLeakOrUnusualSmell,
            observations: [.visible],
            required: [
                .observation(.visible),
                .fluidAnswer(key: IncidentFluidAnswerKey.color, value: "Red or reddish")
            ],
            support: [
                .observation(.visible),
                .fluidAnswer(key: IncidentFluidAnswerKey.color, value: "Red or reddish")
            ],
            contradict: [],
            area: .leaksSmokeAndOdors,
            explanation: "Red fluid usually means either transmission fluid or power steering fluid. Location is a useful clue: leaks nearer the front are more often power steering, while leaks more toward the middle or rear are more often transmission.",
            action: .professionalInspection,
            questions: [
                "Was the leak nearer the front or the middle/rear of the vehicle?",
                "Has power steering or shifting felt different recently?"
            ],
            verificationState: .reviewedGeneralPrinciple,
            contentState: .verifiedGeneralAutomotivePrinciple,
            sourceReferences: [
                IncidentGuidanceSourceReference(
                    id: "openhood-reviewed-visible-fluid-red-guidance",
                    title: "OpenHood, \"Reviewed General Automotive Guidance — Red or Reddish Visible Fluid\"",
                    location: nil,
                    isPlaceholder: false
                )
            ],
            possibleAreaTerms: [
                IncidentPossibleAreaTerm(
                    id: "power-steering-hose-or-rack",
                    name: "Power steering hose or rack",
                    plainExplanation: "A worn power steering hose or a leaking rack seal can let reddish fluid escape, usually nearer the front.",
                    typicalCostRange: "Roughly $150–$500"
                ),
                IncidentPossibleAreaTerm(
                    id: "transmission-pan-gasket-or-seal",
                    name: "Transmission pan gasket or seal",
                    plainExplanation: "A worn transmission pan gasket or seal can let reddish fluid drip, usually nearer the middle or rear.",
                    typicalCostRange: "Roughly $150–$450"
                ),
                IncidentPossibleAreaTerm(
                    id: "transmission-cooler-line",
                    name: "Transmission cooler line",
                    plainExplanation: "A worn or damaged transmission cooler line can leak fluid, sometimes intermittently.",
                    typicalCostRange: "Roughly $100–$350"
                )
            ],
            repairSearchTerm: "fluid leak diagnosis"
        ),
        record(
            id: "phase1.fluid-smell.visible-fluid.clear",
            family: .fluidLeakOrUnusualSmell,
            observations: [.visible],
            required: [
                .observation(.visible),
                .fluidAnswer(key: IncidentFluidAnswerKey.color, value: "Clear or light")
            ],
            support: [
                .observation(.visible),
                .fluidAnswer(key: IncidentFluidAnswerKey.color, value: "Clear or light")
            ],
            contradict: [],
            area: .leaksSmokeAndOdors,
            explanation: "Clear fluid dripping under the front-center of the car, especially after using the AC, is usually just normal air-conditioning condensation — not a leak. It's typically nothing to worry about, but worth mentioning if it keeps happening in dry weather with the AC off.",
            action: .safeObservation,
            questions: [
                "Does this happen mainly after the AC has been running?",
                "Has this occurred with the AC off in dry weather?"
            ],
            verificationState: .reviewedGeneralPrinciple,
            contentState: .verifiedGeneralAutomotivePrinciple,
            sourceReferences: [
                IncidentGuidanceSourceReference(
                    id: "openhood-reviewed-visible-fluid-clear-guidance",
                    title: "OpenHood, \"Reviewed General Automotive Guidance — Clear or Light Visible Fluid\"",
                    location: nil,
                    isPlaceholder: false
                )
            ]
        ),
        record(
            id: "phase1.fluid-smell.unusual-odor",
            family: .fluidLeakOrUnusualSmell,
            observations: [.smell, .visible],
            required: [
                .observation(.smell),
                .fluidAnswer(key: IncidentFluidAnswerKey.odor, value: "I’m not sure")
            ],
            support: [
                .observation(.smell),
                .fluidAnswer(key: IncidentFluidAnswerKey.odor, value: "I’m not sure"),
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
        record(
            id: "phase1.fluid-smell.unusual-odor.sweet-or-coolant",
            family: .fluidLeakOrUnusualSmell,
            observations: [.smell],
            required: [
                .observation(.smell),
                .fluidAnswer(key: IncidentFluidAnswerKey.odor, value: "Sweet or coolant-like")
            ],
            support: [
                .observation(.smell),
                .fluidAnswer(key: IncidentFluidAnswerKey.odor, value: "Sweet or coolant-like")
            ],
            contradict: [],
            area: .cooling,
            explanation: "A sweet smell, especially when the heater is on, usually points to a coolant leak — sometimes small enough that there's no visible puddle yet. Worth checking the coolant level and having it inspected soon, and watching the temperature gauge in the meantime.",
            action: .professionalInspection,
            questions: [
                "Has the coolant level been checked recently?",
                "Is the smell stronger when the heater is running?"
            ],
            verificationState: .reviewedGeneralPrinciple,
            contentState: .verifiedGeneralAutomotivePrinciple,
            sourceReferences: [
                IncidentGuidanceSourceReference(
                    id: "openhood-reviewed-unusual-odor-sweet-coolant-guidance",
                    title: "OpenHood, \"Reviewed General Automotive Guidance — Sweet or Coolant-Like Odor\"",
                    location: nil,
                    isPlaceholder: false
                )
            ],
            possibleAreaTerms: [
                IncidentPossibleAreaTerm(
                    id: "radiator-or-hose",
                    name: "Radiator or hose",
                    plainExplanation: "A cracked radiator or a worn, split coolant hose is one of the most common sources of a coolant leak.",
                    typicalCostRange: "Roughly $150–$450"
                ),
                IncidentPossibleAreaTerm(
                    id: "water-pump",
                    name: "Water pump",
                    plainExplanation: "The water pump circulates coolant through the engine. A worn seal or bearing can let coolant seep out.",
                    typicalCostRange: "Roughly $300–$750 including labor"
                ),
                IncidentPossibleAreaTerm(
                    id: "radiator-cap-or-reservoir",
                    name: "Radiator cap or reservoir",
                    plainExplanation: "A worn cap or a cracked overflow reservoir can let coolant escape, especially under pressure.",
                    typicalCostRange: "Roughly $20–$100"
                )
            ],
            repairSearchTerm: "coolant leak repair"
        ),
        record(
            id: "phase1.fluid-smell.unusual-odor.musty",
            family: .fluidLeakOrUnusualSmell,
            observations: [.smell],
            required: [
                .observation(.smell),
                .fluidAnswer(key: IncidentFluidAnswerKey.odor, value: "Musty or moldy")
            ],
            support: [
                .observation(.smell),
                .fluidAnswer(key: IncidentFluidAnswerKey.odor, value: "Musty or moldy")
            ],
            contradict: [],
            area: .exhaustAndVentilation,
            explanation: "This usually points to moisture buildup in the ventilation system or cabin air filter, not a mechanical problem. It's common and not a safety concern, though unpleasant.",
            action: .professionalInspection,
            questions: [
                "Does the smell occur mainly when the AC or heater first turns on?",
                "When was the cabin air filter last replaced?"
            ],
            verificationState: .reviewedGeneralPrinciple,
            contentState: .verifiedGeneralAutomotivePrinciple,
            sourceReferences: [
                IncidentGuidanceSourceReference(
                    id: "openhood-reviewed-unusual-odor-musty-guidance",
                    title: "OpenHood, \"Reviewed General Automotive Guidance — Musty or Moldy Odor\"",
                    location: nil,
                    isPlaceholder: false
                )
            ],
            possibleAreaTerms: [
                IncidentPossibleAreaTerm(
                    id: "cabin-air-filter",
                    name: "Cabin air filter",
                    plainExplanation: "A dirty or moisture-trapping cabin air filter is one of the most common sources of a musty smell from the vents.",
                    typicalCostRange: "Roughly $20–$75"
                ),
                IncidentPossibleAreaTerm(
                    id: "ac-evaporator-moisture-buildup",
                    name: "AC evaporator moisture buildup",
                    plainExplanation: "Moisture can collect on the AC evaporator and grow mildew, especially after the system sits humid between uses.",
                    typicalCostRange: "Often $0 — running the AC on a dry setting for a few minutes before shutting off can resolve it; roughly $100–$200 if professionally cleaned"
                )
            ],
            repairSearchTerm: "cabin air filter replacement"
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
        ),
        // Same tier as phase1.suspension.bump-noise above — reviewed
        // general-guidance content, not a needsVerification placeholder.
        // Closes a real gap: the noiseQuestions already offer "While
        // braking" as a timing answer and "Squeal" as a sound answer, but
        // nothing matched that combination, so it fell through to the
        // generic MONITOR/not-enough-information result.
        //
        // sourceReferences below are attributed to OpenHood, not to the
        // specific outlets consulted, for the same reason given above the
        // suspension-noise record: a source being public doesn't make it
        // citable on screen. Cost figures and the underlying explanation
        // were cross-checked across multiple independent outlets (repair-
        // cost aggregators and brake-specialty shop articles) tonight,
        // 2026-08-05 — the facts themselves (wear-indicator tabs, glazing,
        // hardware, sticking calipers) are well-known, independently
        // corroborated automotive knowledge, not proprietary to any one
        // site.
        //
        // Known next gap, intentionally not addressed in this pass:
        // selecting "While braking" + "Grind" still falls through to the
        // generic result. Grinding while braking is a distinct, more
        // serious case (possible metal-on-metal contact) that deserves
        // its own scoped pass rather than being folded in here — and
        // since this engine's drive-recommendation severity is driven by
        // reported observation types, not per-record, escalating that
        // case properly likely needs a new question capturing whether
        // stopping distance or pedal feel has changed, not just a content
        // record.
        record(
            id: "phase1.brakes.squeal-while-braking",
            family: .noiseVibrationOrSuspension,
            observations: [.sound],
            required: [
                .noiseAnswer(key: IncidentNoiseAnswerKey.timing, value: "While braking")
            ],
            support: [
                .noiseAnswer(key: IncidentNoiseAnswerKey.sound, value: "Squeal")
            ],
            contradict: [],
            area: .brakesAndSteering,
            explanation: "A squeal while braking is most often the brake pad wear indicator doing its job — a small metal tab that's designed to touch the rotor and make noise once the pad material gets low, as a built-in warning. It can also come from glazed pad or rotor surfaces, worn hardware, or a caliper that isn't releasing cleanly. This does not identify a failed part.",
            action: .professionalInspection,
            questions: [
                "Does the squeal happen every time you brake, or only sometimes?",
                "Has the pedal feel, stopping distance, or noise changed recently?",
                "Has any brake work been done recently?"
            ],
            verificationState: .reviewedGeneralPrinciple,
            contentState: .verifiedGeneralAutomotivePrinciple,
            sourceReferences: [
                IncidentGuidanceSourceReference(
                    id: "openhood-reviewed-brake-squeal-guidance",
                    title: "OpenHood, \"Reviewed General Automotive Guidance — Squeal While Braking\"",
                    location: nil,
                    isPlaceholder: false
                )
            ],
            possibleAreaTerms: [
                IncidentPossibleAreaTerm(
                    id: "brake-pads-wear-indicator",
                    name: "Brake pads (wear indicator)",
                    plainExplanation: "A small metal tab on the pad touches the rotor on purpose once the pad is low, creating a squeal as a built-in warning that it's time to replace them.",
                    typicalCostRange: "Roughly $150–$400 per axle"
                ),
                IncidentPossibleAreaTerm(
                    id: "glazed-pads-or-rotors",
                    name: "Glazed pads or rotors",
                    plainExplanation: "Heat can harden the surface of the pads or rotors into a smooth, glass-like finish, which can vibrate and squeal even during light braking.",
                    typicalCostRange: "Roughly $40–$150 per axle to resurface, more if full replacement is needed"
                ),
                IncidentPossibleAreaTerm(
                    id: "worn-or-missing-brake-hardware",
                    name: "Worn or missing brake hardware",
                    plainExplanation: "Small clips and shims that cushion the pad and absorb vibration. When they're missing, worn, or out of lubricant, they can't do that job.",
                    typicalCostRange: "Roughly $150–$350 per axle, often included when pads are replaced"
                ),
                IncidentPossibleAreaTerm(
                    id: "sticking-caliper",
                    name: "Sticking caliper",
                    plainExplanation: "A caliper that doesn't release cleanly can drag unevenly, building up heat and vibration that can cause squeal.",
                    typicalCostRange: "Roughly $300–$600 per caliper, more for luxury or performance vehicles"
                )
            ],
            repairSearchTerm: "brake repair"
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
