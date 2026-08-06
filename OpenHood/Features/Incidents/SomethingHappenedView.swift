import SwiftUI
import UIKit

// MARK: - Something Happened

struct SomethingHappenedCard: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                ZStack {
                    Circle()
                        .fill(Color.white.opacity(0.14))
                        .frame(width: 52, height: 52)

                    Image(
                        systemName: "waveform.and.magnifyingglass"
                    )
                    .font(.system(size: 24, weight: .semibold))
                    .foregroundStyle(.white)
                }

                Spacer()

                Image(systemName: "arrow.up.right")
                    .font(.headline)
                    .foregroundStyle(.white.opacity(0.8))
            }

            VStack(alignment: .leading, spacing: 5) {
                Text("Something happened")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundStyle(.white)

                Text(
                    "Tell OpenHood what you heard, felt, saw, or smelled."
                )
                .font(.subheadline)
                .foregroundStyle(.white.opacity(0.76))
                .multilineTextAlignment(.leading)
            }
        }
        .padding(22)
        .frame(
            maxWidth: .infinity,
            alignment: .leading
        )
        .background(
            LinearGradient(
                colors: [
                    Color.black,
                    Color.black.opacity(0.78)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
        .clipShape(
            RoundedRectangle(cornerRadius: 26)
        )
    }
}

struct SomethingHappenedPlaceholderView: View {
    @EnvironmentObject private var garageStore: GarageStore
    @EnvironmentObject private var incidentStore: IncidentStore
    @State private var incidentForIntake: VehicleIncident?

    private var activeVehicle: SavedVehicle? {
        garageStore.activeVehicle
    }

    private var activeDraft: VehicleIncident? {
        guard let vehicleID = activeVehicle?.id else { return nil }
        return incidentStore.draft(for: vehicleID)
    }

    private var savedIncidents: [VehicleIncident] {
        guard let vehicleID = activeVehicle?.id else { return [] }
        return incidentStore.incidents
            .filter {
                $0.vehicleID == vehicleID
                    && $0.status == .submitted
                    && $0.guidanceSnapshot != nil
            }
            .sorted { $0.updatedAt > $1.updatedAt }
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                Image(systemName: "waveform.and.magnifyingglass")
                    .font(.system(size: 52))

                VStack(alignment: .leading, spacing: 8) {
                    Text("Something happened")
                        .font(.largeTitle)
                        .fontWeight(.bold)

                    Text(activeVehicle?.incidentDisplayName ?? "Active vehicle unavailable")
                        .font(.title3)
                        .foregroundStyle(.secondary)
                }

                Text(
                    "OpenHood helps you collect useful information and identify the safest next step. It does not confirm a diagnosis."
                )
                .font(.body)
                .foregroundStyle(.secondary)

                if let activeDraft {
                    Button {
                        incidentForIntake = activeDraft
                    } label: {
                        Text("Continue this issue")
                            .font(.headline)
                            .frame(maxWidth: .infinity)
                            .padding()
                    }
                    .buttonStyle(.borderedProminent)

                    Button("Describe something new") {
                        startNewIncident()
                    }
                    .font(.headline)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .buttonStyle(.bordered)
                } else {
                    Button {
                        startNewIncident()
                    } label: {
                        Text("Start")
                            .font(.headline)
                            .frame(maxWidth: .infinity)
                            .padding()
                    }
                    .buttonStyle(.borderedProminent)
                }

                if !savedIncidents.isEmpty {
                    Text("Saved guidance")
                        .font(.title2)
                        .fontWeight(.bold)

                    ForEach(savedIncidents) { savedIncident in
                        Button {
                            incidentForIntake = savedIncident
                        } label: {
                            IncidentChoiceCard(
                                title: savedIncident.safetySelection?.title
                                    ?? "Saved issue"
                            )
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
            .padding(24)
        }
        .background(Color(.systemGroupedBackground))
        .navigationTitle("Something Happened")
        .navigationBarTitleDisplayMode(.inline)
        .fullScreenCover(item: $incidentForIntake) { incident in
            if let activeVehicle {
                IncidentIntakeView(
                    initialIncident: incident,
                    vehicle: activeVehicle,
                    incidentStore: incidentStore
                )
            }
        }
    }

    private func startNewIncident() {
        guard let vehicleID = activeVehicle?.id else { return }
        incidentForIntake = incidentStore.startNewDraft(for: vehicleID)
    }
}

private enum IncidentStep: Hashable {
    case urgentSafety
    case urgentQuestion(Int)
    case cautionSafety
    case observations
    case noiseQuestion(Int)
    case warningQuestion(Int)
    case fluidQuestion(Int)
    case startingQuestion(Int)
    case description
    case recentWork
    case review
    case guidance
    case saved
}

private struct IncidentIntakeView: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject var incidentStore: IncidentStore

    let vehicle: SavedVehicle

    @State private var incident: VehicleIncident
    @State private var path: [IncidentStep]

    init(
        initialIncident: VehicleIncident,
        vehicle: SavedVehicle,
        incidentStore: IncidentStore
    ) {
        self.vehicle = vehicle
        self.incidentStore = incidentStore
        _incident = State(initialValue: initialIncident)
        _path = State(initialValue: Self.resumePath(for: initialIncident))
    }

    var body: some View {
        NavigationStack(path: $path) {
            IncidentSafetyQuestionView { selection in
                incident.safetySelection = selection
                saveDraft()

                switch selection.urgency {
                case .urgent:
                    path.append(.urgentSafety)
                case .caution:
                    path.append(.cautionSafety)
                case .routine:
                    path.append(.observations)
                }
            }
            .navigationTitle("Safety check")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Close") {
                        dismiss()
                    }
                }
            }
            .navigationDestination(for: IncidentStep.self) { step in
                destination(for: step)
            }
        }
    }

    @ViewBuilder
    private func destination(for step: IncidentStep) -> some View {
        switch step {
        case .urgentSafety:
            IncidentSafetyGuidanceView(
                selection: incident.safetySelection,
                isUrgent: true,
                primaryTitle: "I’m safe — continue",
                secondaryTitle: "Save and exit",
                confirmationMessage: "Continue only after the vehicle is stopped, the engine is off when appropriate, you are away from immediate danger, and you will not reproduce the symptom.",
                onSecondary: {
                    incidentStore.submit(incident)
                    path.append(.saved)
                }
            ) {
                guard path.last == .urgentSafety else { return }
                advanceUrgentIntake()
            }
        case .urgentQuestion(let index):
            urgentQuestionDestination(index: index)
        case .cautionSafety:
            IncidentSafetyGuidanceView(
                selection: incident.safetySelection,
                isUrgent: false,
                primaryTitle: "Continue"
            ) {
                path.append(.observations)
            }
        case .observations:
            IncidentObservationView(
                selections: $incident.observationTypes,
                onChange: saveDraft
            ) {
                advanceNoiseIntake()
            }
        case .noiseQuestion(let index):
            noiseQuestionDestination(index: index)
        case .warningQuestion(let index):
            warningQuestionDestination(index: index)
        case .fluidQuestion(let index):
            fluidQuestionDestination(index: index)
        case .startingQuestion(let index):
            startingQuestionDestination(index: index)
        case .description:
            IncidentDescriptionView(
                description: $incident.userDescription,
                onChange: saveDraft
            ) {
                path.append(.recentWork)
            }
        case .recentWork:
            IncidentRecentWorkView(
                response: $incident.recentWorkResponse,
                notes: $incident.recentWorkNotes,
                onChange: saveDraft
            ) {
                path.append(.review)
            }
        case .review:
            IncidentReviewView(
                incident: incident,
                vehicleName: vehicle.incidentDisplayName,
                onContinue: {
                    path.append(.guidance)
                },
                onStartOver: {
                    incident = incidentStore.startNewDraft(
                        for: incident.vehicleID
                    )
                    path.removeAll()
                }
            )
        case .guidance:
            if incident.guidanceSnapshot != nil
                || !requiresUrgentQuestions
                || isUrgentIntakeComplete {
                let result = incident.guidanceSnapshot.map {
                    IncidentGuidanceResult(snapshot: $0)
                } ?? IncidentGuidanceEngine().evaluate(
                    incident: incident,
                    vehicle: vehicle
                )
                IncidentGuidanceView(
                    result: result,
                    onSave: {
                        incident.guidanceSnapshot = result.snapshot
                        incidentStore.submit(incident)
                        appendIfNeeded(.saved)
                    }
                )
            } else {
                IncidentIncompleteIntakeRecoveryView {
                    resumeIncompleteUrgentIntake()
                }
            }
        case .saved:
            IncidentSavedView {
                dismiss()
            }
        }
    }

    @ViewBuilder
    private func urgentQuestionDestination(index: Int) -> some View {
        let questions = urgentQuestions
        if questions.indices.contains(index) {
            let question = questions[index]
            IncidentUrgentFollowUpView(
                title: question.title,
                message: question.message,
                options: question.options
            ) { answer in
                guard path.last == .urgentQuestion(index) else { return }
                setUrgentAnswer(answer, key: question.answerKey)
                advanceUrgentIntake()
            }
        } else {
            IncidentIncompleteIntakeRecoveryView {
                resumeIncompleteUrgentIntake()
            }
        }
    }

    /// phase1.suspension.bump-noise: structured follow-up asked only
    /// when the reported observation could be suspension noise (`.sound`
    /// or `.vibrationOrMovement`) — see `noiseQuestions`. Mirrors the
    /// urgent-question step pattern above, but for the routine intake
    /// path, so IncidentGuidanceEngine can match against exact recorded
    /// answers (IncidentNoiseAnswerKey) instead of free-text guessing.
    @ViewBuilder
    private func noiseQuestionDestination(index: Int) -> some View {
        let questions = noiseQuestions
        if questions.indices.contains(index) {
            let question = questions[index]
            IncidentUrgentFollowUpView(
                title: question.title,
                message: question.message,
                options: question.options
            ) { answer in
                guard path.last == .noiseQuestion(index) else { return }
                setNoiseAnswer(answer, key: question.answerKey)
                advanceNoiseIntake()
            }
        } else {
            IncidentIncompleteIntakeRecoveryView {
                advanceNoiseIntake()
            }
        }
    }

    private var noiseQuestions: [IncidentUrgentQuestion] {
        guard incident.observationTypes.contains(.sound)
            || incident.observationTypes.contains(.vibrationOrMovement) else {
            return []
        }
        return [
            question("Where is the noise coming from?", key: IncidentNoiseAnswerKey.location, choices: ["Front", "Rear", "Left", "Right", "All over", "I’m not sure"]),
            question("When does it happen?", key: IncidentNoiseAnswerKey.timing, choices: ["Over bumps", "While turning", "While braking", "Constant", "Only at speed", "I’m not sure"]),
            question("What does it sound like?", key: IncidentNoiseAnswerKey.sound, choices: ["Rattle", "Clunk", "Grind", "Squeal", "I’m not sure"])
        ]
    }

    private func advanceNoiseIntake() {
        if let index = nextUnansweredNoiseQuestionIndex {
            appendIfNeeded(.noiseQuestion(index))
        } else {
            advanceWarningIntake()
        }
    }

    private var nextUnansweredNoiseQuestionIndex: Int? {
        noiseQuestions.firstIndex { question in
            guard let answer = incident.noiseFollowUpAnswers?[question.answerKey] else {
                return true
            }
            return !question.options.contains { $0.id == answer }
        }
    }

    private func setNoiseAnswer(_ answer: String, key: String) {
        var answers = incident.noiseFollowUpAnswers ?? [:]
        answers[key] = answer
        incident.noiseFollowUpAnswers = answers
        saveDraft()
    }

    /// phase1.warning.record-code / phase1.warning.engine-information:
    /// structured follow-up asked only when the reported observation
    /// includes .warningLightOrMessage — see `warningQuestions`. Chained
    /// after the noise questions (advanceNoiseIntake falls through to
    /// this once noise questions are answered or not applicable), then
    /// falls through to the fluid questions below, so a report can
    /// include a sound, a warning light, a visible fluid, an odor, or
    /// any combination without any path being skipped.
    ///
    /// "Temperature warning light" and "ABS or traction control light"
    /// are deliberately excluded from that fall-through when their
    /// follow-up answer is dangerous — see temperatureObservationEscalation
    /// and absTractionEscalation below, same treatment as "Electrical or
    /// burning plastic"/"Exhaust" in fluidQuestionDestination.
    @ViewBuilder
    private func warningQuestionDestination(index: Int) -> some View {
        let questions = warningQuestions
        if questions.indices.contains(index) {
            let question = questions[index]
            IncidentUrgentFollowUpView(
                title: question.title,
                message: question.message,
                options: question.options
            ) { answer in
                guard path.last == .warningQuestion(index) else { return }
                setWarningAnswer(answer, key: question.answerKey)
                if question.answerKey == IncidentWarningAnswerKey.temperatureDetail,
                   let escalation = temperatureObservationEscalation(for: answer) {
                    escalateToUrgentSafety(escalation)
                } else if question.answerKey == IncidentWarningAnswerKey.absBrakeCheck,
                          let escalation = absTractionEscalation(for: answer) {
                    escalateToUrgentSafety(escalation)
                } else {
                    advanceWarningIntake()
                }
            }
        } else {
            IncidentIncompleteIntakeRecoveryView {
                advanceWarningIntake()
            }
        }
    }

    private var warningQuestions: [IncidentUrgentQuestion] {
        guard incident.observationTypes.contains(.warningLightOrMessage) else {
            return []
        }
        var questions = [
            question("Which light or message came on?", key: IncidentWarningAnswerKey.light, choices: ["Check engine light (steady)", "Battery or charging symbol", "Temperature warning light", "ABS or traction control light", "I’m not sure which one"])
        ]
        // OH-UIK gap fix (same tier as the odor-escalation and
        // oil-pressure severity fixes): a temperature warning light
        // reported through general navigation is a real overheating
        // precursor, and Phase 1's ordinaryDriveRecommendation has no
        // path to DO NOT RESTART — see phase1.cooling.temperature-control
        // and temperatureObservationEscalation below for why this record
        // was removed rather than upgraded with ordinary content. This
        // follow-up is only asked once "Temperature warning light" is
        // selected above, so it never fires for an unrelated warning
        // light (battery, check engine, tire pressure).
        if incident.warningFollowUpAnswers?[IncidentWarningAnswerKey.light] == "Temperature warning light" {
            questions.append(
                question("What did you notice?", key: IncidentWarningAnswerKey.temperatureDetail, choices: ["Temperature gauge reading high or in the red", "Steam or visible vapor", "Warning light for temperature", "Sweet smell with rising temperature", "I’m not sure"])
            )
        }
        // ABS-alone is safe, ordinary Phase 1 content (see
        // phase1.warning.abs-traction-alone) — but ABS combined with the
        // regular brake warning light, or an unconfirmed answer, is a real
        // hydraulic-system possibility that escalates instead (see
        // absTractionEscalation). This follow-up is only asked once "ABS
        // or traction control light" is selected above.
        if incident.warningFollowUpAnswers?[IncidentWarningAnswerKey.light] == "ABS or traction control light" {
            questions.append(
                question("Is the regular brake warning light also on?", key: IncidentWarningAnswerKey.absBrakeCheck, choices: ["No, just this one", "Yes, both are on", "I’m not sure"])
            )
        }
        return questions
    }

    /// Mirrors dangerousOdorEscalation exactly, but every answer maps to
    /// the same urgent selection — see the Part 3 scope note on
    /// warningQuestions above: there is no safe subset of "what did you
    /// notice" for an active overheating report, unlike the odor
    /// question's musty/sweet-coolant choices, so unlike
    /// dangerousOdorEscalation this has no case that returns nil for a
    /// real answer.
    private func temperatureObservationEscalation(for answer: String) -> IncidentSafetySelection? {
        // Every choice on this question is an overheating precursor —
        // deliberately unconditional, see the comment above warningQuestions.
        .overheatingOrSteam
    }

    /// Mirrors dangerousOdorEscalation exactly: unlike
    /// temperatureObservationEscalation, this one DOES have a safe
    /// answer — "No, just this one" returns nil and resolves to real,
    /// reviewed Phase 1 content (phase1.warning.abs-traction-alone).
    /// "Yes, both are on" and "I'm not sure" both escalate, since the
    /// regular brake warning light being on at the same time is a real
    /// hydraulic-system possibility, and an unconfirmed answer can't be
    /// assumed safe either.
    private func absTractionEscalation(for answer: String) -> IncidentSafetySelection? {
        switch answer {
        case "Yes, both are on", "I’m not sure": .unsafeBrakesOrSteering
        default: nil
        }
    }

    private func advanceWarningIntake() {
        if let index = nextUnansweredWarningQuestionIndex {
            appendIfNeeded(.warningQuestion(index))
        } else {
            advanceFluidIntake()
        }
    }

    private var nextUnansweredWarningQuestionIndex: Int? {
        warningQuestions.firstIndex { question in
            guard let answer = incident.warningFollowUpAnswers?[question.answerKey] else {
                return true
            }
            return !question.options.contains { $0.id == answer }
        }
    }

    private func setWarningAnswer(_ answer: String, key: String) {
        var answers = incident.warningFollowUpAnswers ?? [:]
        answers[key] = answer
        incident.warningFollowUpAnswers = answers
        saveDraft()
    }

    /// phase1.fluid-smell.visible-fluid / phase1.fluid-smell.unusual-odor:
    /// structured follow-up asked only when the reported observation
    /// includes .visible (color question) and/or .smell (odor question)
    /// — see `fluidQuestions`. Chained after the warning questions
    /// (advanceWarningIntake falls through to this once warning questions
    /// are answered or not applicable), then falls through to
    /// .description itself, same pattern as noise/warning above.
    ///
    /// "Electrical or burning plastic" and "Exhaust" are deliberately
    /// excluded from that fall-through — see escalateToUrgentSafety below.
    @ViewBuilder
    private func fluidQuestionDestination(index: Int) -> some View {
        let questions = fluidQuestions
        if questions.indices.contains(index) {
            let question = questions[index]
            IncidentUrgentFollowUpView(
                title: question.title,
                message: question.message,
                options: question.options
            ) { answer in
                guard path.last == .fluidQuestion(index) else { return }
                setFluidAnswer(answer, key: question.answerKey)
                if question.answerKey == IncidentFluidAnswerKey.odor,
                   let escalation = dangerousOdorEscalation(for: answer) {
                    escalateToUrgentSafety(escalation)
                } else {
                    advanceFluidIntake()
                }
            }
        } else {
            IncidentIncompleteIntakeRecoveryView {
                advanceFluidIntake()
            }
        }
    }

    private var fluidQuestions: [IncidentUrgentQuestion] {
        var questions: [IncidentUrgentQuestion] = []
        if incident.observationTypes.contains(.visible) {
            questions.append(
                question("What color was the fluid?", key: IncidentFluidAnswerKey.color, choices: ["Green, orange, pink, or yellow", "Brown or black", "Red or reddish", "Clear or light", "I’m not sure"])
            )
        }
        if incident.observationTypes.contains(.smell) {
            questions.append(
                question("Which best describes the smell?", key: IncidentFluidAnswerKey.odor, choices: ["Sweet or coolant-like", "Musty or moldy", "Electrical or burning plastic", "Exhaust", "I’m not sure"])
            )
        }
        return questions
    }

    /// OH-UIK gap fix (same tier as the oil-pressure severity fix): Phase 1's
    /// ordinaryDriveRecommendation can only ever return SERVICE SOON, CHECK
    /// BEFORE DRIVING, or MONITOR — it has no path to STOP DRIVING. An
    /// electrical/burning-plastic odor is a real fire-risk precursor and an
    /// exhaust odor inside the cabin is a real carbon-monoxide risk, so
    /// neither may resolve to an ordinary Phase 1 result just because the
    /// person answered the general odor question instead of picking
    /// "Smoke or fire" / "Strong fuel smell" from the main safety menu up
    /// front. Rather than inventing a second place that decides "this is a
    /// stop-driving situation," this reroutes into the exact same urgent
    /// path those two safety-menu categories already use — same
    /// safetySelection cases, same urgentFollowUpAnswers keys
    /// (smokeOdor/smellDescription), same urgentDriveRecommendation switch
    /// (smokeOrFire/strongFuelSmell both unconditionally return
    /// .doNotRestart), same urgentContributors content (already has real,
    /// reviewed handling for exactly these two answer values). See
    /// escalateToUrgentSafety.
    private func dangerousOdorEscalation(for answer: String) -> IncidentSafetySelection? {
        switch answer {
        case "Electrical or burning plastic": .smokeOrFire
        case "Exhaust": .strongFuelSmell
        default: nil
        }
    }

    /// Mirrors the exact mechanism IncidentSafetyQuestionView uses to enter
    /// the urgent path (set safetySelection, save, push .urgentSafety) —
    /// the only difference is arriving here mid-flow from the Phase 1 odor
    /// question instead of the opening safety-check screen. Prefilling the
    /// matching urgentFollowUpAnswers key means the remaining urgent
    /// questions for that category (e.g. "Is there an active flame?" for
    /// smoke/fire) still get asked normally — this does not skip urgent
    /// intake, it joins it already partway answered.
    private func escalateToUrgentSafety(_ selection: IncidentSafetySelection) {
        incident.safetySelection = selection
        switch selection {
        case .smokeOrFire:
            setUrgentAnswer("Electrical or plastic", key: IncidentUrgentAnswerKey.smokeOdor)
        case .strongFuelSmell:
            setUrgentAnswer("Exhaust", key: IncidentUrgentAnswerKey.smellDescription)
        case .overheatingOrSteam:
            setUrgentAnswer("Yes", key: IncidentUrgentAnswerKey.temperatureIndication)
        case .unsafeBrakesOrSteering:
            // Only absTractionEscalation routes here today, and it's
            // always specifically about the ABS/traction-control and
            // regular brake lights — not steering — so the main-concern
            // question is already answered by context.
            setUrgentAnswer("Braking", key: IncidentUrgentAnswerKey.concernType)
        default:
            saveDraft()
        }
        appendIfNeeded(.urgentSafety)
    }

    private func advanceFluidIntake() {
        if let index = nextUnansweredFluidQuestionIndex {
            appendIfNeeded(.fluidQuestion(index))
        } else {
            advanceStartingIntake()
        }
    }

    private var nextUnansweredFluidQuestionIndex: Int? {
        fluidQuestions.firstIndex { question in
            guard let answer = incident.fluidFollowUpAnswers?[question.answerKey] else {
                return true
            }
            return !question.options.contains { $0.id == answer }
        }
    }

    private func setFluidAnswer(_ answer: String, key: String) {
        var answers = incident.fluidFollowUpAnswers ?? [:]
        answers[key] = answer
        incident.fluidFollowUpAnswers = answers
        saveDraft()
    }

    /// phase1.starting.electrical / phase1.starting.fuel-ignition /
    /// phase1.starting.engine-operation: structured follow-up asked only
    /// when the reported observation includes .startingOrRunningTrouble —
    /// see `startingQuestions`. Chained after the fluid questions
    /// (advanceFluidIntake falls through to this once fluid questions are
    /// answered or not applicable), then falls through to .description
    /// itself, same pattern as noise/warning/fluid above. All three
    /// questions below are asked back-to-back regardless of which answer
    /// is given to the others — the no-crank/clicking record
    /// (phase1.starting.electrical) keys off crankBehavior, the
    /// cranks-but-won't-catch record (phase1.starting.fuel-ignition) keys
    /// off crankClues, and the post-start running-behavior record
    /// (phase1.starting.engine-operation) keys off whatsHappening, so a
    /// person only needs to answer whichever one meaningfully matches
    /// what actually happened; the others can be left at "I’m not sure"
    /// without affecting the result.
    ///
    /// "The engine actually shuts off or dies" is deliberately excluded
    /// from the fall-through below — see engineOperationEscalation.
    @ViewBuilder
    private func startingQuestionDestination(index: Int) -> some View {
        let questions = startingQuestions
        if questions.indices.contains(index) {
            let question = questions[index]
            IncidentUrgentFollowUpView(
                title: question.title,
                message: question.message,
                options: question.options
            ) { answer in
                guard path.last == .startingQuestion(index) else { return }
                setStartingAnswer(answer, key: question.answerKey)
                if question.answerKey == IncidentStartingAnswerKey.whatsHappening,
                   let escalation = engineOperationEscalation(for: answer) {
                    escalateToUrgentSafety(escalation)
                } else {
                    advanceStartingIntake()
                }
            }
        } else {
            IncidentIncompleteIntakeRecoveryView {
                advanceStartingIntake()
            }
        }
    }

    private var startingQuestions: [IncidentUrgentQuestion] {
        guard incident.observationTypes.contains(.startingOrRunningTrouble) else {
            return []
        }
        return [
            question("What happens when you try to start it?", key: IncidentStartingAnswerKey.crankBehavior, choices: ["Rapid clicking", "One single click", "No sound at all", "Cranks slowly then stops", "I’m not sure"]),
            question("Any other clues when it cranks but doesn’t start?", key: IncidentStartingAnswerKey.crankClues, choices: ["No unusual smell or sound", "Smell of gas/fuel while trying to start", "A clicking or ticking sound from the engine while cranking", "A recent check-engine light before this happened", "I’m not sure"]),
            question("What’s happening?", key: IncidentStartingAnswerKey.whatsHappening, choices: ["Rough or shaky idle, but the engine keeps running", "Occasional stumble or hesitation while driving, engine keeps running", "The engine actually shuts off or dies", "I’m not sure"])
        ]
    }

    /// OH-UIK gap fix (same tier as the odor-escalation and
    /// temperature-warning-light severity fixes): phase1.starting.
    /// engine-operation used to be a single free-text-matched placeholder
    /// whose support list included "will not stay running" — meaning a
    /// real stalling report could resolve to an ordinary Phase 1 result
    /// (SERVICE SOON at best, via ordinaryDriveRecommendation, which has
    /// no path to DO NOT RESTART). An engine that actually shuts off or
    /// dies can mean losing power steering and power brake assist, a real
    /// safety risk especially while driving — the same category the app
    /// already has real, cited urgent guidance for
    /// (IncidentSafetySelection.engineWillNotStayRunning, which
    /// unconditionally returns DO NOT RESTART — see
    /// urgentDriveRecommendation). So this answer routes into that exact
    /// urgent path instead of ever reaching Phase 1 evaluation, mirroring
    /// dangerousOdorEscalation/temperatureObservationEscalation exactly.
    /// The other three answers (rough idle, hesitation, "I’m not sure")
    /// are genuinely not a driving hazard while the engine keeps running,
    /// so they resolve normally as real Phase 1 records — see
    /// phase1.starting.engine-operation.rough-idle,
    /// phase1.starting.engine-operation.hesitation, and the
    /// "I’m not sure" fallback under the original record id in
    /// IncidentGuidanceKnowledge.
    private func engineOperationEscalation(for answer: String) -> IncidentSafetySelection? {
        switch answer {
        case "The engine actually shuts off or dies": .engineWillNotStayRunning
        default: nil
        }
    }

    private func advanceStartingIntake() {
        if let index = nextUnansweredStartingQuestionIndex {
            appendIfNeeded(.startingQuestion(index))
        } else {
            appendIfNeeded(.description)
        }
    }

    private var nextUnansweredStartingQuestionIndex: Int? {
        startingQuestions.firstIndex { question in
            guard let answer = incident.startingFollowUpAnswers?[question.answerKey] else {
                return true
            }
            return !question.options.contains { $0.id == answer }
        }
    }

    private func setStartingAnswer(_ answer: String, key: String) {
        var answers = incident.startingFollowUpAnswers ?? [:]
        answers[key] = answer
        incident.startingFollowUpAnswers = answers
        saveDraft()
    }

    private var urgentQuestions: [IncidentUrgentQuestion] {
        switch incident.safetySelection {
        case .smokeOrFire:
            return [
                IncidentUrgentQuestion(
                    title: "Is there an active flame?",
                    message: "Answer only from a safe distance.",
                    answerKey: IncidentUrgentAnswerKey.activeFlame,
                    options: [
                        .init(id: "activeFire", title: "Yes"),
                        .init(id: "No", title: "No"),
                        .init(id: "I’m not sure", title: "I’m not sure")
                    ]
                ),
                IncidentUrgentQuestion(
                    title: "Is smoke still present after shutdown?",
                    message: nil,
                    answerKey: IncidentUrgentAnswerKey.smokePresent,
                    options: [
                        .init(id: "continuingSmoke", title: "Yes"),
                        .init(id: "No", title: "No"),
                        .init(id: "I’m not sure", title: "I’m not sure")
                    ]
                ),
                question("Where did it appear to come from?", key: IncidentUrgentAnswerKey.smokeSource, choices: ["Under the hood", "Near a wheel", "Under the vehicle", "Inside the cabin", "Near the rear", "I’m not sure"]),
                question("Which smell was closest?", key: IncidentUrgentAnswerKey.smokeOdor, choices: ["Electrical or plastic", "Gasoline", "Burning oil", "Sweet or coolant-like", "I didn’t notice a smell", "I’m not sure"])
            ]
        case .strongFuelSmell:
            return [
                question("Which description is closest?", key: IncidentUrgentAnswerKey.smellDescription, choices: ["Gasoline", "Burning oil", "Sweet or coolant-like", "Electrical or plastic", "Exhaust", "I’m not sure"]),
                question("Where was the smell strongest?", key: IncidentUrgentAnswerKey.smellLocation, choices: ["Inside", "Outside", "Under the hood", "Near the rear", "I’m not sure"]),
                question("Was anything visible?", key: IncidentUrgentAnswerKey.visibleEvidence, choices: ["Liquid", "Smoke", "Vapor", "Nothing visible", "I’m not sure"], message: "Observe only from a safe distance."),
                question("Did it begin after a recent event?", key: IncidentUrgentAnswerKey.recentTrigger, choices: ["Refueling", "Service", "A recent repair", "No recent event", "I’m not sure"])
            ]
        case .overheatingOrSteam:
            return [
                question("Did the gauge or warning indicate overheating?", key: IncidentUrgentAnswerKey.temperatureIndication, choices: yesNoUnsure()),
                question("What cooling-system sign did you observe?", key: IncidentUrgentAnswerKey.coolingEvidence, choices: ["Steam", "Bubbling", "Leaking fluid", "More than one", "None", "I’m not sure"], message: "Do not open a hot cooling system or touch hot components."),
                question("What happened to the cabin heat?", key: IncidentUrgentAnswerKey.cabinHeat, choices: ["It became cold", "It was inconsistent", "It stayed normal", "I didn’t check", "I’m not sure"]),
                question("When did it happen?", key: IncidentUrgentAnswerKey.drivingCondition, choices: ["While stopped", "While moving", "Both", "I’m not sure"]),
                question("Was coolant added or cooling work performed recently?", key: IncidentUrgentAnswerKey.coolingRecentWork, choices: ["Coolant was added", "Cooling-system work was performed", "Both", "Neither", "I’m not sure"])
            ]
        case .flashingWarningLight:
            return [
                question("Which light flashed?", key: IncidentUrgentAnswerKey.warningSymbol, choices: ["Check engine", "Oil pressure", "Temperature", "Brake", "Charging or battery", "Tire pressure", "I’m not sure"], message: "Do not restart the vehicle to check again."),
                question("What is the warning doing now?", key: IncidentUrgentAnswerKey.warningState, choices: ["Still flashing", "Now steady", "Gone", "I’m not sure"]),
                question("How did the engine behave?", key: IncidentUrgentAnswerKey.engineBehavior, choices: ["Shaking", "Lost power", "Stalled", "Behaved normally", "I’m not sure"]),
                question("Did another warning appear?", key: IncidentUrgentAnswerKey.additionalWarning, choices: yesNoUnsure())
            ]
        case .unsafeBrakesOrSteering:
            var questions = [
                question("What is the main concern?", key: IncidentUrgentAnswerKey.concernType, choices: ["Braking", "Steering", "Both", "I’m not sure"]),
                question("Can you steer and control the vehicle’s direction normally?", key: IncidentUrgentAnswerKey.steeringControlLoss, choices: ["Yes", "No", "I’m not sure"], message: "Answer only from a safe, stopped position.")
            ]
            if vehicleIsHondaHRV2025 {
                // CLM-STR-002: the HR-V's owner's manual treats a separate
                // "Do not drive" message as more severe than the EPS
                // indicator alone, so it needs its own question rather
                // than being inferred from steeringControlLoss.
                questions.append(
                    question("Does the dashboard show a specific “Do not drive” message — not just the steering warning icon?", key: IncidentUrgentAnswerKey.hrvDoNotDriveMessage, choices: ["Yes", "No", "I’m not sure"])
                )
            }
            questions += [
                question("What did it feel or sound like?", key: IncidentUrgentAnswerKey.controlBehavior, choices: ["Pulling", "Shaking or wobbling", "Grinding", "Soft braking", "Unusually heavy steering", "Inconsistent response", "I’m not sure"]),
                question("When did it happen?", key: IncidentUrgentAnswerKey.occurrenceContext, choices: ["Low speed", "Highway speed", "During braking", "During turning", "Continuously", "I’m not sure"]),
                question("Did a warning light appear?", key: IncidentUrgentAnswerKey.controlWarning, choices: yesNoUnsure()),
                question("Was related work performed recently?", key: IncidentUrgentAnswerKey.controlRecentWork, choices: ["Tire or wheel work", "Brake work", "Suspension or alignment work", "Steering work", "No recent work", "I’m not sure"])
            ]
            return questions
        case .engineWillNotStayRunning:
            return [
                question("What happens when it runs?", key: IncidentUrgentAnswerKey.runningDetail, choices: ["Starts and immediately stops", "Idles roughly", "Shakes or misfires", "Stalls when placed in gear", "I’m not sure"]),
                question("Did this begin after recent work?", key: IncidentUrgentAnswerKey.runningRecentWork, choices: ["Service", "Battery work", "Fueling", "A repair", "No recent work", "I’m not sure"]),
                question("What are the warning lights doing?", key: IncidentUrgentAnswerKey.runningWarning, choices: ["Flashing", "Steady", "None", "I’m not sure"]),
                question("What else did you notice?", key: IncidentUrgentAnswerKey.runningEvidence, choices: ["Fuel smell", "Smoke", "Unusual noise", "Visible disconnected component", "Nothing else", "I’m not sure"]),
                question("Did restarting change anything?", key: IncidentUrgentAnswerKey.restartEffect, choices: ["Yes", "No", "I did not restart it", "I’m not sure"], message: "Do not restart it now to reproduce the concern.")
            ]
        case .noneOfThese, .unsure, nil:
            return []
        }
    }

    private func question(
        _ title: String,
        key: String,
        choices: [String],
        message: String? = nil
    ) -> IncidentUrgentQuestion {
        IncidentUrgentQuestion(
            title: title,
            message: message,
            answerKey: key,
            options: choices.map { .init(id: $0, title: $0) }
        )
    }

    private func yesNoUnsure() -> [String] {
        ["Yes", "No", "I’m not sure"]
    }

    /// CLM-STR-002 is the only claim in the steering ledger with a real,
    /// checkable vehicle scope (Honda HR-V, 2025) — see the doc comment on
    /// IncidentEvidenceGatedKnowledge.claims. This gate only controls
    /// whether the extra question is asked; IncidentGuidanceEngine still
    /// re-checks the same scope via evidenceClaims before actually citing
    /// CLM-STR-002 or escalating to STOP DRIVING.
    private var vehicleIsHondaHRV2025: Bool {
        vehicle.make.caseInsensitiveCompare("Honda") == .orderedSame
            && vehicle.model.caseInsensitiveCompare("HR-V") == .orderedSame
            && vehicle.year == 2025
    }

    private var requiresUrgentQuestions: Bool {
        incident.safetySelection?.urgency == .urgent
            && !urgentQuestions.isEmpty
    }

    private var hasImmediateDangerAnswer: Bool {
        let answers = incident.urgentFollowUpAnswers ?? [:]
        return answers[IncidentUrgentAnswerKey.activeFlame] == "activeFire"
            || answers[IncidentUrgentAnswerKey.smokePresent] == "continuingSmoke"
    }

    private var nextUnansweredUrgentQuestionIndex: Int? {
        urgentQuestions.firstIndex { question in
            guard let answer = incident.urgentFollowUpAnswers?[question.answerKey] else {
                return true
            }
            return !question.options.contains { $0.id == answer }
        }
    }

    private var isUrgentIntakeComplete: Bool {
        hasImmediateDangerAnswer
            || (requiresUrgentQuestions
                && nextUnansweredUrgentQuestionIndex == nil)
    }

    private func advanceUrgentIntake() {
        if hasImmediateDangerAnswer {
            appendIfNeeded(.guidance)
        } else if let index = nextUnansweredUrgentQuestionIndex {
            appendIfNeeded(.urgentQuestion(index))
        } else if isUrgentIntakeComplete {
            appendIfNeeded(.guidance)
        }
    }

    private func resumeIncompleteUrgentIntake() {
        if path.last == .guidance
            || path.last.map({ step in
                if case .urgentQuestion = step { return true }
                return false
            }) == true {
            path.removeLast()
        }
        advanceUrgentIntake()
    }

    private func appendIfNeeded(_ step: IncidentStep) {
        guard path.last != step else { return }
        path.append(step)
    }

    private func setUrgentAnswer(_ answer: String, key: String) {
        var answers = incident.urgentFollowUpAnswers ?? [:]
        answers[key] = answer
        incident.urgentFollowUpAnswers = answers
        saveDraft()
    }

    private func urgentAnswer(_ key: String) -> String? {
        incident.urgentFollowUpAnswers?[key]
    }

    private func saveDraft() {
        incidentStore.saveDraft(incident)
    }

    private static func resumePath(
        for incident: VehicleIncident
    ) -> [IncidentStep] {
        if incident.status == .submitted,
           incident.guidanceSnapshot != nil {
            return [.guidance]
        }

        guard let safety = incident.safetySelection else {
            return []
        }

        if safety.urgency == .urgent {
            return [.urgentSafety]
        }

        let safetyPath: [IncidentStep] = safety.urgency == .caution
            ? [.cautionSafety]
            : []

        guard !incident.observationTypes.isEmpty else {
            return safetyPath + [.observations]
        }

        guard !incident.userDescription
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .isEmpty else {
            return safetyPath + [.observations, .description]
        }

        guard incident.recentWorkResponse != nil else {
            return safetyPath + [
                .observations,
                .description,
                .recentWork
            ]
        }

        return safetyPath + [
            .observations,
            .description,
            .recentWork,
            .review
        ]
    }
}

private struct IncidentSafetyQuestionView: View {
    let onSelect: (IncidentSafetySelection) -> Void

    var body: some View {
        IncidentQuestionLayout(
            title: "What is happening right now?",
            message: "Choose the closest answer. Safety comes first."
        ) {
            ForEach(IncidentSafetySelection.allCases) { selection in
                Button {
                    onSelect(selection)
                } label: {
                    IncidentChoiceCard(title: selection.title)
                }
                .buttonStyle(.plain)
            }
        }
    }
}

private struct IncidentUrgentFollowUpOption: Identifiable {
    let id: String
    let title: String
}

private struct IncidentUrgentQuestion {
    let title: String
    let message: String?
    let answerKey: String
    let options: [IncidentUrgentFollowUpOption]
}

private struct IncidentIncompleteIntakeRecoveryView: View {
    let onContinue: () -> Void

    var body: some View {
        IncidentQuestionLayout(
            title: "Continue this issue",
            message: "A required answer is still needed before OpenHood can show the result."
        ) {
            IncidentContinueButton(
                title: "Continue questions",
                isDisabled: false,
                action: onContinue
            )
        }
        .navigationTitle("Something Happened")
        .navigationBarTitleDisplayMode(.inline)
    }
}

private struct IncidentUrgentFollowUpView: View {
    let title: String
    var message: String?
    let options: [IncidentUrgentFollowUpOption]
    let onSelect: (String) -> Void

    var body: some View {
        IncidentQuestionLayout(title: title, message: message) {
            ForEach(options) { option in
                Button {
                    onSelect(option.id)
                } label: {
                    IncidentChoiceCard(title: option.title)
                }
                .buttonStyle(.plain)
            }
        }
        .navigationTitle("Safety follow-up")
        .navigationBarTitleDisplayMode(.inline)
    }
}

private struct IncidentSafetyGuidanceView: View {
    let selection: IncidentSafetySelection?
    let isUrgent: Bool
    let primaryTitle: String
    var secondaryTitle: String?
    var confirmationMessage: String?
    var onSecondary: (() -> Void)?
    let onContinue: () -> Void

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                Image(systemName: isUrgent ? "exclamationmark.triangle.fill" : "shield.lefthalf.filled")
                    .font(.system(size: 48))
                    .foregroundStyle(isUrgent ? .red : .orange)

                Text(isUrgent ? "Put safety first" : "Use caution")
                    .font(.largeTitle)
                    .fontWeight(.bold)

                Text(selection?.safetyGuidance ?? IncidentSafetySelection.unsure.safetyGuidance)
                    .font(.title3)

                Text("OpenHood has not identified the cause.")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)

                if let confirmationMessage {
                    Text(confirmationMessage)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .padding(16)
                        .background(Color(.secondarySystemGroupedBackground))
                        .clipShape(RoundedRectangle(cornerRadius: 18))
                }

                Button(action: onContinue) {
                    Text(primaryTitle)
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .padding()
                }
                .buttonStyle(.borderedProminent)

                if let secondaryTitle, let onSecondary {
                    Button(secondaryTitle, action: onSecondary)
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .buttonStyle(.bordered)
                }
            }
            .padding(24)
        }
        .background(Color(.systemGroupedBackground))
        .navigationTitle("Safety")
        .navigationBarTitleDisplayMode(.inline)
    }
}

private struct IncidentObservationView: View {
    @Binding var selections: [IncidentObservationType]
    let onChange: () -> Void
    let onContinue: () -> Void

    var body: some View {
        IncidentQuestionLayout(
            title: "What did you notice?",
            message: "Choose all that apply."
        ) {
            ForEach(IncidentObservationType.allCases) { observation in
                Button {
                    toggle(observation)
                } label: {
                    IncidentChoiceCard(
                        title: observation.title,
                        isSelected: selections.contains(observation)
                    )
                }
                .buttonStyle(.plain)
            }

            IncidentContinueButton(
                title: "Continue",
                isDisabled: selections.isEmpty,
                action: onContinue
            )
        }
        .navigationTitle("Observation")
        .navigationBarTitleDisplayMode(.inline)
    }

    private func toggle(_ observation: IncidentObservationType) {
        if let index = selections.firstIndex(of: observation) {
            selections.remove(at: index)
        } else {
            selections.append(observation)
        }
        onChange()
    }
}

private struct IncidentDescriptionView: View {
    @Binding var description: String
    let onChange: () -> Void
    let onContinue: () -> Void

    private var isEmpty: Bool {
        description.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    var body: some View {
        IncidentQuestionLayout(
            title: "Tell us what happened.",
            message: "Use your own words. Keyboard dictation works normally."
        ) {
            ZStack(alignment: .topLeading) {
                if description.isEmpty {
                    Text(
                        "Describe when it started, what you noticed, and whether the vehicle was moving, idling, or starting."
                    )
                    .foregroundStyle(.secondary)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 18)
                    .allowsHitTesting(false)
                }

                TextEditor(text: $description)
                    .frame(minHeight: 190)
                    .padding(10)
                    .scrollContentBackground(.hidden)
                    .background(Color.clear)
                    .onChange(of: description) { _, _ in
                        onChange()
                    }
            }
            .background(Color(.secondarySystemGroupedBackground))
            .clipShape(RoundedRectangle(cornerRadius: 20))

            IncidentContinueButton(
                title: "Continue",
                isDisabled: isEmpty,
                action: onContinue
            )
        }
        .navigationTitle("Description")
        .navigationBarTitleDisplayMode(.inline)
    }
}

private struct IncidentRecentWorkView: View {
    @Binding var response: IncidentRecentWorkResponse?
    @Binding var notes: String
    let onChange: () -> Void
    let onContinue: () -> Void

    var body: some View {
        IncidentQuestionLayout(
            title: "Did this begin after recent service, a repair, or a modification?"
        ) {
            ForEach(IncidentRecentWorkResponse.allCases) { option in
                Button {
                    response = option
                    if option != .yes {
                        notes = ""
                    }
                    onChange()
                } label: {
                    IncidentChoiceCard(
                        title: option.title,
                        isSelected: response == option
                    )
                }
                .buttonStyle(.plain)
            }

            if response == .yes {
                VStack(alignment: .leading, spacing: 10) {
                    Text("What work was done?")
                        .font(.headline)

                    TextEditor(text: $notes)
                        .frame(minHeight: 130)
                        .padding(10)
                        .scrollContentBackground(.hidden)
                        .background(Color(.secondarySystemGroupedBackground))
                        .clipShape(RoundedRectangle(cornerRadius: 20))
                        .onChange(of: notes) { _, _ in
                            onChange()
                        }
                }
            }

            IncidentContinueButton(
                title: "Review",
                isDisabled: response == nil,
                action: onContinue
            )
        }
        .navigationTitle("Recent work")
        .navigationBarTitleDisplayMode(.inline)
    }
}

private struct IncidentReviewView: View {
    let incident: VehicleIncident
    let vehicleName: String
    let onContinue: () -> Void
    let onStartOver: () -> Void

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                Text("Review incident")
                    .font(.largeTitle)
                    .fontWeight(.bold)

                VStack(spacing: 0) {
                    IncidentReviewRow(title: "Vehicle", value: vehicleName)
                    Divider()
                    IncidentReviewRow(
                        title: "Safety response",
                        value: incident.safetySelection?.title ?? "Not answered"
                    )
                    Divider()
                    IncidentReviewRow(
                        title: "What you noticed",
                        value: incident.observationTypes
                            .map(\.title)
                            .joined(separator: ", ")
                    )
                    Divider()
                    IncidentReviewRow(
                        title: "Description",
                        value: incident.userDescription
                    )
                    Divider()
                    IncidentReviewRow(
                        title: "Recent work",
                        value: recentWorkSummary
                    )
                }
                .background(Color(.secondarySystemGroupedBackground))
                .clipShape(RoundedRectangle(cornerRadius: 22))

                IncidentContinueButton(
                    title: "Your next step",
                    isDisabled: false,
                    action: onContinue
                )

                Button("Describe something new", role: .destructive, action: onStartOver)
                    .font(.headline)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .buttonStyle(.bordered)
            }
            .padding(24)
        }
        .background(Color(.systemGroupedBackground))
        .navigationTitle("Review")
        .navigationBarTitleDisplayMode(.inline)
    }

    private var recentWorkSummary: String {
        guard let response = incident.recentWorkResponse else {
            return "Not answered"
        }

        if response == .yes,
           !incident.recentWorkNotes
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .isEmpty {
            return "Yes — \(incident.recentWorkNotes)"
        }

        return response.title
    }
}

private enum IncidentGuidanceDisclosure: Hashable {
    case areas
    case rationale
    case uncertainty
    case avoid
    case mechanic
    case sources
    case answers
    case moreDetails
}

/// The 4-point non-emergency severity scale shown by IncidentGuidanceView's
/// severityLadder. .doNotRestart is deliberately not a 5th step here — see
/// the doc comment on `severityLadderStep` for why.
private enum IncidentSeverityLadderStep: CaseIterable {
    case monitor, serviceSoon, checkBeforeDriving, stopDriving

    var title: String {
        switch self {
        case .monitor: "Monitor"
        case .serviceSoon: "Service soon"
        case .checkBeforeDriving: "Check before driving"
        case .stopDriving: "Stop driving"
        }
    }

    var color: Color {
        switch self {
        case .monitor: .secondary
        case .serviceSoon, .checkBeforeDriving: .orange
        case .stopDriving: .red
        }
    }
}

private struct IncidentGuidanceView: View {
    let result: IncidentGuidanceResult
    let onSave: () -> Void

    @Environment(\.openURL) private var openURL
    @State private var expandedSection: IncidentGuidanceDisclosure?
    @State private var expandedTermIDs: Set<String> = []
    @State private var didCopySummary = false

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                Text("Your answer")
                    .font(.largeTitle)
                    .fontWeight(.bold)

                if result.isUrgent {
                    urgentContent
                } else {
                    phase1Content
                }
            }
            .padding(24)
        }
        .background(Color(.systemGroupedBackground))
        .navigationTitle("Your next step")
        .navigationBarTitleDisplayMode(.inline)
    }

    // MARK: - Urgent (emergency) layout — unchanged from before the Phase 1 redesign

    @ViewBuilder
    private var urgentContent: some View {
        Text(result.driveRecommendation.rawValue)
            .font(.title2)
            .fontWeight(.bold)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(16)
            .foregroundStyle(driveStatusColor)
            .background(driveStatusColor.opacity(0.10))
            .clipShape(RoundedRectangle(cornerRadius: 18))

        resultCard(title: "What this most strongly suggests") {
            Text(result.plainLanguageAssessment)
                .font(.headline)
            Text("OpenHood has not physically inspected the vehicle or confirmed the cause.")
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }

        resultCard(title: "Do this now") {
            Text(result.immediateAction)
                .font(.headline)
        }

        resultCard(title: "What would help confirm it") {
            Text(result.confirmationStep)
                .font(.headline)
        }

        Text("More details")
            .font(.title2)
            .fontWeight(.bold)

        if !result.possibleContributors.isEmpty {
            disclosureCard(
                title: "Possible system areas",
                section: .areas
            ) {
                ForEach(result.possibleContributors) { contributor in
                    VStack(alignment: .leading, spacing: 5) {
                        Text(contributor.category.rawValue)
                            .font(.headline)
                        Text(contributor.confidenceWording)
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                }
            }
        }

        if !result.possibleContributors.isEmpty {
            disclosureCard(
                title: "Why this fits",
                section: .rationale
            ) {
                ForEach(result.possibleContributors) { contributor in
                    VStack(alignment: .leading, spacing: 5) {
                        Text(contributor.rationale.observedFact)
                            .font(.headline)
                        Text(contributor.rationale.explanation)
                            .foregroundStyle(.secondary)
                    }
                }
            }
        }

        if !result.uncertaintyStatements.isEmpty {
            disclosureCard(
                title: "What remains uncertain",
                section: .uncertainty
            ) {
                guidanceList(result.uncertaintyStatements)
            }
        }

        if !result.actionsToAvoid.isEmpty {
            disclosureCard(
                title: "What to avoid",
                section: .avoid
            ) {
                guidanceList(result.actionsToAvoid)
            }
        }

        if !result.mechanicReadySummary.isEmpty {
            disclosureCard(
                title: "Information for a mechanic",
                section: .mechanic
            ) {
                Text(result.mechanicReadySummary)
                    .textSelection(.enabled)

                copySummaryButton
            }
        }

        sourcesDisclosure
        answersDisclosure

        IncidentContinueButton(
            title: "Save this result",
            isDisabled: false,
            action: onSave
        )
    }

    // MARK: - Phase 1 (non-emergency) redesigned layout

    @ViewBuilder
    private var phase1Content: some View {
        severityLadder

        if let context = result.reportedContext {
            Label(context, systemImage: "mappin.and.ellipse")
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }

        if showsTrustIndicator {
            Label("Reviewed automotive guidance, not a guess", systemImage: "checkmark.seal.fill")
                .font(.subheadline)
                .foregroundStyle(.green)
        }

        resultCard(title: "What this most strongly suggests") {
            Text(result.plainLanguageAssessment)
                .font(.headline)
            Text("OpenHood has not physically inspected the vehicle or confirmed the cause.")
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }

        resultCard(title: "Do this now") {
            Text(result.immediateAction)
                .font(.headline)
        }

        resultCard(title: "What would help confirm it") {
            Text(result.confirmationStep)
                .font(.headline)
        }

        possibleAreasSection
        findShopButton
        costRangeSection
        moreDetailsSection
        sourcesDisclosure
        answersDisclosure

        IncidentContinueButton(
            title: "Save this result",
            isDisabled: false,
            action: onSave
        )
    }

    /// Maps the result's single driveRecommendation onto the 4-point
    /// ladder. .doNotRestart has no ladder position — it's about not
    /// restarting after already stopping, not a point on a "how much
    /// longer can I keep driving" scale, so it's surfaced as its own
    /// badge (see `doNotRestartBadge`) instead of forcing it onto this
    /// line. The ordinary (non-urgent) path never actually produces
    /// .doNotRestart today, but this stays correct if that ever changes.
    private var severityLadderStep: IncidentSeverityLadderStep? {
        switch result.driveRecommendation {
        case .monitor: .monitor
        case .serviceSoon: .serviceSoon
        case .checkBeforeDriving: .checkBeforeDriving
        case .stopDriving: .stopDriving
        case .doNotRestart: nil
        }
    }

    @ViewBuilder
    private var severityLadder: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(spacing: 4) {
                ForEach(IncidentSeverityLadderStep.allCases, id: \.self) { step in
                    let isActive = step == severityLadderStep
                    Text(step.title)
                        .font(.caption)
                        .fontWeight(isActive ? .bold : .regular)
                        .multilineTextAlignment(.center)
                        .foregroundStyle(isActive ? .white : .secondary)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 10)
                        .background(isActive ? step.color : Color.secondary.opacity(0.12))
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                }
            }

            if result.driveRecommendation == .doNotRestart {
                doNotRestartBadge
            }
        }
    }

    private var doNotRestartBadge: some View {
        Label("Do not restart", systemImage: "exclamationmark.octagon.fill")
            .font(.caption)
            .fontWeight(.bold)
            .foregroundStyle(.white)
            .padding(.horizontal, 10)
            .padding(.vertical, 6)
            .background(Color.red)
            .clipShape(Capsule())
    }

    /// Only claims "reviewed automotive guidance" when every shown
    /// contributor is actually backed by reviewed content — never true
    /// yet for the 8 still-placeholder Phase 1 records, so this line
    /// simply doesn't appear for those instead of overclaiming.
    private var showsTrustIndicator: Bool {
        !result.possibleContributors.isEmpty
            && result.possibleContributors.allSatisfy(\.isReviewedGuidance)
    }

    private var allTerms: [IncidentPossibleAreaTerm] {
        result.possibleContributors.flatMap(\.terms)
    }

    /// Item 3: individual tappable rows (icon + term) instead of a
    /// paragraph. Falls back to a plain category list for any Phase 1
    /// record that hasn't been given structured possibleAreaTerms yet
    /// (everything except phase1.suspension.bump-noise, for now).
    @ViewBuilder
    private var possibleAreasSection: some View {
        if !result.possibleContributors.isEmpty {
            resultCard(title: "Possible areas to inspect") {
                if allTerms.isEmpty {
                    ForEach(result.possibleContributors) { contributor in
                        Text(contributor.category.rawValue)
                            .font(.headline)
                    }
                } else {
                    VStack(alignment: .leading, spacing: 14) {
                        ForEach(allTerms) { term in
                            termRow(term)
                        }
                    }
                }
            }
        }
    }

    @ViewBuilder
    private func termRow(_ term: IncidentPossibleAreaTerm) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Button {
                toggleTerm(term.id)
            } label: {
                HStack {
                    Image(systemName: "wrench.and.screwdriver")
                        .foregroundStyle(.secondary)
                    Text(term.name)
                        .font(.headline)
                        .foregroundStyle(.primary)
                    Spacer()
                    Image(
                        systemName: expandedTermIDs.contains(term.id)
                            ? "chevron.up"
                            : "chevron.down"
                    )
                    .font(.caption)
                    .foregroundStyle(.secondary)
                }
            }
            .buttonStyle(.plain)

            if expandedTermIDs.contains(term.id) {
                Text(term.plainExplanation)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .padding(.leading, 26)
            }
        }
    }

    private func toggleTerm(_ id: String) {
        if expandedTermIDs.contains(id) {
            expandedTermIDs.remove(id)
        } else {
            expandedTermIDs.insert(id)
        }
    }

    /// Item 4: zero-cost handoff to the user's own Maps app — no ratings
    /// API, no network call this app makes, just a pre-filled search.
    private var firstRepairSearchTerm: String? {
        result.possibleContributors.compactMap(\.repairSearchTerm).first
    }

    @ViewBuilder
    private var findShopButton: some View {
        if let searchTerm = firstRepairSearchTerm {
            Button {
                openMaps(searchingFor: searchTerm)
            } label: {
                Label("Find a shop", systemImage: "map")
                    .font(.headline)
                    .frame(maxWidth: .infinity)
                    .padding()
            }
            .buttonStyle(.bordered)
        }
    }

    private func openMaps(searchingFor searchTerm: String) {
        var components = URLComponents(string: "http://maps.apple.com/")
        components?.queryItems = [
            URLQueryItem(name: "q", value: "\(searchTerm) near me")
        ]
        guard let url = components?.url else { return }
        openURL(url)
    }

    /// Item 5: cost ranges are display strings, not necessarily numeric
    /// (e.g. strut mounts), and are only shown when at least one term
    /// actually has one.
    @ViewBuilder
    private var costRangeSection: some View {
        let costedTerms = allTerms.filter { $0.typicalCostRange != nil }
        if !costedTerms.isEmpty {
            resultCard(title: "Typical cost range") {
                VStack(alignment: .leading, spacing: 12) {
                    ForEach(costedTerms) { term in
                        VStack(alignment: .leading, spacing: 2) {
                            Text(term.name)
                                .font(.subheadline)
                                .fontWeight(.semibold)
                            Text(term.typicalCostRange ?? "")
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                        }
                    }
                    Text("General U.S. estimate, varies by location, vehicle, and labor rates — not a quote.")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
        }
    }

    /// Item 2's last bullet: the deeper stuff, collapsed by default
    /// (expandedSection defaults to nil).
    @ViewBuilder
    private var moreDetailsSection: some View {
        if !result.uncertaintyStatements.isEmpty
            || !result.actionsToAvoid.isEmpty
            || !result.mechanicReadySummary.isEmpty {
            disclosureCard(title: "More details", section: .moreDetails) {
                VStack(alignment: .leading, spacing: 16) {
                    if !result.uncertaintyStatements.isEmpty {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("What remains uncertain")
                                .font(.headline)
                            guidanceList(result.uncertaintyStatements)
                        }
                    }
                    if !result.actionsToAvoid.isEmpty {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("What to avoid")
                                .font(.headline)
                            guidanceList(result.actionsToAvoid)
                        }
                    }
                    if !result.mechanicReadySummary.isEmpty {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Information for a mechanic")
                                .font(.headline)
                            Text(result.mechanicReadySummary)
                                .textSelection(.enabled)
                            copySummaryButton
                        }
                    }
                }
            }
        }
    }

    private var copySummaryButton: some View {
        Button {
            UIPasteboard.general.string = result.mechanicReadySummary
            didCopySummary = true
        } label: {
            Label(
                didCopySummary ? "Copied" : "Copy summary",
                systemImage: didCopySummary ? "checkmark" : "doc.on.doc"
            )
            .font(.headline)
            .frame(maxWidth: .infinity)
            .padding()
        }
        .buttonStyle(.bordered)
    }

    @ViewBuilder
    private var sourcesDisclosure: some View {
        disclosureCard(
            title: "Sources and confidence",
            section: .sources
        ) {
            Text(result.confidenceLabel)
                .font(.headline)
            Text(result.knowledgeStatus)
                .foregroundStyle(.secondary)
            Text("Knowledge record IDs: \(result.matchedRecordIDs.joined(separator: ", "))")
                .font(.caption)
                .foregroundStyle(.secondary)
                .textSelection(.enabled)
        }
    }

    @ViewBuilder
    private var answersDisclosure: some View {
        if !result.reportedSummary.isEmpty {
            disclosureCard(
                title: "Your answers",
                section: .answers
            ) {
                Text(result.reportedSummary)
                    .foregroundStyle(.secondary)
            }
        }
    }

    private var driveStatusColor: Color {
        switch result.driveRecommendation {
        case .stopDriving, .doNotRestart:
            .red
        case .serviceSoon, .checkBeforeDriving:
            .orange
        case .monitor:
            .secondary
        }
    }

    @ViewBuilder
    private func resultCard<Content: View>(
        title: String,
        @ViewBuilder content: () -> Content
    ) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(title)
                .font(.title2)
                .fontWeight(.bold)
            content()
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(16)
        .background(Color(.secondarySystemGroupedBackground))
        .clipShape(RoundedRectangle(cornerRadius: 18))
    }

    @ViewBuilder
    private func disclosureCard<Content: View>(
        title: String,
        section: IncidentGuidanceDisclosure,
        @ViewBuilder content: () -> Content
    ) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Button {
                expandedSection = expandedSection == section ? nil : section
            } label: {
                HStack {
                    Text(title)
                        .font(.headline)
                        .multilineTextAlignment(.leading)
                    Spacer()
                    Image(
                        systemName: expandedSection == section
                            ? "chevron.up"
                            : "chevron.down"
                    )
                }
            }
            .buttonStyle(.plain)

            if expandedSection == section {
                content()
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(16)
        .background(Color(.secondarySystemGroupedBackground))
        .clipShape(RoundedRectangle(cornerRadius: 18))
    }

    private func guidanceList(_ items: [String]) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            ForEach(items, id: \.self) { item in
                HStack(alignment: .top, spacing: 10) {
                    Image(systemName: "circle.fill")
                        .font(.system(size: 6))
                        .padding(.top, 7)
                    Text(item)
                }
            }
        }
    }
}

private struct IncidentSavedView: View {
    let onReturn: () -> Void

    var body: some View {
        VStack(spacing: 20) {
            Spacer()

            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 64))
                .foregroundStyle(.green)

            Text("Incident saved")
                .font(.largeTitle)
                .fontWeight(.bold)

            Text(
                "OpenHood recorded your observations without identifying a cause."
            )
            .font(.title3)
            .foregroundStyle(.secondary)
            .multilineTextAlignment(.center)

            Spacer()

            IncidentContinueButton(
                title: "Return to Help",
                isDisabled: false,
                action: onReturn
            )
        }
        .padding(24)
        .navigationBarBackButtonHidden(true)
    }
}

private struct IncidentQuestionLayout<Content: View>: View {
    let title: String
    var message: String?
    @ViewBuilder let content: Content

    init(
        title: String,
        message: String? = nil,
        @ViewBuilder content: () -> Content
    ) {
        self.title = title
        self.message = message
        self.content = content()
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                Text(title)
                    .font(.largeTitle)
                    .fontWeight(.bold)

                if let message {
                    Text(message)
                        .font(.body)
                        .foregroundStyle(.secondary)
                }

                content
            }
            .padding(24)
        }
        .background(Color(.systemGroupedBackground))
    }
}

private struct IncidentChoiceCard: View {
    let title: String
    var isSelected = false

    var body: some View {
        HStack(spacing: 14) {
            Text(title)
                .font(.headline)
                .multilineTextAlignment(.leading)

            Spacer()

            if isSelected {
                Image(systemName: "checkmark.circle.fill")
                    .foregroundStyle(.green)
            } else {
                Image(systemName: "chevron.right")
                    .foregroundStyle(.secondary)
            }
        }
        .padding(18)
        .background(Color(.secondarySystemGroupedBackground))
        .clipShape(RoundedRectangle(cornerRadius: 20))
        .overlay {
            RoundedRectangle(cornerRadius: 20)
                .stroke(
                    isSelected ? Color.primary : Color.secondary.opacity(0.12),
                    lineWidth: isSelected ? 1.5 : 1
                )
        }
        .contentShape(Rectangle())
    }
}

private struct IncidentContinueButton: View {
    let title: String
    let isDisabled: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.headline)
                .frame(maxWidth: .infinity)
                .padding()
        }
        .buttonStyle(.borderedProminent)
        .disabled(isDisabled)
    }
}

private struct IncidentReviewRow: View {
    let title: String
    let value: String

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(title)
                .font(.caption)
                .foregroundStyle(.secondary)

            Text(value.isEmpty ? "Not provided" : value)
                .font(.body)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(16)
    }
}

private extension SavedVehicle {
    var incidentDisplayName: String {
        let name = [year.map(String.init), make, model]
            .compactMap { value in
                guard let value, !value.isEmpty else { return nil }
                return value
            }
            .joined(separator: " ")

        guard let trim, !trim.isEmpty else {
            return name
        }

        return "\(name) · \(trim)"
    }
}

private extension IncidentSafetySelection {
    var safetyGuidance: String {
        switch self {
        case .smokeOrFire:
            "Stop driving and switch off the vehicle when safe. Move everyone away from the vehicle. Contact emergency services if there is fire or continuing smoke, and arrange roadside assistance."
        case .strongFuelSmell:
            "Stop driving and switch off the vehicle when safe. Keep away from flames or sparks and move away from the vehicle. Contact emergency services if there is immediate danger, and arrange roadside assistance."
        case .overheatingOrSteam:
            "Stop driving and switch off the vehicle when safe. Do not open a hot cooling system or touch hot components. Keep a safe distance and arrange roadside assistance."
        case .flashingWarningLight:
            "Stop driving as soon as it is safe and switch off the vehicle. Do not drive to reproduce the warning. Arrange roadside assistance, and contact emergency services if there is an immediate hazard."
        case .unsafeBrakesOrSteering:
            "Do not continue driving. Stop in the safest available place, use hazard lights when appropriate, and arrange roadside assistance. Contact emergency services if you cannot get out of immediate danger safely."
        case .engineWillNotStayRunning:
            "Do not keep driving or repeatedly try to reproduce the problem. Move to a safe location if possible without driving farther, switch off the vehicle, and arrange roadside assistance."
        case .unsure:
            "If the vehicle feels unsafe, do not continue driving. Stop in a safe place and arrange roadside assistance. You may continue describing only what you already observed."
        case .noneOfThese:
            "Continue describing what you observed without driving to reproduce the symptom."
        }
    }
}
