# OpenHood Universal Incident Knowledge Pack 1

Revision v1.2 — Evidence-Gated Research Correction

Version: 1.2
Date reviewed: 2026-08-03
Authorized scope: Research normalization only
Phase 1 incident families retained: 4
Deferred records retained: 9
App modification authorized: No (pending this Engineering handoff)

Spot-verification note (added by Claude, Master Advisor chat, corrected 2026-08-03): four of the highest-stakes claims driving STOP DRIVING routing were independently checked against real public web sources via live search, not just asserted. Correction to an earlier draft of this note: only one of the four was actually checked before this note was first written; the other three were verified afterward, in the same session, before this file was finalized. All four are now confirmed accurate:

- Honda overheating/steam scalding warning — confirmed via techinfo.honda.com owner's manual pages (HR-V, CR-V, Accord, Pilot, multiple years): "Steam and spray from an overheated engine can seriously scald you. Do not open the hood if steam is coming out." Near word-for-word match to CLM-OHT-001/002.
- Ford blinking malfunction indicator / misfire warning — confirmed via fordservicecontent.com owner's manual content ("Instrument Cluster — Warning Lamps and Indicators"): blinking MIL indicates misfire; drive moderately, avoid heavy acceleration/deceleration, contact dealer; risk of catalytic converter/fuel system/component damage or fire. Near word-for-word match to CLM-MIL-001/002.
- Toyota RAV4 red brake warning — confirmed via multiple sources: red brake warning indicates parking brake engaged or a system malfunction; if it persists with parking brake released, stop driving and have it towed to a Toyota dealer. Matches CLM-BRK-001.
- Kia Sportage recall 24V422 — confirmed via the actual NHTSA recall report (static.nhtsa.gov/odi/rcl/2024/RCLRPT-24V422-5132.PDF): power-steering circuit board short from contaminated flux, ~1,075 vehicles built Kia's Georgia plant between April 30–May 23, 2024, loss of assist increases crash risk. Matches CLM-STR-007 exactly, including the affected population size.

The remaining claims in this pack (Honda HR-V EPS claims, Ford steering-loss message, AAA soft-pedal claim, Honda Pilot brake claim, etc.) were not independently verified and should be treated according to their own stated source_tier/support_type/product_use_status until spot-checked.

---

## 1. Delta summary from v1.1 to v1.2

Version 1.2 corrects the remaining evidence-governance problems in v1.1.

### Structural changes

Every claim now carries three independent fields:

- source_tier:
- support_type:
- product_use_status:

These fields must never be collapsed into one verification label.

### New product-use status

PRODUCT_POLICY is now available for cautious OpenHood behavior that:

- limits overstatement,
- prevents unsafe assumptions,
- requests confirmation,
- preserves uncertainty,
- or chooses a conservative route,

but is not itself presented as externally verified automotive fact.

Example:

"Do not name a failed component from this symptom alone."

That is an appropriate OpenHood product policy. It does not require pretending an OEM published that exact product rule.

### Evidence-gating correction

Only claims with one of these product_use_status values may control visible guidance:

- VISIBLE_GUIDANCE_APPROVED
- VISIBLE_GUIDANCE_SCOPE_LIMITED
- PRODUCT_POLICY

Claims marked:

- RESEARCH_ONLY
- NEEDS_VERIFICATION
- REJECTED
- UNRESOLVED

may not determine: driving status, immediate action, assessment text, confirmation steps, actions to avoid, or the mechanic-ready summary. They may appear internally as an uncertainty or research gap only.

### Cross-manufacturer correction

No cross-manufacturer synthesis is now labeled fully approved merely because one OEM supports it. A vehicle-specific OEM claim remains limited to: the stated manufacturer, covered model, covered model years, stated market, and the document's conditions.

A broader OpenHood route must either: have support from multiple applicable sources, remain scope-limited, be explicitly identified as inference, or be classified as PRODUCT_POLICY.

### Steering correction

CLM-STR-005 is no longer treated as externally verified universal guidance. The prior NHTSA tire-loss material addressed tire blowouts and vehicle stability, not conventional steering-assist failure. It therefore does not directly support the claimed universal steering instruction. CLM-STR-005 is now:

- support_type: INFERENCE
- product_use_status: RESEARCH_ONLY

OpenHood may still route a user reporting actual inability to control direction to STOP DRIVING, but that route is now a cautious PRODUCT_POLICY, not a falsely universalized NHTSA fact.

### Existing OpenHood states retained

No new urgency enum is introduced. All recommendations map to: STOP DRIVING, DO NOT RESTART, SERVICE SOON, CHECK BEFORE DRIVING, MONITOR.

---

## 2. Evidence and product-use rules

### 2.1 source_tier

Allowed values: VERIFIED_OEM_OR_GOVERNMENT, PROFESSIONALLY_SUPPORTED_GENERAL_GUIDANCE, CONFIRMED_SOLVED_OWNER_CASE, COMMUNITY_REPORTED_PATTERN, UNRESOLVED_HYPOTHESIS, NO_EXTERNAL_SOURCE_PRODUCT_POLICY.

NO_EXTERNAL_SOURCE_PRODUCT_POLICY is used only when the claim governs OpenHood's cautious behavior and is not displayed as an automotive fact.

### 2.2 support_type

Allowed values: DIRECT, INFERENCE, NONE, CONTRADICTED.

- DIRECT: The cited source directly states the material claim within its applicable scope.
- INFERENCE: The source supports related facts, but OpenHood is drawing a bounded conclusion not directly stated by the source.
- NONE: No adequate source currently supports the claim.
- CONTRADICTED: The reviewed evidence materially conflicts with the claim.

### 2.3 product_use_status

Allowed values: VISIBLE_GUIDANCE_APPROVED, VISIBLE_GUIDANCE_SCOPE_LIMITED, PRODUCT_POLICY, RESEARCH_ONLY, NEEDS_VERIFICATION, REJECTED.

- VISIBLE_GUIDANCE_APPROVED: May control visible app guidance within the expressly documented scope.
- VISIBLE_GUIDANCE_SCOPE_LIMITED: May be shown only when the relevant manufacturer, model, model year, market, warning, or condition matches.
- PRODUCT_POLICY: May control OpenHood's cautious communication or evidence-gating behavior, but must not be presented as sourced automotive fact. Examples: confirm the warning symbol before interpreting it; do not claim a component diagnosis; treat active symptoms differently from symptoms that stopped; exclude unsupported causes from visible guidance.
- RESEARCH_ONLY: May remain in internal research, but cannot affect customer-facing guidance.
- NEEDS_VERIFICATION: Cannot affect visible guidance.
- REJECTED: Must not be used.

### 2.4 Visible-guidance eligibility

A claim is eligible to affect the user experience only when product_use_status = VISIBLE_GUIDANCE_APPROVED or VISIBLE_GUIDANCE_SCOPE_LIMITED or PRODUCT_POLICY.

Additionally: VISIBLE_GUIDANCE_SCOPE_LIMITED requires a matching applicability check. PRODUCT_POLICY must be expressed as OpenHood behavior, not external technical fact. INFERENCE_ONLY is not a valid visible status in v1.2. An inferential research claim must be RESEARCH_ONLY unless separately converted into a clearly bounded PRODUCT_POLICY.

---

## 3. Corrected claim ledger

### A. Flashing check-engine light with shaking or rough running

**CLM-MIL-001**
- record_id: OH-UIK-001
- exact_claim: In the cited Ford owner guidance, a blinking malfunction indicator indicates that engine misfire may be occurring and that catalytic-converter or other component damage may result.
- source_tier: VERIFIED_OEM_OR_GOVERNMENT
- support_type: DIRECT
- product_use_status: VISIBLE_GUIDANCE_SCOPE_LIMITED
- source: Ford Motor Company, "Instrument Cluster — Warning Lamps and Indicators", United States, Ford, model/year not safely established from retrieved page, date reviewed 2026-08-03.
- limitations: Applies only to vehicles covered by the cited Ford manual. Does not identify the misfiring cylinder or a failed component.

**CLM-MIL-002**
- record_id: OH-UIK-001
- exact_claim: In the cited Ford owner guidance, heavy acceleration and deceleration should be avoided while the malfunction indicator is blinking.
- source_tier: VERIFIED_OEM_OR_GOVERNMENT / support_type: DIRECT / product_use_status: VISIBLE_GUIDANCE_SCOPE_LIMITED
- source: Ford Motor Company, "Instrument Cluster — Warning Lamps and Indicators".
- limitations: This exact instruction must not be silently applied to every make and model.

**CLM-MIL-003**
- record_id: OH-UIK-001
- exact_claim: Certain Honda Civic owner guidance instructs the driver to stop in a safe place when the malfunction indicator blinks.
- source_tier: VERIFIED_OEM_OR_GOVERNMENT / support_type: DIRECT / product_use_status: VISIBLE_GUIDANCE_SCOPE_LIMITED
- source: American Honda Motor Co., Civic Coupe Owner's Guide, United States.
- limitations: Subsequent wait/restart/limited-driving instructions must come from the exact applicable Honda manual. Not universal Honda guidance.

**CLM-MIL-004**
- record_id: OH-UIK-001
- exact_claim: A flashing check-engine indicator with rough running does not, by itself, confirm which component failed.
- source_tier: NO_EXTERNAL_SOURCE_PRODUCT_POLICY / support_type: NONE / product_use_status: PRODUCT_POLICY
- source: OpenHood, "Evidence and Diagnostic Boundaries Policy".
- limitations: Product-behavior rule, not an externally verified statement attributed to an OEM.

**CLM-MIL-005**
- record_id: OH-UIK-001
- exact_claim: OpenHood should confirm the warning symbol, determine whether the condition is active, reduce unsupported certainty, and use the exact owner's manual before applying manufacturer-specific continuation guidance.
- source_tier: NO_EXTERNAL_SOURCE_PRODUCT_POLICY / support_type: NONE / product_use_status: PRODUCT_POLICY
- source: OpenHood, "Incident Evidence-Gating Policy".
- limitations: Does not establish a universal automotive driving instruction.

**CLM-MIL-006** (excluded)
- record_id: OH-UIK-001
- exact_claim: A diagnostic trouble code does not by itself prove that the component named in its description has failed.
- source_tier: UNRESOLVED_HYPOTHESIS / support_type: NONE / product_use_status: NEEDS_VERIFICATION
- Visible use: Excluded as a factual claim. Equivalent safe behavior covered by CLM-MIL-004 as PRODUCT_POLICY.

### B. Overheating or visible steam

**CLM-OHT-001**
- record_id: OH-UIK-006
- exact_claim: Steam or spray from an overheated engine can cause serious scalding.
- source_tier: VERIFIED_OEM_OR_GOVERNMENT / support_type: DIRECT / product_use_status: VISIBLE_GUIDANCE_SCOPE_LIMITED
- source: American Honda Motor Co., "Overheating" — Civic Hatchback Owner's Manual, United States, 2025 edition.
- limitations: Formally applies to the cited Honda manual; the physical hazard is broadly relevant but the source must not be represented as universal OEM guidance.

**CLM-OHT-002**
- record_id: OH-UIK-006
- exact_claim: The cited Honda manual instructs the owner not to open the hood while steam is actively coming from the engine compartment.
- source_tier: VERIFIED_OEM_OR_GOVERNMENT / support_type: DIRECT / product_use_status: VISIBLE_GUIDANCE_SCOPE_LIMITED
- source: American Honda Motor Co., "Overheating" — Civic Hatchback Owner's Manual.
- limitations: Exact procedure after steam stops remains vehicle-specific.

**CLM-OHT-003**
- record_id: OH-UIK-006
- exact_claim: The cited Toyota manual warns not to loosen the coolant-reservoir or radiator cap while the engine and cooling system are hot because hot coolant or steam may spray out.
- source_tier: VERIFIED_OEM_OR_GOVERNMENT / support_type: DIRECT / product_use_status: VISIBLE_GUIDANCE_SCOPE_LIMITED
- source: Toyota Motor Sales U.S.A., "If Your Vehicle Overheats" — 2025 RAV4.
- limitations: Cap design, reservoir type, cooldown method, and inspection procedure vary by vehicle.

**CLM-OHT-004**
- record_id: OH-UIK-006
- exact_claim: Certain Ford owner guidance instructs the driver to stop safely, switch off the engine, and arrange assistance when the vehicle reports a defined overheating fail-safe condition.
- source_tier: VERIFIED_OEM_OR_GOVERNMENT / support_type: DIRECT / product_use_status: VISIBLE_GUIDANCE_SCOPE_LIMITED
- source: Ford Motor Company, "Maintenance — Engine Coolant Check / Fail-Safe Cooling Guidance".
- limitations: Not every vehicle has Ford's fail-safe cooling strategy. Must never become a universal overheating rule.

**CLM-OHT-005**
- record_id: OH-UIK-006
- exact_claim: OpenHood should route a confirmed high-temperature warning or visible engine-bay steam to STOP DRIVING and should require vehicle-specific owner-manual review before restart or ordinary driving.
- source_tier: NO_EXTERNAL_SOURCE_PRODUCT_POLICY / support_type: NONE / product_use_status: PRODUCT_POLICY
- source: OpenHood, "Conservative Incident Routing Policy".

**CLM-OHT-006** (excluded) — Clear water beneath the passenger compartment after A/C use is often normal condensate rather than an engine-cooling leak. UNRESOLVED_HYPOTHESIS / NEEDS_VERIFICATION.

**CLM-OHT-007** (excluded) — Cabin heat becoming cold while coolant temperature rises may indicate reduced coolant flow. UNRESOLVED_HYPOTHESIS / NEEDS_VERIFICATION.

### C. Soft, sinking, hard, or weak braking

**CLM-BRK-001**
- record_id: OH-UIK-011
- exact_claim: In the 2025 Toyota RAV4 manual, the red brake-system warning may indicate low brake-fluid level or a brake-system malfunction, and Toyota instructs the driver to stop immediately in a safe place and contact a Toyota dealer.
- source_tier: VERIFIED_OEM_OR_GOVERNMENT / support_type: DIRECT / product_use_status: VISIBLE_GUIDANCE_SCOPE_LIMITED
- source: Toyota Motor Sales U.S.A., "If a Warning Light Turns On or a Warning Buzzer Sounds" — 2025 RAV4.
- limitations: Exact symbol meaning and instructions vary; cannot be applied until warning symbol and vehicle are confirmed.

**CLM-BRK-002**
- record_id: OH-UIK-011
- exact_claim: In the cited Honda Pilot manual, abnormal brake-pedal pressure combined with the applicable brake warning requires immediate owner-manual action.
- source_tier: VERIFIED_OEM_OR_GOVERNMENT / support_type: DIRECT / product_use_status: VISIBLE_GUIDANCE_SCOPE_LIMITED
- source: American Honda Motor Co., "Indicator Coming On/Blinking" — Pilot Owner's Manual, 2026.
- limitations: Must be tied to the exact Honda warning and manual.

**CLM-BRK-003**
- record_id: OH-UIK-011
- exact_claim: AAA states that a soft or spongy brake pedal may be associated with air in the brake lines or a hydraulic-system leak.
- source_tier: PROFESSIONALLY_SUPPORTED_GENERAL_GUIDANCE / support_type: DIRECT / product_use_status: VISIBLE_GUIDANCE_APPROVED
- source: AAA, "13 Common Car Problems Explained".
- limitations: "May" is mandatory; symptom does not confirm either condition or a particular failed component.

**CLM-BRK-004**
- record_id: OH-UIK-011
- exact_claim: OpenHood must not identify a master cylinder, booster, hose, caliper, ABS unit, or other component from pedal feel alone.
- source_tier: NO_EXTERNAL_SOURCE_PRODUCT_POLICY / support_type: NONE / product_use_status: PRODUCT_POLICY
- source: OpenHood, "Diagnostic Certainty Boundary".

**CLM-BRK-005**
- record_id: OH-UIK-011
- exact_claim: When the owner reports that the vehicle cannot slow or stop normally, OpenHood should route the incident to STOP DRIVING and should not ask the owner to road-test it.
- source_tier: NO_EXTERNAL_SOURCE_PRODUCT_POLICY / support_type: NONE / product_use_status: PRODUCT_POLICY
- source: OpenHood, "Loss-of-Control Safety Routing Policy".

**CLM-BRK-006** (excluded) — Temporary improvement after pumping the brake pedal does not establish that the braking system is repaired. UNRESOLVED_HYPOTHESIS / NEEDS_VERIFICATION.

**CLM-BRK-007** (excluded) — Adding brake fluid without identifying why the fluid is low should not be represented as a completed repair. UNRESOLVED_HYPOTHESIS / NEEDS_VERIFICATION.

### D. Steering-assist or steering-control loss

**CLM-STR-001**
- record_id: OH-UIK-013
- exact_claim: In the cited Honda HR-V manual, an EPS indicator means the EPS system has detected a problem.
- source_tier: VERIFIED_OEM_OR_GOVERNMENT / support_type: DIRECT / product_use_status: VISIBLE_GUIDANCE_SCOPE_LIMITED
- source: American Honda Motor Co., "Indicators" — HR-V Owner's Manual, 2025.
- limitations: Does not identify the failed component.

**CLM-STR-002**
- record_id: OH-UIK-013
- exact_claim: In the cited Honda HR-V manual, a persistent EPS indicator requires the vehicle to be checked by a dealer; a separate "Do not drive" message requires immediate safe stopping and dealer contact.
- source_tier: VERIFIED_OEM_OR_GOVERNMENT / support_type: DIRECT / product_use_status: VISIBLE_GUIDANCE_SCOPE_LIMITED
- limitations: The EPS indicator alone and the explicit "Do not drive" message must not be treated as equivalent.

**CLM-STR-003**
- record_id: OH-UIK-013
- exact_claim: Toyota's U.S. warning-light reference identifies its EPS warning as indicating a malfunction in the EPS system.
- source_tier: VERIFIED_OEM_OR_GOVERNMENT / support_type: DIRECT / product_use_status: VISIBLE_GUIDANCE_SCOPE_LIMITED
- source: Toyota Motor Sales U.S.A., "Toyota Dashboard Symbols and Warning Lights".
- limitations: Does not create one universal stop-or-drive instruction for every Toyota model.

**CLM-STR-004**
- record_id: OH-UIK-013
- exact_claim: OpenHood must not convert an EPS warning into a confirmed steering-rack, motor, pump, module, battery, wiring, or sensor failure.
- source_tier: NO_EXTERNAL_SOURCE_PRODUCT_POLICY / support_type: NONE / product_use_status: PRODUCT_POLICY
- source: OpenHood, "System-Level Warning Interpretation Policy".

**CLM-STR-005** (excluded, corrected in v1.2)
- record_id: OH-UIK-013
- exact_claim: Actual inability to steer normally, severe looseness, binding, or loss of directional control warrants stopping safely rather than continuing ordinary driving.
- source_tier: UNRESOLVED_HYPOTHESIS / support_type: INFERENCE / product_use_status: RESEARCH_ONLY
- source: NHTSA, "Tire Safety Ratings and Awareness — TireWise".
- limitations: The cited NHTSA material addresses tire blowouts and stabilization, not universal conventional steering-assist/steering-control failure. The previous v1.1 use was overbroad.
- Visible use: Excluded.

**CLM-STR-005P**
- record_id: OH-UIK-013
- exact_claim: When a user reports that the vehicle cannot be directed normally, OpenHood should use STOP DRIVING and avoid asking the user to continue or road-test it.
- source_tier: NO_EXTERNAL_SOURCE_PRODUCT_POLICY / support_type: NONE / product_use_status: PRODUCT_POLICY
- source: OpenHood, "Reported Loss-of-Control Routing Policy".

**CLM-STR-006** (excluded) — If steering assistance returns after a restart, the original condition is not proven repaired. UNRESOLVED_HYPOTHESIS / NEEDS_VERIFICATION. Source: Ford Motor Company, "Electric Power Steering Precautions" (does not directly state the claim; procedure is not universal).

**CLM-STR-007**
- record_id: OH-UIK-013
- exact_claim: Loss of power steering assistance may leave some vehicles mechanically steerable but require substantially more steering effort.
- source_tier: VERIFIED_OEM_OR_GOVERNMENT / support_type: DIRECT / product_use_status: VISIBLE_GUIDANCE_SCOPE_LIMITED
- source: Kia America, Inc. / NHTSA recall repository, "Important Safety Recall — Certain 2024 Kia Sportage Vehicles", recall 24V422, 2024-07-19.
- limitations: Applies only to the recalled population (~1,075 vehicles, production dates April 30–May 23, 2024). Cannot be silently converted into a universal steering rule. **Independently confirmed accurate via NHTSA recall report, 2026-08-03.**

**CLM-STR-008**
- record_id: OH-UIK-013
- exact_claim: Certain Ford information messages explicitly instruct the driver to stop safely when the power-steering system is not working.
- source_tier: VERIFIED_OEM_OR_GOVERNMENT / support_type: DIRECT / product_use_status: VISIBLE_GUIDANCE_SCOPE_LIMITED
- source: Ford Motor Company, "Steering — Information Messages".
- exact_claim_supported: "Steering Loss — Stop Safely" when the power-steering system is not working.
- limitations: Only applies when the exact Ford message and applicable manual match.

---

## 4. Corrected normalized four-record knowledge pack

The records below include only visible guidance supported by eligible source claims, scope-checked OEM claims, or explicit PRODUCT_POLICY. Unsupported cause lists have been removed from visible content.

### Record OH-UIK-001 — Flashing check-engine light with shaking or rough running

- applicable_vehicle_scope: Gasoline-powered passenger vehicles; exact OEM instructions required; excludes unconfirmed warning symbol, diesel-specific warning, hybrid system warning not confirmed as check engine, heavy commercial vehicle.
- trigger_tags: flashing_check_engine_light, confirmed_flashing_MIL, shaking, rough_running, power_loss.
- safety_gate: driving_status = CHECK BEFORE DRIVING (claims: CLM-MIL-005). immediate_action: Confirm the symbol is the engine-shaped check-engine indicator. If moving, avoid hard acceleration and move to a safe place. Use the exact owner's manual before deciding whether the vehicle may be moved again. (claims: CLM-MIL-002, CLM-MIL-003, CLM-MIL-005)
- follow_up_questions: (MIL-Q1) Are you currently driving? (MIL-Q2) Is the engine-shaped light flashing now, or did it stop? (MIL-Q3) Is the engine shaking badly or losing major power? (MIL-Q4) Is there smoke, a strong raw-fuel odor, overheating, or a red oil warning?
- plain_language_assessment: A flashing engine warning with rough running can be associated with a misfire condition on some vehicles. It does not identify the failed part. (claims: CLM-MIL-001, CLM-MIL-004)
- possible_system_categories: Combustion or misfire-related condition (scope_limited, CLM-MIL-001).
- remaining_uncertainty: exact cause; affected cylinder or system; whether recent service is relevant; whether the applicable manufacturer permits restricted movement.
- safe_evidence_requests: Photograph the confirmed warning symbol while parked. Record whether the light is flashing or steady. Save scan results before clearing them. Record recent service, refueling, or modifications. Record a short stationary video of the rough running if safe.
- actions_to_avoid: Do not use heavy acceleration to test the problem (CLM-MIL-002). Do not tell the user that a coil, plug, injector, or sensor is confirmed failed (CLM-MIL-004). Do not apply Ford or Honda continuation instructions to another vehicle without a scope match (CLM-MIL-005).
- smartest_next_step: CHECK BEFORE DRIVING — confirm the symbol, preserve codes and event details, consult the exact owner's manual. Severe active shaking, smoke, overheating, raw-fuel odor, or major power loss should be routed to STOP DRIVING.
- confirmation_step: Confirm exact warning symbol. Confirm manufacturer, model, model year, market. Confirm whether symptom is active now.
- mechanic_summary_fields: warning symbol; flashing or steady; active now or stopped; shaking severity; power loss; codes and freeze-frame data if available; recent repairs or modifications; other warnings, smoke, odor, or overheating.
- visible_claim_ids: CLM-MIL-001, CLM-MIL-002, CLM-MIL-003, CLM-MIL-004, CLM-MIL-005. excluded_claim_ids: CLM-MIL-006.
- review_status: APPROVED_FOR_PRODUCT_REVIEW_WITH_SCOPE_GATES

### Record OH-UIK-006 — Overheating or visible engine-bay steam

- applicable_vehicle_scope: Liquid-cooled gasoline passenger vehicles; exact OEM instructions required; excludes ordinary tailpipe vapor, unconfirmed condensation, battery-electric thermal warning, air-cooled engine.
- trigger_tags: overheating, high_temperature_warning, gauge_in_hot_zone, steam_under_hood, coolant_spray.
- safety_gate: driving_status = STOP DRIVING (CLM-OHT-005); restart_status = CHECK BEFORE DRIVING. immediate_action: Move to a safe location and shut the engine down. Keep away from active steam. Do not open the cooling system while it is hot. Use the exact owner's manual before inspection or restart. (claims: CLM-OHT-001, CLM-OHT-002, CLM-OHT-003, CLM-OHT-005)
- follow_up_questions: (OHT-Q1) Are you driving now? (OHT-Q2) Is steam or spray actively coming from under the hood? (OHT-Q3) Is a temperature warning active, or was the gauge in the hot zone? (OHT-Q4) Is fluid visibly discharging or pooling?
- plain_language_assessment: The vehicle has evidence of a possible high-temperature or pressurized cooling-system event. The cause is not confirmed. (CLM-OHT-005)
- possible_system_categories: Cooling-system temperature or pressure event (cautious_general_category, CLM-OHT-005).
- remaining_uncertainty: whether the material is steam, smoke, or another vapor; coolant level; leak source; airflow/circulation/pressure/indication cause; whether restart is allowed by the exact manual.
- safe_evidence_requests: Photograph the temperature warning or gauge while parked. Observe steam only from a safe distance. Photograph visible fluid or residue without touching it. Record recent cooling-system service. Check coolant level only after cooldown and only under the exact manual procedure.
- actions_to_avoid: Do not open the hood while steam is actively escaping on vehicles covered by the cited Honda procedure (CLM-OHT-002). Do not loosen a hot cooling-system cap on vehicles covered by the cited Toyota procedure (CLM-OHT-003). Do not name a thermostat, fan, water pump, cap, sensor, or head gasket as failed from this symptom alone (CLM-OHT-005). Do not apply one OEM's exact restart procedure to another vehicle (CLM-OHT-005).
- smartest_next_step: STOP DRIVING — shut the vehicle down safely, allow it to cool, preserve warning and fluid evidence, consult the exact owner's manual before inspection or restart.
- confirmation_step: Confirm the temperature warning or gauge. Confirm active steam versus smoke or unknown vapor. Confirm vehicle identity and exact owner's manual.
- mechanic_summary_fields: temperature warning or gauge position; steam or spray present; active now or stopped; visible fluid and location; driving condition when it occurred; recent cooling-system work; whether the engine was restarted.
- visible_claim_ids: CLM-OHT-001, CLM-OHT-002, CLM-OHT-003, CLM-OHT-004, CLM-OHT-005. excluded_claim_ids: CLM-OHT-006, CLM-OHT-007.
- review_status: APPROVED_FOR_PRODUCT_REVIEW_WITH_SCOPE_GATES

### Record OH-UIK-011 — Soft, sinking, hard, or weak braking

- applicable_vehicle_scope: Passenger vehicles with service brakes; exact OEM instructions required; excludes vibration-only with normal stopping, normal ABS pulsation not yet verified, parking-brake indicator with brake applied.
- trigger_tags: soft_brake_pedal, spongy_brake_pedal, sinking_pedal, hard_pedal, weak_braking, increased_stopping_distance, red_brake_warning.
- safety_gate: driving_status = STOP DRIVING (CLM-BRK-005). immediate_action: If the vehicle cannot slow or stop normally, stop using it and do not road-test it. Confirm any dashboard warning through the exact owner's manual. (claims: CLM-BRK-001, CLM-BRK-002, CLM-BRK-005)
- follow_up_questions: (BRK-Q1) Are you currently driving? (BRK-Q2) Can the vehicle slow and stop as normally as before? (BRK-Q3) Does the pedal feel soft, continue sinking, feel unusually hard, or feel normal? (BRK-Q4) Is a red brake warning confirmed in the exact owner's manual?
- plain_language_assessment: The braking system is not behaving normally. A soft or spongy pedal may be associated with air or hydraulic leakage, but the symptom does not confirm a specific failure. (CLM-BRK-003, CLM-BRK-004)
- possible_system_categories: Hydraulic pressure or brake-fluid containment (possible_not_confirmed, CLM-BRK-003). Other braking or assist condition (uncertainty_only, CLM-BRK-004).
- remaining_uncertainty: exact failed system or component; whether stopping performance is materially reduced; exact warning symbol; whether visible fluid is brake fluid; whether recent service is relevant.
- safe_evidence_requests: Photograph the dashboard warning while parked. Describe pedal feel without road-testing. Photograph visible fluid without touching it or crawling under the vehicle. Preserve recent brake-service documentation.
- actions_to_avoid: Do not road-test a vehicle reported to have reduced braking (CLM-BRK-005). Do not name a master cylinder, booster, caliper, hose, or ABS unit from pedal feel alone (CLM-BRK-004). Do not apply the 2025 RAV4 warning instruction unless the vehicle and symbol match (CLM-BRK-001).
- smartest_next_step: STOP DRIVING — keep the vehicle out of ordinary use and arrange professional brake-system inspection when stopping ability or pedal behavior is materially abnormal.
- confirmation_step: Confirm whether stopping ability changed. Confirm the exact warning symbol. Confirm whether the incident is active now.
- mechanic_summary_fields: stopping ability; pedal feel; warning symbol and color; active now or intermittent; visible fluid; recent brake service; conditions when the symptom occurs.
- visible_claim_ids: CLM-BRK-001, CLM-BRK-002, CLM-BRK-003, CLM-BRK-004, CLM-BRK-005. excluded_claim_ids: CLM-BRK-006, CLM-BRK-007.
- review_status: APPROVED_FOR_PRODUCT_REVIEW_WITH_SCOPE_GATES

### Record OH-UIK-013 — Steering-assist warning or steering-control loss

- applicable_vehicle_scope: Passenger vehicles; exact OEM instructions required; excludes mild vibration only, minor pull only, driver assistance intervention, unconfirmed warning symbol.
- trigger_tags: EPS_warning, power_steering_warning, heavy_steering, steering_assist_loss, steering_loose, steering_binding, cannot_control_direction.
- safety_gate: default_state = CHECK BEFORE DRIVING (CLM-STR-001, CLM-STR-002, CLM-STR-003). loss_of_control_state = STOP DRIVING (CLM-STR-005P). immediate_action: First determine whether this is only a warning or whether the vehicle can no longer be directed normally. An explicit OEM "Stop safely" or "Do not drive" message must follow that exact manual. Reported loss of directional control routes to STOP DRIVING under OpenHood policy. (claims: CLM-STR-002, CLM-STR-005P, CLM-STR-008)
- follow_up_questions: (STR-Q1) Are you currently driving? (STR-Q2) Can you steer and control the direction normally? (STR-Q3) Is there an EPS, power-steering, "Stop safely," or "Do not drive" message? (STR-Q4) Does the steering feel heavy, loose, binding, intermittent, or unresponsive?
- plain_language_assessment: The vehicle may have a steering-assistance or steering-control problem. A warning identifies a system-level concern, not the failed component. (CLM-STR-001, CLM-STR-003, CLM-STR-004)
- possible_system_categories: Power-steering or EPS system (system_level_only, CLM-STR-001, CLM-STR-003). Steering-control concern (uncertainty_only, CLM-STR-005P).
- remaining_uncertainty: exact warning and OEM instruction; assistance loss versus directional-control loss; electrical/hydraulic/mechanical/wheel/tire/suspension cause; whether restarting is an applicable OEM procedure; whether the vehicle remains safely steerable.
- safe_evidence_requests: Photograph the exact warning while parked. Describe steering behavior without conducting a road test. Record recent impact, tire service, battery issue, or steering repair. Photograph visible tire or wheel damage from a safe position.
- actions_to_avoid: Do not identify a steering rack, motor, pump, module, sensor, or battery as failed from the warning alone (CLM-STR-004). Do not apply the Kia recall's increased-effort statement to unrelated vehicles (CLM-STR-007). Do not apply Ford's "Steering Loss — Stop Safely" wording unless the exact vehicle message and manual match (CLM-STR-008). Do not use the prior NHTSA tire-blowout source as steering-loss guidance (CLM-STR-005).
- smartest_next_step (conditional): Vehicle cannot be directed normally → STOP DRIVING (CLM-STR-005P). Exact OEM message says Stop safely or Do not drive → STOP DRIVING (CLM-STR-002, CLM-STR-008). EPS warning only and steering remains normal → CHECK BEFORE DRIVING (CLM-STR-001, CLM-STR-002, CLM-STR-003).
- confirmation_step: Confirm exact warning or message. Confirm manufacturer, model, model year, market. Confirm whether steering control is actually impaired.
- mechanic_summary_fields: exact warning and message; steering normal/heavy/loose/binding/unresponsive; active now or intermittent; speed and event when it began; recent impact, battery event, tire work, or repair; whether an OEM-authorized restart procedure was attempted.
- visible_claim_ids: CLM-STR-001, CLM-STR-002, CLM-STR-003, CLM-STR-004, CLM-STR-005P, CLM-STR-007, CLM-STR-008. excluded_claim_ids: CLM-STR-005, CLM-STR-006.
- review_status: APPROVED_FOR_PRODUCT_REVIEW_WITH_STRICT_SCOPE_GATES

---

## 5. Explicit exclusion list

Excluded claim IDs: CLM-MIL-006, CLM-OHT-006, CLM-OHT-007, CLM-BRK-006, CLM-BRK-007, CLM-STR-005, CLM-STR-006.

Excluded automotive assertions — OpenHood must not visibly assert that: a trouble code proves the named component failed; flashing MIL instructions from Ford apply to Toyota, Nissan, Honda, or another make; Honda blinking-MIL procedures apply to every Honda model; every overheating event requires the same cooldown or restart procedure; water beneath the passenger side is normal A/C condensation without further evidence; loss of cabin heat confirms low coolant or failed circulation; a soft pedal confirms air or a leak; a sinking pedal confirms a master-cylinder failure; a hard pedal confirms a booster failure; pumping the pedal means the brakes are temporarily safe; adding brake fluid resolves the incident; an EPS warning confirms a steering-rack failure; all vehicles remain mechanically steerable after power-assist loss; the Kia Sportage recall describes every EPS system; the NHTSA tire-blowout procedure is steering-failure guidance; restarting and regaining assistance proves the condition is resolved.

Excluded product behavior — OpenHood must not: let an excluded claim change the driving state; include an excluded cause in the plain-language assessment; use an excluded claim to tell the owner what action to take; use an excluded claim in "actions to avoid" as though verified; include an excluded diagnosis in the mechanic summary; present an OEM instruction without applicability matching; elevate a community pattern into a safety rule; silently rewrite an inference as fact.

---

## 6. Acceptance tests for evidence gating

1. **Unsupported cause cannot control assessment.** A claim with support_type NONE / product_use_status NEEDS_VERIFICATION must not appear as fact, select a system category, or affect driving status. Pass: "The cause is not confirmed." Fail: "Your water pump is likely failing."
2. **Product policy may control caution, not technical attribution.** May say "OpenHood cannot confirm the failed component from this symptom." May not say "Ford confirms this symptom cannot identify the failed component" unless Ford directly supports that exact claim.
3. **OEM scope must match.** A 2025 Toyota RAV4 brake-warning claim must not control visible guidance for a 2018 Honda Civic. The app may use general OpenHood policy while requesting the exact Honda manual.
4. **Warning symbol must be confirmed.** If the user selects "flashing warning light" but the exact symbol is unknown, the app must not invoke the flashing-check-engine record as confirmed; required state is CHECK BEFORE DRIVING with assessment "Warning symbol not yet confirmed." Exception: independently reported smoke, fire, control loss, weak braking, or overheating may activate its own eligible record.
5. **Active and stopped symptoms remain distinct.** If a flashing check-engine light stopped, preserve symptom_active_now: false, event_occurred: true. Must not claim "The issue is gone."
6. **Steering warning versus control loss.** EPS warning with normal steering → CHECK BEFORE DRIVING subject to the exact manual. Reported inability to direct the vehicle normally → STOP DRIVING under CLM-STR-005P, clearly classified as PRODUCT_POLICY.
7. **NHTSA tire guidance cannot drive steering logic.** CLM-STR-005 (RESEARCH_ONLY) must not produce STOP DRIVING, appear in visible assessment, generate immediate steering instructions, or appear in the mechanic summary.
8. **Recall information remains recall-specific.** CLM-STR-007 concerns certain recalled 2024 Kia Sportage vehicles; if the current vehicle is not inside that recalled population, the claim must not appear in visible guidance.
9. **Braking causes remain non-diagnostic.** May say "A soft or spongy pedal may be associated with a hydraulic-pressure or fluid-containment concern." Must not say "You have air in the lines" or "Your master cylinder failed."
10. **Exact OEM emergency message overrides generic state.** If the exact matched owner's manual displays "Do not drive" or "Steering Loss — Stop Safely," the scope-matched OEM claim may set state: STOP DRIVING. A generic EPS warning without that message must not automatically inherit it.
11. **Excluded claims cannot enter mechanic summary.** CLM-OHT-007 (NEEDS_VERIFICATION) must not produce "Cabin heat went cold, confirming low coolant flow" — only the observation: "Cabin heat reportedly became cold while the temperature warning rose."
12. **Observation, inference, and fact remain separate.** Every generated incident result must preserve separate fields for user-reported observation, verified/scope-matched fact (with source claim IDs), OpenHood policy (with policy claim IDs), and uncertainty (excluded/unverified claim IDs). No field may silently migrate from uncertainty to fact.
13. **One manufacturer cannot establish universal guidance.** If only one OEM supports an exact instruction, product_use_status must be VISIBLE_GUIDANCE_SCOPE_LIMITED, not VISIBLE_GUIDANCE_APPROVED for all vehicles.
14. **Deferred records remain inactive.** OH-UIK-002, 003, 004, 005, 007, 008, 009, 010, 012 must remain status: DEFERRED_RESEARCH, visible_guidance_enabled: false, and must not become separate product routes or screens during this revision.

---

## 7. Deferred research preserved (inactive, no visible guidance authorized)

- OH-UIK-002 — Steady check-engine light without drivability symptoms
- OH-UIK-003 — Rough running shortly after service
- OH-UIK-004 — Starts, then immediately stalls
- OH-UIK-005 — Stalls at idle or while stopping
- OH-UIK-007 — Reservoir boiling after shutdown
- OH-UIK-008 — Persistent raw-fuel odor
- OH-UIK-009 — Burning-fluid or electrical odor
- OH-UIK-010 — Brake pulsation or braking vibration
- OH-UIK-012 — Speed-related steering vibration or pull

---

## 8. Master Advisor review outcome

Reviewed 2026-08-03. Structural review (scope-limiting, product-policy separation, exclusion list, acceptance tests, existing urgency states only, deferred records inactive) passes on its own terms. Four of the highest-stakes citations (Ford misfire/MIL, Honda overheating/steam, Toyota RAV4 brake warning, Kia recall 24V422) were independently spot-checked against public sources and confirmed accurate. Remaining citations were not independently verified before this handoff.

Cleared for Engineering handoff for the four Phase 1 records only (OH-UIK-001, OH-UIK-006, OH-UIK-011, OH-UIK-013). The nine deferred records remain inactive. No expansion beyond these four families is authorized in this pass.
