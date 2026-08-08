# OpenHood — Handoff Brief

> **This is the current, authoritative handoff document.** It lives in the
> repo, so it travels with the code and is always in sync with whatever
> commit you have checked out — no need to be sent a copy.
>
> Companion document: `INTAKE_REDESIGN_SPEC.md` (same folder) — the build
> spec for the diagnostic intake rework, steps 1–3 of which are done.
>
> **Ignore these older files, they are stale and predate this work:**
> `CLAUDE_HANDOFF.md` (Aug 3) and the previous contents of this file (Aug 5).

Prepared August 8, 2026, ~4:30 PM. Supersedes all earlier versions of this
file. Written to be self-contained: whoever reads this does not need any
prior conversation.

**This file does not update itself.** If it was AirDropped or copied
somewhere, that copy is frozen at the moment it was sent. Re-send it after
any further work.

---

## What OpenHood is

A solo-founder iOS app (SwiftUI) that helps a car owner understand a vehicle
concern in plain language, without pretending to replace a mechanic. Four
tabs: Home, Garage, Help (the "Something Happened" diagnostic flow), and
Learn. The owner is Kenneth Acosta — not a developer. He needs plain
language, exact copy-paste commands, and no assumed familiarity with git,
Xcode, or terminal conventions.

---

## Repo, build, and how to run it

- Local path: `~/Desktop/OpenHood/OpenHood` (open `OpenHood.xcodeproj`)
- GitHub: `KennyMade/OpenHood`
- Active branch: `claude-work`, at **`f2fba7b`**
- `main` was last synced at `18973dd` via PR #2. **Four commits are ahead of
  `main`:** `942736d`, `ebc4c17`, `8de22c1`, `f2fba7b`. Open a PR from
  `claude-work` into `main` when convenient.
- Last confirmed clean build: `8de22c1`. **`f2fba7b` is committed but has
  NOT been build-checked.** Do that first.

### Critical: building is not installing

`xcodebuild build` compiles but does **not** put the app on the simulator.
Kenneth lost real time testing a stale binary because of this. To actually
see changes, either press Run (▶) in Xcode, or:

```
xcodebuild -scheme OpenHood -configuration Debug -sdk iphonesimulator build
xcrun simctl install booted <path-to-OpenHood.app>
xcrun simctl launch booted <bundle-id>
```

When something "didn't change," **check the install before checking the
code.**

### Project-file quirk

Traditional Xcode file list, not Xcode 16+ synchronized folders (confirmed:
`grep -l "PBXFileSystemSynchronizedRootGroup" *.pbxproj` returns nothing). A
new `.swift` file created outside Xcode will not join the build target and
will silently not compile in. Add new code to an existing tracked file, or
create the file through Xcode itself.

---

## Current state, by the numbers

| Thing | Count |
|---|---|
| Diagnostic knowledge records | 64 |
| Named parts/areas across those records | 166 |
| Vehicle fact sheets (oil, coolant, tire pressure) | 32 |
| Maintenance how-to guides | 13 |
| Plan tab recommendations | 39 |
| Records marked unverified or placeholder | **0** |

That last row is the most valuable property in the codebase. Every record is
`verificationState: .reviewedGeneralPrinciple` with real source references.
**Do not add content that breaks this.** If a figure can't be confirmed, the
established pattern is to say so explicitly (`nil` fields, "Not
independently confirmed" text) rather than estimate.

---

## Architecture

**Diagnostic flow** — `OpenHood/Features/Incidents/`

- `SomethingHappenedView.swift` — the question flow, a `NavigationStack` over
  the `IncidentStep` enum
- `IncidentGuidanceKnowledge.swift` — the 64 records
- `IncidentGuidanceEngine.swift` — matching and scoring, plus the new
  `IncidentDescriptionRouter`
- `Models/VehicleIncident.swift` — `IncidentSafetySelection` (8 dangerous
  cases + `.noneOfThese`/`.unsure`), `IncidentObservationType` (8 cases,
  stored as an **Array**, not a Set)

Matching: a record's `required` evidence must ALL match, then score =
`observationMatches + (supportingMatches * 2) - (contradictingMatches * 3)`,
gated by `minimumScore` (default 3). **Ties break alphabetically by record
id** — this caused a real bug where `phase1.exhaust-smoke` beat
`phase1.fluid-smell.unusual-odor.musty` at equal score.

**Safety architecture — read this before touching the intake.** Every urgent
escalation fires from a question's *answer handler* (`brakeGrindEscalation`,
`dangerousOdorEscalation`, `engineOperationEscalation`,
`transmissionBehaviorEscalation`, `absTractionEscalation`,
`temperatureObservationEscalation`, `dashboardMessageEscalation`,
`dashboardBrakeLightEscalation`). **If any code pre-fills one of those
answers, the question is skipped and the escalation never runs** — a
burning-plastic smell would silently get ordinary maintenance guidance
instead of STOP DRIVING. `IncidentDescriptionRouter.forbiddenAnswers` exists
to enforce this and must not be weakened.

Adding a new dangerous answer requires updating six exhaustive switches over
`IncidentSafetySelection`: `urgentDriveRecommendation`, `urgentAssessment`,
`urgentContributors`, `urgentEvidenceRequests` (engine), plus
`urgentQuestions` and `safetyGuidance` (view).

**Plan tab** — `Features/Plan/VehiclePlanView.swift`. `.reliable`,
`.performance`, `.style` have real content; `.custom` is intentionally empty.
`PlanRecommendationLibrary.reliabilityPrototype` is a stale name — it holds
all goals.

**Learn tab** — `ContentView.swift` + `VehicleCatalog.swift`. "How does my car
work" and "Ask a question" are still placeholders and need a design
conversation, not a content pass.

**Vehicle catalog** — `VehicleCatalog.swift`. 17 makes. `VehicleModel`
`availability` **defaults to `.hidden`** — omitting it silently makes a model
unselectable. This was a real bug (Corolla, Camry, Tacoma). Always set it
explicitly.

---

## The intake redesign (in progress — read `OpenHood_Intake_Redesign_Spec.md`)

The full spec is in that companion file. Steps 1, 2, and 3 are **done**:

1. **`IncidentDescriptionRouter`** (`ebc4c17`) — turns typed prose into the
   same structured answers the menus produce. ~60 keyword rules. Verified
   against 11 sentences.
2. **Safety gate** (`f2fba7b`) — the intake opened with all ten dangerous
   options; now one question ("Is anything dangerous happening right now?")
   with those ten behind "yes."
3. **Description first** (`8de22c1`) — the observation checklist used to come
   before the text box; now the text box is first and the checklist is only
   the fallback when the router matches nothing.

Result: slow-crank goes from ~13 screens to about 3.

**Still to do (steps 4–5):** a confirmation line on the first remaining
question ("From what you wrote, I've got: engine turns over slowly…"), and
formally retiring the checklist as a normal screen.

---

## Open items, in the order I'd do them

1. **Build-check `f2fba7b`.** Not yet verified.
2. **THE DARK THEME PASS — Kenneth's most-repeated unmet request.** He has
   asked at least four times for the app's white backgrounds to become the
   dark teal from the app icon, with cards on the same scale and readable
   text. What was actually done was only `AccentColor` (which tints buttons
   and links — that's why buttons went teal but pages stayed white). The
   real work is per-view background colors across roughly a dozen files in
   `ContentView.swift`, `GarageView.swift`, `VehiclePlanView.swift`,
   `SomethingHappenedView.swift`. **Verified brand colors, sampled from the
   actual icon pixels:**
   - Deep teal `#0E4152` (dominant background)
   - Accent cyan `#4CECFD` (the sparkle mark)
   - White `#FEFEFE`
   `AccentColor.colorset` is already set to teal for light mode and cyan for
   dark. The backgrounds are the remaining job. **Start here.** It is the
   thing he most wants to see and the thing that has most repeatedly not
   happened.
3. **Model year coverage.** 350Z and 4Runner have full year lists; Tacoma and
   many others don't. Per-model research.
4. **Make `VehicleFactSheet.lookup` year-aware.** It matches make+model only,
   so a 2006 350Z is served figures researched for a 2009 with a different
   engine. Currently mitigated with an honest on-screen caveat, which is a
   patch, not a fix.
5. **Privacy Policy needs a public URL.** The in-app screen is real and
   accurate, but App Store Connect requires a hosted page. Smallest concrete
   blocker to TestFlight.
6. **Intake steps 4–5** from the spec.
7. **Settings screen** — Kenneth finds it long; wants collapsible sections.
8. **Home screen cards** — wants them on the brand color scale, not black.

---

## Things that went wrong today — so they don't repeat

- **"Nothing changed" was usually a stale install, not a code failure.** See
  the build-vs-install note above. Verify the binary before debugging code.
- **The wrong screen got fixed repeatedly.** Kenneth said "it goes to the
  choices again" several times meaning the *safety check*; it was read as the
  *observation checklist*. When a user describes a screen, confirm which one
  before changing code.
- **The color request was answered with the wrong fix three times.** Accent
  color ≠ background theme. He asked for backgrounds; accent was delivered.
- **A safety hole was nearly shipped in the router spec** — it routed
  "burning plastic" straight into the odor answer, which would have bypassed
  a fire-risk escalation. Caught before implementation. This is the class of
  mistake to watch for whenever anything pre-fills an answer.

---

## Working norms this project uses

- Never claim a build succeeded, a file saved, or content verified without
  checking. Kenneth is non-technical and relies on being told the truth.
- Every cost figure and legal claim is researched and cited, not invented.
- Verification discipline before each commit: programmatic brace/paren/
  bracket balance, duplicate-id scans, `git status --short`.
- Kenneth pushes to GitHub himself from Terminal. Hand him exact `cd` and
  `git push` commands as separate lines.
- He wants large complete batches with one check-in at the end, not
  incremental pieces with frequent interruptions.

---

## Next action

1. Build-check and push `f2fba7b`, then open a PR from `claude-work` into
   `main` (four commits ahead).
2. Then do the dark theme pass. Colors above. Backgrounds, not accents.
