import SwiftUI

// MARK: - Vehicle Planning

enum VehiclePlanGoal: String, CaseIterable, Identifiable {
    case reliable = "Reliability"
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
            return "What should your reliability plan focus on?"

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
    var subtitle: String? = nil
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

enum PlanRecommendationVerificationStatus: String {
    case prototype = "Prototype — verification required"
    case verified = "Verified"
}

struct PlanRecommendationRecord: Identifiable {
    let id: String
    let vehicleApplicability: String
    let goal: VehiclePlanGoal
    let focus: String
    let triggeringAnswers: [String]
    let recommendedInspection: String
    let conditionalNextStep: String
    let reason: String
    let partsEstimateStatus: String
    let laborEstimateStatus: String
    let benefits: String
    let tradeoffs: String
    let supportingWork: String
    let verificationStatus: PlanRecommendationVerificationStatus
    let sourceReferences: [String]
}

enum PlanRecommendationLibrary {
    static let reliabilityPrototype: [PlanRecommendationRecord] = [
        PlanRecommendationRecord(
            id: "reliability-stay-ahead-no-known-concerns",
            vehicleApplicability: "General guidance; not vehicle-specific",
            goal: .reliable,
            focus: "Stay ahead of problems",
            triggeringAnswers: ["No known concerns"],
            recommendedInspection: "Compare the saved mileage and service history against typical intervals below to see what's likely due.",
            conditionalNextStep: "If service records confirm something is already overdue, prioritize that before anything optional.",
            reason: "Staying ahead of scheduled items is usually cheaper than waiting for something to fail.",
            partsEstimateStatus: "Reference by item: oil change roughly $35–$100 every 5,000–7,500 miles, tire rotation roughly $25–$75 on the same interval (often bundled with the oil change), cabin and engine air filters roughly $35–$130 combined every 12,000–15,000 miles, brake fluid roughly $173–$205 around every 30,000 miles.",
            laborEstimateStatus: "Labor is typically included in the ranges above for each item; these are routine service intervals, not a single repair estimate.",
            benefits: "Keeping to these intervals is one of the cheapest ways to avoid larger repairs later and helps preserve resale value.",
            tradeoffs: "Actual intervals vary by manufacturer and driving conditions — the owner's manual is the final word for this specific vehicle.",
            supportingWork: "None of these require a specific concern to justify — they're scheduled regardless of symptoms.",
            verificationStatus: .verified,
            sourceReferences: [
                "OpenHood, \"Reviewed General Automotive Guidance — Routine Maintenance Intervals\""
            ]
        ),
        PlanRecommendationRecord(
            id: "reliability-preventive-prototype",
            vehicleApplicability: "Saved vehicle profile; vehicle-specific applicability not yet verified",
            goal: .reliable,
            focus: "Stay ahead of problems",
            triggeringAnswers: [],
            recommendedInspection: "Start by confirming the saved service history, current concerns, and the vehicle's present condition.",
            conditionalNextStep: "If inspection verifies overdue or condition-based needs, organize confirmed work before optional improvements.",
            reason: "A verified baseline helps avoid recommending work the vehicle may not need.",
            partsEstimateStatus: "Pending verified data",
            laborEstimateStatus: "Pending verified data",
            benefits: "Potential benefits depend on what inspection and service records confirm.",
            tradeoffs: "Inspection may show that no immediate replacement work is needed.",
            supportingWork: "Supporting work remains conditional until vehicle-specific records and inspection results are available.",
            verificationStatus: .prototype,
            sourceReferences: []
        ),
        PlanRecommendationRecord(
            id: "reliability-current-concern-brakes-verified",
            vehicleApplicability: "Saved vehicle profile; reviewed general automotive guidance, not vehicle-specific inspection findings",
            goal: .reliable,
            focus: "Fix something now",
            triggeringAnswers: ["Braking or steering concern"],
            recommendedInspection: "Have the brakes inspected to check pad wear, rotor condition, hardware, and caliper operation. A squeal while braking is most often just the pad wear indicator doing its job, but glazed pads/rotors, worn hardware, or a sticking caliper can also cause it. This is for a known or intermittent concern you're planning around, not an active problem — if the brakes feel unsafe or aren't stopping normally right now, use Something Happened's safety check instead of planning ahead.",
            conditionalNextStep: "If inspection confirms low pad wear, glazing, worn hardware, or a sticking caliper, use that finding to define the confirmed repair.",
            reason: "Squeal while braking can come from several different causes with very different costs, so OpenHood needs the inspection finding before recommending a specific repair.",
            partsEstimateStatus: "For a straightforward pad replacement: parts roughly $25–$150/axle, plus $60–$150/axle for rotors if they're also needed. Other causes stay combined: glazed pads/rotors ~$40–$150/axle to resurface, worn hardware ~$150–$350/axle, sticking caliper ~$300–$600/caliper.",
            laborEstimateStatus: "For a straightforward pad replacement: labor roughly $80–$220/axle, rising to $150–$200/axle if rotors are also done. Included in the combined ranges above for glazed pads/rotors, worn hardware, and sticking caliper — confirmed once inspection identifies the specific cause.",
            benefits: "Confirming the cause first avoids paying for pad or rotor replacement when the real issue is worn hardware or a sticking caliper, which cost less.",
            tradeoffs: "Squeal alone doesn't confirm which part is worn, so inspection may find more than one contributing cause.",
            supportingWork: "Supporting work such as hardware or caliper service is often bundled with pad replacement when it's the confirmed cause.",
            verificationStatus: .verified,
            sourceReferences: [
                "OpenHood, \"Reviewed General Automotive Guidance — Squeal While Braking\""
            ]
        ),
        PlanRecommendationRecord(
            id: "reliability-current-concern-warning-light-verified",
            vehicleApplicability: "Saved vehicle profile; reviewed general automotive guidance, not vehicle-specific inspection findings",
            goal: .reliable,
            focus: "Fix something now",
            triggeringAnswers: ["Warning light"],
            recommendedInspection: "Get the exact code read first — many auto parts stores do this for free — before estimating cost. A steady check engine light often points to a loose gas cap, a worn oxygen sensor, or aging spark plugs; a battery or charging symbol often points to the alternator, the battery itself, or the terminals/cables. Which light is on changes everything, so the code or specific light needs to be confirmed before planning further.",
            conditionalNextStep: "Once the code or specific light is confirmed, use that finding to define the confirmed repair.",
            reason: "Different warning lights point to completely different systems and costs, so OpenHood needs the actual code or light identified before recommending a specific repair.",
            partsEstimateStatus: "For an oxygen sensor, the most researched cause here: parts roughly $20–$250+. Other causes are typically quoted as one number since labor is minimal: gas cap usually free to ~$20, spark plugs ~$100–$300/set, battery ~$100–$250. Alternator ~$400–$700 and terminals/cables ~$20–$150 also stay combined.",
            laborEstimateStatus: "For an oxygen sensor: labor roughly $80–$250, confirmed once the code or specific light is read. Gas cap, spark plug, and battery causes don't split cleanly — they're quick, low-labor jobs usually quoted as one number, included above. Alternator and terminals/cables labor is also included in the combined figures above.",
            benefits: "Reading the code first, often for free, avoids guessing between low-cost fixes like a gas cap and higher-cost ones like an alternator.",
            tradeoffs: "A code points to a system, not always the exact part, so some causes still need a hands-on inspection after the code is read.",
            supportingWork: "Supporting work depends on which system the code or light points to and what the inspection confirms.",
            verificationStatus: .verified,
            sourceReferences: [
                "OpenHood, \"Reviewed General Automotive Guidance — Steady Check Engine Light\"",
                "OpenHood, \"Reviewed General Automotive Guidance — Battery or Charging Warning Light\""
            ]
        ),
        PlanRecommendationRecord(
            id: "reliability-current-concern-leak-verified",
            vehicleApplicability: "Saved vehicle profile; reviewed general automotive guidance, not vehicle-specific inspection findings",
            goal: .reliable,
            focus: "Fix something now",
            triggeringAnswers: ["Leak"],
            recommendedInspection: "Fluid color is the fastest way to narrow this down, same as it already does in Something Happened — note where the fluid was visible and its color without touching it, then have it inspected. Coolant (green, orange, pink, or yellow) is the broadest and most common category, usually pointing to a radiator or hose, the water pump, or the radiator cap/reservoir, and is worth inspecting soon with an eye on overheating in the meantime.",
            conditionalNextStep: "If inspection verifies coolant loss, use the confirmed source (radiator/hose, water pump, or cap/reservoir) to define the repair. Other fluid colors point to different systems and would need their own confirmation.",
            reason: "Leak color and location point to different systems with very different costs, so OpenHood needs the confirmed source before recommending a specific repair.",
            partsEstimateStatus: "For a confirmed coolant leak from the water pump — the costliest common source, and the one with real cost data available: parts roughly $200–$400. Radiator or hose ~$150–$450 and radiator cap or reservoir ~$20–$100 stay combined. Other fluid colors point to different systems with their own ranges.",
            laborEstimateStatus: "For the water pump specifically: labor roughly $225–$500 — worth noting labor actually costs more than parts here, since the pump sits deep in the engine. Radiator/hose and cap/reservoir labor stays included in the combined ranges above; confirmed once the source is inspected.",
            benefits: "Identifying the fluid color and source first avoids paying for a water pump when the real issue is a $20 cap.",
            tradeoffs: "A visible leak doesn't confirm severity — some sources are urgent active coolant loss, others are minor.",
            supportingWork: "Supporting work depends on the confirmed source and may include a coolant flush or pressure test.",
            verificationStatus: .verified,
            sourceReferences: [
                "OpenHood, \"Reviewed General Automotive Guidance — Coolant-Colored Visible Fluid\""
            ]
        ),
        PlanRecommendationRecord(
            id: "reliability-current-concern-noise-vibration-verified",
            vehicleApplicability: "Saved vehicle profile; reviewed general automotive guidance, not vehicle-specific inspection findings",
            goal: .reliable,
            focus: "Fix something now",
            triggeringAnswers: ["Unusual sound or vibration"],
            recommendedInspection: "Have the suspension, wheels/tires, and driveline checked — the exact cause depends heavily on when it happens: over bumps often points to worn control-arm bushings, sway bar links/bushings, ball joints, or strut mounts; at highway speed often points to wheel/tire balance or alignment; while turning often points to a CV joint/axle or wheel bearing.",
            conditionalNextStep: "If inspection confirms one of these causes, use that finding to define the confirmed repair.",
            reason: "Sound or vibration alone can come from several unrelated systems — suspension, tires, or driveline — with very different costs, so OpenHood needs the inspection finding before recommending a specific repair.",
            partsEstimateStatus: "Range depends heavily on which cause an inspection confirms. Wheel bearing: parts roughly $122–$177. Sway bar link: parts roughly $63–$98. CV joint parts vary too widely by vehicle for a clean number — see labor below instead. Control-arm bushings ~$250–$450, ball joints ~$200–$400 each, wheel balance ~$60–$100 for all four, and wheel alignment ~$80–$150 stay combined. Strut mounts and tire condition vary too much for a fixed number without inspection.",
            laborEstimateStatus: "Wheel bearing: labor roughly $227–$333. CV joint: labor roughly $150–$350. Sway bar link: labor roughly $60–$150 per side. For control-arm bushings, ball joints, wheel balance, and wheel alignment, labor is included in the combined figures above — confirmed once inspection identifies the specific cause.",
            benefits: "Confirming the specific cause first avoids paying for suspension work when the real issue is a much cheaper tire balance, or vice versa.",
            tradeoffs: "These causes span different systems, so more than one inspection may be needed to fully rule causes in or out.",
            supportingWork: "Supporting work depends on the confirmed cause and system — suspension, tire/wheel, or driveline.",
            verificationStatus: .verified,
            sourceReferences: [
                "OpenHood, \"Reviewed General Automotive Guidance — Bump-Triggered Suspension Noise\"",
                "OpenHood, \"Reviewed General Automotive Guidance — Vibration at Highway Speed\"",
                "OpenHood, \"Reviewed General Automotive Guidance — Vibration or Shudder While Turning\""
            ]
        ),
        PlanRecommendationRecord(
            id: "reliability-current-concern-starting-verified",
            vehicleApplicability: "Saved vehicle profile; reviewed general automotive guidance, not vehicle-specific inspection findings",
            goal: .reliable,
            focus: "Fix something now",
            triggeringAnswers: ["Starting or running issue"],
            recommendedInspection: "Have the starting and charging system checked, and get a diagnostic code read if the engine cranks but won't catch. The cause depends on exactly what happens: rapid clicking or a dead-feeling start often points to the battery, terminals/cables, or alternator; a single click more often points to the starter or its relay; cranking without starting often points to the fuel pump, ignition coil, spark plugs, or fuel filter.",
            conditionalNextStep: "If inspection or the code confirms a specific cause, use that finding to define the confirmed repair.",
            reason: "Starting and running issues can come from the electrical/charging system or the fuel/ignition system, so OpenHood needs the confirmed cause before recommending a specific repair.",
            partsEstimateStatus: "Range depends heavily on the confirmed cause. Starter: parts roughly $80–$500. Battery ~$150–$450, terminals/cables ~$20–$150, starter relay/fuse ~$20–$100, alternator ~$400–$900 total, fuel pump ~$600–$900, ignition coil ~$200–$300, spark plugs ~$100–$300/set, fuel filter ~$100–$300 — these stay combined.",
            laborEstimateStatus: "Starter: labor roughly $100–$300. Alternator labor is typically $150–$300 of its $400–$900 total. For battery, terminals/cables, starter relay/fuse, fuel pump, ignition coil, spark plugs, and fuel filter, labor is included in the combined figures above; confirmed once the specific cause is inspected or diagnosed by code.",
            benefits: "Confirming the specific cause first avoids paying for a starter or alternator when the real issue is a loose terminal or a weak battery.",
            tradeoffs: "A code scan narrows the fuel/ignition side but doesn't replace inspection for the electrical/starting side, so both may be needed.",
            supportingWork: "Supporting work depends on the confirmed cause and may span the charging system or the fuel/ignition system.",
            verificationStatus: .verified,
            sourceReferences: [
                "OpenHood, \"Reviewed General Automotive Guidance — Rapid Clicking When Starting\"",
                "OpenHood, \"Reviewed General Automotive Guidance — Single Click When Starting\"",
                "OpenHood, \"Reviewed General Automotive Guidance — Cranks But Won't Start, No Unusual Clue\""
            ]
        ),
        PlanRecommendationRecord(
            id: "reliability-current-concern-prototype",
            vehicleApplicability: "Saved vehicle profile; symptom-specific applicability not yet verified",
            goal: .reliable,
            focus: "Fix something now",
            triggeringAnswers: [],
            recommendedInspection: "Start by confirming the reported concern with an appropriate inspection. Do not treat the selected symptom as a diagnosis.",
            conditionalNextStep: "If inspection verifies a specific fault, use that finding to define the confirmed repair and any supporting work.",
            reason: "Similar symptoms can have different causes, so OpenHood needs more information before recommending replacement.",
            partsEstimateStatus: "Pending verified data",
            laborEstimateStatus: "Pending verified data",
            benefits: "Benefits can be described after the cause and required work are confirmed.",
            tradeoffs: "Additional inspection may be required before parts or labor can be estimated.",
            supportingWork: "Supporting work depends on the verified cause and vehicle-specific repair information.",
            verificationStatus: .prototype,
            sourceReferences: []
        ),
        PlanRecommendationRecord(
            id: "reliability-return-stock-prototype",
            vehicleApplicability: "Saved vehicle profile; original configuration not yet verified",
            goal: .reliable,
            focus: "Return to stock",
            triggeringAnswers: [],
            recommendedInspection: "Start by confirming the current configuration and the correct original equipment for the saved vehicle.",
            conditionalNextStep: "If inspection verifies non-stock components, compare them with verified factory configuration before planning changes.",
            reason: "OpenHood needs verified current and factory configuration details before recommending replacement.",
            partsEstimateStatus: "Pending verified data",
            laborEstimateStatus: "Pending verified data",
            benefits: "Potential benefits depend on the current modifications and the verified factory configuration.",
            tradeoffs: "Returning one area to stock may affect connected modifications or require additional compatible components.",
            supportingWork: "Compatibility and supporting work remain conditional until the installed parts are identified.",
            verificationStatus: .prototype,
            sourceReferences: []
        )
    ]

    static func recommendation(
        for goal: VehiclePlanGoal,
        focus: String,
        answers: [String: String]
    ) -> PlanRecommendationRecord? {
        reliabilityPrototype.first { record in
            record.goal == goal
                && record.focus == focus
                && record.triggeringAnswers.allSatisfy { answers.values.contains($0) }
        }
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
    @State private var mileage = ""
    @State private var reliabilityDetail = ""

    private let mileageKey = "What is the current mileage?"
    private let serviceHistoryKey = "How much service history is known?"
    private let concernsKey = "Are there any current concerns?"
    private let currentIssueKey = "What's the concern you're planning around?"
    private let returnToStockKey = "What needs to return to stock?"

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

        case .reliable:
            return reliabilityFollowUpQuestions

        case .custom:
            return []
        }
    }

    private var reliabilityFollowUpQuestions: [PlanFollowUpQuestion] {
        switch focus {
        case "Stay ahead of problems":
            return [
                PlanFollowUpQuestion(
                    title: serviceHistoryKey,
                    options: [
                        PlanQuestionOption("Complete"),
                        PlanQuestionOption("Some"),
                        PlanQuestionOption("Very little"),
                        PlanQuestionOption("I’m not sure")
                    ]
                ),
                PlanFollowUpQuestion(
                    title: concernsKey,
                    options: reliabilityConcernOptions(includeNoKnownConcerns: true)
                )
            ]

        case "Fix something now":
            return [
                PlanFollowUpQuestion(
                    title: currentIssueKey,
                    subtitle: "If you're not sure yet, use Something Happened first to figure out what's going on.",
                    options: reliabilityConcernOptions(includeNoKnownConcerns: false)
                )
            ]

        default:
            return [
                PlanFollowUpQuestion(
                    title: returnToStockKey,
                    options: [
                        PlanQuestionOption("Engine or exhaust"),
                        PlanQuestionOption("Suspension or ride height"),
                        PlanQuestionOption("Wheels or tires"),
                        PlanQuestionOption("Exterior"),
                        PlanQuestionOption("Interior"),
                        PlanQuestionOption("Lighting or electrical"),
                        PlanQuestionOption("Multiple areas"),
                        PlanQuestionOption("I’m not sure")
                    ]
                )
            ]
        }
    }

    private func reliabilityConcernOptions(
        includeNoKnownConcerns: Bool
    ) -> [PlanQuestionOption] {
        let concerns = [
            "Warning light",
            "Leak",
            "Unusual sound or vibration",
            "Starting or running issue",
            "Overheating",
            "Braking or steering concern",
            "Something else"
        ].map { PlanQuestionOption($0) }

        if includeNoKnownConcerns {
            return [PlanQuestionOption("No known concerns")] + concerns
        }

        return concerns
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

    private var mileageStepCount: Int {
        goal == .reliable && focus == "Stay ahead of problems" ? 1 : 0
    }

    private var needsReliabilityDetail: Bool {
        guard goal == .reliable else {
            return false
        }

        return answers.values.contains("Something else")
            || answers.values.contains("Multiple areas")
    }

    private var reliabilityDetailStepCount: Int {
        needsReliabilityDetail ? 1 : 0
    }

    private var budgetStep: Int {
        customDescriptionStepCount
            + mileageStepCount
            + followUpQuestions.count
            + reliabilityDetailStepCount
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
                } else if goal == .reliable,
                          focus == "Stay ahead of problems",
                          step == customDescriptionStepCount {
                    mileageQuestion
                } else if let question = currentFollowUpQuestion {
                    choiceQuestion(
                        title: question.title,
                        subtitle: question.subtitle,
                        options: question.options
                    ) { answer in
                        answers[question.title] = answer
                        step += 1
                    }
                } else if needsReliabilityDetail,
                          step == budgetStep - 1 {
                    reliabilityDetailQuestion
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
        let questionIndex = step
            - customDescriptionStepCount
            - mileageStepCount

        guard questionIndex >= 0,
              questionIndex < followUpQuestions.count else {
            return nil
        }

        return followUpQuestions[questionIndex]
    }

    private var mileageQuestion: some View {
        shortTextQuestion(
            title: mileageKey,
            subtitle: "Reliability · \(focus)",
            text: $mileage,
            prompt: "Enter mileage",
            keyboardType: .numberPad
        ) {
            answers[mileageKey] = mileage.trimmingCharacters(in: .whitespacesAndNewlines)
            step += 1
        }
    }

    private var reliabilityDetailQuestion: some View {
        shortTextQuestion(
            title: "Tell us a little more",
            subtitle: "A short description is enough.",
            text: $reliabilityDetail,
            prompt: "Add a short description",
            keyboardType: .default
        ) {
            answers["Details"] = reliabilityDetail.trimmingCharacters(in: .whitespacesAndNewlines)
            step += 1
        }
    }

    private func shortTextQuestion(
        title: String,
        subtitle: String,
        text: Binding<String>,
        prompt: String,
        keyboardType: UIKeyboardType,
        continueAction: @escaping () -> Void
    ) -> some View {
        VStack(alignment: .leading, spacing: 20) {
            questionHeader(title: title, subtitle: subtitle)

            TextField(prompt, text: text)
                .font(.body)
                .keyboardType(keyboardType)
                .padding(18)
                .background(Color(.secondarySystemGroupedBackground))
                .clipShape(RoundedRectangle(cornerRadius: 22))
                .overlay {
                    RoundedRectangle(cornerRadius: 22)
                        .stroke(Color.secondary.opacity(0.15), lineWidth: 1)
                }

            Button(action: continueAction) {
                Text("Continue")
                    .font(.headline)
                    .foregroundStyle(Color(.systemBackground))
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 18)
                    .background(
                        text.wrappedValue.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
                            ? Color.secondary.opacity(0.35)
                            : Color.primary
                    )
                    .clipShape(RoundedRectangle(cornerRadius: 18))
            }
            .buttonStyle(.plain)
            .disabled(text.wrappedValue.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
        }
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
        subtitle: String? = nil,
        options: [PlanQuestionOption],
        selection: @escaping (String) -> Void
    ) -> some View {
        VStack(alignment: .leading, spacing: 20) {
            questionHeader(
                title: title,
                subtitle: subtitle ?? "\(goal.rawValue) · \(focus)"
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
                vehicle: vehicle.vehicleName,
                goal: goal.rawValue,
                focus: focus,
                budget: budget?.rawValue ?? "",
                timeline: timeline?.rawValue ?? "",
                answers: answers,
                customGoal: needsCustomDescription ? customGoal : nil
            )

            if let recommendation = PlanRecommendationLibrary.recommendation(
                for: goal,
                focus: focus,
                answers: answers
            ) {
                PlanRecommendedStartingPointCard(recommendation: recommendation, timeline: timeline)
                PlanCostImpactCard(recommendation: recommendation)
            } else {
                PlanCostImpactCard(recommendation: nil)
            }

            Spacer(minLength: 24)
        }
    }
}

struct PlanSelectionSummaryCard: View {
    let vehicle: String
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

            summaryRow(label: "Vehicle", value: vehicle)
            summaryRow(label: "Goal", value: goal)
            summaryRow(label: "Focus", value: focus)

            if let customGoal,
               !customGoal.isEmpty {
                summaryRow(label: "Description", value: customGoal)
            }

            if goal == VehiclePlanGoal.reliable.rawValue {
                reliabilitySummaryRows
            } else {
                ForEach(answers.keys.sorted(), id: \.self) { question in
                    if let answer = answers[question] {
                        summaryRow(label: question, value: answer)
                    }
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

    @ViewBuilder
    private var reliabilitySummaryRows: some View {
        let concernKeys = [
            "Are there any current concerns?",
            "What's the concern you're planning around?",
            "What needs to return to stock?"
        ]

        if let concern = concernKeys.compactMap({ answers[$0] }).first {
            summaryRow(
                label: focus == "Return to stock" ? "Area" : "Concern",
                value: concern
            )
        }

        if let details = answers["Details"] {
            summaryRow(label: "Details", value: details)
        }

        if let mileage = answers["What is the current mileage?"] {
            summaryRow(label: "Mileage", value: mileage)
        }

        if let history = answers["How much service history is known?"] {
            summaryRow(label: "Service history", value: history)
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

struct PlanRecommendedStartingPointCard: View {
    let recommendation: PlanRecommendationRecord
    var timeline: PlanTimeline?

    private var inspectionText: String {
        guard timeline == .thisMonth else {
            return recommendation.recommendedInspection
        }

        return "Worth booking this week — " + recommendation.recommendedInspection
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 18) {
            Text("Recommended starting point")
                .font(.title3)
                .fontWeight(.bold)

            recommendationRow(
                title: "Check first",
                value: inspectionText
            )
            recommendationRow(
                title: "Likely next step",
                value: recommendation.conditionalNextStep
            )
            recommendationRow(
                title: "Why it matters",
                value: recommendation.reason
            )

            Text(recommendation.verificationStatus.rawValue)
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .padding(20)
        .background(Color(.secondarySystemGroupedBackground))
        .clipShape(RoundedRectangle(cornerRadius: 24))
        .overlay {
            RoundedRectangle(cornerRadius: 24)
                .stroke(Color.secondary.opacity(0.12), lineWidth: 1)
        }
    }

    private func recommendationRow(
        title: String,
        value: String
    ) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title)
                .font(.headline)

            Text(value)
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
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
    let recommendation: PlanRecommendationRecord?

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

            HStack(alignment: .top, spacing: 12) {
                estimateStatus(
                    title: "Parts",
                    value: recommendation?.partsEstimateStatus
                        ?? "Pending verified data",
                    icon: "gearshape.fill",
                    tint: .blue
                )

                estimateStatus(
                    title: "Labor",
                    value: recommendation?.laborEstimateStatus
                        ?? "Pending verified data",
                    icon: "wrench.fill",
                    tint: .orange
                )
            }

            VStack(alignment: .leading, spacing: 8) {
                workStatus(label: "Inspection", value: "Recommended first")
                workStatus(label: "Confirmed work", value: "None yet")
                workStatus(label: "Conditional work", value: "Pending inspection")
                workStatus(label: "Optional work", value: "Not recommended yet")
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
                                Text(impactText(for: section))
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

    private func impactText(for section: PlanImpactSection) -> String {
        guard let recommendation else {
            return "Pending verified vehicle-specific data."
        }

        switch section {
        case .benefits:
            return recommendation.benefits
        case .tradeoffs:
            return recommendation.tradeoffs
        case .supportingWork:
            return recommendation.supportingWork
        }
    }

    private func workStatus(
        label: String,
        value: String
    ) -> some View {
        HStack(alignment: .firstTextBaseline) {
            Text(label)
                .font(.subheadline)

            Spacer()

            Text(value)
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.trailing)
        }
    }

    private func estimateStatus(
        title: String,
        value: String,
        icon: String,
        tint: Color
    ) -> some View {
        HStack(alignment: .top, spacing: 10) {
            ZStack {
                Circle()
                    .fill(tint.opacity(0.15))
                    .frame(width: 34, height: 34)

                Image(systemName: icon)
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundStyle(tint)
            }

            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.caption)
                    .foregroundStyle(.secondary)

                Text(value)
                    .font(.subheadline)
                    .fontWeight(.bold)
            }
        }
        .padding(14)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.primary.opacity(0.06))
        .clipShape(
            RoundedRectangle(cornerRadius: 16)
        )
    }
}
