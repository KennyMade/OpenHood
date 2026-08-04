# OpenHood — Master Handoff for Codex

Last updated: 2026-08-04, by Claude (Cowork "Master Advisor" session), for Kenneth Acosta.
Purpose: let Codex pick up this project accurately, without re-deriving context or re-doing work that's already done and verified tonight.

---

## 1. Who you're working with

Kenneth describes himself as non-technical. Work this way:
- Plain English, no unexplained jargon.
- One step at a time for anything involving Xcode/Terminal/Finder navigation.
- Never say something is done, tested, or verified unless it actually is — this project has a strict "verify, don't assume" discipline that has held up all night and should not slip now.
- Nothing destructive, irreversible, or public-facing without his explicit go-ahead.
- He is also using Claude Code (in Terminal) for implementation and a Cowork "Master Advisor" Claude session for planning/review/research. Keep your work compatible with theirs — see Section 4 before touching git.

## 2. What OpenHood is

An iOS app (SwiftUI/Xcode) — a vehicle-care companion app. Key areas:
- **Garage** — tracking owned vehicles (`GarageView`, `GarageStore`, `SavedVehicle`).
- **Something Happened** — an incident-guidance flow with two genuinely different subsystems (see Section 6). This has been the focus of tonight's work.
- **Vehicle Plan** — still mostly placeholder; flagged as the strongest candidate for a real retention feature, not yet built out.
- Profile/Settings, tab navigation.

The core product thesis, grounded in Kenneth's own experience buying a 2014 4Runner and a 2006 350Z with unclear history: a trustworthy, on-demand tool for triaging car issues and sanity-checking shop diagnoses — "a calculator for these things," not an oracle. This was validated tonight through an adversarial multi-round review process (a separate AI chat playing skeptical "CEO"), which is documented informally in this session's chat history, not in a file — ask Kenneth if you need that context restated.

## 3. Where everything is

| Folder | What it is |
|---|---|
| `/Users/kenny.acost/Desktop/OpenHood/OpenHood` | **Live, active project.** Contains `OpenHood.xcodeproj`. |
| `/Users/kenny.acost/Desktop/OpenHood/OpenHood - OLD BACKUP (July 29)` / `(July 31)` | Old snapshots. Reference only, do not edit. |

Real source: `/Users/kenny.acost/Desktop/OpenHood/OpenHood/OpenHood/*.swift` (confirmed against `project.pbxproj`).

Key files touched tonight (all paths verified directly, not recalled from memory):
- `OpenHood/OpenHood/Features/Incidents/IncidentGuidanceKnowledge.swift` — Phase 1 general-knowledge records.
- `OpenHood/OpenHood/Features/Incidents/IncidentGuidanceEngine.swift` — routing/matching logic for both subsystems.
- `OpenHood/OpenHood/Features/Incidents/IncidentEvidenceGatedKnowledge.swift` — the ~30-claim emergency-safety ledger.
- `OpenHood/OpenHood/Features/Incidents/SomethingHappenedView.swift` — the intake UI, including tonight's new structured noise questions.
- `OpenHood/OpenHood/Models/IncidentGuidance.swift` — `IncidentGuidanceResult` / `IncidentGuidanceSnapshot` (includes new `factClaimIDs`/`policyClaimIDs`/`uncertaintyClaimIDs` fields added tonight).
- `OpenHood/OpenHood/Models/SavedVehicle.swift` — no VIN/recall field; this is why some claims (see Section 6) deliberately can't be vehicle-scoped.
- `OpenHood/OpenHood/IncidentKnowledgePack-v1.2.md` — the source knowledge-pack document the emergency ledger was built from, including its citation-verification notes.

## 4. Git status — read before touching anything

- Currently checked out on branch **`claude-work`** (confirmed via `.git/HEAD` just now).
- All of tonight's work (described in Section 5) was built and confirmed working via Xcode builds during this session. **Exact commit state was not independently re-verified while writing this handoff** — run `git log --oneline -15` and `git status` yourself before assuming what's committed vs. still-uncommitted. Don't guess.
- Do not merge, rebase, or touch any other branch without asking Kenneth first — this rule has held all night regardless of how "safe" a change seems.

## 5. What's actually done and verified tonight (not aspirational)

All of the following were confirmed by direct code reading and/or live on-device Simulator testing during this session — not assumed:

- **Incident Knowledge Pack v1.2 fully integrated** into the four emergency safety families (flashing check-engine, overheating, unsafe brakes/steering). ~30 claims, each tagged `source_tier` / `support_type` / `product_use_status`, enforced through a single visibility chokepoint (`IncidentClaimVisibility`) so unsupported claims can't reach the screen.
- **4 of the highest-stakes citations independently verified** via live web search (Honda overheating/steam, Ford blinking-MIL, Toyota RAV4 brake warning, Kia Sportage recall 24V422). Documented with sources in `IncidentKnowledgePack-v1.2.md`.
- **All 14 acceptance tests from the knowledge pack pass** against real code (13 clean, 1 — test 5 — passes with a documented, pack-consistent simplification). This includes the two that were closed last, tonight:
  - Test 10 (exact OEM "do not drive" message overriding the generic gate): built for the 2025 Honda HR-V only (CLM-STR-002) — the Ford equivalent claim (CLM-STR-008) is intentionally left unscoped/inactive because its own source citation never names a specific model or year, so it cannot be safely scope-matched. Don't "fix" this by guessing a Ford model — that would violate the pack's own scope rule.
  - Test 12 (separate observation/fact/policy/uncertainty fields): `IncidentGuidanceResult`/`Snapshot` gained `factClaimIDs`, `policyClaimIDs`, `uncertaintyClaimIDs` as new, additive fields (old saved incidents still decode fine, defaulting to empty arrays).
- **A real, confirmed gap was found and partly closed**: the non-emergency "Something Happened" path (Phase 1 general engine, separate from the 4 emergency families) had zero real content — all 8 of its original records were explicitly placeholder (`verificationState: .needsVerification`, `isPlaceholder: true`), and none covered noise/vibration/suspension at all. Live-tested with a real case (2006 Nissan 350Z, rear rattle/grind over bumps) before any fix: result was a generic `MONITOR — not enough information`, with follow-up questions that ignored the actual symptom.
- **Fix, built and live-device-verified**: new structured noise-qualifying questions (location / timing / sound — shown only for "A sound" or "A vibration or movement" observations, no free-text guessing required) plus one real sourced record, `phase1.suspension.bump-noise`, citing JD Power and 1A Auto, `isPlaceholder: false`. Confirmed live on device: same 350Z case now returns `SERVICE SOON` with real system-level content ("consistent with suspension or chassis noise under load... common sources include worn control-arm bushings, sway bar links or bushings, ball joints, or strut mounts") instead of the generic fallback.
- **Design confirmed intentional**: this new record has no vehicle scope (no make/model/year requirement) — verified directly in code. It's built from general, cross-vehicle mechanical knowledge, unlike the OEM-specific emergency claims, which *do* require exact scope matches because they cite one manufacturer's literal wording. This distinction matters — don't blur it when adding more content.

## 6. Architecture — two genuinely different subsystems, don't conflate them

1. **Urgent safety path**: fixed menu of 7 categories (flashing warning light, overheating/steam, unsafe brakes/steering, smoke/fire, strong fuel smell, engine won't stay running, not sure) → structured yes/no/multiple-choice follow-ups → routed through the evidence-gated claim ledger (Section 5). Only 4 of the 7 categories are backed by the verified ledger; the other 3 (smoke/fire, fuel smell, engine won't stay running) still use older hardcoded text, not yet run through the same verification discipline.
2. **Phase 1 general engine**: originally free-text keyword matching against `userDescription` (fragile — a real user testing this tonight typed "rattling and grinding" and matched nothing, because he never typed "control arm"). Tonight added a parallel, more reliable structured-question path (`.noiseAnswer` signals) for noise/vibration symptoms specifically. Free-text matching still exists for the other original 8 records and is still fragile — worth knowing if you extend those.

Both subsystems are fully on-device and deterministic. Zero external API calls, zero marginal cost. This is a deliberate, load-bearing architecture decision, independently stress-tested tonight — do not introduce an LLM call or paid data source without a real, explicit conversation with Kenneth first. That would break the cost/liability posture the whole app has been built around.

## 7. Proposed but NOT yet done — don't assume these exist

- **Brake-squeal record**: scoped and researched tonight (sources checked: Firestone Complete Auto Care, Bosch Auto Service, NAPA — squeal-only-when-braking = pad wear indicator, intentional design; progressing to grind = pad material gone, more urgent). An instruction file was prepared for Claude Code but **was not successfully built this session** — verify directly in `IncidentGuidanceKnowledge.swift` whether a `phase1.brakes.squeal` (or similarly named) record actually exists before assuming it does.
- **Cross-vehicle live verification**: the suspension-noise record is confirmed code-level to have no vehicle scope, and confirmed live-device-working on the 350Z — but has *not* yet been live-tested on a second, different vehicle (e.g., Kenneth's 4Runner) to visually confirm it fires the same way. Quick, worth doing before claiming "universal" as a tested fact rather than a code-verified one.
- **Resume-mid-flow gap**: if the app is killed between the Observations step and finishing the new noise questions, resuming currently skips straight to Description — the new questions get silently dropped. Flagged by Claude Code as real but low-stakes (these are supplementary evidence, not a safety gate). Not fixed. Ask Kenneth before prioritizing this.
- **UI/UX improvements identified, not built**: the incident-result screen buries its most differentiating content (real sources/citations) in a collapsed "Sources and confidence" accordion at the bottom — recommended elevating it near the top as a visible trust indicator. Also recommended: a simple visual location indicator (car outline, highlighted zone) instead of describing location in prose, since location is now a structured answer, not free text. The result screen is also fairly long (7 accordion sections) — worth a deliberate decision on trust-depth vs. speed, not yet made.
- **Warning-lights-beyond-check-engine and maintenance-interval records**: identified as good next candidates (common, well-documented, low legal risk) but not researched or built yet.

## 8. Older, unrelated open item — separate from tonight's work

- **Onboarding transmission/drivetrain gap** (Tasks in earlier session): a hardcoded special-case for the 2014 4Runner that skipped asking transmission/drivetrain questions was removed, and an "I'm not sure" choice was added to `DrivetrainView`. But `DrivetrainView` still isn't wired into the generic onboarding flow for all vehicles — most vehicles are still never asked about drivetrain at all except through the now-removed hardcoded path. Not touched tonight. Real, still open.

## 9. Deferred — not code work, not yours to decide

Business/product questions were raised and partly answered tonight but remain genuinely undecided: precise target-user positioning beyond "recent used-car buyer with unclear history" (validated via Kenneth's own story), first distribution channel (provisional hypothesis: model-specific/used-car enthusiast forums, untested), 90-day success metrics, kill criteria. Don't invent answers to these — flag them back to Kenneth if they come up.

## 10. Operating rules (carried forward, hold the line on these)

- **Verify, don't assume.** Check the actual code/state before claiming something works. If you didn't check, say so.
- **Evidence, not vibes.** Cite file and line for findings.
- **No sycophancy.** Don't open with praise; say plainly if something's wrong or a premise is off.
- **Say what you actually did.** Approximation is not the real thing — label it.
- **Decide vs. ask**: reversible/low-stakes → make the call, state the assumption. Irreversible/ambiguous/anything touching git branches or another tool's work → ask first.
- **Track multi-step work visibly**, don't narrate every step in prose.
- **Stay in scope, flag what you trip over** — don't silently expand, don't silently ignore.
- **Precision over padding.**
- **Own mistakes without collapsing.** This project has already had one real self-correction (an overclaimed citation-verification note, caught and fixed) — that's the standard to keep meeting, not a one-time event.

## 11. Suggested first steps for Codex

1. Run `git log --oneline -15` and `git status` — confirm what's actually committed before touching anything.
2. Read `IncidentGuidanceKnowledge.swift` directly to confirm which records actually exist (suspension-noise should be there; brake-squeal may or may not be — check, don't assume).
3. If picking up the brake-squeal work: sources are already researched (Section 7) — build the record, reuse the existing `.noiseAnswer` structured-question infrastructure, test on a real vehicle in the Simulator, report the real before/after.
4. Ask Kenneth what he wants prioritized next before doing anything not listed above — this project has stayed disciplined tonight by never quietly expanding scope, and that's worth protecting.
