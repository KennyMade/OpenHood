import SwiftUI

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
    @StateObject private var incidentStore = IncidentStore()
    @State private var incidentForIntake: VehicleIncident?

    private var activeVehicle: SavedVehicle? {
        garageStore.activeVehicle
    }

    private var activeDraft: VehicleIncident? {
        guard let vehicleID = activeVehicle?.id else { return nil }
        return incidentStore.draft(for: vehicleID)
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
                        Text("Continue draft")
                            .font(.headline)
                            .frame(maxWidth: .infinity)
                            .padding()
                    }
                    .buttonStyle(.borderedProminent)

                    Button("Start over") {
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
            }
            .padding(24)
        }
        .background(Color(.systemGroupedBackground))
        .navigationTitle("Something Happened")
        .navigationBarTitleDisplayMode(.inline)
        .fullScreenCover(item: $incidentForIntake) { incident in
            IncidentIntakeView(
                initialIncident: incident,
                vehicleName: activeVehicle?.incidentDisplayName ?? "Vehicle",
                incidentStore: incidentStore
            )
        }
    }

    private func startNewIncident() {
        guard let vehicleID = activeVehicle?.id else { return }
        incidentForIntake = incidentStore.startNewDraft(for: vehicleID)
    }
}

private enum IncidentStep: Hashable {
    case urgentSafety
    case cautionSafety
    case observations
    case description
    case recentWork
    case review
    case saved
}

private struct IncidentIntakeView: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject var incidentStore: IncidentStore

    let vehicleName: String

    @State private var incident: VehicleIncident
    @State private var path: [IncidentStep]

    init(
        initialIncident: VehicleIncident,
        vehicleName: String,
        incidentStore: IncidentStore
    ) {
        self.vehicleName = vehicleName
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
                primaryTitle: "Save incident"
            ) {
                incidentStore.submit(incident)
                path.append(.saved)
            }
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
                path.append(.description)
            }
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
                vehicleName: vehicleName,
                onSave: {
                    incidentStore.submit(incident)
                    path.append(.saved)
                },
                onStartOver: {
                    incident = incidentStore.startNewDraft(
                        for: incident.vehicleID
                    )
                    path.removeAll()
                }
            )
        case .saved:
            IncidentSavedView {
                dismiss()
            }
        }
    }

    private func saveDraft() {
        incidentStore.saveDraft(incident)
    }

    private static func resumePath(
        for incident: VehicleIncident
    ) -> [IncidentStep] {
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

private struct IncidentSafetyGuidanceView: View {
    let selection: IncidentSafetySelection?
    let isUrgent: Bool
    let primaryTitle: String
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

                Text("OpenHood has not diagnosed the vehicle.")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)

                Button(action: onContinue) {
                    Text(primaryTitle)
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .padding()
                }
                .buttonStyle(.borderedProminent)
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
    let onSave: () -> Void
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
                    title: "Save incident",
                    isDisabled: false,
                    action: onSave
                )

                Button("Start over", role: .destructive, action: onStartOver)
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
                "OpenHood recorded your observations but has not diagnosed the vehicle."
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
