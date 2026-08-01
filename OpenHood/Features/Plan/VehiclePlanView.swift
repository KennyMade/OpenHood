import SwiftUI

// MARK: - Vehicle Planning

enum VehiclePlanGoal: String, CaseIterable, Identifiable {
    case reliable = "Reliable"
    case performance = "Performance"
    case style = "Style"
    case custom = "Custom Plan"

    var id: String {
        rawValue
    }

    var icon: String {
        switch self {
        case .reliable:
            return "shield.checkered"

        case .performance:
            return "gauge.with.dots.needle.67percent"

        case .style:
            return "paintbrush.fill"

        case .custom:
            return "slider.horizontal.3"
        }
    }

    var subtitle: String {
        switch self {
        case .reliable:
            return "Reliability, comfort, preparation, and long-term ownership"

        case .performance:
            return "Power, handling, braking, cooling, sound, and track use"

        case .style:
            return "Wheels, stance, exterior, lighting, interior, and sound"

        case .custom:
            return "Restore, refine, compete, show, or describe your own goal"
        }
    }

    var focusPrompt: String {
        switch self {
        case .reliable:
            return "What should your reliable plan focus on?"

        case .performance:
            return "What matters most?"

        case .style:
            return "Which area do you want to change?"

        case .custom:
            return "What kind of plan do you have in mind?"
        }
    }

    var focusChoices: [String] {
        switch self {
        case .reliable:
            return [
                "Stay ahead of problems",
                "Fix something now",
                "Return to stock"
            ]

        case .performance:
            return [
                "Power",
                "Handling",
                "Braking",
                "Sound",
                "Track use"
            ]

        case .style:
            return [
                "Exterior",
                "Interior",
                "Sound"
            ]

        case .custom:
            return [
                "Restore to factory",
                "OEM+",
                "Street",
                "Drift",
                "Track",
                "Show",
                "Stance",
                "Describe my own goal"
            ]
        }
    }

}

enum PlanBudget: String, CaseIterable, Identifiable {
    case underFiveHundred = "Under $500"
    case fiveHundredToFifteenHundred = "$500–$1,500"
    case fifteenHundredToThreeThousand = "$1,500–$3,000"
    case threeThousandPlus = "$3,000+"
    case flexible = "Flexible"

    var id: String {
        rawValue
    }
}

enum PlanTimeline: String, CaseIterable, Identifiable {
    case thisMonth = "This month"
    case nextThreeMonths = "Next 3 months"
    case thisYear = "This year"
    case noDeadline = "No deadline"

    var id: String {
        rawValue
    }
}

struct PlanFollowUpQuestion: Identifiable {
    let title: String
    let options: [PlanQuestionOption]

    var id: String {
        title
    }
}

struct PlanQuestionOption: Identifiable {
    let title: String
    let subtitle: String?

    var id: String {
        title
    }

    init(
        _ title: String,
        subtitle: String? = nil
    ) {
        self.title = title
        self.subtitle = subtitle
    }
}

struct VehiclePlanView: View {
    @EnvironmentObject private var vehicle: VehicleOnboardingData

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                VStack(alignment: .leading, spacing: 7) {
                    Text("Plan your build")
                        .font(.largeTitle)
                        .fontWeight(.bold)

                    Text("What are you building your \(vehicle.model) toward?")
                        .font(.body)
                        .foregroundStyle(.secondary)
                }

                VStack(spacing: 14) {
                    ForEach(VehiclePlanGoal.allCases) { goal in
                        NavigationLink {
                            VehiclePlanGoalView(goal: goal)
                        } label: {
                            PlanGoalCard(goal: goal)
                        }
                        .buttonStyle(.plain)
                    }
                }

                VStack(alignment: .leading, spacing: 8) {
                    Label(
                        "Plans will be vehicle-specific",
                        systemImage: "checkmark.seal.fill"
                    )
                    .font(.headline)

                    Text(
                        "OpenHood will account for your exact vehicle, mileage, maintenance history, existing modifications, budget, and intended use."
                    )
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                }
                .padding(18)
                .background(Color(.secondarySystemGroupedBackground))
                .clipShape(
                    RoundedRectangle(cornerRadius: 20)
                )

                Spacer(minLength: 24)
            }
            .padding(20)
        }
        .background(Color(.systemGroupedBackground))
        .navigationTitle("Plan")
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct PlanGoalCard: View {
    let goal: VehiclePlanGoal

    var body: some View {
        HStack(spacing: 16) {
            ZStack {
                RoundedRectangle(cornerRadius: 18)
                    .fill(Color.primary.opacity(0.08))
                    .frame(width: 58, height: 58)

                Image(systemName: goal.icon)
                    .font(.system(size: 24, weight: .semibold))
            }

            VStack(alignment: .leading, spacing: 5) {
                Text(goal.rawValue)
                    .font(.headline)

                Text(goal.subtitle)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.leading)
            }

            Spacer()

            Image(systemName: "chevron.right")
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .padding(18)
        .frame(maxWidth: .infinity)
        .background(Color(.secondarySystemGroupedBackground))
        .clipShape(
            RoundedRectangle(cornerRadius: 22)
        )
        .overlay {
            RoundedRectangle(cornerRadius: 22)
                .stroke(
                    Color.secondary.opacity(0.12),
                    lineWidth: 1
                )
        }
    }
}

struct VehiclePlanGoalView: View {
    @EnvironmentObject private var vehicle: VehicleOnboardingData

    let goal: VehiclePlanGoal

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                VStack(alignment: .leading, spacing: 16) {
                    ZStack {
                        RoundedRectangle(cornerRadius: 24)
                            .fill(Color.primary)
                            .frame(width: 76, height: 76)

                        Image(systemName: goal.icon)
                            .font(.system(size: 31, weight: .semibold))
                            .foregroundStyle(Color(.systemBackground))
                    }

                    VStack(alignment: .leading, spacing: 8) {
                        Text(goal.focusPrompt)
                            .font(.largeTitle)
                            .fontWeight(.bold)

                        Text(vehicle.vehicleName)
                            .font(.headline)
                            .foregroundStyle(.secondary)
                    }
                }

                VStack(spacing: 14) {
                    ForEach(goal.focusChoices, id: \.self) { focus in
                        NavigationLink {
                            PlanBuilderPlaceholderView(
                                goal: goal,
                                focus: focus
                            )
                        } label: {
                            PlanSelectionCard(title: focus)
                        }
                        .buttonStyle(.plain)
                    }
                }

                Spacer(minLength: 24)
            }
            .padding(20)
        }
        .background(Color(.systemGroupedBackground))
        .navigationTitle(goal.rawValue)
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct PlanSelectionCard: View {
    let title: String
    var subtitle: String? = nil

    var body: some View {
        HStack(spacing: 16) {
            VStack(alignment: .leading, spacing: 5) {
                Text(title)
                    .font(.headline)

                if let subtitle {
                    Text(subtitle)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.leading)
                }
            }

            Spacer()

            Image(systemName: "chevron.right")
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .padding(20)
        .frame(maxWidth: .infinity, minHeight: 72)
        .background(Color(.secondarySystemGroupedBackground))
        .clipShape(
            RoundedRectangle(cornerRadius: 22)
        )
        .overlay {
            RoundedRectangle(cornerRadius: 22)
                .stroke(
                    Color.secondary.opacity(0.12),
                    lineWidth: 1
                )
        }
    }
}

struct PlanPreviewCard: View {
    let title: String
    let icon: String
    let items: [String]

    var body: some View {
        VStack(alignment: .leading, spacing: 17) {
            HStack(spacing: 11) {
                Image(systemName: icon)
                    .font(.title3)

                Text(title)
                    .font(.title3)
                    .fontWeight(.bold)
            }

            VStack(alignment: .leading, spacing: 13) {
                ForEach(items, id: \.self) { item in
                    HStack(alignment: .top, spacing: 11) {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)

                        Text(item)
                            .font(.subheadline)
                            .frame(
                                maxWidth: .infinity,
                                alignment: .leading
                            )
                    }
                }
            }
        }
        .padding(20)
        .background(Color(.secondarySystemGroupedBackground))
        .clipShape(
            RoundedRectangle(cornerRadius: 24)
        )
        .overlay {
            RoundedRectangle(cornerRadius: 24)
                .stroke(
                    Color.secondary.opacity(0.12),
                    lineWidth: 1
                )
        }
    }
}

struct PlanBuilderPlaceholderView: View {
    @EnvironmentObject private var vehicle: VehicleOnboardingData

    let goal: VehiclePlanGoal
    let focus: String

    @State private var step = 0
    @State private var answers: [String: String] = [:]
    @State private var budget: PlanBudget?
    @State private var timeline: PlanTimeline?
    @State private var customGoal = ""

    private var followUpQuestions: [PlanFollowUpQuestion] {
        switch goal {
        case .performance:
            return [
                PlanFollowUpQuestion(
                    title: "How will you use the vehicle?",
                    options: [
                        PlanQuestionOption("Daily driving"),
                        PlanQuestionOption("Spirited street driving"),
                        PlanQuestionOption("Track days"),
                        PlanQuestionOption("Competition")
                    ]
                ),
                PlanFollowUpQuestion(
                    title: "How should we balance performance and everyday use?",
                    options: [
                        PlanQuestionOption(
                            "Everyday reliability",
                            subtitle: "Avoid changes that add significant upkeep or strain."
                        ),
                        PlanQuestionOption(
                            "Street balance",
                            subtitle: "Allow moderate upgrades with manageable maintenance."
                        ),
                        PlanQuestionOption(
                            "Performance priority",
                            subtitle: "Accept more upkeep, wear, and potential downtime."
                        )
                    ]
                )
            ]

        case .style:
            return [
                styleDetailQuestion,
                PlanFollowUpQuestion(
                    title: "Does daily practicality matter?",
                    options: [
                        PlanQuestionOption("Yes"),
                        PlanQuestionOption("No")
                    ]
                ),
                PlanFollowUpQuestion(
                    title: "Should changes be easily reversible?",
                    options: [
                        PlanQuestionOption("Yes"),
                        PlanQuestionOption("No")
                    ]
                )
            ]

        case .reliable, .custom:
            return []
        }
    }

    private var styleDetailQuestion: PlanFollowUpQuestion {
        switch focus {
        case "Exterior":
            return PlanFollowUpQuestion(
                title: "What part of the exterior?",
                options: [
                    PlanQuestionOption("Wheels and tires"),
                    PlanQuestionOption("Stance"),
                    PlanQuestionOption("Paint or wrap"),
                    PlanQuestionOption("Bodywork"),
                    PlanQuestionOption("Lighting")
                ]
            )

        case "Interior":
            return PlanFollowUpQuestion(
                title: "What part of the interior?",
                options: [
                    PlanQuestionOption("Seats"),
                    PlanQuestionOption("Steering and controls"),
                    PlanQuestionOption("Trim and materials"),
                    PlanQuestionOption("Audio and technology")
                ]
            )

        default:
            return PlanFollowUpQuestion(
                title: "What kind of sound change?",
                options: [
                    PlanQuestionOption("Exhaust tone"),
                    PlanQuestionOption("Exhaust appearance"),
                    PlanQuestionOption("Cabin audio")
                ]
            )
        }
    }

    private var needsCustomDescription: Bool {
        goal == .custom && focus == "Describe my own goal"
    }

    private var customDescriptionStepCount: Int {
        needsCustomDescription ? 1 : 0
    }

    private var budgetStep: Int {
        customDescriptionStepCount + followUpQuestions.count
    }

    private var timelineStep: Int {
        budgetStep + 1
    }

    private var previewStep: Int {
        timelineStep + 1
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                if needsCustomDescription && step == 0 {
                    customDescriptionQuestion
                } else if let question = currentFollowUpQuestion {
                    choiceQuestion(
                        title: question.title,
                        options: question.options
                    ) { answer in
                        answers[question.title] = answer
                        step += 1
                    }
                } else if step == budgetStep {
                    choiceQuestion(
                        title: "What is your budget?",
                        options: PlanBudget.allCases.map {
                            PlanQuestionOption($0.rawValue)
                        }
                    ) { answer in
                        budget = PlanBudget(rawValue: answer)
                        step += 1
                    }
                } else if step == timelineStep {
                    choiceQuestion(
                        title: "What is your timeline?",
                        options: PlanTimeline.allCases.map {
                            PlanQuestionOption($0.rawValue)
                        }
                    ) { answer in
                        timeline = PlanTimeline(rawValue: answer)
                        step += 1
                    }
                } else {
                    planPreview
                }
            }
            .padding(20)
        }
        .background(Color(.systemGroupedBackground))
        .navigationTitle(step >= previewStep ? "Plan Preview" : goal.rawValue)
        .navigationBarTitleDisplayMode(.inline)
    }

    private var currentFollowUpQuestion: PlanFollowUpQuestion? {
        let questionIndex = step - customDescriptionStepCount

        guard questionIndex >= 0,
              questionIndex < followUpQuestions.count else {
            return nil
        }

        return followUpQuestions[questionIndex]
    }

    private var customDescriptionQuestion: some View {
        VStack(alignment: .leading, spacing: 20) {
            questionHeader(
                title: "Describe your goal",
                subtitle: "A short description is enough. You do not need to know the names of the parts."
            )

            TextEditor(text: $customGoal)
                .font(.body)
                .frame(minHeight: 170)
                .padding(14)
                .scrollContentBackground(.hidden)
                .background(Color(.secondarySystemGroupedBackground))
                .clipShape(
                    RoundedRectangle(cornerRadius: 22)
                )
                .overlay {
                    RoundedRectangle(cornerRadius: 22)
                        .stroke(
                            Color.secondary.opacity(0.15),
                            lineWidth: 1
                        )
                }

            Button {
                step += 1
            } label: {
                Text("Continue")
                    .font(.headline)
                    .foregroundStyle(Color(.systemBackground))
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 18)
                    .background(
                        customGoal.trimmingCharacters(
                            in: .whitespacesAndNewlines
                        ).isEmpty
                            ? Color.secondary.opacity(0.35)
                            : Color.primary
                    )
                    .clipShape(
                        RoundedRectangle(cornerRadius: 18)
                    )
            }
            .buttonStyle(.plain)
            .disabled(
                customGoal.trimmingCharacters(
                    in: .whitespacesAndNewlines
                ).isEmpty
            )
        }
    }

    private func choiceQuestion(
        title: String,
        options: [PlanQuestionOption],
        selection: @escaping (String) -> Void
    ) -> some View {
        VStack(alignment: .leading, spacing: 20) {
            questionHeader(
                title: title,
                subtitle: "\(goal.rawValue) · \(focus)"
            )

            VStack(spacing: 14) {
                ForEach(options) { option in
                    Button {
                        selection(option.title)
                    } label: {
                        PlanSelectionCard(
                            title: option.title,
                            subtitle: option.subtitle
                        )
                    }
                    .buttonStyle(.plain)
                }
            }
        }
    }

    private func questionHeader(
        title: String,
        subtitle: String
    ) -> some View {
        VStack(alignment: .leading, spacing: 7) {
            Text(title)
                .font(.largeTitle)
                .fontWeight(.bold)

            Text(subtitle)
                .font(.body)
                .foregroundStyle(.secondary)
        }
    }

    private var planPreview: some View {
        VStack(alignment: .leading, spacing: 24) {
            VStack(alignment: .leading, spacing: 7) {
                Text("Your plan")
                    .font(.largeTitle)
                    .fontWeight(.bold)

                Text(vehicle.vehicleName)
                    .font(.headline)
                    .foregroundStyle(.secondary)
            }

            PlanSelectionSummaryCard(
                goal: goal.rawValue,
                focus: focus,
                budget: budget?.rawValue ?? "",
                timeline: timeline?.rawValue ?? "",
                answers: answers,
                customGoal: needsCustomDescription ? customGoal : nil
            )

            PlanCostImpactCard()

            Spacer(minLength: 24)
        }
    }
}

struct PlanSelectionSummaryCard: View {
    let goal: String
    let focus: String
    let budget: String
    let timeline: String
    let answers: [String: String]
    let customGoal: String?

    var body: some View {
        VStack(alignment: .leading, spacing: 15) {
            Text("Plan summary")
                .font(.title3)
                .fontWeight(.bold)

            summaryRow(label: "Goal", value: goal)
            summaryRow(label: "Focus", value: focus)

            if let customGoal,
               !customGoal.isEmpty {
                summaryRow(label: "Description", value: customGoal)
            }

            ForEach(answers.keys.sorted(), id: \.self) { question in
                if let answer = answers[question] {
                    summaryRow(label: question, value: answer)
                }
            }

            summaryRow(label: "Budget", value: budget)
            summaryRow(label: "Timeline", value: timeline)
        }
        .padding(20)
        .background(Color(.secondarySystemGroupedBackground))
        .clipShape(
            RoundedRectangle(cornerRadius: 24)
        )
        .overlay {
            RoundedRectangle(cornerRadius: 24)
                .stroke(
                    Color.secondary.opacity(0.12),
                    lineWidth: 1
                )
        }
    }

    private func summaryRow(
        label: String,
        value: String
    ) -> some View {
        VStack(alignment: .leading, spacing: 3) {
            Text(label)
                .font(.caption)
                .foregroundStyle(.secondary)

            Text(value)
                .font(.subheadline)
                .fontWeight(.semibold)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

enum PlanImpactSection: String, CaseIterable, Identifiable {
    case benefits = "Benefits"
    case tradeoffs = "Tradeoffs"
    case supportingWork = "Supporting work"

    var id: String {
        rawValue
    }
}

struct PlanCostImpactCard: View {
    @State private var expandedSection: PlanImpactSection?

    var body: some View {
        VStack(alignment: .leading, spacing: 18) {
            HStack(spacing: 11) {
                Image(systemName: "dollarsign.circle.fill")
                    .font(.title3)

                Text("Cost and impact")
                    .font(.title3)
                    .fontWeight(.bold)
            }

            HStack(spacing: 12) {
                estimateStatus(
                    title: "Parts",
                    value: "Pending verified data"
                )

                estimateStatus(
                    title: "Labor",
                    value: "Pending verified data"
                )
            }

            VStack(spacing: 0) {
                ForEach(PlanImpactSection.allCases) { section in
                    if section != .benefits {
                        Divider()
                    }

                    Button {
                        withAnimation(.easeInOut(duration: 0.18)) {
                            expandedSection = expandedSection == section
                                ? nil
                                : section
                        }
                    } label: {
                        VStack(alignment: .leading, spacing: 10) {
                            HStack {
                                Text(section.rawValue)
                                    .font(.headline)

                                Spacer()

                                Image(
                                    systemName: expandedSection == section
                                        ? "chevron.up"
                                        : "chevron.down"
                                )
                                .font(.caption)
                                .foregroundStyle(.secondary)
                            }

                            if expandedSection == section {
                                Text("Pending verified vehicle-specific data.")
                                    .font(.subheadline)
                                    .foregroundStyle(.secondary)
                                    .multilineTextAlignment(.leading)
                            }
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.vertical, 14)
                    }
                    .buttonStyle(.plain)
                }
            }
        }
        .padding(20)
        .background(Color(.secondarySystemGroupedBackground))
        .clipShape(
            RoundedRectangle(cornerRadius: 24)
        )
        .overlay {
            RoundedRectangle(cornerRadius: 24)
                .stroke(
                    Color.secondary.opacity(0.12),
                    lineWidth: 1
                )
        }
    }

    private func estimateStatus(
        title: String,
        value: String
    ) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title)
                .font(.caption)
                .foregroundStyle(.secondary)

            Text(value)
                .font(.subheadline)
                .fontWeight(.semibold)
        }
        .padding(14)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.primary.opacity(0.06))
        .clipShape(
            RoundedRectangle(cornerRadius: 16)
        )
    }
}
