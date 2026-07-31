import SwiftUI

    // MARK: - Vehicle Planning

    enum VehiclePlanGoal: String, CaseIterable, Identifiable {
        case reliable = "Reliable"
        case performance = "Performance"
        case restore = "Restore"
        case custom = "Custom Build"

        var id: String {
            rawValue
        }

        var icon: String {
            switch self {
            case .reliable:
                return "shield.checkered"

            case .performance:
                return "gauge.with.dots.needle.67percent"

            case .restore:
                return "arrow.counterclockwise.circle.fill"

            case .custom:
                return "slider.horizontal.3"
            }
        }

        var subtitle: String {
            switch self {
            case .reliable:
                return "Maintenance, comfort, safety, and long-term ownership"

            case .performance:
                return "Power, handling, braking, cooling, and sound"

            case .restore:
                return "Bring worn or modified areas closer to factory condition"

            case .custom:
                return "Create a unique goal such as drift, track, show, or stance"
            }
        }

        var overviewTitle: String {
            switch self {
            case .reliable:
                return "Build a more reliable vehicle"

            case .performance:
                return "Build for performance"

            case .restore:
                return "Restore your vehicle"

            case .custom:
                return "Create a custom build"
            }
        }

        var overviewDescription: String {
            switch self {
            case .reliable:
                return
                    """
                    OpenHood will prioritize overdue maintenance, common failure \
                    prevention, safety, comfort, operating cost, and improvements \
                    that make the vehicle easier to own every day.
                    """

            case .performance:
                return
                    """
                    OpenHood will organize power, handling, braking, cooling, sound, \
                    and supporting modifications in the correct order while showing \
                    cost, benefits, drawbacks, and reliability impact.
                    """

            case .restore:
                return
                    """
                    OpenHood will organize worn, damaged, missing, or modified areas \
                    into a practical path toward proper factory condition.
                    """

            case .custom:
                return
                    """
                    Describe the vehicle you want to build. OpenHood will organize \
                    your goal into stages with estimated costs, supporting work, \
                    compatibility concerns, risks, advantages, and disadvantages.
                    """
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
                            Text(goal.overviewTitle)
                                .font(.largeTitle)
                                .fontWeight(.bold)

                            Text(vehicle.vehicleName)
                                .font(.headline)
                                .foregroundStyle(.secondary)

                            Text(goal.overviewDescription)
                                .font(.body)
                                .foregroundStyle(.secondary)
                        }
                    }

                    PlanPreviewCard(
                        title: "Vehicle baseline",
                        icon: "checklist",
                        items: [
                            "Current mileage and service history",
                            "Existing problems and warning signs",
                            "Installed modifications",
                            "Safety and reliability priorities"
                        ]
                    )

                    PlanPreviewCard(
                        title: "Recommended path",
                        icon: "point.topleft.down.to.point.bottomright.curvepath",
                        items: [
                            "Work arranged in the proper order",
                            "Maintenance required before upgrades",
                            "Supporting parts and future dependencies",
                            "Professional installation or tuning requirements"
                        ]
                    )

                    PlanPreviewCard(
                        title: "Cost and impact",
                        icon: "dollarsign.circle.fill",
                        items: [
                            "Estimated parts range",
                            "Estimated labor range",
                            "Expected benefits",
                            "Disadvantages and reliability risks"
                        ]
                    )

                    NavigationLink {
                        PlanBuilderPlaceholderView(goal: goal)
                    } label: {
                        Text(
                            goal == .custom
                                ? "Describe my goal"
                                : "Start this plan"
                        )
                        .font(.headline)
                        .foregroundStyle(Color(.systemBackground))
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 18)
                        .background(Color.primary)
                        .clipShape(
                            RoundedRectangle(cornerRadius: 18)
                        )
                    }
                    .buttonStyle(.plain)

                    Spacer(minLength: 24)
                }
                .padding(20)
            }
            .background(Color(.systemGroupedBackground))
            .navigationTitle(goal.rawValue)
            .navigationBarTitleDisplayMode(.inline)
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

        @State private var customGoal = ""

        var body: some View {
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    if goal == .custom {
                        VStack(alignment: .leading, spacing: 10) {
                            Text("What do you want from your car?")
                                .font(.largeTitle)
                                .fontWeight(.bold)

                            Text(
                                "Describe the result you want. You do not need to know the names of the parts."
                            )
                            .font(.body)
                            .foregroundStyle(.secondary)
                        }

                        TextEditor(text: $customGoal)
                            .font(.body)
                            .frame(minHeight: 190)
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
                    } else {
                        VStack(alignment: .leading, spacing: 10) {
                            Text("Your \(goal.rawValue.lowercased()) plan")
                                .font(.largeTitle)
                                .fontWeight(.bold)

                            Text(vehicle.vehicleName)
                                .font(.headline)
                                .foregroundStyle(.secondary)
                        }
                    }

                    VStack(alignment: .leading, spacing: 13) {
                        Label(
                            "Plan builder coming next",
                            systemImage: "hammer.fill"
                        )
                        .font(.title3)
                        .fontWeight(.bold)

                        Text(
                            "The next version will ask about your budget, intended use, timeline, existing modifications, maintenance condition, and risk tolerance before recommending anything."
                        )
                        .font(.body)
                        .foregroundStyle(.secondary)
                    }
                    .padding(20)
                    .background(Color(.secondarySystemGroupedBackground))
                    .clipShape(
                        RoundedRectangle(cornerRadius: 24)
                    )

                    Spacer(minLength: 24)
                }
                .padding(20)
            }
            .background(Color(.systemGroupedBackground))
            .navigationTitle("Plan Builder")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
