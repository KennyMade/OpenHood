import Foundation

enum IncidentGuidanceKnowledge {
    static let contentVersion = 1

    static let records: [IncidentGuidanceKnowledgeRecord] = [
        // OH-UIK gap fix (same tier as the odor-escalation and
        // temperature-warning-light severity fixes): phase1.starting.
        // engine-operation used to be a single free-text-matched
        // placeholder whose support list literally included "will not
        // stay running" — meaning this record could absorb an actual
        // stalling report and cap it at SERVICE SOON via
        // ordinaryDriveRecommendation, which has no path to DO NOT
        // RESTART. It is now split into one record per structured answer
        // (IncidentStartingAnswerKey.whatsHappening, asked in
        // SomethingHappenedView.startingQuestions), mirroring the
        // check-engine/battery-light and fluid-color/odor splits above —
        // except the dangerous answer, "The engine actually shuts off or
        // dies," gets no record here at all. It escalates directly into
        // IncidentSafetySelection.engineWillNotStayRunning before Phase 1
        // evaluation ever runs (see engineOperationEscalation in
        // SomethingHappenedView.swift), the same mechanism already used
        // for "Electrical or burning plastic"/"Exhaust" on the odor
        // question and "Temperature warning light" on the warning-light
        // question. Removing the free-text "will not stay running" match
        // (not just leaving it unreachable) closes the same gap the
        // odor/cooling fixes closed: a typed description alone can no
        // longer produce the old capped SERVICE SOON result for a real
        // stall.
        //
        // The original free-text descriptionContains matching (minus
        // "will not stay running") is kept, additive, on the "I'm not
        // sure" record below under the original record id — same
        // treatment as the fluid-smell generic records.
        //
        // sourceReferences below are attributed to OpenHood, not to the
        // specific outlets consulted, for the same reason given above the
        // suspension-noise record: a source being public doesn't make it
        // citable on screen. The explanations and cost figures were
        // cross-checked across multiple independent automotive-reference
        // sources tonight, 2026-08-05 — the underlying facts (rough idle
        // pointing to vacuum leaks, dirty throttle bodies, or worn spark
        // plugs; hesitation while driving sharing those same causes or
        // worn engine mounts) are well-known, independently corroborated
        // automotive knowledge, not proprietary to any one site.
        record(
            id: "phase1.starting.engine-operation",
            family: .roughRunningStallingOrPostService,
            observations: [.startingOrRunningTrouble],
            required: [
                .observation(.startingOrRunningTrouble),
                .startingAnswer(key: IncidentStartingAnswerKey.whatsHappening, value: "I’m not sure")
            ],
            support: [
                .observation(.startingOrRunningTrouble),
                .startingAnswer(key: IncidentStartingAnswerKey.whatsHappening, value: "I’m not sure"),
                .descriptionContains("rough"),
                .descriptionContains("misfire"),
                .descriptionContains("sputter")
            ],
            contradict: [.descriptionContains("runs smoothly")],
            area: .engineAndCombustion,
            explanation: "Uneven engine operation can involve combustion quality, air or fuel delivery, or engine mounts, but without knowing exactly what's happening, a direct inspection is the most reliable next step.",
            action: .professionalInspection,
            questions: [
                "Does it happen while starting, idling, or already moving?",
                "Was a warning light steady, flashing, or absent?"
            ],
            verificationState: .reviewedGeneralPrinciple,
            contentState: .verifiedGeneralAutomotivePrinciple,
            sourceReferences: [
                IncidentGuidanceSourceReference(
                    id: "openhood-reviewed-engine-operation-general-guidance",
                    title: "OpenHood, \"Reviewed General Automotive Guidance — Engine Operation, Not Yet Narrowed Down\"",
                    location: nil,
                    isPlaceholder: false
                )
            ]
        ),
        record(
            id: "phase1.starting.engine-operation.rough-idle",
            family: .roughRunningStallingOrPostService,
            observations: [.startingOrRunningTrouble],
            required: [
                .observation(.startingOrRunningTrouble),
                .startingAnswer(key: IncidentStartingAnswerKey.whatsHappening, value: "Rough or shaky idle, but the engine keeps running")
            ],
            support: [
                .observation(.startingOrRunningTrouble),
                .startingAnswer(key: IncidentStartingAnswerKey.whatsHappening, value: "Rough or shaky idle, but the engine keeps running")
            ],
            contradict: [],
            area: .engineAndCombustion,
            explanation: "A rough idle most often points to a vacuum leak, a dirty throttle body, or worn spark plugs. A useful clue: if the roughness goes away once you're driving faster, that leans toward a vacuum leak; if it's present at all speeds, that leans toward plugs or coils.",
            action: .professionalInspection,
            questions: [
                "Does the roughness improve once you're driving faster, or is it present at all speeds?",
                "When were the spark plugs last replaced?"
            ],
            verificationState: .reviewedGeneralPrinciple,
            contentState: .verifiedGeneralAutomotivePrinciple,
            sourceReferences: [
                IncidentGuidanceSourceReference(
                    id: "openhood-reviewed-rough-idle-guidance",
                    title: "OpenHood, \"Reviewed General Automotive Guidance — Rough or Shaky Idle\"",
                    location: nil,
                    isPlaceholder: false
                )
            ],
            possibleAreaTerms: [
                IncidentPossibleAreaTerm(
                    id: "vacuum-leak",
                    name: "Vacuum leak (hoses or gaskets)",
                    plainExplanation: "A crack or loose connection in a vacuum hose or gasket lets in unmetered air, which can make the idle rough — often more noticeable at idle than at speed.",
                    typicalCostRange: "Roughly $150–$600 depending on location"
                ),
                IncidentPossibleAreaTerm(
                    id: "throttle-body",
                    name: "Throttle body cleaning or service",
                    plainExplanation: "Carbon buildup in the throttle body can disrupt airflow at idle.",
                    typicalCostRange: "Roughly $75–$300"
                ),
                IncidentPossibleAreaTerm(
                    id: "spark-plugs",
                    name: "Spark plugs",
                    plainExplanation: "Worn spark plugs can cause uneven combustion that shows up as a rough idle at any speed.",
                    typicalCostRange: "Roughly $100–$300 for a full set"
                ),
                IncidentPossibleAreaTerm(
                    id: "ignition-coil",
                    name: "Ignition coil",
                    plainExplanation: "A failing ignition coil can cause a misfire that feels like a rough idle.",
                    typicalCostRange: "Roughly $200–$300"
                )
            ],
            repairSearchTerm: "rough idle diagnostic"
        ),
        record(
            id: "phase1.starting.engine-operation.hesitation",
            family: .roughRunningStallingOrPostService,
            observations: [.startingOrRunningTrouble],
            required: [
                .observation(.startingOrRunningTrouble),
                .startingAnswer(key: IncidentStartingAnswerKey.whatsHappening, value: "Occasional stumble or hesitation while driving, engine keeps running")
            ],
            support: [
                .observation(.startingOrRunningTrouble),
                .startingAnswer(key: IncidentStartingAnswerKey.whatsHappening, value: "Occasional stumble or hesitation while driving, engine keeps running")
            ],
            contradict: [],
            area: .engineAndCombustion,
            explanation: "Occasional hesitation while driving, without the engine ever fully dying, often points to the same causes as rough idle, or to worn engine mounts if it's felt more as a shake or clunk than a power loss.",
            action: .professionalInspection,
            questions: [
                "Does it feel more like a loss of power, or more like a shake or clunk?",
                "Have the engine mounts ever been inspected?"
            ],
            verificationState: .reviewedGeneralPrinciple,
            contentState: .verifiedGeneralAutomotivePrinciple,
            sourceReferences: [
                IncidentGuidanceSourceReference(
                    id: "openhood-reviewed-engine-hesitation-guidance",
                    title: "OpenHood, \"Reviewed General Automotive Guidance — Hesitation While Driving\"",
                    location: nil,
                    isPlaceholder: false
                )
            ],
            possibleAreaTerms: [
                IncidentPossibleAreaTerm(
                    id: "spark-plugs",
                    name: "Spark plugs",
                    plainExplanation: "Worn spark plugs can cause a momentary misfire that feels like hesitation while driving.",
                    typicalCostRange: "Roughly $100–$300 for a full set"
                ),
                IncidentPossibleAreaTerm(
                    id: "ignition-coil",
                    name: "Ignition coil",
                    plainExplanation: "A failing ignition coil can cause an intermittent misfire under load.",
                    typicalCostRange: "Roughly $200–$300"
                ),
                IncidentPossibleAreaTerm(
                    id: "engine-mounts",
                    name: "Engine mounts",
                    plainExplanation: "Worn engine mounts can let the engine shift under load, which can feel like a hesitation or clunk rather than a true power loss.",
                    typicalCostRange: "Roughly $300–$700 per mount"
                ),
                IncidentPossibleAreaTerm(
                    id: "vacuum-leak",
                    name: "Vacuum leak",
                    plainExplanation: "A vacuum leak can cause an inconsistent air-fuel mixture that shows up as hesitation under certain driving conditions.",
                    typicalCostRange: "Roughly $150–$600"
                )
            ],
            repairSearchTerm: "engine hesitation diagnostic"
        ),
        // Same tier as phase1.warning.record-code/engine-information and
        // the fluid-smell/noise/brake records — reviewed general-guidance
        // content, not needsVerification placeholders, for the two
        // starting-trouble families below. phase1.starting.electrical and
        // phase1.starting.fuel-ignition used to be free-text-only ("a
        // no-crank...can involve electrical power...but direct testing is
        // still needed" with open follow-up questions and no real
        // content) — the same failure mode fixed elsewhere: nobody types
        // the exact words that would make free-text matching work. Each
        // is now split into one record per structured answer
        // (IncidentStartingAnswerKey, asked in
        // SomethingHappenedView.startingQuestions), mirroring the
        // check-engine/battery-light and fluid-color/odor splits above.
        // The original free-text descriptionContains matching is kept,
        // additive, on the two generic "I'm not sure" records below (not
        // removed) — same treatment as the fluid-smell generic records.
        //
        // Both structured questions (crankBehavior, crankClues) are asked
        // back-to-back whenever .startingOrRunningTrouble is reported, so
        // a person only needs to meaningfully answer whichever one
        // matches what actually happened — the other can be left at "I'm
        // not sure" without changing the result, since each family's
        // records key off only its own answer.
        //
        // Safety note: a car not starting while parked is an
        // inconvenience, not a driving-safety hazard, so these stay
        // SERVICE-SOON-tier — ordinaryDriveRecommendation already forces
        // SERVICE SOON for any .startingOrRunningTrouble report
        // regardless of which answer is given. No urgent-path routing is
        // needed here, unlike the cooling/temperature severity fix.
        //
        // sourceReferences below are attributed to OpenHood, not to the
        // specific outlets consulted, for the same reason given above the
        // suspension-noise record: a source being public doesn't make it
        // citable on screen. The explanations and cost figures were
        // cross-checked across multiple independent automotive-reference
        // sources tonight, 2026-08-05 — the underlying facts (rapid
        // clicking indicating low battery power reaching the starter
        // relay but not the starter motor; a single click pointing more
        // toward the starter/starter relay; no crank/no sound pointing to
        // battery, connections, or an immobilizer; fuel delivery vs.
        // ignition being the two general causes of cranks-but-no-start)
        // are well-known, independently corroborated automotive
        // knowledge, not proprietary to any one site.
        record(
            id: "phase1.starting.electrical",
            family: .roughRunningStallingOrPostService,
            observations: [.startingOrRunningTrouble, .warningLightOrMessage],
            required: [
                .observation(.startingOrRunningTrouble),
                .startingAnswer(key: IncidentStartingAnswerKey.crankBehavior, value: "I’m not sure")
            ],
            // Deliberately NOT including .observation(.startingOrRunningTrouble)
            // in support (unlike every other record's "I'm not sure" base
            // above it) — see the matching note on phase1.starting.fuel-
            // ignition below. Both structured starting questions are asked
            // back-to-back regardless of each other's answer, so a person
            // reporting the cranks-but-won't-start scenario (Part 2) has no
            // real option for crankBehavior and must pick "I'm not sure"
            // here while giving a real crankClues answer. Counting the
            // shared observation signal in both this record's support and
            // phase1.starting.fuel-ignition.no-unusual-clue's support made
            // them score identically (5) whenever that happened, and the
            // generic record won the tie purely because "electrical" sorts
            // before "fuel-ignition" alphabetically — not because it was
            // more specific. Dropping this one entry brings the generic
            // fallback's score to 3 (still >= minimumScore 3, so it still
            // qualifies on its own) while any specific-answer record stays
            // at 5, so a real answer on the other question always wins.
            support: [
                .startingAnswer(key: IncidentStartingAnswerKey.crankBehavior, value: "I’m not sure"),
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
            id: "phase1.starting.electrical.rapid-clicking",
            family: .roughRunningStallingOrPostService,
            observations: [.startingOrRunningTrouble],
            required: [
                .observation(.startingOrRunningTrouble),
                .startingAnswer(key: IncidentStartingAnswerKey.crankBehavior, value: "Rapid clicking")
            ],
            support: [
                .observation(.startingOrRunningTrouble),
                .startingAnswer(key: IncidentStartingAnswerKey.crankBehavior, value: "Rapid clicking")
            ],
            contradict: [],
            area: .startingAndElectrical,
            explanation: "Rapid clicking most often means the battery doesn't have enough power to turn the starter motor, even though there's enough for the starter relay to click. This is the single most common cause of this exact sound. The alternator is the least likely of the three — it's more relevant if the battery keeps dying repeatedly or dies while driving, rather than a one-time rapid-click.",
            action: .professionalInspection,
            questions: [
                "Is the battery original, or has it been replaced recently?",
                "Are the battery terminals clean, tight, and free of corrosion?"
            ],
            verificationState: .reviewedGeneralPrinciple,
            contentState: .verifiedGeneralAutomotivePrinciple,
            sourceReferences: [
                IncidentGuidanceSourceReference(
                    id: "openhood-reviewed-starting-rapid-clicking-guidance",
                    title: "OpenHood, \"Reviewed General Automotive Guidance — Rapid Clicking When Starting\"",
                    location: nil,
                    isPlaceholder: false
                )
            ],
            possibleAreaTerms: [
                IncidentPossibleAreaTerm(
                    id: "battery",
                    name: "Battery",
                    plainExplanation: "The battery may be too weak or discharged to turn the starter motor, even though it can still power the smaller starter relay.",
                    typicalCostRange: "Roughly $150–$400"
                ),
                IncidentPossibleAreaTerm(
                    id: "battery-terminals-or-cables",
                    name: "Battery terminals or cables",
                    plainExplanation: "Loose, corroded, or damaged connections can limit how much power reaches the starter, even from a good battery.",
                    typicalCostRange: "Roughly $20–$150"
                ),
                IncidentPossibleAreaTerm(
                    id: "alternator",
                    name: "Alternator",
                    plainExplanation: "If the battery keeps dying, the alternator may not be recharging it while driving.",
                    typicalCostRange: "Roughly $400–$900"
                )
            ],
            repairSearchTerm: "battery replacement"
        ),
        record(
            id: "phase1.starting.electrical.single-click",
            family: .roughRunningStallingOrPostService,
            observations: [.startingOrRunningTrouble],
            required: [
                .observation(.startingOrRunningTrouble),
                .startingAnswer(key: IncidentStartingAnswerKey.crankBehavior, value: "One single click")
            ],
            support: [
                .observation(.startingOrRunningTrouble),
                .startingAnswer(key: IncidentStartingAnswerKey.crankBehavior, value: "One single click")
            ],
            contradict: [],
            area: .startingAndElectrical,
            explanation: "A single click more often points to the starter itself or the starter relay, rather than the battery.",
            action: .professionalInspection,
            questions: [
                "Has a jump start been tried, and did that change anything?",
                "Is the battery original, or has it been replaced recently?"
            ],
            verificationState: .reviewedGeneralPrinciple,
            contentState: .verifiedGeneralAutomotivePrinciple,
            sourceReferences: [
                IncidentGuidanceSourceReference(
                    id: "openhood-reviewed-starting-single-click-guidance",
                    title: "OpenHood, \"Reviewed General Automotive Guidance — Single Click When Starting\"",
                    location: nil,
                    isPlaceholder: false
                )
            ],
            possibleAreaTerms: [
                IncidentPossibleAreaTerm(
                    id: "starter",
                    name: "Starter",
                    plainExplanation: "A worn or failing starter motor can produce a single click without turning the engine over.",
                    typicalCostRange: "Roughly $400–$800"
                ),
                IncidentPossibleAreaTerm(
                    id: "starter-relay-or-fuse",
                    name: "Starter relay or fuse",
                    plainExplanation: "A failed relay or blown fuse can prevent the starter from receiving the signal to engage, often producing just one click.",
                    typicalCostRange: "Roughly $20–$200"
                ),
                IncidentPossibleAreaTerm(
                    id: "battery",
                    name: "Battery",
                    plainExplanation: "Still worth ruling out first — a jump start is a fast way to tell whether the battery is the cause.",
                    typicalCostRange: "Roughly $150–$400"
                )
            ],
            repairSearchTerm: "starter replacement"
        ),
        record(
            id: "phase1.starting.electrical.no-sound",
            family: .roughRunningStallingOrPostService,
            observations: [.startingOrRunningTrouble],
            required: [
                .observation(.startingOrRunningTrouble),
                .startingAnswer(key: IncidentStartingAnswerKey.crankBehavior, value: "No sound at all")
            ],
            support: [
                .observation(.startingOrRunningTrouble),
                .startingAnswer(key: IncidentStartingAnswerKey.crankBehavior, value: "No sound at all")
            ],
            contradict: [],
            area: .startingAndElectrical,
            explanation: "No sound at all often points to a dead battery, a poor connection, or in some vehicles an immobilizer or security-system issue. Check for dash lights or interior lights responding at all as a first clue.",
            action: .professionalInspection,
            questions: [
                "Do the dash lights or interior lights respond at all?",
                "Are the battery terminals clean, tight, and free of corrosion?"
            ],
            verificationState: .reviewedGeneralPrinciple,
            contentState: .verifiedGeneralAutomotivePrinciple,
            sourceReferences: [
                IncidentGuidanceSourceReference(
                    id: "openhood-reviewed-starting-no-sound-guidance",
                    title: "OpenHood, \"Reviewed General Automotive Guidance — No Sound When Starting\"",
                    location: nil,
                    isPlaceholder: false
                )
            ],
            possibleAreaTerms: [
                IncidentPossibleAreaTerm(
                    id: "battery",
                    name: "Battery",
                    plainExplanation: "A fully dead battery may not power anything at all, including the starter relay.",
                    typicalCostRange: "Roughly $150–$400"
                ),
                IncidentPossibleAreaTerm(
                    id: "battery-terminals-or-cables",
                    name: "Battery terminals or cables",
                    plainExplanation: "A loose or fully disconnected terminal can cut power entirely, even with a good battery.",
                    typicalCostRange: "Roughly $20–$150"
                ),
                IncidentPossibleAreaTerm(
                    id: "ignition-switch-or-immobilizer",
                    name: "Ignition switch or immobilizer system",
                    plainExplanation: "On some vehicles, a security or immobilizer fault can prevent the starting system from engaging at all.",
                    typicalCostRange: "Varies significantly — worth a professional diagnosis before estimating"
                )
            ],
            repairSearchTerm: "no start diagnosis"
        ),
        record(
            id: "phase1.starting.electrical.slow-crank",
            family: .roughRunningStallingOrPostService,
            observations: [.startingOrRunningTrouble],
            required: [
                .observation(.startingOrRunningTrouble),
                .startingAnswer(key: IncidentStartingAnswerKey.crankBehavior, value: "Cranks slowly then stops")
            ],
            support: [
                .observation(.startingOrRunningTrouble),
                .startingAnswer(key: IncidentStartingAnswerKey.crankBehavior, value: "Cranks slowly then stops")
            ],
            contradict: [],
            area: .startingAndElectrical,
            explanation: "A slow crank that gives up usually means the battery has some charge but not enough, or a poor connection is limiting how much power reaches the starter.",
            action: .professionalInspection,
            questions: [
                "Is the battery original, or has it been replaced recently?",
                "Are the battery terminals and grounds clean and tight?"
            ],
            verificationState: .reviewedGeneralPrinciple,
            contentState: .verifiedGeneralAutomotivePrinciple,
            sourceReferences: [
                IncidentGuidanceSourceReference(
                    id: "openhood-reviewed-starting-slow-crank-guidance",
                    title: "OpenHood, \"Reviewed General Automotive Guidance — Slow Crank When Starting\"",
                    location: nil,
                    isPlaceholder: false
                )
            ],
            possibleAreaTerms: [
                IncidentPossibleAreaTerm(
                    id: "battery",
                    name: "Battery",
                    plainExplanation: "A partially charged or weakening battery can turn the starter slowly but not consistently.",
                    typicalCostRange: "Roughly $150–$400"
                ),
                IncidentPossibleAreaTerm(
                    id: "battery-terminals-or-cables-grounds",
                    name: "Battery terminals or cables, including grounds",
                    plainExplanation: "A poor connection anywhere in the starting circuit, including ground straps, can limit power reaching the starter.",
                    typicalCostRange: "Roughly $20–$150"
                ),
                IncidentPossibleAreaTerm(
                    id: "starter",
                    name: "Starter",
                    plainExplanation: "A worn starter motor can struggle to turn the engine even with adequate battery power.",
                    typicalCostRange: "Roughly $400–$800"
                )
            ],
            repairSearchTerm: "starter replacement"
        ),
        // Same tier as phase1.starting.electrical.* above. Support
        // deliberately omits .observation(.startingOrRunningTrouble) for
        // the same tie-breaking reason documented on phase1.starting.
        // electrical's own "I'm not sure" base record above — keeps this
        // generic fallback's score at 3 (vs. 5 for any specific-answer
        // record) so a real crankBehavior answer on the other question
        // always outranks this one instead of an alphabetical accident.
        record(
            id: "phase1.starting.fuel-ignition",
            family: .roughRunningStallingOrPostService,
            observations: [.startingOrRunningTrouble],
            required: [
                .observation(.startingOrRunningTrouble),
                .startingAnswer(key: IncidentStartingAnswerKey.crankClues, value: "I’m not sure")
            ],
            support: [
                .startingAnswer(key: IncidentStartingAnswerKey.crankClues, value: "I’m not sure"),
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
            id: "phase1.starting.fuel-ignition.no-unusual-clue",
            family: .roughRunningStallingOrPostService,
            observations: [.startingOrRunningTrouble],
            required: [
                .observation(.startingOrRunningTrouble),
                .startingAnswer(key: IncidentStartingAnswerKey.crankClues, value: "No unusual smell or sound")
            ],
            support: [
                .observation(.startingOrRunningTrouble),
                .startingAnswer(key: IncidentStartingAnswerKey.crankClues, value: "No unusual smell or sound")
            ],
            contradict: [],
            area: .fuelAndIgnition,
            explanation: "When the engine cranks normally but doesn't catch, with nothing unusual noticed, the two most common general causes are the fuel system not delivering fuel or the ignition system not producing spark. Both need a proper diagnostic to tell apart.",
            action: .obtainCodeScan,
            questions: [
                "Is there a warning message or stored diagnostic code?",
                "When was the fuel filter or spark plugs last replaced?"
            ],
            verificationState: .reviewedGeneralPrinciple,
            contentState: .verifiedGeneralAutomotivePrinciple,
            sourceReferences: [
                IncidentGuidanceSourceReference(
                    id: "openhood-reviewed-cranks-no-clue-guidance",
                    title: "OpenHood, \"Reviewed General Automotive Guidance — Cranks But Won't Start, No Unusual Clue\"",
                    location: nil,
                    isPlaceholder: false
                )
            ],
            possibleAreaTerms: [
                IncidentPossibleAreaTerm(
                    id: "fuel-pump",
                    name: "Fuel pump",
                    plainExplanation: "A failed or weak fuel pump can leave the engine without enough fuel pressure to start.",
                    typicalCostRange: "Roughly $500–$1,200 — cost depends heavily on whether the pump is easy to access or requires dropping the fuel tank"
                ),
                IncidentPossibleAreaTerm(
                    id: "ignition-coil",
                    name: "Ignition coil",
                    plainExplanation: "A failed ignition coil can prevent spark from reaching one or more cylinders.",
                    typicalCostRange: "Roughly $200–$300"
                ),
                IncidentPossibleAreaTerm(
                    id: "spark-plugs",
                    name: "Spark plugs",
                    plainExplanation: "Worn or fouled spark plugs may not be able to ignite the fuel mixture.",
                    typicalCostRange: "Roughly $100–$300 for a full set"
                ),
                IncidentPossibleAreaTerm(
                    id: "fuel-filter",
                    name: "Fuel filter",
                    plainExplanation: "A clogged fuel filter can restrict fuel flow enough to prevent starting.",
                    typicalCostRange: "Roughly $100–$300"
                )
            ],
            repairSearchTerm: "no start diagnostic"
        ),
        record(
            id: "phase1.starting.fuel-ignition.cold-start",
            family: .roughRunningStallingOrPostService,
            observations: [.startingOrRunningTrouble],
            required: [
                .observation(.startingOrRunningTrouble),
                .startingAnswer(key: IncidentStartingAnswerKey.crankClues, value: "Cranks slower or takes longer to start in cold weather")
            ],
            support: [
                .observation(.startingOrRunningTrouble),
                .startingAnswer(key: IncidentStartingAnswerKey.crankClues, value: "Cranks slower or takes longer to start in cold weather")
            ],
            contradict: [],
            area: .fuelAndIgnition,
            explanation: "In cold weather, a battery loses a significant portion of its cranking power — enough that a battery that works fine in warm weather can struggle or fail below freezing. Thickened engine oil in cold temperatures adds to the strain. If the car starts fine once it warms up but struggles every cold morning, the battery is the most common cause and worth checking first.",
            action: .obtainCodeScan,
            questions: [
                "Does it start fine once the weather warms up, or is this happening in mild weather too?",
                "How old is the battery, and has it needed a jump start recently?"
            ],
            verificationState: .reviewedGeneralPrinciple,
            contentState: .verifiedGeneralAutomotivePrinciple,
            sourceReferences: [
                IncidentGuidanceSourceReference(
                    id: "openhood-reviewed-cold-weather-starting-guidance",
                    title: "OpenHood, \"Reviewed General Automotive Guidance — Cold Weather Starting Difficulty\"",
                    location: nil,
                    isPlaceholder: false
                )
            ],
            possibleAreaTerms: [
                IncidentPossibleAreaTerm(
                    id: "battery",
                    name: "Battery",
                    plainExplanation: "A battery that's aging or already marginal can lose enough cold-weather power to fail a cold start, even if it still starts the car in warm weather.",
                    typicalCostRange: "Roughly $150–$400"
                ),
                IncidentPossibleAreaTerm(
                    id: "battery-terminals-or-connections",
                    name: "Battery terminals or connections",
                    plainExplanation: "Corrosion or a loose connection at the battery terminals reduces the power actually reaching the starter, which shows up worse in cold weather.",
                    typicalCostRange: "Often free to inspect; cleaning terminals typically under $50 if no parts are needed"
                ),
                IncidentPossibleAreaTerm(
                    id: "engine-oil-viscosity",
                    name: "Engine oil viscosity",
                    plainExplanation: "The wrong-weight oil for the climate thickens more in cold temperatures, making the engine harder to turn over.",
                    typicalCostRange: nil
                )
            ],
            repairSearchTerm: "cold weather no start diagnostic"
        ),
        record(
            id: "phase1.starting.fuel-ignition.fuel-smell",
            family: .roughRunningStallingOrPostService,
            observations: [.startingOrRunningTrouble],
            required: [
                .observation(.startingOrRunningTrouble),
                .startingAnswer(key: IncidentStartingAnswerKey.crankClues, value: "Smell of gas/fuel while trying to start")
            ],
            support: [
                .observation(.startingOrRunningTrouble),
                .startingAnswer(key: IncidentStartingAnswerKey.crankClues, value: "Smell of gas/fuel while trying to start")
            ],
            contradict: [],
            area: .fuelAndIgnition,
            explanation: "A fuel smell during a failed start attempt can mean the engine is getting fuel but not igniting it, or that it's flooded from repeated attempts. Give it a few minutes before trying again rather than repeatedly cranking.",
            action: .obtainCodeScan,
            avoid: [
                "Do not keep repeatedly cranking the engine.",
                "Do not touch hot or moving components or go under an unsupported vehicle."
            ],
            questions: [
                "How many times was starting attempted before the smell was noticed?",
                "Is there a warning message or stored diagnostic code?"
            ],
            verificationState: .reviewedGeneralPrinciple,
            contentState: .verifiedGeneralAutomotivePrinciple,
            sourceReferences: [
                IncidentGuidanceSourceReference(
                    id: "openhood-reviewed-cranks-fuel-smell-guidance",
                    title: "OpenHood, \"Reviewed General Automotive Guidance — Fuel Smell While Cranking\"",
                    location: nil,
                    isPlaceholder: false
                )
            ],
            possibleAreaTerms: [
                IncidentPossibleAreaTerm(
                    id: "ignition-coil",
                    name: "Ignition coil",
                    plainExplanation: "A failed ignition coil can prevent spark, leaving unburned fuel to be smelled.",
                    typicalCostRange: "Roughly $200–$300"
                ),
                IncidentPossibleAreaTerm(
                    id: "spark-plugs",
                    name: "Spark plugs",
                    plainExplanation: "Worn or fouled spark plugs may not ignite the fuel-air mixture, leaving unburned fuel behind.",
                    typicalCostRange: "Roughly $100–$300 for a full set"
                ),
                IncidentPossibleAreaTerm(
                    id: "fuel-injector",
                    name: "Fuel injector",
                    plainExplanation: "A stuck-open or leaking injector can deliver too much fuel during starting attempts.",
                    typicalCostRange: "Roughly $150–$600 per injector — direct-injection engines cost more than older port-injection engines"
                )
            ],
            repairSearchTerm: "no start diagnostic"
        ),
        record(
            id: "phase1.starting.fuel-ignition.ticking-sound",
            family: .roughRunningStallingOrPostService,
            observations: [.startingOrRunningTrouble],
            required: [
                .observation(.startingOrRunningTrouble),
                .startingAnswer(key: IncidentStartingAnswerKey.crankClues, value: "A clicking or ticking sound from the engine while cranking")
            ],
            support: [
                .observation(.startingOrRunningTrouble),
                .startingAnswer(key: IncidentStartingAnswerKey.crankClues, value: "A clicking or ticking sound from the engine while cranking")
            ],
            contradict: [],
            area: .fuelAndIgnition,
            explanation: "This is a different sound than the starter clicking covered elsewhere — a ticking from the engine itself while it cranks is worth having inspected before repeated attempts.",
            action: .professionalInspection,
            questions: [
                "Is the ticking coming from the top of the engine or lower down?",
                "Does it continue if the engine briefly starts and stalls?"
            ],
            verificationState: .reviewedGeneralPrinciple,
            contentState: .verifiedGeneralAutomotivePrinciple,
            sourceReferences: [
                IncidentGuidanceSourceReference(
                    id: "openhood-reviewed-cranks-ticking-guidance",
                    title: "OpenHood, \"Reviewed General Automotive Guidance — Ticking Sound From the Engine While Cranking\"",
                    location: nil,
                    isPlaceholder: false
                )
            ],
            repairSearchTerm: "no start diagnostic"
        ),
        record(
            id: "phase1.starting.fuel-ignition.check-engine-light",
            family: .roughRunningStallingOrPostService,
            observations: [.startingOrRunningTrouble],
            required: [
                .observation(.startingOrRunningTrouble),
                .startingAnswer(key: IncidentStartingAnswerKey.crankClues, value: "A recent check-engine light before this happened")
            ],
            support: [
                .observation(.startingOrRunningTrouble),
                .startingAnswer(key: IncidentStartingAnswerKey.crankClues, value: "A recent check-engine light before this happened")
            ],
            contradict: [],
            area: .fuelAndIgnition,
            explanation: "A check-engine light shortly before a no-start can be a real clue pointing toward the same system that triggered it.",
            action: .obtainCodeScan,
            questions: [
                "Was a diagnostic code recorded before the light was cleared, if it was cleared?",
                "How long before this did the light first appear?"
            ],
            verificationState: .reviewedGeneralPrinciple,
            contentState: .verifiedGeneralAutomotivePrinciple,
            sourceReferences: [
                IncidentGuidanceSourceReference(
                    id: "openhood-reviewed-cranks-check-engine-guidance",
                    title: "OpenHood, \"Reviewed General Automotive Guidance — Recent Check-Engine Light Before a No-Start\"",
                    location: nil,
                    isPlaceholder: false
                )
            ],
            possibleAreaTerms: [
                IncidentPossibleAreaTerm(
                    id: "ignition-coil",
                    name: "Ignition coil",
                    plainExplanation: "A failing ignition coil can trigger a check-engine light before eventually preventing a start.",
                    typicalCostRange: "Roughly $200–$300"
                ),
                IncidentPossibleAreaTerm(
                    id: "fuel-pump",
                    name: "Fuel pump",
                    plainExplanation: "A weakening fuel pump can trigger a check-engine light before it fails to deliver enough fuel to start.",
                    typicalCostRange: "Roughly $500–$1,200 — cost depends heavily on whether the pump is easy to access or requires dropping the fuel tank"
                )
            ],
            repairSearchTerm: "no start diagnostic"
        ),
        // Same tier as phase1.starting.electrical/phase1.starting.fuel-
        // ignition above — reviewed general-guidance content, not
        // needsVerification placeholders, gated on a structured answer
        // (IncidentStartingAnswerKey.transmissionBehavior, asked in
        // SomethingHappenedView.startingQuestions) rather than free-text
        // description matching.
        //
        // Severity note, read carefully before touching this section:
        // only "Shifting feels harsh or delayed..." and "I'm not sure"
        // have records below. "The engine revs up but the car doesn't
        // speed up... (slipping)" and "A burning smell..." are DELIBERATELY
        // UNHANDLED — real guidance is consistent that both mean stop
        // driving as soon as it's safely possible (loss of reliable power
        // delivery; already-degraded fluid risking complete failure), not
        // a SERVICE-SOON-tier Phase 1 result, the same severity tier this
        // Phase 1 engine already can't represent (ordinaryDriveRecommendation
        // only ever returns SERVICE SOON, CHECK BEFORE DRIVING, or
        // MONITOR — no path to STOP DRIVING).
        //
        // Every prior severity fix this session (cooling, oil-pressure,
        // odor, temperature warning light, ABS/brakes) closed this same
        // kind of gap by escalating into one of the app's existing 7
        // IncidentSafetySelection categories via escalateToUrgentSafety.
        // This one is different: none of the 7 fit without asking a
        // misleading follow-up question. Checked each category's actual
        // urgentQuestions wording (not just its name), specifically
        // against "engine revs fine but the car won't accelerate" (no
        // smell, no fire, no coolant/temperature sign, no brake/steering
        // symptom, engine keeps running normally) and "burning smell
        // after stop-and-go/towing":
        //   - .smokeOrFire: first question assumes an active flame right
        //     now ("Is there an active flame? Answer only from a safe
        //     distance.") — wrong premise for a smell with no fire, and
        //     entirely wrong for slipping (no smoke/smell at all).
        //   - .strongFuelSmell: first question forces a fuel-oriented
        //     description (Gasoline/Burning oil/Sweet or coolant-like/
        //     Electrical or plastic/Exhaust) under a "strong fuel smell"
        //     framing — mischaracterizes a transmission-fluid smell as a
        //     fuel leak, and doesn't apply at all to slipping (no smell).
        //   - .overheatingOrSteam: first question asks whether "the gauge
        //     or warning indicate[d] overheating" — most vehicles have no
        //     transmission-temperature gauge, so this forces a coolant/
        //     engine-temperature framing that doesn't fit either symptom.
        //   - .flashingWarningLight: first question assumes a specific
        //     dashboard light flashed (Check engine/Oil pressure/
        //     Temperature/Brake/Charging/Tire pressure) — many transmission
        //     slips or burning smells present with no dashboard light at
        //     all, so this forces a false premise.
        //   - .unsafeBrakesOrSteering: the closest guess by theme (loss of
        //     reliable vehicle control), but its first question forces
        //     "What is the main concern? Braking / Steering / Both / I'm
        //     not sure" — slipping is neither a braking nor a steering
        //     symptom (the brakes and steering both work normally; the
        //     problem is the engine not transferring power to the wheels),
        //     so answering this question honestly means picking "I'm not
        //     sure" for a question that does apply to the person's car,
        //     just not to their problem — a misleading fit, not a clean
        //     one, despite the surface-level "loss of control" similarity.
        //   - .engineWillNotStayRunning: first question ("What happens
        //     when it runs? Starts and immediately stops/Idles roughly/
        //     Shakes or misfires/Stalls when placed in gear") is about the
        //     ENGINE stalling or misfiring — but transmission slipping is
        //     specifically the engine running fine while the car doesn't
        //     accelerate, the opposite premise.
        //   - .noneOfThese: not an urgent category at all (routine path),
        //     so it can't produce the required stop-driving-tier result
        //     regardless of fit.
        // Conclusion: no existing category fits both dangerous answers
        // without a misleading premise. Per instruction, this is left
        // unwired rather than forced — selecting either answer currently
        // falls through to an ordinary Phase 1 result (typically SERVICE
        // SOON, forced by the .startingOrRunningTrouble observation floor
        // in ordinaryDriveRecommendation, generally with no record
        // actually matching that specific answer) instead of the correct
        // stop-driving treatment. This is a known, called-out gap — not
        // an oversight — pending a product decision on whether a new
        // IncidentSafetySelection category is needed for "transmission
        // failing under load" specifically.
        //
        // sourceReferences below are attributed to OpenHood, not to the
        // specific outlets consulted, for the same reason given above the
        // suspension-noise record: a source being public doesn't make it
        // citable on screen. The explanation and cost figures were
        // cross-checked across multiple independent automotive-reference
        // sources tonight, 2026-08-05 — the underlying facts (harsh/
        // delayed shifts pointing to fluid condition or a shift solenoid;
        // slipping and burning smell both being stop-driving-tier
        // symptoms rather than routine service items) are well-known,
        // independently corroborated automotive knowledge, not
        // proprietary to any one site.
        record(
            id: "phase1.transmission.harsh-shifting",
            family: .roughRunningStallingOrPostService,
            observations: [.startingOrRunningTrouble],
            required: [
                .observation(.startingOrRunningTrouble),
                .startingAnswer(key: IncidentStartingAnswerKey.transmissionBehavior, value: "Shifting feels harsh or delayed, but the car drives normally otherwise")
            ],
            support: [
                .observation(.startingOrRunningTrouble),
                .startingAnswer(key: IncidentStartingAnswerKey.transmissionBehavior, value: "Shifting feels harsh or delayed, but the car drives normally otherwise")
            ],
            contradict: [],
            area: .mechanicalOrCompression,
            explanation: "Harsh or delayed shifts on their own, with no burning smell and no loss of power, most often point to low or worn transmission fluid, or a shift solenoid that's starting to fail. This is worth having checked soon, but it's not an immediate driving hazard by itself.",
            action: .professionalInspection,
            questions: [
                "When was the transmission fluid last checked or changed?",
                "Does the delay happen more when the transmission is cold, or all the time?"
            ],
            verificationState: .reviewedGeneralPrinciple,
            contentState: .verifiedGeneralAutomotivePrinciple,
            sourceReferences: [
                IncidentGuidanceSourceReference(
                    id: "openhood-reviewed-transmission-harsh-shifting-guidance",
                    title: "OpenHood, \"Reviewed General Automotive Guidance — Harsh or Delayed Shifting\"",
                    location: nil,
                    isPlaceholder: false
                )
            ],
            possibleAreaTerms: [
                IncidentPossibleAreaTerm(
                    id: "transmission-fluid",
                    name: "Transmission fluid level or condition",
                    plainExplanation: "Low or worn transmission fluid is one of the most common, cheapest causes of harsh or delayed shifting.",
                    typicalCostRange: "Roughly $80–$250 for a standard service"
                ),
                IncidentPossibleAreaTerm(
                    id: "shift-solenoid",
                    name: "Shift solenoid",
                    plainExplanation: "A shift solenoid controls fluid flow that triggers each gear change. A failing one can cause harsh or delayed shifts.",
                    typicalCostRange: "Roughly $150–$1,500 — cost rises sharply if the full solenoid pack needs replacing rather than a single unit"
                )
            ],
            repairSearchTerm: "transmission fluid service and diagnostic"
        ),
        record(
            id: "phase1.transmission",
            family: .roughRunningStallingOrPostService,
            observations: [.startingOrRunningTrouble],
            required: [
                .observation(.startingOrRunningTrouble),
                .startingAnswer(key: IncidentStartingAnswerKey.transmissionBehavior, value: "I’m not sure")
            ],
            support: [
                .observation(.startingOrRunningTrouble),
                .startingAnswer(key: IncidentStartingAnswerKey.transmissionBehavior, value: "I’m not sure")
            ],
            contradict: [],
            area: .mechanicalOrCompression,
            explanation: "Transmission symptoms can range from a simple fluid or solenoid issue to something more serious. If you notice the engine revving without the car speeding up, or a burning smell, treat that as more serious and stop driving as soon as it's safely possible — otherwise, this is worth a professional inspection to narrow down.",
            action: .professionalInspection,
            questions: [
                "Does the car drive normally otherwise, or has power delivery changed too?",
                "Is there any unusual smell, especially after stop-and-go driving or towing?"
            ],
            verificationState: .reviewedGeneralPrinciple,
            contentState: .verifiedGeneralAutomotivePrinciple,
            sourceReferences: [
                IncidentGuidanceSourceReference(
                    id: "openhood-reviewed-transmission-general-guidance",
                    title: "OpenHood, \"Reviewed General Automotive Guidance — Transmission Behavior, Not Yet Narrowed Down\"",
                    location: nil,
                    isPlaceholder: false
                )
            ]
        ),
        // OH-UIK gap fix (same tier as the odor-escalation and
        // oil-pressure severity fixes): phase1.cooling.temperature-control
        // used to live here as a free-text-matched placeholder
        // ("temperature, steam, or boiling-coolant observations...") that
        // could resolve to an ordinary Phase 1 result (SERVICE SOON at
        // best, via ordinaryDriveRecommendation, which has no path to DO
        // NOT RESTART). Unlike the odor and warning-light placeholders
        // upgraded elsewhere in this file, there is no safe subset of an
        // active overheating report — a gauge in the red, steam, or
        // boiling coolant is always a stop-driving-level situation, and
        // the app already has real, cited urgent guidance for exactly
        // this (IncidentSafetySelection.overheatingOrSteam, which
        // unconditionally returns DO NOT RESTART — see
        // urgentDriveRecommendation). So instead of upgrading this record
        // with reviewed content the way phase1.starting.* was above, it
        // was removed entirely, and the "Temperature warning light"
        // answer to the warningQuestions light-identification question
        // now escalates directly into the urgent .overheatingOrSteam path
        // (see temperatureObservationEscalation/escalateToUrgentSafety in
        // SomethingHappenedView.swift) — mirroring exactly how
        // "Electrical or burning plastic"/"Exhaust" escalate out of the
        // fluid odor question via dangerousOdorEscalation, rather than
        // inventing a new severity mechanism. No record with this id
        // computes an ordinary result anymore; removing it (not just
        // leaving it unreachable) also closes the free-text
        // descriptionContains fallback that let a typed "overheating"
        // description alone produce the old capped SERVICE SOON result.
        //
        // Known scope gap, intentionally not addressed in this pass: a
        // user who notices steam/vapor but never checks "A warning light
        // or message" as an observation (only "Something visible") will
        // not reach this escalation today, since gating it broadly on
        // .visible would force every unrelated visible-fluid report (a
        // red transmission leak, for example) through this same
        // all-answers-escalate question. Closing that gap needs its own
        // dedicated visible-observation branch, not a broad gate here.
        //
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
                    typicalCostRange: "Roughly $150–$580 — luxury vehicles run higher"
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
                    typicalCostRange: "Roughly $150–$400"
                ),
                IncidentPossibleAreaTerm(
                    id: "alternator",
                    name: "Alternator",
                    plainExplanation: "The alternator recharges the battery while the engine runs. When it fails, the battery drains even while driving.",
                    typicalCostRange: "Roughly $400–$900"
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
        record(
            id: "phase1.warning.tire-pressure-light",
            family: .warningLightOrMessage,
            observations: [.warningLightOrMessage],
            required: [
                .observation(.warningLightOrMessage),
                .warningAnswer(key: IncidentWarningAnswerKey.light, value: "Tire pressure light")
            ],
            support: [
                .observation(.warningLightOrMessage),
                .warningAnswer(key: IncidentWarningAnswerKey.light, value: "Tire pressure light")
            ],
            contradict: [],
            area: .tiresWheelsAndPressure,
            explanation: "A tire pressure light most often means a tire is genuinely low — from a slow leak or just normal loss over time — or that a recent temperature drop lowered the pressure enough to trigger it. It's not usually an emergency, but driving on a significantly underinflated tire isn't safe, so check the actual pressure at a gas station or with a home gauge rather than guessing.",
            action: .obtainCodeScan,
            questions: [
                "Does one tire look or feel visibly low?",
                "Did the temperature drop recently?"
            ],
            verificationState: .reviewedGeneralPrinciple,
            contentState: .verifiedGeneralAutomotivePrinciple,
            sourceReferences: [
                IncidentGuidanceSourceReference(
                    id: "openhood-reviewed-tire-pressure-light-guidance",
                    title: "OpenHood, \"Reviewed General Automotive Guidance — Tire Pressure Warning Light\"",
                    location: nil,
                    isPlaceholder: false
                )
            ],
            possibleAreaTerms: [
                IncidentPossibleAreaTerm(
                    id: "low-tire-pressure",
                    name: "Low tire pressure",
                    plainExplanation: "The most common cause by far. Checking and correcting the pressure on all four tires, including the spare if the light doesn't clear, often resolves it.",
                    typicalCostRange: "Usually free at a gas station air pump; a slow leak may need a patch, roughly $15–$30"
                ),
                IncidentPossibleAreaTerm(
                    id: "temperature-related-pressure-drop",
                    name: "Temperature-related pressure drop",
                    plainExplanation: "Tire pressure drops as the temperature does. A cold morning can be enough to trigger the light even without a leak.",
                    typicalCostRange: nil
                ),
                IncidentPossibleAreaTerm(
                    id: "tpms-sensor",
                    name: "TPMS sensor",
                    plainExplanation: "Less common, but a sensor or its battery can fail over time, triggering the light even when pressure is fine.",
                    typicalCostRange: "Roughly $25–$300 per sensor — tire shops and budget retailers run cheapest, dealerships cost more"
                )
            ],
            repairSearchTerm: "tire pressure check"
        ),
        // OH-UIK "wow moment" pass, 2026-08-07 — same tier as the rotten-
        // egg-smell and vibration-while-braking records added earlier
        // tonight: reviewed general-guidance content, not a
        // needsVerification placeholder. Closes a real gap:
        // phase1.warning.tire-pressure-light (above) and
        // phase1.suspension.vibration-at-speed (below) both already
        // existed as separate records sharing the same possibleArea
        // (.tiresWheelsAndPressure) — so when both were reported
        // together, selectDistinctAreas would only ever surface one of
        // them, silently, with no acknowledgment that the two symptoms
        // reinforce each other. This record requires both signals
        // together and is scored (more supporting matches) to outrank
        // either one alone, so a user who reports both gets a single,
        // stronger, explicitly-connected result instead of one symptom's
        // content picked arbitrarily over the other's.
        //
        // The underlying fact — that a TPMS light plus a speed-dependent
        // vibration together points more specifically at one problem tire
        // (a leak, sidewall damage, or internal separation) rather than a
        // routine seasonal pressure drop or a simple wheel imbalance — is
        // well-known, independently corroborated automotive knowledge.
        // sourceReferences attributed to OpenHood, not to specific
        // outlets, for the same reason given throughout this file: a
        // source being public doesn't make it citable on screen.
        record(
            id: "phase1.tires.tpms-light-with-vibration",
            family: .warningLightOrMessage,
            observations: [.warningLightOrMessage, .sound, .vibrationOrMovement],
            required: [
                .warningAnswer(key: IncidentWarningAnswerKey.light, value: "Tire pressure light"),
                .noiseAnswer(key: IncidentNoiseAnswerKey.timing, value: "Only at speed")
            ],
            support: [
                .observation(.warningLightOrMessage),
                .observation(.sound),
                .observation(.vibrationOrMovement),
                .warningAnswer(key: IncidentWarningAnswerKey.light, value: "Tire pressure light"),
                .noiseAnswer(key: IncidentNoiseAnswerKey.timing, value: "Only at speed"),
                .noiseAnswer(key: IncidentNoiseAnswerKey.location, value: "Front"),
                .noiseAnswer(key: IncidentNoiseAnswerKey.location, value: "Rear"),
                .noiseAnswer(key: IncidentNoiseAnswerKey.location, value: "All over")
            ],
            contradict: [],
            area: .tiresWheelsAndPressure,
            explanation: "A tire pressure warning light together with a vibration that shows up mainly at highway speed is a stronger signal than either one alone. On its own, the tire pressure light is often just a seasonal pressure drop, and a highway-speed vibration alone is often just a wheel or tire balance issue — but the two together point more specifically at one tire having a real problem, such as a leak, sidewall damage, or internal separation. This combination is worth checking sooner rather than later.",
            action: .professionalInspection,
            questions: [
                "Does one specific tire look or feel visibly low, bulging, or damaged?",
                "Does the vibration come through the steering wheel, the seat/floor, or both?",
                "Has the vehicle hit a pothole or curb, or had a tire repaired recently?"
            ],
            verificationState: .reviewedGeneralPrinciple,
            contentState: .verifiedGeneralAutomotivePrinciple,
            sourceReferences: [
                IncidentGuidanceSourceReference(
                    id: "openhood-reviewed-tpms-with-vibration-guidance",
                    title: "OpenHood, \"Reviewed General Automotive Guidance — Tire Pressure Light With Speed-Related Vibration\"",
                    location: nil,
                    isPlaceholder: false
                )
            ],
            possibleAreaTerms: [
                IncidentPossibleAreaTerm(
                    id: "tire-damage-or-leak",
                    name: "Tire damage or leak",
                    plainExplanation: "A puncture, sidewall bulge, or internal belt separation can cause both a pressure warning and an out-of-round feel at speed. Worth a visual and pressure check on all four tires now, not just a top-off.",
                    typicalCostRange: "Varies — a repairable puncture is roughly $15–$30; a tire needing replacement is roughly $100–$300 or more depending on size"
                ),
                IncidentPossibleAreaTerm(
                    id: "wheel-or-tire-balance-combo",
                    name: "Wheel or tire balance",
                    plainExplanation: "Less likely than a tire problem when both signals are present together, but still possible if the tire itself checks out fine.",
                    typicalCostRange: "Roughly $15–$25 per tire, often $60–$100 for all four"
                )
            ],
            repairSearchTerm: "tire inspection and balance"
        ),
        // Same tier as phase1.warning.record-code/phase1.warning.engine-
        // information above — reviewed general-guidance content, not a
        // needsVerification placeholder, but with a real safety gate
        // in front of it, unlike those two. An ABS or traction-control
        // light on by itself is genuinely safe as ordinary Phase 1
        // content: real guidance is clear that ABS-alone means the
        // anti-lock function may not work correctly, but normal braking
        // still works. It's a different, more serious situation if the
        // regular brake warning light is on at the same time, or if the
        // answer is unconfirmed — that combination is a real
        // hydraulic-system possibility, not general content, so it
        // escalates into the existing urgent .unsafeBrakesOrSteering path
        // instead (see absTractionEscalation/escalateToUrgentSafety in
        // SomethingHappenedView.swift) rather than ever computing an
        // ordinary Phase 1 result — same mechanism as the odor and
        // cooling/temperature fixes. This record's `required` only
        // matches the safe branch (light == "ABS or traction control
        // light" AND absBrakeCheck == "No, just this one"), so the
        // dangerous branches never reach evaluate() at all.
        //
        // sourceReferences below are attributed to OpenHood, not to the
        // specific outlets consulted, for the same reason given above the
        // suspension-noise record: a source being public doesn't make it
        // citable on screen. The explanation and cost figures were
        // cross-checked across multiple independent automotive-reference
        // sources tonight, 2026-08-05 — the underlying facts (ABS-alone
        // preserving normal braking while disabling anti-lock/traction
        // control specifically; wheel speed sensors as the most common
        // cause; low brake fluid as a checkable, inexpensive first step)
        // are well-known, independently corroborated automotive
        // knowledge, not proprietary to any one site.
        record(
            id: "phase1.warning.abs-traction-alone",
            family: .warningLightOrMessage,
            observations: [.warningLightOrMessage],
            required: [
                .observation(.warningLightOrMessage),
                .warningAnswer(key: IncidentWarningAnswerKey.light, value: "ABS or traction control light"),
                .warningAnswer(key: IncidentWarningAnswerKey.absBrakeCheck, value: "No, just this one")
            ],
            support: [
                .observation(.warningLightOrMessage),
                .warningAnswer(key: IncidentWarningAnswerKey.light, value: "ABS or traction control light"),
                .warningAnswer(key: IncidentWarningAnswerKey.absBrakeCheck, value: "No, just this one")
            ],
            contradict: [],
            area: .brakesAndSteering,
            explanation: "When the ABS or traction-control light is on by itself, with the regular brake warning light off and the pedal feeling normal, your regular brakes should still work — you're most likely missing the anti-lock or traction-control function specifically, not losing braking entirely. It's still worth having inspected soon, and it's worth being more cautious in rain or snow in the meantime since anti-lock may not be available.",
            action: .professionalInspection,
            questions: [
                "Has this light been on continuously, or does it come and go?",
                "Has the brake fluid level been checked recently?"
            ],
            verificationState: .reviewedGeneralPrinciple,
            contentState: .verifiedGeneralAutomotivePrinciple,
            sourceReferences: [
                IncidentGuidanceSourceReference(
                    id: "openhood-reviewed-abs-traction-alone-guidance",
                    title: "OpenHood, \"Reviewed General Automotive Guidance — ABS or Traction Control Light Alone\"",
                    location: nil,
                    isPlaceholder: false
                )
            ],
            possibleAreaTerms: [
                IncidentPossibleAreaTerm(
                    id: "wheel-speed-sensor",
                    name: "Wheel speed sensor",
                    plainExplanation: "A dirty, damaged, or failed wheel speed sensor is the most common cause of an ABS or traction-control light on its own.",
                    typicalCostRange: "Roughly $150–$500 per sensor"
                ),
                IncidentPossibleAreaTerm(
                    id: "low-brake-fluid",
                    name: "Low brake fluid",
                    plainExplanation: "A low fluid level can trigger this light. Checking it is free; topping off is inexpensive, but a level that keeps dropping points to a leak worth inspecting.",
                    typicalCostRange: "Roughly free to check, inexpensive to top off"
                ),
                IncidentPossibleAreaTerm(
                    id: "abs-module-or-fuse",
                    name: "ABS module or fuse",
                    plainExplanation: "Less common than a sensor, but a failed ABS module or blown fuse can also trigger this light.",
                    typicalCostRange: "Varies significantly — worth a professional scan before estimating"
                )
            ],
            repairSearchTerm: "ABS diagnostic"
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
                    id: "radiator-hose",
                    name: "Radiator hose",
                    plainExplanation: "A worn, split, or cracked coolant hose is one of the most common sources of a coolant leak.",
                    typicalCostRange: "Roughly $150–$450"
                ),
                IncidentPossibleAreaTerm(
                    id: "radiator",
                    name: "Radiator",
                    plainExplanation: "A cracked, corroded, or leaking radiator is a less common but significantly more expensive source of a coolant leak than a hose.",
                    typicalCostRange: "Roughly $400–$1,500, more for larger vehicles or if the AC condenser has to come out too"
                ),
                IncidentPossibleAreaTerm(
                    id: "water-pump",
                    name: "Water pump",
                    plainExplanation: "The water pump circulates coolant through the engine. A worn seal or bearing can let coolant seep out.",
                    typicalCostRange: "Roughly $500–$1,100 including labor"
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
                    typicalCostRange: "Roughly $400–$800 — this job often requires dropping the subframe or exhaust, which is why it costs more than a typical gasket job"
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
                    id: "power-steering-hose",
                    name: "Power steering hose",
                    plainExplanation: "A worn power steering hose can let reddish fluid escape, usually nearer the front.",
                    typicalCostRange: "Roughly $150–$400"
                ),
                IncidentPossibleAreaTerm(
                    id: "power-steering-rack",
                    name: "Power steering rack",
                    plainExplanation: "A leaking rack-and-pinion seal is a less common but far more expensive source of a reddish fluid leak than a hose.",
                    typicalCostRange: "Roughly $700–$2,400 — one of the more expensive common repairs, get a second opinion before authorizing"
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
        // Same tier as the other reviewed general-guidance records in this
        // file, not a needsVerification placeholder. Gated on the new
        // "What did you see?" leading question (fluidQuestions in
        // SomethingHappenedView) rather than color/odor, since a frayed
        // belt is a visual finding, not a fluid. Reuses the serpentine-
        // belt/belt-tensioner possible-area content and cost figures
        // already audited for phase1.noise.squeal-not-braking above — same
        // belt, just discovered visually instead of by sound, so no new
        // cost research needed. Cross-checked tonight, 2026-08-07 —
        // sourceReferences attributed to OpenHood for the same reason
        // given above the other reviewed records in this file: a source
        // being public doesn't make it citable on screen.
        record(
            id: "phase1.visible.frayed-belt",
            family: .fluidLeakOrUnusualSmell,
            observations: [.visible],
            required: [
                .observation(.visible),
                .fluidAnswer(key: IncidentFluidAnswerKey.whatWasVisible, value: "A frayed or damaged belt")
            ],
            support: [
                .observation(.visible),
                .fluidAnswer(key: IncidentFluidAnswerKey.whatWasVisible, value: "A frayed or damaged belt")
            ],
            contradict: [],
            area: .engineAndCombustion,
            explanation: "A visibly frayed, cracked, or damaged belt should be replaced before it fails completely — a broken serpentine belt can also take the power steering, alternator, and in some vehicles the water pump out with it.",
            action: .professionalInspection,
            questions: [
                "Is there a squealing or chirping noise along with the visible damage?",
                "Has any belt or accessory work been done recently?"
            ],
            verificationState: .reviewedGeneralPrinciple,
            contentState: .verifiedGeneralAutomotivePrinciple,
            sourceReferences: [
                IncidentGuidanceSourceReference(
                    id: "openhood-reviewed-visible-frayed-belt-guidance",
                    title: "OpenHood, \"Reviewed General Automotive Guidance — Visibly Frayed or Damaged Belt\"",
                    location: nil,
                    isPlaceholder: false
                )
            ],
            possibleAreaTerms: [
                IncidentPossibleAreaTerm(
                    id: "serpentine-belt",
                    name: "Serpentine belt",
                    plainExplanation: "The single belt that drives accessories like the alternator, power steering pump, and A/C compressor. Visible fraying or cracking means it's due for replacement.",
                    typicalCostRange: "Roughly $70–$250"
                ),
                IncidentPossibleAreaTerm(
                    id: "belt-tensioner",
                    name: "Belt tensioner",
                    plainExplanation: "Keeps the serpentine belt at the right tension. Worth checking alongside a damaged belt, since a weak tensioner can cause premature wear.",
                    typicalCostRange: "Roughly $250–$300 alone, often less if replaced along with the belt"
                )
            ],
            repairSearchTerm: "serpentine belt replacement"
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
                    id: "radiator-hose",
                    name: "Radiator hose",
                    plainExplanation: "A worn, split, or cracked coolant hose is one of the most common sources of a coolant leak.",
                    typicalCostRange: "Roughly $150–$450"
                ),
                IncidentPossibleAreaTerm(
                    id: "radiator",
                    name: "Radiator",
                    plainExplanation: "A cracked, corroded, or leaking radiator is a less common but significantly more expensive source of a coolant leak than a hose.",
                    typicalCostRange: "Roughly $400–$1,500, more for larger vehicles or if the AC condenser has to come out too"
                ),
                IncidentPossibleAreaTerm(
                    id: "water-pump",
                    name: "Water pump",
                    plainExplanation: "The water pump circulates coolant through the engine. A worn seal or bearing can let coolant seep out.",
                    typicalCostRange: "Roughly $500–$1,100 including labor"
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
                    typicalCostRange: "Roughly $20–$130 — DIY is closer to $20, a shop visit including labor is usually $60–$130"
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
        // Same tier as the odor records above — reviewed general-guidance
        // content, not a needsVerification placeholder. Closes a real gap:
        // "Rotten egg or sulfur" wasn't previously an option on the smell
        // question at all, so this smell had nowhere to route.
        record(
            id: "phase1.fluid-smell.rotten-egg",
            family: .fluidLeakOrUnusualSmell,
            observations: [.smell],
            required: [
                .observation(.smell),
                .fluidAnswer(key: IncidentFluidAnswerKey.odor, value: "Rotten egg or sulfur")
            ],
            support: [
                .observation(.smell),
                .fluidAnswer(key: IncidentFluidAnswerKey.odor, value: "Rotten egg or sulfur")
            ],
            contradict: [],
            area: .exhaustAndVentilation,
            explanation: "A rotten-egg or sulfur smell almost always points to the catalytic converter — it's normally responsible for neutralizing that smell, so its presence means the converter is failing or the engine is running richer than it should, overwhelming it. A brief version of this smell right after hard acceleration usually isn't a concern; a smell that lingers is worth having checked.",
            action: .professionalInspection,
            questions: [
                "Does the smell happen briefly after hard acceleration, or does it linger?",
                "Has the vehicle been running rough, hesitating, or using more fuel than usual?"
            ],
            verificationState: .reviewedGeneralPrinciple,
            contentState: .verifiedGeneralAutomotivePrinciple,
            sourceReferences: [
                IncidentGuidanceSourceReference(
                    id: "openhood-reviewed-rotten-egg-odor-guidance",
                    title: "OpenHood, \"Reviewed General Automotive Guidance — Rotten Egg or Sulfur Odor\"",
                    location: nil,
                    isPlaceholder: false
                )
            ],
            possibleAreaTerms: [
                IncidentPossibleAreaTerm(
                    id: "catalytic-converter",
                    name: "Catalytic converter",
                    plainExplanation: "The catalytic converter normally neutralizes sulfur compounds in exhaust. A failing converter can let that rotten-egg smell pass through.",
                    typicalCostRange: "Roughly $900–$3,500 — one of the more expensive common repairs, worth a proper diagnosis before replacing"
                ),
                IncidentPossibleAreaTerm(
                    id: "engine-running-rich",
                    name: "Engine running rich",
                    plainExplanation: "An engine burning more fuel than it should can overwhelm even a healthy catalytic converter, producing the same smell.",
                    typicalCostRange: "Varies significantly — worth a professional diagnosis before estimating"
                )
            ],
            repairSearchTerm: "catalytic converter inspection"
        ),
        // Same tier as the fluid-color/odor records above — reviewed
        // general-guidance content, not needsVerification placeholders,
        // gated on a structured answer (IncidentFluidAnswerKey.
        // exhaustSmokeColor, asked in SomethingHappenedView.fluidQuestions
        // alongside color/odor) rather than free-text description
        // matching. This is genuinely simpler than the odor/warning-light
        // splits above: all four answers are safe as SERVICE SOON-tier
        // Phase 1 content on their own, since none of them is an
        // immediate driving hazard the way active fire, carbon monoxide,
        // or oil-pressure loss are — no escalation needed here, unlike
        // "Electrical or burning plastic"/"Exhaust" on the odor question
        // above. This is for someone describing exhaust smoke color after
        // the fact or during a milder moment ("I noticed blue smoke on
        // startup"), reached through general navigation — it does not
        // change or duplicate the existing "Smoke or fire" urgent
        // category in the main safety menu, which stays the answer for
        // continuous/heavy smoke happening right now.
        //
        // sourceReferences below are attributed to OpenHood, not to the
        // specific outlets consulted, for the same reason given above the
        // suspension-noise record: a source being public doesn't make it
        // citable on screen. The explanations and cost figures were
        // cross-checked across multiple independent automotive-reference
        // sources tonight, 2026-08-05 — the underlying facts (white smoke
        // as normal cold-start condensation vs. persistent coolant-burning/
        // head-gasket signs; blue smoke as burning oil from valve seals or
        // piston rings; black smoke as a rich fuel-air mixture from an air
        // filter, sensor, or injector) are well-known, independently
        // corroborated automotive knowledge, not proprietary to any one
        // site.
        record(
            id: "phase1.exhaust-smoke",
            family: .fluidLeakOrUnusualSmell,
            observations: [.visible, .smell],
            required: [
                .fluidAnswer(key: IncidentFluidAnswerKey.exhaustSmokeColor, value: "I’m not sure")
            ],
            support: [
                .observation(.visible),
                .observation(.smell),
                .fluidAnswer(key: IncidentFluidAnswerKey.exhaustSmokeColor, value: "I’m not sure")
            ],
            contradict: [],
            area: .leaksSmokeAndOdors,
            explanation: "Exhaust smoke color is a useful clue, but without knowing the color, a direct inspection is the most reliable way to narrow down whether this involves coolant, oil, or the fuel-air mixture.",
            action: .professionalInspection,
            questions: [
                "Does the smoke happen mainly on startup, or does it continue once the engine is warm?",
                "Does it happen more at idle, or under acceleration?"
            ],
            verificationState: .reviewedGeneralPrinciple,
            contentState: .verifiedGeneralAutomotivePrinciple,
            sourceReferences: [
                IncidentGuidanceSourceReference(
                    id: "openhood-reviewed-exhaust-smoke-general-guidance",
                    title: "OpenHood, \"Reviewed General Automotive Guidance — Exhaust Smoke, Color Not Yet Identified\"",
                    location: nil,
                    isPlaceholder: false
                )
            ]
        ),
        record(
            id: "phase1.exhaust-smoke.white",
            family: .fluidLeakOrUnusualSmell,
            observations: [.visible, .smell],
            required: [
                .fluidAnswer(key: IncidentFluidAnswerKey.exhaustSmokeColor, value: "White or light gray")
            ],
            support: [
                .observation(.visible),
                .observation(.smell),
                .fluidAnswer(key: IncidentFluidAnswerKey.exhaustSmokeColor, value: "White or light gray")
            ],
            contradict: [],
            area: .cooling,
            explanation: "A small amount of white smoke on a cold morning is usually just condensation burning off and is normal — it should stop once the engine warms up. If it's thick, doesn't go away once the engine is warm, or keeps happening, it can mean coolant is getting into the engine's combustion chambers, which is worth having checked soon.",
            action: .professionalInspection,
            questions: [
                "Does the smoke go away once the engine warms up, or does it continue?",
                "Has the coolant level been checked recently?"
            ],
            verificationState: .reviewedGeneralPrinciple,
            contentState: .verifiedGeneralAutomotivePrinciple,
            sourceReferences: [
                IncidentGuidanceSourceReference(
                    id: "openhood-reviewed-exhaust-smoke-white-guidance",
                    title: "OpenHood, \"Reviewed General Automotive Guidance — White or Light Gray Exhaust Smoke\"",
                    location: nil,
                    isPlaceholder: false
                )
            ],
            possibleAreaTerms: [
                IncidentPossibleAreaTerm(
                    id: "head-gasket",
                    name: "Head gasket",
                    plainExplanation: "A blown or leaking head gasket can let coolant enter the combustion chambers, producing thick white smoke that doesn't go away once the engine is warm.",
                    typicalCostRange: "Roughly $1,000–$3,500, most of the cost is labor"
                ),
                IncidentPossibleAreaTerm(
                    id: "cracked-engine-component",
                    name: "Cracked engine component",
                    plainExplanation: "A cracked cylinder head or engine block can also let coolant reach the combustion chambers, though this is less common than a head gasket.",
                    typicalCostRange: "Varies significantly — needs professional diagnosis before estimating"
                )
            ],
            repairSearchTerm: "white exhaust smoke diagnostic"
        ),
        record(
            id: "phase1.exhaust-smoke.blue",
            family: .fluidLeakOrUnusualSmell,
            observations: [.visible, .smell],
            required: [
                .fluidAnswer(key: IncidentFluidAnswerKey.exhaustSmokeColor, value: "Blue or blue-gray")
            ],
            support: [
                .observation(.visible),
                .observation(.smell),
                .fluidAnswer(key: IncidentFluidAnswerKey.exhaustSmokeColor, value: "Blue or blue-gray")
            ],
            contradict: [],
            area: .lubricationAndOilPressure,
            explanation: "Blue or blue-gray smoke usually means the engine is burning oil, often more noticeable on startup or when accelerating. Common causes are worn valve seals or worn piston rings — both are more about age and mileage than a single sudden failure.",
            action: .professionalInspection,
            questions: [
                "Is the smoke more noticeable on startup, or during acceleration?",
                "Has oil consumption between changes increased recently?"
            ],
            verificationState: .reviewedGeneralPrinciple,
            contentState: .verifiedGeneralAutomotivePrinciple,
            sourceReferences: [
                IncidentGuidanceSourceReference(
                    id: "openhood-reviewed-exhaust-smoke-blue-guidance",
                    title: "OpenHood, \"Reviewed General Automotive Guidance — Blue or Blue-Gray Exhaust Smoke\"",
                    location: nil,
                    isPlaceholder: false
                )
            ],
            possibleAreaTerms: [
                IncidentPossibleAreaTerm(
                    id: "valve-seals",
                    name: "Valve seals",
                    plainExplanation: "Worn valve seals can let oil seep into the combustion chambers, often more noticeable as smoke on startup.",
                    typicalCostRange: "Roughly $700–$2,000"
                ),
                IncidentPossibleAreaTerm(
                    id: "piston-rings",
                    name: "Piston rings",
                    plainExplanation: "Worn piston rings can let oil past into the combustion chambers, often more noticeable under acceleration. This is a much bigger job than valve seals — professional diagnosis first is worth it before assuming this is the cause.",
                    typicalCostRange: "Roughly $2,000–$3,000"
                )
            ],
            repairSearchTerm: "blue exhaust smoke diagnostic"
        ),
        record(
            id: "phase1.exhaust-smoke.black",
            family: .fluidLeakOrUnusualSmell,
            observations: [.visible, .smell],
            required: [
                .fluidAnswer(key: IncidentFluidAnswerKey.exhaustSmokeColor, value: "Black")
            ],
            support: [
                .observation(.visible),
                .observation(.smell),
                .fluidAnswer(key: IncidentFluidAnswerKey.exhaustSmokeColor, value: "Black")
            ],
            contradict: [],
            area: .intakeAndAirMeasurement,
            explanation: "Black smoke usually means the engine is burning too much fuel relative to air — more fuel is going in than is being properly burned. Common general causes include a clogged air filter, a failing sensor that's misreading the air-fuel mixture, or a fuel injector issue.",
            action: .professionalInspection,
            questions: [
                "When was the air filter last replaced?",
                "Has fuel economy changed recently?"
            ],
            verificationState: .reviewedGeneralPrinciple,
            contentState: .verifiedGeneralAutomotivePrinciple,
            sourceReferences: [
                IncidentGuidanceSourceReference(
                    id: "openhood-reviewed-exhaust-smoke-black-guidance",
                    title: "OpenHood, \"Reviewed General Automotive Guidance — Black Exhaust Smoke\"",
                    location: nil,
                    isPlaceholder: false
                )
            ],
            possibleAreaTerms: [
                IncidentPossibleAreaTerm(
                    id: "air-filter",
                    name: "Air filter",
                    plainExplanation: "A clogged air filter restricts airflow, making the fuel-air mixture too rich and one of the most common, cheapest causes of black smoke.",
                    typicalCostRange: "Roughly $20–$75"
                ),
                IncidentPossibleAreaTerm(
                    id: "oxygen-or-maf-sensor",
                    name: "Oxygen or mass airflow sensor",
                    plainExplanation: "A failing sensor can misreport the air-fuel mixture, causing the engine to run richer than it should.",
                    typicalCostRange: "Roughly $150–$400"
                ),
                IncidentPossibleAreaTerm(
                    id: "fuel-injector",
                    name: "Fuel injector",
                    plainExplanation: "A stuck-open or leaking injector can deliver too much fuel, producing black smoke.",
                    typicalCostRange: "Roughly $150–$600 per injector — direct-injection engines cost more than older port-injection engines"
                )
            ],
            repairSearchTerm: "black exhaust smoke diagnostic"
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
                    typicalCostRange: "Roughly $200–$600 each — lower ball joints cost more than upper ones"
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
        // contradict below excludes "Over bumps" specifically so this
        // record can't overlap phase1.suspension.bump-noise, which owns
        // that timing value exclusively via its own required signal.
        // Facts (loose/corroded heat shields as a common source of
        // metallic rattling, and the road-hazard risk if one fully
        // detaches) are well-known, independently corroborated automotive
        // knowledge cross-checked across multiple outlets tonight,
        // 2026-08-07 — sourceReferences attributed to OpenHood for the
        // same reason given above the other reviewed records in this
        // file: a source being public doesn't make it citable on screen.
        record(
            id: "phase1.noise.rattle-not-bumps",
            family: .noiseVibrationOrSuspension,
            observations: [.sound],
            required: [
                .observation(.sound),
                .noiseAnswer(key: IncidentNoiseAnswerKey.sound, value: "Rattle")
            ],
            support: [
                .observation(.sound),
                .noiseAnswer(key: IncidentNoiseAnswerKey.sound, value: "Rattle")
            ],
            contradict: [
                .noiseAnswer(key: IncidentNoiseAnswerKey.timing, value: "Over bumps")
            ],
            area: .exhaustAndVentilation,
            explanation: "A metallic rattle at startup, while accelerating, or continuously — not specifically over bumps — most often points to a loose or corroded exhaust heat shield. It's usually not urgent, but if a shield fully detaches it can become a road hazard, so it's worth having secured.",
            action: .professionalInspection,
            questions: [
                "Does the rattle change with engine speed (RPM), or stay about the same regardless of how fast the engine is running?",
                "Can you see or reach a heat shield near the exhaust that looks loose, bent, or rusted through?"
            ],
            verificationState: .reviewedGeneralPrinciple,
            contentState: .verifiedGeneralAutomotivePrinciple,
            sourceReferences: [
                IncidentGuidanceSourceReference(
                    id: "openhood-reviewed-rattle-not-bumps-guidance",
                    title: "OpenHood, \"Reviewed General Automotive Guidance — Rattle Not Over Bumps\"",
                    location: nil,
                    isPlaceholder: false
                )
            ],
            possibleAreaTerms: [
                IncidentPossibleAreaTerm(
                    id: "exhaust-heat-shield",
                    name: "Exhaust heat shield",
                    plainExplanation: "A thin metal shield that keeps exhaust heat away from nearby components. When its mounting corrodes or loosens, it can rattle against the exhaust or the underbody.",
                    typicalCostRange: "Roughly $100–$500, often on the lower end since these are simple parts"
                )
            ],
            repairSearchTerm: "exhaust heat shield repair"
        ),
        // Same tier as phase1.suspension.bump-noise above — reviewed
        // general-guidance content, not a needsVerification placeholder.
        // contradict below excludes "Over bumps" specifically so this
        // record can't overlap phase1.suspension.bump-noise, which owns
        // that timing value exclusively via its own required signal.
        // Reuses the same audited possible-area content and cost figures
        // as phase1.suspension.bump-noise above (CV joint, sway bar
        // links/bushings, ball joints, control-arm bushings) rather than
        // researching new numbers — the components are the same; only
        // the timing that surfaces the symptom differs (while turning or
        // accelerating, not tied to a bump). Cross-checked tonight,
        // 2026-08-07 — sourceReferences attributed to OpenHood for the
        // same reason given above the other reviewed records in this
        // file: a source being public doesn't make it citable on screen.
        record(
            id: "phase1.noise.clunk-not-bumps",
            family: .noiseVibrationOrSuspension,
            observations: [.sound],
            required: [
                .observation(.sound),
                .noiseAnswer(key: IncidentNoiseAnswerKey.sound, value: "Clunk")
            ],
            support: [
                .observation(.sound),
                .noiseAnswer(key: IncidentNoiseAnswerKey.sound, value: "Clunk")
            ],
            contradict: [
                .noiseAnswer(key: IncidentNoiseAnswerKey.timing, value: "Over bumps")
            ],
            area: .suspensionAndChassis,
            explanation: "A clunk while turning or accelerating, not tied to bumps, most often points to a worn CV joint, sway bar link, ball joint, or control-arm bushing — components that knock against each other once they develop play.",
            action: .professionalInspection,
            questions: [
                "Does the clunk happen while turning, while accelerating, or both?",
                "Is there any looseness or visible play at the suspension corner where the noise happens?",
                "Has any suspension, steering, or wheel work been done recently?"
            ],
            verificationState: .reviewedGeneralPrinciple,
            contentState: .verifiedGeneralAutomotivePrinciple,
            sourceReferences: [
                IncidentGuidanceSourceReference(
                    id: "openhood-reviewed-clunk-not-bumps-guidance",
                    title: "OpenHood, \"Reviewed General Automotive Guidance — Clunk Not Over Bumps\"",
                    location: nil,
                    isPlaceholder: false
                )
            ],
            possibleAreaTerms: [
                IncidentPossibleAreaTerm(
                    id: "cv-joint-or-axle",
                    name: "CV joint or axle",
                    plainExplanation: "The joint that lets the axle flex as the suspension moves and the wheels turn. When worn, it can develop play that knocks under load.",
                    typicalCostRange: "Roughly $250–$700 per side"
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
                    typicalCostRange: "Roughly $200–$600 each — lower ball joints cost more than upper ones"
                ),
                IncidentPossibleAreaTerm(
                    id: "control-arm-bushings",
                    name: "Control-arm bushings",
                    plainExplanation: "Rubber cushions that let the suspension move quietly. When worn, parts can knock together.",
                    typicalCostRange: "Roughly $250–$450"
                )
            ],
            repairSearchTerm: "suspension repair"
        ),
        // Same tier as phase1.suspension.bump-noise above — reviewed
        // general-guidance content, not needsVerification placeholders.
        // The noiseQuestions timing question already offers "Only at
        // speed" and "While turning" alongside "Over bumps" and "While
        // braking", but until now only the latter two had matching
        // records — these fell through to the generic MONITOR/not-
        // enough-information result. "Constant" is deliberately left
        // unhandled in this pass — it's genuinely ambiguous (engine
        // mounts, driveline, tires, or several at once) and deserves its
        // own careful pass rather than a guess.
        //
        // sourceReferences below are attributed to OpenHood, not to the
        // specific outlets consulted, for the same reason given above the
        // suspension-noise record: a source being public doesn't make it
        // citable on screen. The explanations and cost figures were
        // cross-checked across multiple independent automotive-reference
        // sources tonight, 2026-08-05 — the underlying facts (steering-
        // wheel vs. seat/floor vibration distinguishing front vs. rear
        // tire/wheel imbalance; CV joint/axle clicking or popping during
        // turns, especially sharp turns or pulling away from a stop; wheel
        // bearing symptoms changing with speed rather than only with
        // turning) are well-known, independently corroborated automotive
        // knowledge, not proprietary to any one site.
        record(
            id: "phase1.suspension.vibration-at-speed",
            family: .noiseVibrationOrSuspension,
            observations: [.sound, .vibrationOrMovement],
            required: [
                .noiseAnswer(key: IncidentNoiseAnswerKey.timing, value: "Only at speed")
            ],
            support: [
                .observation(.sound),
                .observation(.vibrationOrMovement),
                .noiseAnswer(key: IncidentNoiseAnswerKey.timing, value: "Only at speed"),
                .noiseAnswer(key: IncidentNoiseAnswerKey.location, value: "Front"),
                .noiseAnswer(key: IncidentNoiseAnswerKey.location, value: "Rear"),
                .noiseAnswer(key: IncidentNoiseAnswerKey.location, value: "All over")
            ],
            // No contradict signals: `required` above already pins timing
            // to exactly "Only at speed" (single-choice), so any other
            // timing value already excludes this record before scoring.
            contradict: [],
            area: .tiresWheelsAndPressure,
            explanation: "A vibration that shows up mainly at highway speed and comes through the steering wheel or the seat most often points to a wheel or tire imbalance, or in some cases a wheel alignment issue. A useful clue: vibration through the steering wheel usually means a front tire, vibration through the seat or floor usually means a rear tire.",
            action: .professionalInspection,
            questions: [
                "Does the vibration come through the steering wheel, the seat/floor, or both?",
                "Has any tire been replaced, rotated, or repaired recently?",
                "Has the vehicle hit a pothole or curb recently?"
            ],
            verificationState: .reviewedGeneralPrinciple,
            contentState: .verifiedGeneralAutomotivePrinciple,
            sourceReferences: [
                IncidentGuidanceSourceReference(
                    id: "openhood-reviewed-vibration-at-speed-guidance",
                    title: "OpenHood, \"Reviewed General Automotive Guidance — Vibration at Highway Speed\"",
                    location: nil,
                    isPlaceholder: false
                )
            ],
            possibleAreaTerms: [
                IncidentPossibleAreaTerm(
                    id: "wheel-or-tire-balance",
                    name: "Wheel or tire balance",
                    plainExplanation: "Small weights keep a wheel and tire spinning evenly. When they shift or fall off, the wheel can vibrate at certain speeds.",
                    typicalCostRange: "Roughly $15–$25 per tire, often $60–$100 for all four"
                ),
                IncidentPossibleAreaTerm(
                    id: "wheel-alignment",
                    name: "Wheel alignment",
                    plainExplanation: "Misaligned wheels can cause a vibration or pull, especially at highway speed.",
                    typicalCostRange: "Roughly $80–$150"
                ),
                IncidentPossibleAreaTerm(
                    id: "tire-condition",
                    name: "Tire condition (uneven wear or damage)",
                    plainExplanation: "Uneven wear, a bulge, or internal damage can cause a vibration that balancing alone won't fix.",
                    typicalCostRange: "Varies — worth a visual check first, no fixed number"
                )
            ],
            repairSearchTerm: "wheel balance and alignment"
        ),
        record(
            id: "phase1.suspension.vibration-while-turning",
            family: .noiseVibrationOrSuspension,
            observations: [.sound, .vibrationOrMovement],
            required: [
                .noiseAnswer(key: IncidentNoiseAnswerKey.timing, value: "While turning")
            ],
            support: [
                .observation(.sound),
                .observation(.vibrationOrMovement),
                .noiseAnswer(key: IncidentNoiseAnswerKey.timing, value: "While turning"),
                .noiseAnswer(key: IncidentNoiseAnswerKey.location, value: "Front"),
                .noiseAnswer(key: IncidentNoiseAnswerKey.location, value: "Rear"),
                .noiseAnswer(key: IncidentNoiseAnswerKey.location, value: "All over")
            ],
            // No contradict signals: `required` above already pins timing
            // to exactly "While turning" (single-choice), so any other
            // timing value already excludes this record before scoring.
            contradict: [],
            area: .suspensionAndChassis,
            explanation: "A vibration or shudder that gets worse specifically when turning, especially a sharp turn or pulling away from a stop, often points to a CV joint or axle issue. If it comes with a clicking or popping sound during the turn, that's a stronger signal for the same area.",
            action: .professionalInspection,
            questions: [
                "Is there a clicking or popping sound during the turn?",
                "Does it happen more on sharp turns, or during any turn?",
                "Does the vibration change with speed, or only with turning?"
            ],
            verificationState: .reviewedGeneralPrinciple,
            contentState: .verifiedGeneralAutomotivePrinciple,
            sourceReferences: [
                IncidentGuidanceSourceReference(
                    id: "openhood-reviewed-vibration-while-turning-guidance",
                    title: "OpenHood, \"Reviewed General Automotive Guidance — Vibration or Shudder While Turning\"",
                    location: nil,
                    isPlaceholder: false
                )
            ],
            possibleAreaTerms: [
                IncidentPossibleAreaTerm(
                    id: "cv-joint-or-axle",
                    name: "CV joint or axle",
                    plainExplanation: "A worn CV joint often clicks or pops during turns, especially sharp ones or pulling away from a stop.",
                    typicalCostRange: "Roughly $250–$700 per side"
                ),
                IncidentPossibleAreaTerm(
                    id: "wheel-bearing",
                    name: "Wheel bearing",
                    plainExplanation: "More likely if the vibration or noise changes with speed rather than only with turning.",
                    typicalCostRange: "Roughly $250–$550 per side"
                )
            ],
            repairSearchTerm: "CV joint or wheel bearing inspection"
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
        // OH-UIK gap fix (same tier as the ABS+brake-light severity fix):
        // "While braking" + "Grind" used to fall through to the generic
        // result — this record's own `support` only rewards a "Squeal"
        // sound answer, so "Grind" never scored high enough to qualify,
        // but nothing routed it anywhere safer either. Metal-on-metal
        // brake grinding means the pads are worn through and stopping
        // distance/control are compromised — a real, unanimous stop-
        // driving case, not general content this Phase 1 engine could
        // safely word (ordinaryDriveRecommendation has no path to STOP
        // DRIVING). Rather than writing general content for it, "While
        // braking" + "Grind" now escalates directly into the existing
        // urgent .unsafeBrakesOrSteering path before Phase 1 evaluation
        // ever runs — see brakeGrindEscalation/escalateToUrgentSafety in
        // SomethingHappenedView.swift, reusing the exact same mechanism
        // the ABS+brake-light fix already wired. "While braking" +
        // "Squeal" is untouched below; it's the existing, correct
        // wear-indicator content.
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
                    typicalCostRange: "Roughly $300–$900 per caliper, more for luxury or performance vehicles"
                )
            ],
            repairSearchTerm: "brake repair"
        ),
        // Same tier as phase1.brakes.squeal-while-braking above — reviewed
        // general-guidance content, not a needsVerification placeholder.
        // Closes a real gap: "While braking" was already a timing answer
        // and .vibrationOrMovement was already a selectable observation,
        // but nothing connected the two — a vibration or pedal pulsation
        // specific to braking fell through to the generic result.
        record(
            id: "phase1.suspension.vibration-while-braking",
            family: .noiseVibrationOrSuspension,
            observations: [.vibrationOrMovement],
            required: [
                .observation(.vibrationOrMovement),
                .noiseAnswer(key: IncidentNoiseAnswerKey.timing, value: "While braking")
            ],
            support: [
                .observation(.vibrationOrMovement),
                .noiseAnswer(key: IncidentNoiseAnswerKey.timing, value: "While braking")
            ],
            contradict: [],
            area: .brakesAndSteering,
            explanation: "A pulsation in the brake pedal or a shake in the steering wheel specifically when braking — not at other times — almost always means the brake rotors are warped or worn unevenly. This is different from a vibration that's present all the time or only at highway speed, which points elsewhere.",
            action: .professionalInspection,
            questions: [
                "Does the vibration happen only while braking, or at other times too?",
                "Does it come through the pedal, the steering wheel, or both?"
            ],
            verificationState: .reviewedGeneralPrinciple,
            contentState: .verifiedGeneralAutomotivePrinciple,
            sourceReferences: [
                IncidentGuidanceSourceReference(
                    id: "openhood-reviewed-vibration-while-braking-guidance",
                    title: "OpenHood, \"Reviewed General Automotive Guidance — Vibration While Braking\"",
                    location: nil,
                    isPlaceholder: false
                )
            ],
            possibleAreaTerms: [
                IncidentPossibleAreaTerm(
                    id: "brake-rotors",
                    name: "Brake rotors",
                    plainExplanation: "Warped or unevenly worn rotors create a pulsation felt in the pedal or steering wheel specifically when braking.",
                    typicalCostRange: "Roughly $300–$850 per axle to replace; resurfacing, when the rotor is thick enough, runs $40–$150 per axle and costs less"
                )
            ],
            repairSearchTerm: "brake rotor replacement"
        ),
        // Same tier as phase1.brakes.squeal-while-braking above — reviewed
        // general-guidance content, not a needsVerification placeholder.
        // contradict below excludes "While braking" specifically so this
        // record can't overlap phase1.brakes.squeal-while-braking, which
        // owns that timing value exclusively via its own required signal.
        // Facts (worn/glazed/slipping serpentine belts as a common source
        // of non-braking squeal) are well-known, independently
        // corroborated automotive knowledge cross-checked across multiple
        // outlets tonight, 2026-08-07 — sourceReferences attributed to
        // OpenHood for the same reason given above the other reviewed
        // records in this file: a source being public doesn't make it
        // citable on screen.
        record(
            id: "phase1.noise.squeal-not-braking",
            family: .noiseVibrationOrSuspension,
            observations: [.sound],
            required: [
                .observation(.sound),
                .noiseAnswer(key: IncidentNoiseAnswerKey.sound, value: "Squeal")
            ],
            support: [
                .observation(.sound),
                .noiseAnswer(key: IncidentNoiseAnswerKey.sound, value: "Squeal")
            ],
            contradict: [
                .noiseAnswer(key: IncidentNoiseAnswerKey.timing, value: "While braking")
            ],
            area: .engineAndCombustion,
            explanation: "A squeal that happens at startup, while accelerating, or continuously — not specifically while braking — most often points to a worn, glazed, or slipping serpentine belt rather than brakes. A squeal specifically when braking is a different, brake-related concern.",
            action: .professionalInspection,
            questions: [
                "Does the squeal happen at startup, while accelerating, or continuously — and does it change with engine RPM?",
                "Has the serpentine belt or belt tensioner been inspected or replaced recently?"
            ],
            verificationState: .reviewedGeneralPrinciple,
            contentState: .verifiedGeneralAutomotivePrinciple,
            sourceReferences: [
                IncidentGuidanceSourceReference(
                    id: "openhood-reviewed-squeal-not-braking-guidance",
                    title: "OpenHood, \"Reviewed General Automotive Guidance — Squeal Not While Braking\"",
                    location: nil,
                    isPlaceholder: false
                )
            ],
            possibleAreaTerms: [
                IncidentPossibleAreaTerm(
                    id: "serpentine-belt",
                    name: "Serpentine belt",
                    plainExplanation: "The single belt that drives accessories like the alternator, power steering pump, and A/C compressor. When it's worn, glazed, or slipping, it can squeal.",
                    typicalCostRange: "Roughly $70–$250"
                ),
                IncidentPossibleAreaTerm(
                    id: "belt-tensioner",
                    name: "Belt tensioner",
                    plainExplanation: "Keeps the serpentine belt at the right tension. When it weakens or seizes, the belt can slip and squeal even if the belt itself is fine.",
                    typicalCostRange: "Roughly $250–$300 alone, often less if replaced along with the belt"
                )
            ],
            repairSearchTerm: "serpentine belt replacement"
        ),
        // Same tier as phase1.brakes.squeal-while-braking above — reviewed
        // general-guidance content, not a needsVerification placeholder.
        // contradict below excludes both "Over bumps" (owned by
        // phase1.suspension.bump-noise) and "While braking" — the latter
        // is already routed to the urgent .unsafeBrakesOrSteering path via
        // brakeGrindEscalation before Phase 1 evaluation ever runs (see
        // the comment above phase1.brakes.squeal-while-braking), so this
        // exclusion is a defensive belt-and-suspenders match against that
        // routing rather than one this record would otherwise need to
        // resolve on its own. Facts (CV joint noise worse at full-lock
        // turns; wheel bearing noise constant and speed-dependent) are
        // well-known, independently corroborated automotive knowledge
        // cross-checked across multiple outlets tonight, 2026-08-07 —
        // sourceReferences attributed to OpenHood for the same reason
        // given above the other reviewed records in this file: a source
        // being public doesn't make it citable on screen.
        record(
            id: "phase1.noise.grind-not-bumps-not-braking",
            family: .noiseVibrationOrSuspension,
            observations: [.sound],
            required: [
                .observation(.sound),
                .noiseAnswer(key: IncidentNoiseAnswerKey.sound, value: "Grind")
            ],
            support: [
                .observation(.sound),
                .noiseAnswer(key: IncidentNoiseAnswerKey.sound, value: "Grind")
            ],
            contradict: [
                .noiseAnswer(key: IncidentNoiseAnswerKey.timing, value: "Over bumps"),
                .noiseAnswer(key: IncidentNoiseAnswerKey.timing, value: "While braking")
            ],
            area: .suspensionAndChassis,
            explanation: "A grinding noise while turning, or one that's fairly constant, most often points to a CV joint — especially if it's worse at full-lock turns like parking — or a wheel bearing, which tends to stay present at all speeds and get louder as you go faster. A grind specifically while braking is a different, brake-related concern.",
            action: .professionalInspection,
            questions: [
                "Does the grind get worse when turning the wheel all the way, like when parking?",
                "Does the noise change with speed, and is it present even when driving straight?",
                "Has any suspension, steering, or wheel work been done recently?"
            ],
            verificationState: .reviewedGeneralPrinciple,
            contentState: .verifiedGeneralAutomotivePrinciple,
            sourceReferences: [
                IncidentGuidanceSourceReference(
                    id: "openhood-reviewed-grind-not-bumps-not-braking-guidance",
                    title: "OpenHood, \"Reviewed General Automotive Guidance — Grind Not Over Bumps, Not While Braking\"",
                    location: nil,
                    isPlaceholder: false
                )
            ],
            possibleAreaTerms: [
                IncidentPossibleAreaTerm(
                    id: "cv-joint-or-axle",
                    name: "CV joint or axle",
                    plainExplanation: "The joint that lets the axle flex as the suspension moves and the wheels turn. Worn joints often grind or click most noticeably at full-lock turns.",
                    typicalCostRange: "Roughly $250–$700 per side"
                ),
                IncidentPossibleAreaTerm(
                    id: "wheel-bearing",
                    name: "Wheel bearing",
                    plainExplanation: "More likely if the grinding is fairly constant and changes with speed rather than only with turning.",
                    typicalCostRange: "Roughly $250–$550 per side"
                )
            ],
            repairSearchTerm: "CV joint or wheel bearing inspection"
        ),
        // phase1.driving-change.* — structured follow-up asked only when
        // the reported observation includes .drivingChange, gated on the
        // "What's changed about how it drives?" question (see
        // SomethingHappenedView.drivingChangeQuestions). "Mainly when
        // braking" (pulling) and "Suddenly" (steering) are deliberately
        // excluded below — see drivingChangeQuestionDestination — since
        // both escalate into the urgent .unsafeBrakesOrSteering path
        // instead of ever reaching Phase 1 evaluation. Sources consulted:
        // Firestone (pulling), Nelson's (caliper drag, heavy steering
        // causes, sluggish acceleration causes, catalytic converter cost,
        // power steering pump cost, serpentine belt cost) — same
        // attribution reasoning as the rest of this file: a source being
        // public doesn't make it citable on screen, so sourceReferences
        // below are attributed to OpenHood.
        record(
            id: "phase1.driving-change.pulls-to-one-side",
            family: .drivingChange,
            observations: [.drivingChange],
            required: [
                .observation(.drivingChange),
                .drivingChangeAnswer(key: IncidentDrivingChangeAnswerKey.whatChanged, value: "Pulls to one side")
            ],
            support: [
                .observation(.drivingChange),
                .drivingChangeAnswer(key: IncidentDrivingChangeAnswerKey.whatChanged, value: "Pulls to one side")
            ],
            contradict: [],
            area: .tiresWheelsAndPressure,
            explanation: "A car that drifts or pulls to one side most often points to wheel alignment or uneven tire pressure — even a 5 PSI difference side to side can cause a noticeable pull. If it happens specifically while braking, that can mean a dragging brake caliper, which is a safety concern worth having checked promptly.",
            action: .professionalInspection,
            questions: [
                "Is the pull constant, or does it only show up at certain speeds?",
                "When were the tires last rotated or the alignment last checked?"
            ],
            verificationState: .reviewedGeneralPrinciple,
            contentState: .verifiedGeneralAutomotivePrinciple,
            sourceReferences: [
                IncidentGuidanceSourceReference(
                    id: "openhood-reviewed-driving-change-pulling-guidance",
                    title: "OpenHood, \"Reviewed General Automotive Guidance — Pulling to One Side\"",
                    location: nil,
                    isPlaceholder: false
                )
            ],
            possibleAreaTerms: [
                IncidentPossibleAreaTerm(
                    id: "wheel-alignment",
                    name: "Wheel alignment",
                    plainExplanation: "Misaligned wheels are one of the most common causes of a steady pull to one side.",
                    typicalCostRange: "Roughly $80–$200"
                ),
                IncidentPossibleAreaTerm(
                    id: "uneven-tire-pressure",
                    name: "Uneven tire pressure",
                    plainExplanation: "Even a small pressure difference side to side, as little as 5 PSI, can cause a noticeable pull.",
                    typicalCostRange: "Usually free to check and correct at a gas station air pump"
                ),
                IncidentPossibleAreaTerm(
                    id: "tire-wear-or-tread-mismatch",
                    name: "Tire wear or tread mismatch",
                    plainExplanation: "Uneven wear or mismatched tread patterns side to side can pull the car even with correct pressure and alignment.",
                    typicalCostRange: "Varies — worth a visual check first, no fixed number"
                ),
                IncidentPossibleAreaTerm(
                    id: "suspension-components",
                    name: "Suspension components (control arm, bushings, or shocks)",
                    plainExplanation: "Worn suspension parts can let one side of the car sit or handle differently than the other, causing a pull.",
                    typicalCostRange: "Roughly $250–$450"
                )
            ],
            repairSearchTerm: "wheel alignment and tire inspection"
        ),
        record(
            id: "phase1.driving-change.heavy-steering",
            family: .drivingChange,
            observations: [.drivingChange],
            required: [
                .observation(.drivingChange),
                .drivingChangeAnswer(key: IncidentDrivingChangeAnswerKey.whatChanged, value: "Steering feels heavier than normal")
            ],
            support: [
                .observation(.drivingChange),
                .drivingChangeAnswer(key: IncidentDrivingChangeAnswerKey.whatChanged, value: "Steering feels heavier than normal")
            ],
            contradict: [],
            area: .powerSteeringOrEPS,
            explanation: "Steering that's gradually gotten heavier most often starts with low or old power steering fluid — the cheapest and most common cause, worth checking first — followed by a worn serpentine belt or a failing power steering pump.",
            action: .professionalInspection,
            questions: [
                "Has the power steering fluid level been checked recently?",
                "Is there any whining or squealing noise while turning?"
            ],
            verificationState: .reviewedGeneralPrinciple,
            contentState: .verifiedGeneralAutomotivePrinciple,
            sourceReferences: [
                IncidentGuidanceSourceReference(
                    id: "openhood-reviewed-driving-change-heavy-steering-guidance",
                    title: "OpenHood, \"Reviewed General Automotive Guidance — Steering Feels Heavier Than Normal\"",
                    location: nil,
                    isPlaceholder: false
                )
            ],
            possibleAreaTerms: [
                IncidentPossibleAreaTerm(
                    id: "power-steering-fluid",
                    name: "Power steering fluid",
                    plainExplanation: "Low or degraded power steering fluid is the cheapest and most common cause of heavier steering, worth checking first.",
                    typicalCostRange: "Often free to check; topping off is usually under $20 if needed"
                ),
                IncidentPossibleAreaTerm(
                    id: "serpentine-belt",
                    name: "Serpentine belt",
                    plainExplanation: "A worn or slipping serpentine belt can reduce power to the steering pump, making steering feel heavier.",
                    typicalCostRange: "Roughly $70–$250"
                ),
                IncidentPossibleAreaTerm(
                    id: "power-steering-pump",
                    name: "Power steering pump",
                    plainExplanation: "A failing pump can't build enough pressure to keep steering assist consistent.",
                    typicalCostRange: "Roughly $400–$900"
                )
            ],
            repairSearchTerm: "power steering diagnostic"
        ),
        record(
            id: "phase1.driving-change.sluggish-acceleration",
            family: .drivingChange,
            observations: [.drivingChange],
            required: [
                .observation(.drivingChange),
                .drivingChangeAnswer(key: IncidentDrivingChangeAnswerKey.whatChanged, value: "Feels sluggish or slow to accelerate")
            ],
            support: [
                .observation(.drivingChange),
                .drivingChangeAnswer(key: IncidentDrivingChangeAnswerKey.whatChanged, value: "Feels sluggish or slow to accelerate")
            ],
            contradict: [],
            area: .engineAndCombustion,
            explanation: "Sluggish acceleration usually traces back to something restricting airflow or fuel delivery, or a transmission not shifting cleanly — a clogged air filter, a dirty mass airflow sensor, a clogged catalytic converter, or low/degraded transmission fluid are the most common causes.",
            action: .professionalInspection,
            questions: [
                "When was the engine air filter last replaced?",
                "Does it feel worse from a stop, or more at highway speed?"
            ],
            verificationState: .reviewedGeneralPrinciple,
            contentState: .verifiedGeneralAutomotivePrinciple,
            sourceReferences: [
                IncidentGuidanceSourceReference(
                    id: "openhood-reviewed-driving-change-sluggish-acceleration-guidance",
                    title: "OpenHood, \"Reviewed General Automotive Guidance — Sluggish Acceleration\"",
                    location: nil,
                    isPlaceholder: false
                )
            ],
            possibleAreaTerms: [
                IncidentPossibleAreaTerm(
                    id: "engine-air-filter",
                    name: "Engine air filter",
                    plainExplanation: "A clogged air filter restricts airflow, making the engine work harder to breathe and reducing power.",
                    typicalCostRange: "Roughly $20–$75"
                ),
                IncidentPossibleAreaTerm(
                    id: "mass-airflow-sensor",
                    name: "Mass airflow sensor",
                    plainExplanation: "A dirty or failing sensor can misread incoming air, causing the engine to run poorly and feel underpowered.",
                    typicalCostRange: "Roughly $150–$580"
                ),
                IncidentPossibleAreaTerm(
                    id: "catalytic-converter",
                    name: "Catalytic converter",
                    plainExplanation: "A clogged converter restricts exhaust flow, which can make the engine feel noticeably underpowered.",
                    typicalCostRange: "Roughly $900–$3,500 — one of the more expensive common repairs, worth a proper diagnosis before replacing"
                ),
                IncidentPossibleAreaTerm(
                    id: "transmission-fluid-level-or-condition",
                    name: "Transmission fluid level or condition",
                    plainExplanation: "Low or degraded transmission fluid can prevent clean, timely shifts, which can feel like sluggish acceleration.",
                    typicalCostRange: "Roughly $80–$250 for a standard service"
                )
            ],
            repairSearchTerm: "acceleration performance diagnostic"
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
