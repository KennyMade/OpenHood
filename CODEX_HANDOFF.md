# OpenHood — Master Handoff

Last updated: 2026-08-05 (mid-day), by Claude (Cowork "Master Advisor" session), for Kenneth Acosta.
Purpose: let a fresh chat (Codex, ChatGPT, or otherwise) pick up this project accurately without re-deriving context or redoing work that's already done and verified. This replaces the earlier version from this morning — several things below were "in progress" there and are now done and committed.

---

## 1. Who you're working with

Kenneth describes himself as non-technical. Work this way:
- Plain English, no unexplained jargon.
- One step at a time for anything involving Xcode/Terminal/Finder navigation.
- Never say something is done, tested, or verified unless it actually is. This project runs on a strict "verify, don't assume" discipline — check the real code and real build/run output before claiming anything.
- Nothing destructive, irreversible, or public-facing without his explicit go-ahead.
- He also uses Claude Code (in Terminal) for implementation and a Cowork "Master Advisor" Claude session for planning/review/research/legal-risk checking. Keep work compatible with theirs — read Section 4 before touching git.
- He gets overwhelmed by long technical explanations under pressure, and he's often working close to a usage limit on whichever AI tool he's in. If he says he's near a limit or overwhelmed, prioritize getting a safety checkpoint committed over anything else, then summarize in 3 points or fewer.

## 2. What OpenHood is

An iOS app (SwiftUI/Xcode) — a vehicle-care companion app. Core loop: someone notices something wrong with their car, taps "Something Happened," answers a few questions, and gets a real, honest answer — a possible cause, not a diagnosis, with a "don't quote me, get it checked" framing throughout. No accounts, no backend, no server — everything runs on-device, deterministic, zero marginal cost per use. This is a deliberate, load-bearing architecture decision — do not introduce an LLM call or a paid external API without an explicit conversation with Kenneth first.

Core product thesis, grounded in Kenneth's own experience buying a 2014 4Runner and a 2006 350Z with unclear history: a trustworthy, on-demand second opinion for triaging car issues, not an oracle.

Real, current app areas:
- **Onboarding** — fast 3-step flow (welcome → vehicle → confirm), genuinely usable by anyone now (Section 5).
- **Garage** — saved vehicles (`GarageView`, `GarageStore`, `SavedVehicle`).
- **Something Happened** — the incident-guidance flow, two genuinely different subsystems (Section 6). Main focus of all work so far, and where nearly all recent progress is.
- **Learn** — placeholder only. Tiles route to `LearnTopicPlaceholderView`. Looks finished, isn't.
- **Plan** ("Plan your build" — Reliability/Performance/Style/Custom) — real, substantial code (~1,274 lines), but whether it belongs in this app's mission is still undecided. Don't expand it without asking Kenneth.
- Profile/Settings — data erase, works.

## 3. Where everything is

| Folder | What it is |
|---|---|
| `/Users/kenny.acost/Desktop/OpenHood/OpenHood` | **Live, active project.** Contains `OpenHood.xcodeproj`. |
| `/Users/kenny.acost/Desktop/OpenHood/OpenHood - OLD BACKUP (July 29)` / `(July 31)` | Old snapshots. Reference only, do not edit. |

Key files, all paths verified directly:
- `OpenHood/OpenHood/Features/Incidents/IncidentGuidanceKnowledge.swift` — Phase 1 general-knowledge records (the bulk of recent work).
- `OpenHood/OpenHood/Features/Incidents/IncidentGuidanceEngine.swift` — routing/matching/severity logic for both subsystems.
- `OpenHood/OpenHood/Features/Incidents/IncidentEvidenceGatedKnowledge.swift` — the emergency-safety claim ledger (urgent path), now includes `CLM-OIL-001`.
- `OpenHood/OpenHood/Features/Incidents/SomethingHappenedView.swift` — intake UI, including all structured questions (noise, warning-light, fluid/odor).
- `OpenHood/OpenHood/Models/IncidentGuidance.swift` — result/snapshot models, `IncidentDriveRecommendation`, `IncidentClaimVehicleScope`.
- `OpenHood/OpenHood/Models/VehicleIncident.swift` — `IncidentSafetySelection` (the fixed 7-category urgent menu).
- `OpenHood/OpenHood/VehicleCatalog.swift` — vehicle make/model/year data (narrower than it looks, see Section 5).
- `OpenHood/OpenHood/ContentView.swift` — onboarding screens, including `ManualVehicleEntryView`.
- `OpenHood/PRIVACY_POLICY.md` — drafted, needs a real contact email and an SDK audit before publishing.

## 4. Git status — read before touching anything

- Checked out on branch **`claude-work`**.
- Last confirmed commit: **`289342f`** — "Safety checkpoint: brake squeal, warning lights, oil-pressure severity fix, fluid-leak/odor content." This was committed as a protective checkpoint while Kenneth was near a usage limit, **not** after full live-Simulator verification — the code was checked for structural integrity (balanced braces, no truncation across every modified file) but the actual on-screen behavior of the newest pieces (fluid-leak/odor content, the odor-escalation routing) has not yet been confirmed by a live test the way brake-squeal and the manual-vehicle-entry fix were.
- Run `git status` and `git log --oneline -10` yourself before assuming anything beyond what's in this file — don't trust this document over the real repo state.
- Do not merge, rebase, or touch any other branch without asking Kenneth first.

## 5. What's done — verified vs. needs a live check

**Verified by live on-device Simulator testing (highest confidence):**
- Onboarding rebuilt: fast 3-step flow, catalog auto-fill, and a manual-entry fallback (`ManualVehicleEntryView`) for any vehicle not in the catalog — the catalog only ever had 3 fully-supported vehicles (Nissan 350Z, Toyota 4Runner, Honda Civic); this fallback is why the app works for anyone now. Live-tested with a 2015 Ford F-150.
- Incident-result screen redesign: severity ladder, tap-to-explain possible areas, cost ranges with an honest "not a quote" caveat, a "Find a shop" button (Apple Maps handoff, no paid API), and JD Power/1A Auto names removed from anywhere on screen (kept as internal-only research notes).
- Suspension/bump-noise content (`phase1.suspension.bump-noise`) — real, sourced, no vehicle scope required.
- Brake-squeal content (`phase1.brakes.squeal-while-braking`) — real, sourced, four possible areas with cost ranges.

**Committed and code-verified for structural integrity, but not yet confirmed live on screen — check before treating as final:**
- Steady check-engine + battery/charging light content (`phase1.warning.record-code`, `phase1.warning.engine-information`), with a structured "which light" question.
- Oil-pressure severity fix: `urgentDriveRecommendation` now has an explicit `"Oil pressure"` branch returning `.stopDriving`, backed by a new claim `CLM-OIL-001` in the evidence ledger, following the same pattern as the existing AAA-sourced `CLM-BRK-003`.
- Fluid-leak content: a structured "what color" question with real content for coolant (green/orange/pink/yellow), engine oil (brown/black), transmission-or-power-steering (red), and normal AC condensation (clear).
- Odor content: a structured "which smell" question with real content for sweet/coolant-like and musty/moldy smells.
- Odor-escalation fix: "Electrical or burning plastic" and "Exhaust" were deliberately excluded from the safe odor content above (both are genuinely serious — electrical smell is a fire-risk precursor, exhaust smell inside the cabin is a carbon-monoxide risk). Instead of building them as capped-severity Phase 1 content, they were routed through the existing urgent categories: selecting "Electrical or burning plastic" routes through the same logic as `.smokeOrFire`, and "Exhaust" routes through `.strongFuelSmell` — reusing the one place in the codebase that already handles these correctly rather than creating a second, parallel severity decision.

**Next step for whoever picks this up:** build and run in the Simulator, walk through each of the items in the second list above at least once, and confirm the on-screen result matches what's described. None of it should be assumed broken, but none of it should be assumed perfect either.

**Known, unfixed:**
- VIN scanner is not real — offered as a primary onboarding option, leads to "Camera scanning is coming next." Either build it or stop presenting it as working.
- Two visual polish items, not yet fixed: a description field on the "Review incident" screen visually truncates instead of wrapping (code has no explicit line limit, so the cause needs to be found — likely a container/row-style issue, not the Text view itself); the severity ladder's four segments should be equal height but "Check before driving" visibly runs taller than the others, most likely because it's the longest label and wraps to two lines while the others don't.
- Worth a deliberate look: multiple flows now end with a free-text "Description" step immediately after a structured question already captured the same information (e.g., "which color" then also "describe it in your own words"), which reads as repetitive. The old free-text `questions` arrays on each content record are unused metadata, not a duplicate-screen source — the repetition is more likely the structured-question-plus-Description pattern repeating across every flow. Worth deciding whether Description should become skippable once a structured answer already has enough signal, given the goal of this app feeling as fast as a calculator.

## 6. Architecture — two genuinely different subsystems, don't conflate them

1. **Urgent safety path.** Fixed menu of 7 categories (`IncidentSafetySelection`) → structured follow-ups → `urgentDriveRecommendation`, which can return the full severity range including STOP DRIVING and DO NOT RESTART, backed by the evidence-gated claim ledger. Flashing check-engine and oil-pressure are both now correctly handled here (Section 5).
2. **Phase 1 general engine.** Reached through free-form description or structured questions for sound/vibration, warning-light, and fluid/odor reports. `ordinaryDriveRecommendation` can only ever return SERVICE SOON, CHECK BEFORE DRIVING, or MONITOR — **never STOP DRIVING.** Do not build genuinely dangerous content here; route it through the urgent path instead, the way oil-pressure and the odor-escalation fix both do.

Both subsystems are fully on-device and deterministic — see Section 2 on why that matters.

## 7. Good next content candidates, not yet researched or built

- A live cross-vehicle check: re-run the suspension-noise and brake-squeal flows on a second real vehicle (4Runner or Civic), not just the Ford F-150 test, to visually confirm no vehicle-scope requirement ever leaks in by accident.
- Beyond what's built, common remaining gaps in Phase 1 content: rough-running/stalling-after-service, and the two original starting/electrical placeholder records — all still marked `.needsVerification` placeholder.
- The Learn tab (Section 2) is a bigger, separate project — real content behind it hasn't been scoped at all yet. Don't start this without asking Kenneth; it's a different shape of work than the Something Happened content records.

## 8. Deferred — business/product questions, not code work

Not decided, don't invent answers: precise target-user positioning beyond "recent used-car buyer with unclear history," first distribution channel, 90-day success metrics, explicit kill criteria, monetization mechanism and timing (leaning: keep core guidance free, paid tier for extras like Plan/deeper cost detail — direction only, not approved as a build task), whether the Plan tab belongs in the app at all. Flag these back to Kenneth if they come up — they're his calls.

## 9. Operating rules — hold the line on these

- **Verify, don't assume.** Check the actual code/git state before claiming something works or exists.
- **Evidence, not vibes.** Cite file and line for findings.
- **No sycophancy.** Say plainly if something's wrong or a premise is off.
- **Say what you actually did**, not what you predicted would happen.
- **Decide vs. ask**: reversible/low-stakes → make the call, state the assumption. Irreversible/ambiguous/anything touching git branches or another tool's in-progress work → ask first.
- **Check licensing/legal exposure before naming a source on screen.** Keep researched facts, never display a company's brand name or reproduce someone's exact written words without confirming it's allowed. This has already been caught and corrected once (JD Power/1A Auto) — the standard now, not a one-time fix.
- **Severity honesty over speed.** Before adding any new symptom content, check whether it's genuinely dangerous (fire, carbon monoxide, engine-damage-risk, brake failure). If so, it must route through the urgent path, which can express STOP DRIVING — never build it as Phase 1 content, which structurally cannot. This exact mistake was caught and fixed twice already (oil-pressure, then the odor-escalation) — check for it every time before writing new content, not after.
- **Commit checkpoints proactively**, especially when Kenneth mentions being close to a usage limit — don't wait to be asked, and verify structural integrity (balanced braces, no truncated statements) before committing if there's any chance work was interrupted mid-write.

## 10. Suggested first steps for whoever picks this up

1. Run `git status` and `git log --oneline -10` — confirm the real current state against Section 4.
2. Build and run in the Simulator. Walk through each item in Section 5's "needs a live check" list once, confirm it behaves as described.
3. Fix the two small visual issues in Section 5 if nothing bigger is queued.
4. Ask Kenneth what he wants prioritized next before starting anything not listed here — especially before touching the Learn tab or Plan tab, both bigger, undecided pieces of work.
