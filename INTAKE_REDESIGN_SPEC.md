# OpenHood — "Something Happened" Intake Redesign

Written August 8, 2026. This is a build spec, not a discussion document. It is
precise enough to implement directly and is grounded in the current code, not
in a sketch of it.

---

## 1. The problem, with evidence

A person whose engine turns over slowly currently faces, before they can say
anything at all:

1. **Safety check** — 10 options, all alarming (smoke or fire, brakes unsafe,
   transmission slipping…)
2. **Observation** — 8 checkboxes, multi-select
3. **A question chain per box checked** — up to 4 questions each

Only after all of that do they reach a free-text box. A user testing this said
it "bombards me with pointless options that lead to nothing," and separately
that when they finally typed "turning slowly," the app "just repeated back what
I said" without a useful follow-up.

That second complaint is the important one. It is the free-text path failing
exactly as this codebase has already documented, twice, in comments:

> "nobody types the exact words that would make free-text matching work"

Current signal counts in `IncidentGuidanceKnowledge.swift`:

- **162** structured-answer signals (`.noiseAnswer`, `.warningAnswer`,
  `.fluidAnswer`, `.startingAnswer`, `.drivingChangeAnswer`)
- **24** free-text signals (`.descriptionContains`)

The structured system is what makes the app work. The menus are not the
problem. **Their position in the flow is the problem.**

---

## 2. Design principle

**Text routes. Structure diagnoses.**

The typed description is used to pre-answer questions and skip screens. It is
never, on its own, allowed to produce a result.

The reason is asymmetric cost:

- Router guesses wrong → the user answers one extra question. Recoverable.
- Prose-to-diagnosis guesses wrong → someone is told the wrong thing about
  their brakes. Not recoverable.

This is also why an LLM is not in this loop. That decision was made
deliberately: a live model can say anything, with no citation and no review,
and the owner of the app owns what it said. Every diagnosis must remain
traceable to a reviewed record.

---

## 3. New step order

Current (`IncidentStep` in `SomethingHappenedView.swift`):

```
urgentSafety → observations → [noise/warning/fluid/starting/drivingChange
chains] → description → recentWork → review → guidance
```

New:

```
safetyGate → description → [only unanswered questions] → recentWork → review → guidance
```

`observations` disappears as a user-facing screen. The observation types are
still set on the incident — they are what the whole matching engine keys off —
but they are inferred by the router and confirmed implicitly, rather than
presented as a checklist.

---

## 4. Step 1: safety gate

Replace the 10-option wall with a single question:

> **Is anything happening right now that feels dangerous?**
> Smoke, fire, a strong fuel smell, overheating, brakes or steering that don't
> feel right.
>
> `[ No, nothing like that ]` `[ Yes, or I'm not sure ]`

- **No** → straight to the description screen. This is the overwhelming
  majority path and it becomes one tap.
- **Yes / not sure** → show the existing 10-option list unchanged, which routes
  into the existing urgent paths.

**Do not remove or reorder anything behind the "yes" branch.** The eight
dangerous `IncidentSafetySelection` cases, `escalateToUrgentSafety`, the
"Put safety first" screen shown before any urgent questions, and the six
exhaustive switches over that enum all stay exactly as they are. This change
only puts one door in front of them.

---

## 5. Step 2: description, moved to the front

The existing description screen (`IncidentStep.description`) becomes the first
thing after the safety gate.

Copy changes from a generic prompt to:

> **What's going on with the car?**
> Tell it however you'd tell a friend. A sentence is plenty.

On Continue, run the router (§6), then jump to the first genuinely unanswered
question (§7).

---

## 6. The router

New file or new section: `IncidentDescriptionRouter`.

```
func route(_ text: String) -> RouterResult

struct RouterResult {
    var observationTypes: Set<IncidentObservationType>
    var startingAnswers: [String: String]
    var noiseAnswers: [String: String]
    var warningAnswers: [String: String]
    var fluidAnswers: [String: String]
    var drivingChangeAnswers: [String: String]
}
```

Match case-insensitively on the lowercased description. Multiple rules may fire.

**Critical implementation rule:** every value written by the router must be a
verbatim copy of an existing option string from `SomethingHappenedView`. The
engine compares these with `==`. A near-miss silently matches nothing. Pull the
strings from the source, do not retype them.

### Observation type rules

| If the text contains | Set observation |
|---|---|
| start, starting, won't start, wont start, turn over, turns over, turning over, crank, cranks, key, ignition, stall, stalls, dies | `.startingOrRunningTrouble` |
| noise, sound, rattle, clunk, grind, squeal, squeak, whine, knock, tick | `.sound` |
| shake, shaking, shakes, vibrate, vibration, wobble, shudder | `.vibrationOrMovement` |
| smell, smells, odor, burning, fumes | `.smell` |
| leak, leaking, puddle, drip, smoke, steam, fluid | `.visible` |
| light, warning, dash, check engine, dashboard, message | `.warningLightOrMessage` |
| pulls, pulling, steering, drives, driving, sluggish, slow to accelerate, handling | `.drivingChange` |

If nothing matches, set `.somethingElse` and ask the observation question the
old way — the checklist survives as the fallback for text the router can't
place.

### Starting-answer rules

Only apply when `.startingOrRunningTrouble` was set.

| Text contains | `crankBehavior` = |
|---|---|
| slow, slowly, sluggish, struggles, labor, weak, dragging | `The engine turns over slowly, then stops` |
| rapid click, clicking, clicks fast, machine gun, chatter | `Rapid clicking` |
| one click, single click, clicks once | `One single click` |
| nothing happens, no sound, dead, silent, no response | `No sound at all` |
| turns over but, cranks but, won't fire, wont fire, won't catch, never starts | `The engine turns over normally, but never starts` |
| runs rough, rough idle, idles rough, hesitat, misfire, sputter, stumble | `It starts up fine — my concern is how it runs afterward` |

### Noise-answer rules

Only when `.sound` or `.vibrationOrMovement` was set.

| Text contains | Key | Value |
|---|---|---|
| rattle, rattling | `sound` | `Rattle` |
| clunk, thunk, knock | `sound` | `Clunk` |
| grind, grinding, metal on metal | `sound` | `Grind` |
| squeal, squeak, screech | `sound` | `Squeal` |
| bump, pothole, uneven road | `timing` | `Over bumps` |
| turn, turning, corner | `timing` | `While turning` |
| brake, braking, stopping, slowing | `timing` | `While braking` |
| all the time, constant, always | `timing` | `Constant` |
| highway, high speed, at speed, faster | `timing` | `Only at speed` |
| front | `location` | `Front` |
| rear, back | `location` | `Rear` |

### Warning / fluid / driving-change rules

| Text contains | Key | Value |
|---|---|---|
| check engine | `warning.light` | `Check engine light (steady)` |
| battery light, charging light | `warning.light` | `Battery or charging symbol` |
| temperature light, temp light, overheat light | `warning.light` | `Temperature warning light` |
| abs, traction | `warning.light` | `ABS or traction control light` |
| tire pressure, tpms, low tire | `warning.light` | `Tire pressure light` |
| puddle, drip, leak, fluid on the ground | `fluid.whatWasVisible` | `Fluid on the ground or under the vehicle` |
| smoke | `fluid.whatWasVisible` | `Smoke` |
| green, orange, pink, yellow (with leak/fluid present) | `fluid.color` | `Green, orange, pink, or yellow` |
| brown, black (with leak/fluid present) | `fluid.color` | `Brown or black` |
| red, reddish (with leak/fluid present) | `fluid.color` | `Red or reddish` |
| sweet, syrup, maple | `fluid.odor` | `Sweet or coolant-like` |
| musty, mold, mildew | `fluid.odor` | `Musty or moldy` |
| electrical, burning plastic | `fluid.odor` | `Electrical or burning plastic` |
| rotten egg, sulfur | `fluid.odor` | `Rotten egg or sulfur` |
| pulls, pulling to | `drivingChange.whatChanged` | `Pulls to one side` |
| heavy steering, hard to steer, stiff steering | `drivingChange.whatChanged` | `Steering feels heavier than normal` |
| sluggish, slow to accelerate, no power, down on power | `drivingChange.whatChanged` | `Feels sluggish or slow to accelerate` |

**Do not route into any answer that escalates to urgent safety.** Specifically
never auto-set `whatsHappening = "The engine actually shuts off or dies"`,
`transmissionBehavior` slipping/burning, `odor` = Exhaust, or
`dashboardMessageText = "Service brake system"`. A STOP DRIVING verdict must
come from something the person deliberately chose, never from a keyword match
on prose. If the text suggests one of these, let the relevant question be asked
normally.

---

## 7. Step 3: ask only what's left

`advance*Intake` and the `nextUnanswered*QuestionIndex` properties already skip
any question whose answer is present and valid. Once the router writes answers
into the incident, those screens are skipped automatically.

Two things still need doing:

1. **Keep the relevance gating.** `startingQuestionIsRelevant` must continue to
   apply. Router-supplied answers narrow the flow; they do not widen it.
2. **Add a confirmation line** at the top of the first question actually shown:
   > "From what you wrote, I've got: engine turns over slowly. Just one more
   > thing —"

   This is what stops the skipping from feeling like the app ignored them.

Expected result for "engine turns over slowly when I start it": safety gate
(1 tap) → description (type it) → one clue question → result. **Three screens
instead of thirteen.**

---

## 8. What must not change

- Every diagnosis still comes from a reviewed record in
  `IncidentGuidanceKnowledge`. The router never writes an explanation, a part,
  a cost, or a drive recommendation.
- All 64 records stay `reviewedGeneralPrinciple` with no placeholder sources.
- The urgent path — `escalateToUrgentSafety`, the eight dangerous categories,
  the "Put safety first" screen before any urgent question — is untouched.
- The router may not set any answer that triggers an urgent escalation (§6).
- `.descriptionContains` records keep working; the description is still stored.

---

## 9. Build order

Each step is independently shippable and independently verifiable.

1. **Router + unit checks, no UI change.** Write `route(_:)`, verify with a
   table of ~20 real sentences that it produces the expected answers. Nothing
   user-facing yet, nothing to break.
2. **Safety gate.** One question in front of the existing 10. Verify the "yes"
   branch still reaches every urgent category.
3. **Move description to the front and wire the router in.** The largest step;
   do it alone and build after it.
4. **Confirmation line** on the first shown question.
5. **Retire the observations checklist** as a normal screen; keep it as the
   fallback when the router matches nothing.

After each step: `xcodebuild` clean, then walk the slow-crank case by hand. It
is the scenario that has regressed twice, and it exercises routing, relevance
gating, and the transmission exclusion in one pass.

---

## 10. Test cases to keep passing

| Typed | Should reach | Must never see |
|---|---|---|
| "engine turns over slowly when I start it" | slow-crank record: battery, terminals, starter, alternator | transmission question |
| "musty smell from the vents" | cabin air filter / musty odor record | exhaust smoke question |
| "grinding noise when I brake" | urgent — unsafe brakes | an ordinary Phase 1 result |
| "check engine light came on" | steady check-engine record | starting questions |
| "puddle of green fluid under the car" | coolant record | starting or noise questions |
| "it just feels different lately" | driving-change unclear record, 5 named areas | a dead end |
| "asdfgh" | observation checklist fallback | a confident diagnosis |
