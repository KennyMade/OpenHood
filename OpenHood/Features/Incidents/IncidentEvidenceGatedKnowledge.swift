import Foundation

/// Claim registry transcribed from IncidentKnowledgePack-v1.2.md, section 3
/// ("Corrected claim ledger"), for the four families authorized in that
/// pack: OH-UIK-001 (flashing check-engine + shaking), OH-UIK-006
/// (overheating/steam), OH-UIK-011 (braking), OH-UIK-013 (steering).
///
/// Excluded claims (CLM-MIL-006, CLM-OHT-006/007, CLM-BRK-006/007,
/// CLM-STR-005/006) are included here for completeness/audit but are
/// unreachable from visible output — IncidentClaimVisibility drops
/// anything not VISIBLE_GUIDANCE_APPROVED, VISIBLE_GUIDANCE_SCOPE_LIMITED
/// (with a scope match), or PRODUCT_POLICY.
///
/// CLM-STR-007 (Kia recall 24V422) intentionally has no `scope`: its real
/// applicability is a ~1,075-VIN recall population, which make/model/year
/// cannot express, and OpenHood has no VIN/recall-status field. Leaving
/// scope nil makes it structurally unmatchable by IncidentClaimVisibility,
/// so it never appears as though it applies to a specific user's vehicle.
///
/// CLM-STR-008 (Ford "Steering Loss — Stop Safely" message) intentionally
/// has no `scope` either, for the same reason: unlike CLM-STR-002 (which
/// names an exact make/model/year — Honda HR-V, 2025 — in its own
/// citation), CLM-STR-008's citation never establishes which Ford
/// model/year the message applies to. Attaching `makes: ["Ford"]` would
/// make it match every Ford vehicle, which is broader than the source
/// actually supports. It cannot be safely wired into live routing until a
/// more specific citation exists, so it stays unmatchable — retained here
/// for audit like the deferred OH-UIK records (pack section 7), not
/// active for product use.
enum IncidentEvidenceGatedKnowledge {
    static let claims: [IncidentClaim] = milClaims + overheatingClaims + brakingClaims + steeringClaims

    // MARK: A. Flashing check-engine light with shaking or rough running (OH-UIK-001)

    private static let milClaims: [IncidentClaim] = [
        IncidentClaim(
            id: "CLM-MIL-001",
            exactClaim: "In the cited Ford owner guidance, a blinking malfunction indicator indicates that engine misfire may be occurring and that catalytic-converter or other component damage may result.",
            sourceTier: .verifiedOEMOrGovernment,
            supportType: .direct,
            productUseStatus: .visibleGuidanceScopeLimited,
            source: "Ford Motor Company, \"Instrument Cluster — Warning Lamps and Indicators\", United States, Ford, model/year not safely established from retrieved page, date reviewed 2026-08-03.",
            limitations: "Applies only to vehicles covered by the cited Ford manual. Does not identify the misfiring cylinder or a failed component.",
            scope: IncidentClaimVehicleScope(makes: ["Ford"])
        ),
        IncidentClaim(
            id: "CLM-MIL-002",
            exactClaim: "In the cited Ford owner guidance, heavy acceleration and deceleration should be avoided while the malfunction indicator is blinking.",
            sourceTier: .verifiedOEMOrGovernment,
            supportType: .direct,
            productUseStatus: .visibleGuidanceScopeLimited,
            source: "Ford Motor Company, \"Instrument Cluster — Warning Lamps and Indicators\".",
            limitations: "This exact instruction must not be silently applied to every make and model.",
            scope: IncidentClaimVehicleScope(makes: ["Ford"])
        ),
        IncidentClaim(
            id: "CLM-MIL-003",
            exactClaim: "Certain Honda Civic owner guidance instructs the driver to stop in a safe place when the malfunction indicator blinks.",
            sourceTier: .verifiedOEMOrGovernment,
            supportType: .direct,
            productUseStatus: .visibleGuidanceScopeLimited,
            source: "American Honda Motor Co., Civic Coupe Owner's Guide, United States.",
            limitations: "Subsequent wait/restart/limited-driving instructions must come from the exact applicable Honda manual. Not universal Honda guidance.",
            scope: IncidentClaimVehicleScope(makes: ["Honda"], models: ["Civic"], bodyStyles: ["Coupe"])
        ),
        IncidentClaim(
            id: "CLM-MIL-004",
            exactClaim: "A flashing check-engine indicator with rough running does not, by itself, confirm which component failed.",
            sourceTier: .noExternalSourceProductPolicy,
            supportType: .none,
            productUseStatus: .productPolicy,
            source: "OpenHood, \"Evidence and Diagnostic Boundaries Policy\".",
            limitations: "Product-behavior rule, not an externally verified statement attributed to an OEM."
        ),
        IncidentClaim(
            id: "CLM-MIL-005",
            exactClaim: "OpenHood should confirm the warning symbol, determine whether the condition is active, reduce unsupported certainty, and use the exact owner's manual before applying manufacturer-specific continuation guidance.",
            sourceTier: .noExternalSourceProductPolicy,
            supportType: .none,
            productUseStatus: .productPolicy,
            source: "OpenHood, \"Incident Evidence-Gating Policy\".",
            limitations: "Does not establish a universal automotive driving instruction."
        ),
        IncidentClaim(
            id: "CLM-MIL-005S",
            exactClaim: "When a flashing check-engine report includes severe active shaking, major power loss, or stalling, OpenHood should escalate from the record's default CHECK BEFORE DRIVING to STOP DRIVING.",
            sourceTier: .noExternalSourceProductPolicy,
            supportType: .none,
            productUseStatus: .productPolicy,
            source: "OpenHood policy, reflecting IncidentKnowledgePack-v1.2 OH-UIK-001 smartest_next_step (\"Severe active shaking...or major power loss should be routed to STOP DRIVING\").",
            limitations: "The pack's smartest_next_step escalation clause carries no independent claim ID of its own in the source ledger; this entry exists so the escalation is traceable/auditable like every other policy-driven decision, per acceptance test 12."
        ),
        IncidentClaim(
            id: "CLM-MIL-006",
            exactClaim: "A diagnostic trouble code does not by itself prove that the component named in its description has failed.",
            sourceTier: .unresolvedHypothesis,
            supportType: .none,
            productUseStatus: .needsVerification,
            source: "Unresolved — equivalent safe behavior is covered by CLM-MIL-004 as PRODUCT_POLICY.",
            limitations: "Excluded as a factual claim; must not appear in visible output."
        )
    ]

    // MARK: B. Overheating or visible steam (OH-UIK-006)

    private static let overheatingClaims: [IncidentClaim] = [
        IncidentClaim(
            id: "CLM-OHT-001",
            exactClaim: "Steam or spray from an overheated engine can cause serious scalding.",
            sourceTier: .verifiedOEMOrGovernment,
            supportType: .direct,
            productUseStatus: .visibleGuidanceScopeLimited,
            source: "American Honda Motor Co., \"Overheating\" — Civic Hatchback Owner's Manual, United States, 2025 edition.",
            limitations: "Formally applies to the cited Honda manual; the physical hazard is broadly relevant but the source must not be represented as universal OEM guidance.",
            scope: IncidentClaimVehicleScope(makes: ["Honda"], models: ["Civic"], bodyStyles: ["Hatchback"])
        ),
        IncidentClaim(
            id: "CLM-OHT-002",
            exactClaim: "The cited Honda manual instructs the owner not to open the hood while steam is actively coming from the engine compartment.",
            sourceTier: .verifiedOEMOrGovernment,
            supportType: .direct,
            productUseStatus: .visibleGuidanceScopeLimited,
            source: "American Honda Motor Co., \"Overheating\" — Civic Hatchback Owner's Manual.",
            limitations: "Exact procedure after steam stops remains vehicle-specific.",
            scope: IncidentClaimVehicleScope(makes: ["Honda"], models: ["Civic"], bodyStyles: ["Hatchback"])
        ),
        IncidentClaim(
            id: "CLM-OHT-003",
            exactClaim: "The cited Toyota manual warns not to loosen the coolant-reservoir or radiator cap while the engine and cooling system are hot because hot coolant or steam may spray out.",
            sourceTier: .verifiedOEMOrGovernment,
            supportType: .direct,
            productUseStatus: .visibleGuidanceScopeLimited,
            source: "Toyota Motor Sales U.S.A., \"If Your Vehicle Overheats\" — 2025 RAV4.",
            limitations: "Cap design, reservoir type, cooldown method, and inspection procedure vary by vehicle.",
            scope: IncidentClaimVehicleScope(makes: ["Toyota"], models: ["RAV4"], modelYears: 2025...2025)
        ),
        IncidentClaim(
            id: "CLM-OHT-004",
            exactClaim: "Certain Ford owner guidance instructs the driver to stop safely, switch off the engine, and arrange assistance when the vehicle reports a defined overheating fail-safe condition.",
            sourceTier: .verifiedOEMOrGovernment,
            supportType: .direct,
            productUseStatus: .visibleGuidanceScopeLimited,
            source: "Ford Motor Company, \"Maintenance — Engine Coolant Check / Fail-Safe Cooling Guidance\".",
            limitations: "Not every vehicle has Ford's fail-safe cooling strategy. Must never become a universal overheating rule.",
            scope: IncidentClaimVehicleScope(makes: ["Ford"])
        ),
        IncidentClaim(
            id: "CLM-OHT-005",
            exactClaim: "OpenHood should route a confirmed high-temperature warning or visible engine-bay steam to STOP DRIVING and should require vehicle-specific owner-manual review before restart or ordinary driving.",
            sourceTier: .noExternalSourceProductPolicy,
            supportType: .none,
            productUseStatus: .productPolicy,
            source: "OpenHood, \"Conservative Incident Routing Policy\"."
        ),
        IncidentClaim(
            id: "CLM-OHT-006",
            exactClaim: "Clear water beneath the passenger compartment after A/C use is often normal condensate rather than an engine-cooling leak.",
            sourceTier: .unresolvedHypothesis,
            supportType: .none,
            productUseStatus: .needsVerification,
            source: "Unresolved.",
            limitations: "Excluded; must not appear in visible output."
        ),
        IncidentClaim(
            id: "CLM-OHT-007",
            exactClaim: "Cabin heat becoming cold while coolant temperature rises may indicate reduced coolant flow.",
            sourceTier: .unresolvedHypothesis,
            supportType: .none,
            productUseStatus: .needsVerification,
            source: "Unresolved.",
            limitations: "Excluded; must not appear in visible output, including the mechanic summary as a conclusion."
        )
    ]

    // MARK: C. Soft, sinking, hard, or weak braking (OH-UIK-011)

    private static let brakingClaims: [IncidentClaim] = [
        IncidentClaim(
            id: "CLM-BRK-001",
            exactClaim: "In the 2025 Toyota RAV4 manual, the red brake-system warning may indicate low brake-fluid level or a brake-system malfunction, and Toyota instructs the driver to stop immediately in a safe place and contact a Toyota dealer.",
            sourceTier: .verifiedOEMOrGovernment,
            supportType: .direct,
            productUseStatus: .visibleGuidanceScopeLimited,
            source: "Toyota Motor Sales U.S.A., \"If a Warning Light Turns On or a Warning Buzzer Sounds\" — 2025 RAV4.",
            limitations: "Exact symbol meaning and instructions vary; cannot be applied until warning symbol and vehicle are confirmed.",
            scope: IncidentClaimVehicleScope(makes: ["Toyota"], models: ["RAV4"], modelYears: 2025...2025)
        ),
        IncidentClaim(
            id: "CLM-BRK-002",
            exactClaim: "In the cited Honda Pilot manual, abnormal brake-pedal pressure combined with the applicable brake warning requires immediate owner-manual action.",
            sourceTier: .verifiedOEMOrGovernment,
            supportType: .direct,
            productUseStatus: .visibleGuidanceScopeLimited,
            source: "American Honda Motor Co., \"Indicator Coming On/Blinking\" — Pilot Owner's Manual, 2026.",
            limitations: "Must be tied to the exact Honda warning and manual.",
            scope: IncidentClaimVehicleScope(makes: ["Honda"], models: ["Pilot"], modelYears: 2026...2026)
        ),
        IncidentClaim(
            id: "CLM-BRK-003",
            exactClaim: "AAA states that a soft or spongy brake pedal may be associated with air in the brake lines or a hydraulic-system leak.",
            sourceTier: .professionallySupportedGeneralGuidance,
            supportType: .direct,
            productUseStatus: .visibleGuidanceApproved,
            source: "AAA, \"13 Common Car Problems Explained\".",
            limitations: "\"May\" is mandatory; symptom does not confirm either condition or a particular failed component."
        ),
        // CLM-OIL-001: unlike CLM-MIL-005 above (a PRODUCT_POLICY claim —
        // OpenHood's own evidence-gating process, not a driving
        // instruction), this backs an actual STOP DRIVING decision with
        // real, corroborated general automotive safety guidance, so it
        // follows the CLM-BRK-003 pattern instead: PROFESSIONALLY_
        // SUPPORTED_GENERAL_GUIDANCE tier, DIRECT support,
        // VISIBLE_GUIDANCE_APPROVED. No vehicle scope needed — a
        // continuously illuminated oil-pressure warning means the same
        // thing on any vehicle.
        IncidentClaim(
            id: "CLM-OIL-001",
            exactClaim: "A continuously illuminated oil-pressure warning light while driving indicates possible loss of oil pressure, and the vehicle should be stopped and shut off promptly rather than driven further, since continued operation risks engine damage.",
            sourceTier: .professionallySupportedGeneralGuidance,
            supportType: .direct,
            productUseStatus: .visibleGuidanceApproved,
            source: "AAA, \"AAA Reminds Drivers to Not Ignore Their Car's Warning Lights\".",
            limitations: "Applies to a light that stays on while driving; does not confirm the exact cause (low oil level, a failed pump, or a faulty sensor)."
        ),
        IncidentClaim(
            id: "CLM-BRK-004",
            exactClaim: "OpenHood must not identify a master cylinder, booster, hose, caliper, ABS unit, or other component from pedal feel alone.",
            sourceTier: .noExternalSourceProductPolicy,
            supportType: .none,
            productUseStatus: .productPolicy,
            source: "OpenHood, \"Diagnostic Certainty Boundary\"."
        ),
        IncidentClaim(
            id: "CLM-BRK-005",
            exactClaim: "When the owner reports that the vehicle cannot slow or stop normally, OpenHood should route the incident to STOP DRIVING and should not ask the owner to road-test it.",
            sourceTier: .noExternalSourceProductPolicy,
            supportType: .none,
            productUseStatus: .productPolicy,
            source: "OpenHood, \"Loss-of-Control Safety Routing Policy\"."
        ),
        IncidentClaim(
            id: "CLM-BRK-006",
            exactClaim: "Temporary improvement after pumping the brake pedal does not establish that the braking system is repaired.",
            sourceTier: .unresolvedHypothesis,
            supportType: .none,
            productUseStatus: .needsVerification,
            source: "Unresolved.",
            limitations: "Excluded; must not appear in visible output."
        ),
        IncidentClaim(
            id: "CLM-BRK-007",
            exactClaim: "Adding brake fluid without identifying why the fluid is low should not be represented as a completed repair.",
            sourceTier: .unresolvedHypothesis,
            supportType: .none,
            productUseStatus: .needsVerification,
            source: "Unresolved.",
            limitations: "Excluded; must not appear in visible output."
        )
    ]

    // MARK: D. Steering-assist or steering-control loss (OH-UIK-013)

    private static let steeringClaims: [IncidentClaim] = [
        IncidentClaim(
            id: "CLM-STR-001",
            exactClaim: "In the cited Honda HR-V manual, an EPS indicator means the EPS system has detected a problem.",
            sourceTier: .verifiedOEMOrGovernment,
            supportType: .direct,
            productUseStatus: .visibleGuidanceScopeLimited,
            source: "American Honda Motor Co., \"Indicators\" — HR-V Owner's Manual, 2025.",
            limitations: "Does not identify the failed component.",
            scope: IncidentClaimVehicleScope(makes: ["Honda"], models: ["HR-V"], modelYears: 2025...2025)
        ),
        IncidentClaim(
            id: "CLM-STR-002",
            exactClaim: "In the cited Honda HR-V manual, a persistent EPS indicator requires the vehicle to be checked by a dealer; a separate \"Do not drive\" message requires immediate safe stopping and dealer contact.",
            sourceTier: .verifiedOEMOrGovernment,
            supportType: .direct,
            productUseStatus: .visibleGuidanceScopeLimited,
            source: "American Honda Motor Co., \"Indicators\" — HR-V Owner's Manual, 2025.",
            limitations: "The EPS indicator alone and the explicit \"Do not drive\" message must not be treated as equivalent.",
            scope: IncidentClaimVehicleScope(makes: ["Honda"], models: ["HR-V"], modelYears: 2025...2025)
        ),
        IncidentClaim(
            id: "CLM-STR-003",
            exactClaim: "Toyota's U.S. warning-light reference identifies its EPS warning as indicating a malfunction in the EPS system.",
            sourceTier: .verifiedOEMOrGovernment,
            supportType: .direct,
            productUseStatus: .visibleGuidanceScopeLimited,
            source: "Toyota Motor Sales U.S.A., \"Toyota Dashboard Symbols and Warning Lights\".",
            limitations: "Does not create one universal stop-or-drive instruction for every Toyota model.",
            scope: IncidentClaimVehicleScope(makes: ["Toyota"])
        ),
        IncidentClaim(
            id: "CLM-STR-004",
            exactClaim: "OpenHood must not convert an EPS warning into a confirmed steering-rack, motor, pump, module, battery, wiring, or sensor failure.",
            sourceTier: .noExternalSourceProductPolicy,
            supportType: .none,
            productUseStatus: .productPolicy,
            source: "OpenHood, \"System-Level Warning Interpretation Policy\"."
        ),
        IncidentClaim(
            id: "CLM-STR-005",
            exactClaim: "Actual inability to steer normally, severe looseness, binding, or loss of directional control warrants stopping safely rather than continuing ordinary driving.",
            sourceTier: .unresolvedHypothesis,
            supportType: .inference,
            productUseStatus: .researchOnly,
            source: "NHTSA, \"Tire Safety Ratings and Awareness — TireWise\".",
            limitations: "The cited NHTSA material addresses tire blowouts and stabilization, not universal conventional steering-assist/steering-control failure. Excluded; superseded for product use by CLM-STR-005P."
        ),
        IncidentClaim(
            id: "CLM-STR-005P",
            exactClaim: "When a user reports that the vehicle cannot be directed normally, OpenHood should use STOP DRIVING and avoid asking the user to continue or road-test it.",
            sourceTier: .noExternalSourceProductPolicy,
            supportType: .none,
            productUseStatus: .productPolicy,
            source: "OpenHood, \"Reported Loss-of-Control Routing Policy\"."
        ),
        IncidentClaim(
            id: "CLM-STR-006",
            exactClaim: "If steering assistance returns after a restart, the original condition is not proven repaired.",
            sourceTier: .unresolvedHypothesis,
            supportType: .none,
            productUseStatus: .needsVerification,
            source: "Ford Motor Company, \"Electric Power Steering Precautions\" (does not directly state the claim; procedure is not universal).",
            limitations: "Excluded; must not appear in visible output."
        ),
        IncidentClaim(
            id: "CLM-STR-007",
            exactClaim: "Loss of power steering assistance may leave some vehicles mechanically steerable but require substantially more steering effort.",
            sourceTier: .verifiedOEMOrGovernment,
            supportType: .direct,
            productUseStatus: .visibleGuidanceScopeLimited,
            source: "Kia America, Inc. / NHTSA recall repository, \"Important Safety Recall — Certain 2024 Kia Sportage Vehicles\", recall 24V422, 2024-07-19.",
            limitations: "Applies only to the recalled population (~1,075 vehicles, production dates April 30–May 23, 2024) — narrower than make/model/year can express and not checkable without VIN/recall data. Intentionally left without a `scope` so it never auto-matches a specific vehicle; OpenHood has no VIN or recall-status field."
            // scope intentionally nil — see doc comment above.
        ),
        IncidentClaim(
            id: "CLM-STR-008",
            exactClaim: "Certain Ford information messages explicitly instruct the driver to stop safely when the power-steering system is not working.",
            sourceTier: .verifiedOEMOrGovernment,
            supportType: .direct,
            productUseStatus: .visibleGuidanceScopeLimited,
            source: "Ford Motor Company, \"Steering — Information Messages\". Exact message: \"Steering Loss — Stop Safely\".",
            limitations: "Only applies when the exact Ford message and applicable manual match — unlike CLM-STR-002's Honda HR-V 2025 citation, this citation never names a specific Ford model or model year, so that match cannot currently be checked against a real vehicle."
            // scope intentionally nil — see doc comment above.
        )
    ]
}
