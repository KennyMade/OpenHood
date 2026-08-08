# OpenHood — Handoff Brief for Claude Code

Last updated: 2026-08-03, by Claude (Cowork session), for Kenneth Acosta.
Purpose of this file: give Claude Code everything it needs to pick up this project safely, without re-asking Kenneth things he's already answered.

---

## 1. Who you're working with

Kenneth describes himself as non-technical ("a toddler behind this computer"). Work this way:
- Plain English, no unexplained jargon.
- One step at a time for anything involving software navigation (Xcode, Terminal, Finder).
- Exact click-by-click or copy-paste instructions when he needs to do something himself.
- Never say something was done/saved/tested/verified unless it actually was.
- Nothing destructive, irreversible, or public-facing without his explicit go-ahead first.
- He's also using ChatGPT/Codex on this same project. He wants your work and Codex's work to stay compatible and mergeable — not drift into two unmanageable versions. Do not assume you have free rein over the whole repo; see Section 4.

## 2. What OpenHood is

An iOS app, built in Swift/Xcode. Based on the source file names present (not yet confirmed by actually running the app), it looks like a vehicle-care / car-ownership companion app, with:
- A "Garage" area for tracking vehicles (`GarageView`, `GarageStore`, `GaragePersistence`, `SavedVehicle`)
- A vehicle catalog / knowledge base (`VehicleCatalog.swift`, `VehicleKnowledge.swift`)
- An incident-reporting flow — "something happened to my car" (`SomethingHappenedView`, `IncidentStore`, `IncidentPersistence`, `VehicleIncident`, `IncidentGuidance`, `IncidentGuidanceEngine`, `IncidentGuidanceKnowledge`)
- A "Vehicle Plan" view
- Profile/Settings
- Tab navigation (`MainTabView`, `AppRootView`)

Confirm this understanding by actually opening/running the app before assuming it's accurate — this is inferred from filenames, not verified behavior.

## 3. Where everything actually is (verified directly, 2026-08-03)

Kenneth had three copies of the project on his Desktop; they've been renamed for clarity:

| Folder | What it is |
|---|---|
| `/Users/kenny.acost/Desktop/OpenHood/OpenHood` | **The live, active project. This is the one to work in.** Contains `OpenHood.xcodeproj`. |
| `/Users/kenny.acost/Desktop/OpenHood/OpenHood - OLD BACKUP (July 29)` | Old snapshot, before recent feature work. Reference only — do not edit. |
| `/Users/kenny.acost/Desktop/OpenHood/OpenHood - OLD BACKUP (July 31)` | Another old snapshot. Reference only — do not edit. |

Inside the live folder, the real, buildable source code sits at:
`/Users/kenny.acost/Desktop/OpenHood/OpenHood/OpenHood/*.swift`
(Confirmed by cross-checking `OpenHood.xcodeproj/project.pbxproj` — this is the only path Xcode's build actually references.)

There are also two **orphaned leftover folders** inside the live project, left behind by Codex/ChatGPT, confirmed NOT referenced anywhere in `project.pbxproj`:
- `OpenHood/OpenHood BackUp - before expanded onboarding/`
- `OpenHood/Models/OpenHood/`

These are harmless clutter (stray old duplicate files), safe to ignore or archive. Not urgent. Don't delete them without telling Kenneth first — he hasn't approved deletion, only identification.

## 4. Git status — read this before touching anything

The live project already has a local git repo. Important, unresolved details:

- **No GitHub remote is configured.** All version history is local-only right now, on Kenneth's Mac. (`git remote -v` will come back empty.)
- **Two branches currently exist: `main` and `stabilization/openhood-structure`.**
- **The repo is currently checked out on `stabilization/openhood-structure`**, not `main`. Last commit message on it: "Add OpenHood app icon."
- It is **NOT yet confirmed which branch represents Codex's most current work** — `main` or `stabilization/openhood-structure`. Do not assume. Run `git log --all --oneline --graph --decorate` (or check commit dates on each) and figure out which branch is actually ahead / most recently touched before doing anything else.
- **Uncommitted changes status is unknown** — this was never checked. Run `git status` first thing.

### Agreed plan (approved by Kenneth, not yet executed)

The plan discussed and approved with Kenneth: don't touch Codex's existing branch at all. Instead:
1. Check `git status`. If there are uncommitted changes, commit them first as a safety checkpoint (e.g. `git commit -am "Safety checkpoint before Claude starts"`) so nothing existing can be lost.
2. Confirm which branch is truly current (see above) before branching from it.
3. Create a **new branch** off that correct base — e.g. `git checkout -b claude-work` — and do all Claude Code work there. This keeps Codex's branch(es) completely untouched.
4. When Kenneth is happy with changes, merge `claude-work` back — with his approval, not automatically.

This was chosen over making a second full duplicate folder, because branches are lighter-weight and far easier to merge back together later (git shows exactly what conflicts, if any). **This step has not been run yet** — confirm with Kenneth before assuming a branch called `claude-work` exists.

## 5. Decision log (for context, not to redo)

- **APPROVED:** Use a git branch, not a duplicate folder, to isolate Claude's work from Codex's.
- **APPROVED:** Rename backup folders for clarity (done, see Section 3).
- **REJECTED:** Full folder duplication as the isolation method (more disk space, harder to merge, more room for confusion).
- **PROPOSED, NOT YET DONE:** Creating the `claude-work` branch itself (see Section 4).
- **DEFERRED:** Setting up a GitHub remote as an off-machine backup. Not urgent, worth revisiting once things stabilize.
- **DEFERRED:** Cleaning up the two orphaned leftover folders inside the live project.

## 6. What Kenneth actually wants next

He wants to get a working build going and see it run in the Simulator the same way Codex/ChatGPT showed him before — meaning: you tell him exactly what to click in Xcode, he runs it, and reports back what he sees (or shares a screenshot). He does not expect you to run the Simulator for him directly — he's already confirmed that's how it worked with the other tools too.

## 7. Suggested first steps for Claude Code

1. Open a terminal in `/Users/kenny.acost/Desktop/OpenHood/OpenHood`.
2. Run `git status` and `git log --all --oneline --graph --decorate -20`. Report back what you find, especially regarding the `main` vs `stabilization/openhood-structure` question in Section 4 — don't just pick one silently.
3. Once that's resolved and a safety checkpoint is committed, create the `claude-work` branch.
4. Try building the project (or walk Kenneth through pressing Run in Xcode) to confirm the current state actually works before changing anything.
5. Ask Kenneth what he wants to build or fix first.
