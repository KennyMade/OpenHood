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
        ),
        PlanRecommendationRecord(
            id: "style-exterior-wheels-tires-verified",
            vehicleApplicability: "General guidance; wheel offset and bolt pattern are vehicle-specific and must be confirmed for the saved vehicle",
            goal: .style,
            focus: "Exterior",
            triggeringAnswers: ["Wheels and tires"],
            recommendedInspection: "Confirm the correct wheel size, offset, and bolt pattern for the saved vehicle before buying anything. An incorrect offset can rub the fender or suspension, and an incorrect bolt pattern won't fit at all. If tires are being replaced too, check that the load rating matches or exceeds the factory spec.",
            conditionalNextStep: "If wheels are changing without new tires, confirm the existing tires' size is compatible with the new wheel diameter.",
            reason: "Wheel fitment mistakes are one of the most common and expensive style-plan errors — the wrong offset or bolt pattern makes an otherwise good-looking wheel unusable.",
            partsEstimateStatus: "A set of four aftermarket wheels typically runs roughly $1,000–$2,500, though basic sets can be found for around $300–$1,000 and premium forged wheels can run well past $4,000. A full set of four tires typically runs roughly $400–$1,800, with performance tires often landing in the $1,800–$3,000+ range.",
            laborEstimateStatus: "Mounting and balancing a set of four tires is typically roughly $60–$180, plus roughly $80–$150 for an alignment afterward. TPMS sensor replacement, if needed, adds roughly $25–$60 per sensor plus a small programming fee.",
            benefits: "Wheels and tires are one of the most visible style changes and, done right, can also improve ride and handling feel.",
            tradeoffs: "Larger wheels with shorter sidewalls can make the ride firmer and are more vulnerable to pothole and curb damage; wider tires can slightly affect fuel economy.",
            supportingWork: "An alignment is worth budgeting for anytime wheel size or offset changes, even if tires aren't replaced.",
            verificationStatus: .verified,
            sourceReferences: [
                "One and Done Prep, \"Tire Installation Costs and Pricing Guide 2026\"",
                "Get Your Wheels, 18-inch wheel set pricing"
            ]
        ),
        PlanRecommendationRecord(
            id: "style-exterior-stance-verified",
            vehicleApplicability: "General guidance; not vehicle-specific",
            goal: .style,
            focus: "Exterior",
            triggeringAnswers: ["Stance"],
            recommendedInspection: "Decide between lowering springs and coilovers first. Springs are the cheaper, simpler option and use the factory shocks/struts, while coilovers replace the whole assembly and add ride-height adjustability. Confirm the vehicle's shocks/struts are in good condition before installing springs, since worn factory dampers won't control a lowered spring well.",
            conditionalNextStep: "If coilovers are chosen, confirm they carry a valid warranty and are rated for daily use if the vehicle will still be driven regularly.",
            reason: "Springs and coilovers solve the same visual goal at very different price points, so the choice changes the entire budget.",
            partsEstimateStatus: "Lowering springs typically run roughly $150–$350 for parts. Coilovers cost significantly more — entry to mid-range sets typically run roughly $800–$2,500, with premium adjustable sets exceeding $4,000.",
            laborEstimateStatus: "Installed together with labor, lowering springs typically total roughly $300–$500. Coilover installation is more involved and typically adds several hundred dollars in labor on top of the parts cost.",
            benefits: "A lowered stance is one of the most immediately visible style changes; coilovers add the option to fine-tune ride height and, on many sets, damping.",
            tradeoffs: "Lowering reduces ground clearance and can affect ride comfort — going too low can cause rubbing, uneven tire wear, or scraping on driveways and speed bumps.",
            supportingWork: "An alignment is recommended anytime ride height changes.",
            verificationStatus: .verified,
            sourceReferences: [
                "CarXplorer, \"How Much To Lower a Car: 2026 Cost & Options Guide\"",
                "TruHart, \"Coilovers vs. Lowering Springs\""
            ]
        ),
        PlanRecommendationRecord(
            id: "style-exterior-paint-wrap-verified",
            vehicleApplicability: "General guidance; not vehicle-specific",
            goal: .style,
            focus: "Exterior",
            triggeringAnswers: ["Paint or wrap"],
            recommendedInspection: "Check the condition of the existing paint first. A wrap works best over paint that's already in good condition, while paint with rust, peeling clear coat, or heavy damage usually needs repair before either option makes sense.",
            conditionalNextStep: "If existing paint or bodywork needs repair first, budget and plan that separately before choosing paint or wrap.",
            reason: "Wrap and paint solve the same goal at very different price points and durability, so existing paint condition should decide which one makes sense.",
            partsEstimateStatus: "A full vinyl wrap typically runs roughly $2,000–$5,000 installed. A professional-quality full paint job typically runs roughly $5,000–$10,000, and can exceed $20,000 for show-quality work.",
            laborEstimateStatus: "Labor is included in the installed ranges above for both options — these are typically quoted as a single installed price rather than separate parts and labor.",
            benefits: "A wrap is reversible and less expensive, with more color and finish options. Paint lasts significantly longer — decades with care, versus roughly two to five years for a wrap — and is the better option if the existing paint needs repair anyway.",
            tradeoffs: "A wrap can be damaged by improper washing or prolonged sun exposure and will need replacement sooner than paint. Paint is a larger, less reversible investment.",
            supportingWork: "Any rust, dents, or damaged clear coat should be repaired before either a wrap or a new paint job — both will show the damage underneath.",
            verificationStatus: .verified,
            sourceReferences: [
                "Metro Center Sign Works, \"Is It Cheaper to Wrap or Paint a Car? 2026 Cost Guide\""
            ]
        ),
        PlanRecommendationRecord(
            id: "style-exterior-bodywork-verified",
            vehicleApplicability: "General guidance; kit fitment is vehicle-specific and must be confirmed for the saved vehicle",
            goal: .style,
            focus: "Exterior",
            triggeringAnswers: ["Bodywork"],
            recommendedInspection: "Confirm the body kit is designed for the specific make, model, and year before buying — fitment varies significantly between trims and model years, and a kit that doesn't fit can require costly modification to install. Decide whether a bolt-on kit or a wide-body kit, which typically requires fender cutting, fits the goal.",
            conditionalNextStep: "If a wide-body kit is chosen, confirm the installer has experience with fender modification before starting.",
            reason: "Body kit costs vary enormously by material and whether the vehicle needs cutting or modification, so confirming the exact scope first avoids a significant budget surprise.",
            partsEstimateStatus: "A bolt-on body kit — front and rear bumpers plus side skirts — typically runs roughly $7,000–$16,000 for parts, though basic fiberglass or ABS plastic kits can be found for less and premium wide-body or carbon fiber kits can run well past $20,000.",
            laborEstimateStatus: "Professional installation typically adds roughly $2,000–$8,000, with wide-body kits requiring fender cutting landing at the higher end. Paint-matching and clear coat typically add another roughly $3,000–$6,000 on top of installation.",
            benefits: "Bodywork is one of the most dramatic and visible style changes available.",
            tradeoffs: "It's also one of the most expensive and least reversible — a wide-body kit permanently alters the fenders, and lower-quality kits can have panel gaps or fitment issues that are difficult to fix afterward.",
            supportingWork: "Paint-matching and clear coat protection are effectively required, not optional, for a finished look — budget for them from the start rather than as an afterthought.",
            verificationStatus: .verified,
            sourceReferences: [
                "Hodoor, \"Cost of body kits\"",
                "Survival Freedom, \"Body Kit Installation Cost\""
            ]
        ),
        PlanRecommendationRecord(
            id: "style-exterior-lighting-verified",
            vehicleApplicability: "General guidance; DOT-compliant assembly availability is vehicle-specific and must be confirmed for the saved vehicle",
            goal: .style,
            focus: "Exterior",
            triggeringAnswers: ["Lighting"],
            recommendedInspection: "Confirm this legal distinction before buying anything: swapping an LED or HID bulb into a headlight housing designed for halogen bulbs is not legal for street use under federal safety standards, regardless of what the listing claims. The legal path is a complete aftermarket headlight assembly designed for LED from the start and carrying a genuine DOT marking.",
            conditionalNextStep: "If a DOT-marked LED assembly isn't available for the saved vehicle, treat bulb-only conversion kits as off-road or show use only, not for a vehicle driven on public roads.",
            reason: "This is a real legal and safety issue, not just a preference — mismatched bulb-and-housing combinations can throw uncontrolled glare at oncoming drivers, and enforcement of excessive-glare rules is active in several states.",
            partsEstimateStatus: "Cost varies enormously depending on whether a DOT-compliant complete LED headlight assembly exists for the saved vehicle. Some popular vehicles have direct-fit options in the roughly $200–$600 per side range, while others may not have a compliant option at all. A bulb-only conversion kit is inexpensive, often under $50, but as noted above isn't legal for street use regardless of price.",
            laborEstimateStatus: "Swapping a complete headlight assembly is typically a straightforward bolt-in job — ask for an installed quote once a specific compliant assembly is identified for the saved vehicle.",
            benefits: "Updated lighting is a highly visible style change and, done correctly with a proper assembly, can also improve nighttime visibility over aging factory halogen bulbs.",
            tradeoffs: "Bulb-only HID/LED conversions in halogen housings are the single most common lighting mistake — widely sold but not legal for road use, and can result in fix-it tickets or failed inspections in states that enforce this.",
            supportingWork: "None beyond confirming DOT compliance for the specific vehicle before buying.",
            verificationStatus: .verified,
            sourceReferences: [
                "LegalClarity, \"In What States Are LED Headlights Illegal?\"",
                "HID Nation, \"Are LED Headlights Legal? What to Know in 2026\"",
                "Bayoptiks, \"LED Headlight Laws: The State-by-State Guide\""
            ]
        ),
        PlanRecommendationRecord(
            id: "style-exterior-prototype",
            vehicleApplicability: "Saved vehicle profile; specific part fitment not yet verified",
            goal: .style,
            focus: "Exterior",
            triggeringAnswers: [],
            recommendedInspection: "Start by confirming exact fitment — size, offset, bolt pattern, or panel compatibility — for the saved vehicle's specific make, model, and year before buying any exterior part.",
            conditionalNextStep: "Once a specific part or category is chosen, its cost and fitment details can be confirmed against the manufacturer's listed compatibility.",
            reason: "Exterior fitment varies significantly across trims and model years, so OpenHood needs the specific part identified before recommending cost or compatibility details.",
            partsEstimateStatus: "Pending verified data",
            laborEstimateStatus: "Pending verified data",
            benefits: "Potential benefits depend on the specific change chosen.",
            tradeoffs: "Fitment issues are common when a part isn't confirmed as compatible with the exact trim and model year before purchase.",
            supportingWork: "Supporting work remains conditional until the specific part and its fitment are confirmed.",
            verificationStatus: .prototype,
            sourceReferences: []
        ),
        PlanRecommendationRecord(
            id: "style-interior-seats-verified",
            vehicleApplicability: "General guidance; seatbelt and airbag sensor integration is vehicle-specific and must be confirmed for the saved vehicle",
            goal: .style,
            focus: "Interior",
            triggeringAnswers: ["Seats"],
            recommendedInspection: "Confirm whether the goal is a reclining sport seat, which bolts into the factory mounting points and keeps factory seatbelt and airbag compatibility, or a fixed racing bucket seat, which usually requires a harness bar and racing harness and generally isn't intended for daily street use with a stock seatbelt.",
            conditionalNextStep: "If fixed racing buckets are chosen, confirm a mounting bracket exists for the specific vehicle and budget the harness bar and harness together with the seats, not separately.",
            reason: "Reclining sport seats and fixed racing buckets serve very different purposes and price points, and mixing up which one fits the vehicle's actual use — daily driving versus dedicated track use — is a common costly mistake.",
            partsEstimateStatus: "A single reclining sport seat typically runs roughly $300–$1,500 depending on brand and materials; a pair for both front seats roughly doubles that. Fixed racing bucket seats intended for competition use can run higher, up to roughly $3,000 per seat.",
            laborEstimateStatus: "Installation complexity varies significantly by vehicle — older cars are often a straightforward bolt-in, while newer cars with seatbelt pretensioner and occupancy sensor wiring can add complexity. Get an installed quote for the saved vehicle rather than assuming a flat rate.",
            benefits: "Aftermarket seats are one of the most noticeable interior changes and can meaningfully improve support during spirited driving.",
            tradeoffs: "Fixed racing buckets without reclining or factory seatbelt integration are significantly less practical for daily driving and often require a harness, which most drivers won't want to put on for routine trips.",
            supportingWork: "A harness bar and harness are a package deal with fixed racing buckets, not an optional add-on, if the factory seatbelt mounting point isn't retained.",
            verificationStatus: .verified,
            sourceReferences: [
                "BRAUM Racing, \"Seats & Safety Harness Buying Guide\"",
                "MotorBiscuit, \"Should You Install Racing Seats in a Street Car?\""
            ]
        ),
        PlanRecommendationRecord(
            id: "style-interior-steering-controls-verified",
            vehicleApplicability: "General guidance; airbag and clock spring compatibility is vehicle-specific and must be confirmed for the saved vehicle",
            goal: .style,
            focus: "Interior",
            triggeringAnswers: ["Steering and controls"],
            recommendedInspection: "If the factory steering wheel has an airbag — true of virtually every vehicle made since the 1990s — confirm the replacement wheel is specifically designed to retain the airbag and is compatible with the factory clock spring and horn wiring for the saved vehicle. Federal safety rules require any replacement wheel to keep full airbag function; there's no legal airbag-delete option for a vehicle driven on public roads.",
            conditionalNextStep: "If a genuinely airbag-compatible wheel isn't available for the saved vehicle, other steering and controls upgrades — shift knob, factory-equipped paddle shifters, pedal covers — don't carry the same safety consideration and remain reasonable options.",
            reason: "This is a real safety and legal issue, not just preference — an incompatible aftermarket wheel can disable airbag deployment or drop the horn and cruise controls, and removing airbag function makes the vehicle unsafe and potentially non-compliant.",
            partsEstimateStatus: "OEM-compatible airbag steering wheels typically run roughly $300–$800, with hand-stitched leather or carbon fiber options exceeding $1,200. A shift knob is a much smaller purchase, typically well under $100.",
            laborEstimateStatus: "Professional installation, including proper airbag module transfer and an SRS system scan afterward to confirm no fault codes, typically runs roughly $300 or more given the diagnostic step involved.",
            benefits: "A properly integrated steering wheel is one of the most noticeable interior touch points and can improve grip and feel.",
            tradeoffs: "The pool of genuinely airbag-compatible aftermarket wheels for any specific vehicle is limited — availability, not just cost, may be the deciding factor.",
            supportingWork: "An SRS/airbag system scan after installation is not optional — it's the only way to confirm the airbag will still deploy correctly.",
            verificationStatus: .verified,
            sourceReferences: [
                "NHTSA, Interpretation ID: 0761 (FMVSS 208)",
                "Automotive Gearz, \"Aftermarket Steering Wheel With Airbag: Is It Legal and Safe?\""
            ]
        ),
        PlanRecommendationRecord(
            id: "style-interior-trim-materials-verified",
            vehicleApplicability: "General guidance; not vehicle-specific",
            goal: .style,
            focus: "Interior",
            triggeringAnswers: ["Trim and materials"],
            recommendedInspection: "Decide between a vinyl wrap over existing trim — cheapest, fully reversible — and genuine carbon fiber or wood trim panels, which cost more but still tend to be removable.",
            conditionalNextStep: "If going with genuine panels, confirm they're a direct-fit replacement for the saved vehicle's trim pieces rather than a universal panel that needs trimming.",
            reason: "Trim materials span an enormous price range for a similar visual result, so the choice mostly comes down to budget and how permanent the look should feel.",
            partsEstimateStatus: "A basic DIY vinyl or carbon-look wrap for trim pieces typically runs roughly $30–$100 in material. Genuine carbon fiber trim panels typically run roughly $300–$3,000 depending on the piece and vehicle.",
            laborEstimateStatus: "Vinyl wrapping trim is a common DIY job with no labor cost if done at home, or a modest professional installation fee if not. Genuine panel installation is typically straightforward trim removal and reinstallation, without major additional labor beyond the panel cost itself.",
            benefits: "This is one of the least expensive ways to meaningfully change the interior's look, especially with vinyl wrap.",
            tradeoffs: "Vinyl wrap can lift at the edges over time, especially around vents and buttons; genuine panels are more durable but far more expensive for the same visual effect.",
            supportingWork: "None typically required beyond care during trim panel removal to avoid breaking factory clips.",
            verificationStatus: .verified,
            sourceReferences: [
                "Supreem Carbon, \"Carbon Fiber Interior Trim: 2026 Guide\""
            ]
        ),
        PlanRecommendationRecord(
            id: "style-interior-audio-tech-verified",
            vehicleApplicability: "General guidance; dash integration fitment is vehicle-specific and must be confirmed for the saved vehicle",
            goal: .style,
            focus: "Interior",
            triggeringAnswers: ["Audio and technology"],
            recommendedInspection: "Confirm whether the goal is a head unit swap, which adds a new screen and interface and often CarPlay/Android Auto to an older vehicle, a speaker upgrade, or both — they're priced and installed very differently, and a head unit swap on a newer vehicle may need a dash-integration kit to avoid a mismatched look.",
            conditionalNextStep: "If a subwoofer or amplifier is being added, confirm the vehicle's electrical system and available trunk or cargo space before buying, since higher-power setups draw more current and take up real space.",
            reason: "Audio and technology upgrades range from a simple speaker swap to a full system, so confirming scope first avoids either underbuying or overspending.",
            partsEstimateStatus: "A basic head unit swap typically runs roughly $100–$400 for parts. Speaker replacement typically runs roughly $100–$500 depending on quality. A full system with head unit, speakers, amplifier, and subwoofer typically runs roughly $300–$1,500 or more.",
            laborEstimateStatus: "Professional installation typically runs roughly $100–$150 for a head unit, and roughly $50 per speaker location; a full system install is usually quoted as a package rather than itemized separately.",
            benefits: "This is one of the more affordable and lower-risk style categories, and a head unit swap can add genuinely useful features like CarPlay/Android Auto to an older vehicle.",
            tradeoffs: "A head unit that doesn't match the factory dash opening or finish can look more like a downgrade than an upgrade without a proper integration kit.",
            supportingWork: "A dash-integration/trim kit is worth budgeting for on any vehicle where the aftermarket unit doesn't match the factory opening size.",
            verificationStatus: .verified,
            sourceReferences: [
                "ConsumerAffairs, \"Cost of Car Stereo Installation (2026)\""
            ]
        ),
        PlanRecommendationRecord(
            id: "style-interior-prototype",
            vehicleApplicability: "Saved vehicle profile; specific part fitment not yet verified",
            goal: .style,
            focus: "Interior",
            triggeringAnswers: [],
            recommendedInspection: "Start by confirming exact fitment and compatibility — seat mounting points, airbag wiring, or trim piece dimensions — for the saved vehicle's specific make, model, and year before buying any interior part.",
            conditionalNextStep: "Once a specific part or category is chosen, its cost and fitment details can be confirmed against the manufacturer's listed compatibility.",
            reason: "Interior fitment and safety-system integration vary significantly across trims and model years, so OpenHood needs the specific part identified before recommending cost or compatibility details.",
            partsEstimateStatus: "Pending verified data",
            laborEstimateStatus: "Pending verified data",
            benefits: "Potential benefits depend on the specific change chosen.",
            tradeoffs: "Fitment and safety-system integration issues are common when a part isn't confirmed as compatible with the exact trim and model year before purchase.",
            supportingWork: "Supporting work remains conditional until the specific part and its fitment are confirmed.",
            verificationStatus: .prototype,
            sourceReferences: []
        ),
        PlanRecommendationRecord(
            id: "style-sound-exhaust-tone-verified",
            vehicleApplicability: "General guidance; exhaust noise limits vary by state and locality and must be checked for where the vehicle is driven",
            goal: .style,
            focus: "Sound",
            triggeringAnswers: ["Exhaust tone"],
            recommendedInspection: "Check state and local exhaust noise laws before buying anything louder than stock. Most states prohibit modifying the exhaust to be louder than the factory system, and enforcement is active in several states, with fines that have risen sharply in recent years.",
            conditionalNextStep: "If a cat-back system is chosen, confirm it retains the factory catalytic converter — a full test-pipe or catalytic-converter-delete setup carries its own separate emissions-law risk beyond noise.",
            reason: "Cat-back exhaust systems change the exhaust note without touching the engine's power delivery in a major way, but the noise-law risk is real and state enforcement has been increasing.",
            partsEstimateStatus: "A cat-back exhaust system typically runs roughly $300–$1,500 for parts, with entry-level systems around $300–$500 and high-performance systems reaching $1,000–$2,500 or more.",
            laborEstimateStatus: "Installation is typically straightforward and quick — roughly an hour or so of shop time — with labor typically running roughly $100–$400.",
            benefits: "A cat-back system is one of the more affordable ways to meaningfully change the exhaust note without major engine work.",
            tradeoffs: "Louder isn't always better received — some states have fines up to $1,000 for exhaust noise violations, and enforcement varies significantly by state, so what's fine in one place may not be in another.",
            supportingWork: "None required beyond the exhaust system itself for a standard cat-back swap.",
            verificationStatus: .verified,
            sourceReferences: [
                "CostHack, \"Cat-Back Exhaust [Labor & Parts]\"",
                "SEMA Action Network, \"Exhaust Noise Laws By State\"",
                "World Population Review, \"Exhaust Laws by State 2026\""
            ]
        ),
        PlanRecommendationRecord(
            id: "style-sound-exhaust-appearance-verified",
            vehicleApplicability: "General guidance; tip inlet diameter is vehicle-specific and must be confirmed for the saved vehicle's exhaust outlet",
            goal: .style,
            focus: "Sound",
            triggeringAnswers: ["Exhaust appearance"],
            recommendedInspection: "Confirm the tip's inlet diameter matches the vehicle's exhaust pipe outlet before buying — a mismatched tip either won't fit or will look proportionally wrong once installed.",
            conditionalNextStep: "None beyond fitment confirmation — this is a purely cosmetic, low-risk change compared to other exhaust work.",
            reason: "This is the lowest-cost, lowest-risk item in the Sound category since it doesn't change how the vehicle actually sounds or runs.",
            partsEstimateStatus: "Exhaust tips typically run roughly $25–$150 per tip.",
            laborEstimateStatus: "Installation typically takes under an hour, with labor typically running roughly $50–$100.",
            benefits: "This is an inexpensive way to change the exhaust's visual finish without the noise-law considerations that come with a full cat-back system.",
            tradeoffs: "A tip alone doesn't change the exhaust note — it's purely cosmetic, and pairing an aggressive-looking tip with a quiet factory exhaust note is a common visual mismatch.",
            supportingWork: "None required.",
            verificationStatus: .verified,
            sourceReferences: [
                "SPELAB, \"How Much Does a Custom Exhaust Cost? Parts, Labor & Pricing\""
            ]
        ),
        PlanRecommendationRecord(
            id: "style-sound-cabin-audio-verified",
            vehicleApplicability: "General guidance; electrical capacity is vehicle-specific and must be confirmed for the saved vehicle",
            goal: .style,
            focus: "Sound",
            triggeringAnswers: ["Cabin audio"],
            recommendedInspection: "Confirm whether the goal is better sound quality, a speaker upgrade, or more bass output, a subwoofer and amplifier — they're different upgrades with very different costs and space requirements.",
            conditionalNextStep: "If a subwoofer and amplifier are added, confirm available trunk or cargo space and battery/electrical capacity before buying, since higher-power setups draw meaningfully more current.",
            reason: "A clearer, better-quality sound system and a louder, bass-heavy system are different goals that call for different equipment, so clarifying which one is actually wanted avoids buying the wrong gear.",
            partsEstimateStatus: "A speaker upgrade alone typically runs roughly $100–$500. A more complete system adding an amplifier and subwoofer typically runs roughly $300–$1,500 or more depending on power and brand.",
            laborEstimateStatus: "Speaker installation typically runs roughly $50 per location. A subwoofer and amplifier installation is usually quoted as a package given the wiring and enclosure work involved, rather than itemized separately.",
            benefits: "This is a lower-risk, fully reversible category compared to most other style changes — nothing here affects the vehicle's structure, warranty, or road legality.",
            tradeoffs: "A subwoofer and amplifier take up real trunk or cargo space and add meaningful electrical load, which matters more on an older vehicle or one with a smaller factory battery.",
            supportingWork: "Confirm the vehicle's electrical system can support the added amperage draw before installing a high-power amplifier.",
            verificationStatus: .verified,
            sourceReferences: [
                "ConsumerAffairs, \"Cost of Car Stereo Installation (2026)\""
            ]
        ),
        PlanRecommendationRecord(
            id: "style-sound-prototype",
            vehicleApplicability: "Saved vehicle profile; specific part fitment not yet verified",
            goal: .style,
            focus: "Sound",
            triggeringAnswers: [],
            recommendedInspection: "Start by confirming what's actually wanted — exhaust note, exhaust appearance, or cabin audio — and check any applicable local noise laws before buying.",
            conditionalNextStep: "Once a specific part or category is chosen, its cost and fitment details can be confirmed against the manufacturer's listed compatibility.",
            reason: "Sound-related changes span exhaust hardware and audio equipment, which are unrelated systems with different costs and legal considerations, so OpenHood needs the specific choice identified before recommending further.",
            partsEstimateStatus: "Pending verified data",
            laborEstimateStatus: "Pending verified data",
            benefits: "Potential benefits depend on the specific change chosen.",
            tradeoffs: "Exhaust noise changes carry state and local legal considerations that audio equipment changes do not.",
            supportingWork: "Supporting work remains conditional until the specific part is confirmed.",
            verificationStatus: .prototype,
            sourceReferences: []
        ),
        PlanRecommendationRecord(
            id: "performance-power-emissions-safe-bolt-ons",
            vehicleApplicability: "General guidance; not vehicle-specific",
            goal: .performance,
            focus: "Power",
            triggeringAnswers: ["Everyday reliability"],
            recommendedInspection: "Start with bolt-on parts that don't touch the vehicle's emissions equipment — a cold air intake and a professional ECU tune that keeps the factory catalytic converters and other emissions hardware in place. Confirm with the tuner that the tune is emissions-compliant, especially in California, Colorado, Maine, or New York, which independently require CARB-legal parts.",
            conditionalNextStep: "If more power is wanted later, forced induction is the next real step up — see the Performance-priority option on this same focus.",
            reason: "These are the highest power-per-dollar changes that don't risk the vehicle's emissions legality or daily reliability.",
            partsEstimateStatus: "A quality cold air intake typically runs roughly $250–$550. An ECU tune typically runs roughly $300–$1,000 depending on the vehicle and tuner, with a dyno tuning session — recommended to verify the tune is actually safe for the engine — typically running roughly $200–$1,000 on top of that.",
            laborEstimateStatus: "Cold air intake installation is usually straightforward and often DIY-friendly, or a modest shop fee. An ECU tune is typically a software-only process with no separate labor cost beyond the tune itself and the dyno session noted above.",
            benefits: "A cold air intake typically adds roughly 5–15 horsepower depending on the engine, and a professional tune can add meaningfully more — both without touching factory emissions equipment, keeping the vehicle legal to drive and easier to pass inspection.",
            tradeoffs: "Gains from an intake alone are modest; a tune is where most of the real power comes from, and quality varies significantly by tuner — a poorly done tune can hurt reliability.",
            supportingWork: "A dyno tuning session is worth budgeting for alongside the tune itself, since it verifies the tune is actually safe rather than just estimated.",
            verificationStatus: .verified,
            sourceReferences: [
                "SPELAB, \"How Much Horsepower Does a Cold Air Intake Add?\"",
                "5 Star Tuning, \"How Much Does Car Engine Tuning Cost?\""
            ]
        ),
        PlanRecommendationRecord(
            id: "performance-power-forced-induction",
            vehicleApplicability: "General guidance; not vehicle-specific",
            goal: .performance,
            focus: "Power",
            triggeringAnswers: ["Performance priority"],
            recommendedInspection: "Confirm upfront that any forced-induction kit or supporting tune keeps the factory catalytic converters and emissions equipment in place and unmodified — removing or replacing them is illegal under the federal Clean Air Act, not just a compliance formality, and several states (California, Colorado, Maine, New York) independently require CARB-certified parts with their own Executive Order numbers.",
            conditionalNextStep: "Budget for supporting upgrades — fuel system and cooling — as part of this decision, not as a surprise after the kit is installed.",
            reason: "Forced induction is the single largest jump in power available, but it's also the modification most likely to run into a real legal line if paired with removing emissions equipment — worth getting right from the start rather than after the fact.",
            partsEstimateStatus: "A supercharger or turbo kit typically runs roughly $2,000–$10,000 depending on the vehicle and kit, with well-known factory-backed kits — like a Ford Performance Mustang supercharger — running toward the higher end, around $10,000.",
            laborEstimateStatus: "Installation is a major undertaking typically requiring a specialized shop; labor varies too widely by vehicle and kit complexity for a single number here — get a shop-specific quote once a kit is chosen. A supporting ECU tune and dyno session, roughly $500–$2,000 combined, is required alongside the hardware, not optional.",
            benefits: "Forced induction offers the largest realistic horsepower gain of any bolt-on category, often 30–100%+ depending on the setup.",
            tradeoffs: "This is also the modification most likely to shorten engine life if not paired with supporting upgrades (fuel system, cooling, stronger internals on higher-power builds), and the modification most likely to create real legal exposure if emissions equipment is altered.",
            supportingWork: "Upgraded fuel injectors or a fuel pump, and often a larger radiator or intercooler, are typically needed alongside forced induction rather than as an afterthought.",
            verificationStatus: .verified,
            sourceReferences: [
                "AOL/Ford Performance, Mustang supercharger kit pricing",
                "National Law Review, \"EPA Reinforces Position that Certain Types of ECM Changes... Constitute 'Tampering'\""
            ]
        ),
        PlanRecommendationRecord(
            id: "performance-power-prototype",
            vehicleApplicability: "Saved vehicle profile; specific part fitment not yet verified",
            goal: .performance,
            focus: "Power",
            triggeringAnswers: [],
            recommendedInspection: "Start by confirming the vehicle's current emissions configuration is unmodified, and decide whether the goal is a modest, emissions-legal power gain or a larger forced-induction build — the right first step is different for each.",
            conditionalNextStep: "Once that's decided, cost and fitment details can be confirmed against the manufacturer's listed compatibility.",
            reason: "Power modifications span a huge cost and legal-risk range, so OpenHood needs the general direction identified before recommending further.",
            partsEstimateStatus: "Pending verified data",
            laborEstimateStatus: "Pending verified data",
            benefits: "Potential benefits depend on the specific change chosen.",
            tradeoffs: "Power modifications carry real legal considerations tied to emissions equipment that most other style or comfort changes do not.",
            supportingWork: "Supporting work remains conditional until the specific part is confirmed.",
            verificationStatus: .prototype,
            sourceReferences: []
        ),
        PlanRecommendationRecord(
            id: "performance-handling-daily-usable",
            vehicleApplicability: "General guidance; not vehicle-specific",
            goal: .performance,
            focus: "Handling",
            triggeringAnswers: ["Everyday reliability"],
            recommendedInspection: "Start with a performance sway bar and a strut tower brace — both reduce body roll and improve chassis stiffness without lowering the car or stiffening the ride the way coilovers do.",
            conditionalNextStep: "If more cornering response is wanted later, coilovers are the next real step up — see the Performance-priority option on this same focus.",
            reason: "These changes improve handling feel while keeping daily-driving comfort and ride height intact, matching an everyday-reliability priority.",
            partsEstimateStatus: "A performance sway bar typically runs roughly $150–$400, with sway bar end links roughly $75–$300 per set if replaced at the same time. A strut tower brace typically runs roughly $100–$300.",
            laborEstimateStatus: "Installation is usually straightforward suspension work; labor is often included in a combined installed quote for a job this size — ask the shop for an installed total.",
            benefits: "A sway bar reduces body roll in corners without lowering the car or stiffening the ride the way coilovers do, keeping daily comfort intact.",
            tradeoffs: "Gains are more subtle than coilovers or a full suspension overhaul — this is a mild, complementary upgrade, not a dramatic handling transformation.",
            supportingWork: "None required beyond the parts themselves for a standard sway bar and brace install.",
            verificationStatus: .verified,
            sourceReferences: [
                "AutoNation Mobile Service, \"Sway Bar Link Replacement Cost\"",
                "Jerry, \"Sway Bar Replacement Cost Estimate\""
            ]
        ),
        PlanRecommendationRecord(
            id: "performance-handling-track-focused",
            vehicleApplicability: "General guidance; not vehicle-specific",
            goal: .performance,
            focus: "Handling",
            triggeringAnswers: ["Performance priority"],
            recommendedInspection: "Decide on coilovers over lowering springs for this priority level — coilovers add ride-height and, on most sets, damping adjustability that springs alone don't offer, which matters more for dedicated performance use than for a simple stance change.",
            conditionalNextStep: "Budget a performance alignment with more aggressive settings alongside the coilovers, not as a separate later purchase.",
            reason: "Coilovers are the biggest realistic handling upgrade available in this category, and performance use benefits from the adjustability springs alone don't provide.",
            partsEstimateStatus: "Coilovers typically run roughly $800–$2,500 for a quality entry-to-mid-range set, with premium adjustable sets exceeding $4,000.",
            laborEstimateStatus: "Installation typically adds several hundred dollars in labor on top of the parts cost, plus a performance alignment afterward, typically roughly $100–$200.",
            benefits: "Coilovers meaningfully improve cornering response and reduce body roll, with the added ability to fine-tune ride height and, on most sets, damping — the biggest realistic handling upgrade available.",
            tradeoffs: "Ride comfort drops noticeably compared to stock or a sway-bar-only upgrade, and aggressive settings can accelerate tire and bushing wear.",
            supportingWork: "A performance alignment with more aggressive camber settings is worth doing alongside coilovers for track use, though it will accelerate front tire wear on the street.",
            verificationStatus: .verified,
            sourceReferences: [
                "CarXplorer, \"How Much To Lower a Car: 2026 Cost & Options Guide\""
            ]
        ),
        PlanRecommendationRecord(
            id: "performance-handling-prototype",
            vehicleApplicability: "Saved vehicle profile; specific part fitment not yet verified",
            goal: .performance,
            focus: "Handling",
            triggeringAnswers: [],
            recommendedInspection: "Start by confirming whether the goal is a mild, daily-usable improvement or a dedicated performance setup — the right first step is different for each.",
            conditionalNextStep: "Once that's decided, cost and fitment details can be confirmed against the manufacturer's listed compatibility.",
            reason: "Handling modifications range from a simple sway bar to a full coilover setup, so OpenHood needs the general direction identified before recommending further.",
            partsEstimateStatus: "Pending verified data",
            laborEstimateStatus: "Pending verified data",
            benefits: "Potential benefits depend on the specific change chosen.",
            tradeoffs: "More aggressive handling setups trade away ride comfort and increase wear on tires and bushings.",
            supportingWork: "Supporting work remains conditional until the specific part is confirmed.",
            verificationStatus: .prototype,
            sourceReferences: []
        ),
        PlanRecommendationRecord(
            id: "performance-braking-pads-rotors-lines",
            vehicleApplicability: "General guidance; not vehicle-specific",
            goal: .performance,
            focus: "Braking",
            triggeringAnswers: ["Street balance"],
            recommendedInspection: "Start with performance brake pads and slotted or drilled rotors, plus stainless steel brake lines — a meaningful upgrade over factory parts without the cost or wheel-fitment considerations of a big brake kit.",
            conditionalNextStep: "If track use becomes a bigger part of the plan later, a big brake kit is the next real step up — see the Track-days option on this same focus.",
            reason: "This is the best stopping-power upgrade per dollar for street and spirited driving that doesn't require a big brake kit's cost or wheel clearance.",
            partsEstimateStatus: "Performance brake pads and rotors for both front wheels typically run roughly $300–$600, using higher-temperature pad compounds and slotted or drilled rotors instead of standard parts. Stainless steel brake lines typically run roughly $100–$250 for a full set.",
            laborEstimateStatus: "Labor is typically similar to a standard brake job, roughly $150–$300 per axle; stainless lines add a brake fluid bleed, usually included in a combined installed quote.",
            benefits: "Performance pads resist fade better under hard use, and stainless lines give a firmer, more consistent pedal feel than factory rubber lines, which can swell under heavy braking.",
            tradeoffs: "Some performance pad compounds are noisier or dustier than factory pads, and can need to warm up before they bite as well as factory pads do when cold.",
            supportingWork: "A brake fluid flush is worth doing at the same time, especially if upgrading to stainless lines.",
            verificationStatus: .verified,
            sourceReferences: [
                "ICOOH, \"How Much Are Brake Pads and Rotors? 2026 Brake Replacement Cost\""
            ]
        ),
        PlanRecommendationRecord(
            id: "performance-braking-big-brake-kit",
            vehicleApplicability: "General guidance; wheel clearance is vehicle-specific and must be confirmed for the saved vehicle",
            goal: .performance,
            focus: "Braking",
            triggeringAnswers: ["Track days"],
            recommendedInspection: "Confirm the current wheels clear the new calipers before buying — this is the most common fitment mistake with big brake kits, and it's worth checking against the specific kit's caliper dimensions before ordering.",
            conditionalNextStep: "If the current wheels don't clear, budget new wheels as part of this purchase rather than discovering the conflict after the kit arrives.",
            reason: "Standard brakes can fade after just a few hard stops on track, so this is the category built specifically for repeated hard braking rather than occasional spirited driving.",
            partsEstimateStatus: "A big brake kit typically runs roughly $1,800–$4,000 installed for a front-only setup, or roughly $3,500–$7,500+ for a full front-and-rear system, with entry-level kits at the lower end and premium multi-piston or carbon-ceramic systems reaching $4,000–$9,000+.",
            laborEstimateStatus: "Labor is typically included in the installed ranges above — big brake kits are usually quoted as a single installed price rather than separate parts and labor.",
            benefits: "A big brake kit meaningfully improves stopping power and fade resistance under repeated hard braking, which matters most for track use where standard brakes can fade after just a few hard stops.",
            tradeoffs: "This is one of the more expensive single upgrades in this category, and often requires a specific, compatible wheel size to clear the larger calipers.",
            supportingWork: "Confirm the current wheels clear the new calipers before purchasing; this is the most common fitment mistake with big brake kits.",
            verificationStatus: .verified,
            sourceReferences: [
                "ICOOH, \"Big Brake Kit Cost in 2026: U.S. Price & Worth It?\""
            ]
        ),
        PlanRecommendationRecord(
            id: "performance-braking-prototype",
            vehicleApplicability: "Saved vehicle profile; specific part fitment not yet verified",
            goal: .performance,
            focus: "Braking",
            triggeringAnswers: [],
            recommendedInspection: "Start by confirming how the vehicle is actually used — street and spirited driving call for a different upgrade than repeated track use.",
            conditionalNextStep: "Once that's decided, cost and fitment details can be confirmed against the manufacturer's listed compatibility.",
            reason: "Braking upgrades range from a pad-and-rotor swap to a full big brake kit, so OpenHood needs the general direction identified before recommending further.",
            partsEstimateStatus: "Pending verified data",
            laborEstimateStatus: "Pending verified data",
            benefits: "Potential benefits depend on the specific change chosen.",
            tradeoffs: "Bigger brake upgrades often require larger wheels to clear the calipers, which is a real fitment consideration, not just a cost one.",
            supportingWork: "Supporting work remains conditional until the specific part is confirmed.",
            verificationStatus: .prototype,
            sourceReferences: []
        ),
        PlanRecommendationRecord(
            id: "performance-sound-cat-back-emissions-legal",
            vehicleApplicability: "General guidance; not vehicle-specific",
            goal: .performance,
            focus: "Sound",
            triggeringAnswers: ["Everyday reliability"],
            recommendedInspection: "Start with a cat-back exhaust system — it changes the exhaust note and gives a modest flow improvement without touching the catalytic converters, keeping the vehicle emissions-legal everywhere, including CARB states.",
            conditionalNextStep: "If more sound and flow are wanted later, headers and a downpipe are the next real step up — see the Performance-priority option on this same focus, and read its legal note carefully before buying anything.",
            reason: "This is the lowest-risk way to meaningfully change the exhaust note, since the factory catalytic converters and headers stay untouched.",
            partsEstimateStatus: "A cat-back exhaust system typically runs roughly $300–$1,500 for parts, with entry-level systems around $300–$500 and high-performance systems reaching $1,000–$2,500 or more.",
            laborEstimateStatus: "Installation is typically straightforward and quick — roughly an hour or so of shop time — with labor typically running roughly $100–$400.",
            benefits: "A cat-back system is the safest way to get a meaningfully different exhaust note and modest flow improvement without touching the catalytic converters.",
            tradeoffs: "Power gains from a cat-back alone are typically modest — a few horsepower at most — since the factory catalytic converters and headers remain the primary restriction on flow.",
            supportingWork: "None required beyond the exhaust system itself for a standard cat-back swap.",
            verificationStatus: .verified,
            sourceReferences: [
                "CostHack, \"Cat-Back Exhaust [Labor & Parts]\""
            ]
        ),
        PlanRecommendationRecord(
            id: "performance-sound-headers-downpipe-legal-note",
            vehicleApplicability: "General guidance; state emissions requirements vary and must be checked for where the vehicle is registered",
            goal: .performance,
            focus: "Sound",
            triggeringAnswers: ["Performance priority"],
            recommendedInspection: "Confirm this before buying anything: headers or a downpipe that remove or relocate a factory catalytic converter are illegal under the federal Clean Air Act, and several states — California, Colorado, Maine, and New York — independently require CARB Executive Order-numbered replacement converters specifically. Headers that keep the factory catalytic converters in their original position are generally CARB-exempt and legal; a header or downpipe that deletes or relocates them is not, regardless of what the seller claims.",
            conditionalNextStep: "If the plan includes a downpipe, confirm it's paired with a CARB EO-numbered high-flow catalytic converter, not a straight pipe or \"test pipe,\" if the vehicle is registered in a state that requires one.",
            reason: "This is real legal exposure, not just a compliance formality — EPA enforcement actions against aftermarket companies, and increasingly individual owners, have resulted in significant penalties, and a vehicle without a functioning catalytic converter will fail an emissions test outright in states that require one.",
            partsEstimateStatus: "Cost varies by vehicle and by whether CARB-compliant high-flow converters are included — headers alone typically run roughly $300–$1,200, with a compliant high-flow converter adding roughly $300–$800 more if the downpipe is included.",
            laborEstimateStatus: "Installation is more involved than a cat-back system, often requiring the vehicle to be lifted with more disassembly — get an installed quote for the specific vehicle rather than assuming a flat rate.",
            benefits: "Headers and a matching downpipe, done legally with the catalytic converters retained or replaced with compliant units, offer a real power and sound gain beyond what a cat-back alone provides.",
            tradeoffs: "This is the highest legal-risk item in the Performance category — the temptation to remove catalytic converters entirely for maximum flow is exactly the illegal path, even though it's widely sold online.",
            supportingWork: "A tune is usually recommended alongside headers and a downpipe to get the full benefit and keep the engine running correctly with the changed exhaust flow.",
            verificationStatus: .verified,
            sourceReferences: [
                "Walker Exhaust, \"CARB or EPA Catalytic Converter\"",
                "dubmagazine, \"Catalytic Converter Delete Fines 2025: EPA Penalties Up to $50k\""
            ]
        ),
        PlanRecommendationRecord(
            id: "performance-sound-prototype",
            vehicleApplicability: "Saved vehicle profile; specific part fitment not yet verified",
            goal: .performance,
            focus: "Sound",
            triggeringAnswers: [],
            recommendedInspection: "Start by confirming whether the goal is a modest, emissions-legal note change or a bigger flow-and-sound upgrade — the legal considerations are very different between the two.",
            conditionalNextStep: "Once that's decided, cost and fitment details can be confirmed against the manufacturer's listed compatibility.",
            reason: "Exhaust modifications for sound range from fully emissions-legal to a real legal risk, so OpenHood needs the general direction identified before recommending further.",
            partsEstimateStatus: "Pending verified data",
            laborEstimateStatus: "Pending verified data",
            benefits: "Potential benefits depend on the specific change chosen.",
            tradeoffs: "Exhaust changes that touch the catalytic converter carry real federal and state legal considerations that a cat-back alone does not.",
            supportingWork: "Supporting work remains conditional until the specific part is confirmed.",
            verificationStatus: .prototype,
            sourceReferences: []
        ),
        PlanRecommendationRecord(
            id: "performance-track-use-brake-fluid-and-fluids",
            vehicleApplicability: "General guidance; not vehicle-specific",
            goal: .performance,
            focus: "Track use",
            triggeringAnswers: ["Track days"],
            recommendedInspection: "Start with a high-temperature brake fluid flush — this is inexpensive insurance against the single most track-relevant brake failure mode, and worth doing before a track day regardless of what else is planned.",
            conditionalNextStep: "If track days become regular rather than occasional, budget for more frequent fluid flushes than a street-only vehicle would need.",
            reason: "Standard DOT 3/4 brake fluid absorbs moisture over time, which lowers its boiling point — under repeated hard track braking, this can cause a soft or fading pedal at the worst possible time.",
            partsEstimateStatus: "A high-performance DOT 4 or DOT 5.1 brake fluid flush typically runs roughly $70–$150 at an independent shop, or $200–$300+ at a dealer. Premium racing-grade fluid alone typically runs roughly $10–$40 per quart, with most vehicles needing 1–2 quarts.",
            laborEstimateStatus: "Labor is included in the flush service ranges above.",
            benefits: "A fresh high-temperature fluid meaningfully raises the margin before brake fade sets in under repeated hard track braking.",
            tradeoffs: "DOT 5.1 costs more than DOT 4, and both need to be flushed more often with regular track use than a street-only vehicle would.",
            supportingWork: "This is worth doing before a track day regardless of what else is planned on this list.",
            verificationStatus: .verified,
            sourceReferences: [
                "brakefluidreplacementcost.com, \"Brake Fluid Replacement Cost: $70 to $150 in 2026\"",
                "My Pro Street, \"Best Brake Fluid for Track Days Explained\""
            ]
        ),
        PlanRecommendationRecord(
            id: "performance-track-use-safety-equipment",
            vehicleApplicability: "General guidance; specific tech inspection requirements vary by track or sanctioning body and must be checked directly",
            goal: .performance,
            focus: "Track use",
            triggeringAnswers: ["Competition"],
            recommendedInspection: "Check the specific track or sanctioning body's tech inspection requirements before buying anything — required safety equipment, harness bar, harness expiration dates, fire extinguisher mounting, seat certification, varies by organization, and equipment that doesn't meet the specific rule set can fail inspection even if it's genuinely safer than stock.",
            conditionalNextStep: "Confirm harness expiration dates against the specific sanctioning body's rules before a scheduled event, not after arriving at tech inspection.",
            reason: "Competition-level track use has real, specific compliance requirements beyond just \"safer than stock,\" and failing tech inspection on race day is a worse outcome than budgeting for compliant equipment up front.",
            partsEstimateStatus: "A harness bar and a set of racing harnesses typically run roughly $300–$800 combined. A track-certified fire extinguisher and mount typically run roughly $50–$150.",
            laborEstimateStatus: "Installation is usually straightforward bolt-in work; budget a modest shop fee if not doing it yourself.",
            benefits: "Proper safety equipment meaningfully improves occupant protection during competition use and is required, not optional, to pass tech inspection at most sanctioned events.",
            tradeoffs: "Harnesses have manufacturer-specified expiration dates, often 2–5 years, since webbing degrades over time — an expired harness will fail tech inspection even if it looks fine.",
            supportingWork: "Confirm seat compatibility with the harness bar and mounting points before buying either separately.",
            verificationStatus: .verified,
            sourceReferences: [
                "BRAUM Racing, \"Seats & Safety Harness Buying Guide\""
            ]
        ),
        PlanRecommendationRecord(
            id: "performance-track-use-prototype",
            vehicleApplicability: "Saved vehicle profile; specific part fitment not yet verified",
            goal: .performance,
            focus: "Track use",
            triggeringAnswers: [],
            recommendedInspection: "Start by confirming whether the goal is occasional track days or regular competition use — the required equipment and compliance considerations differ significantly.",
            conditionalNextStep: "Once that's decided, cost and fitment details can be confirmed against the manufacturer's listed compatibility.",
            reason: "Track preparation ranges from a brake fluid flush to full competition safety equipment, so OpenHood needs the general direction identified before recommending further.",
            partsEstimateStatus: "Pending verified data",
            laborEstimateStatus: "Pending verified data",
            benefits: "Potential benefits depend on the specific change chosen.",
            tradeoffs: "Competition-level equipment carries specific compliance requirements that occasional track-day use does not.",
            supportingWork: "Supporting work remains conditional until the specific part is confirmed.",
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

    /// The app already collected mileage when the vehicle was added, and
    /// stores it on the saved vehicle — asking a person to type the same
    /// number in again is the app forgetting what it was told, which is
    /// the opposite of what a garage-aware tool should do. Pre-fill it
    /// from the saved vehicle so the normal case is a single confirming
    /// tap, while still leaving the field editable, because mileage is the
    /// one saved detail that genuinely drifts between sessions.
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
        .onAppear {
            guard mileage.isEmpty else { return }
            mileage = vehicle.mileage.trimmingCharacters(in: .whitespacesAndNewlines)
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
