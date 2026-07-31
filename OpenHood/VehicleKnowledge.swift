import Foundation

// MARK: - Source Confidence

enum KnowledgeConfidence: String, Codable, Hashable {
    case factoryVerified = "Factory Verified"
    case governmentVerified = "Government Verified"
    case professionallyDocumented = "Professionally Documented"
    case communityReported = "Community Reported"
    case ownerReported = "Owner Reported"
    case unconfirmed = "Unconfirmed"
}

// MARK: - Knowledge Source

struct KnowledgeSource: Identifiable, Hashable {
    let id = UUID()
    let title: String
    let organization: String
    let confidence: KnowledgeConfidence
    let referenceNote: String
}

// MARK: - Engine Specification

struct EngineSpecification: Identifiable, Hashable {
    let id = UUID()
    let code: String
    let family: String
    let displacementLiters: Double
    let cylinders: Int
    let aspiration: String
    let fuelType: String
    let notes: String
}

// MARK: - Drivetrain Specification

struct DrivetrainSpecification: Hashable {
    let layout: String
    let drivenWheels: String
    let differentialDescription: String
}

// MARK: - Fluid Specification

struct FluidSpecification: Identifiable, Hashable {
    let id = UUID()
    let system: String
    let recommendedSpecification: String
    let capacity: String?
    let notes: String
    let confidence: KnowledgeConfidence
}

// MARK: - Tire Specification

struct TireSpecification: Identifiable, Hashable {
    let id = UUID()
    let position: String
    let size: String
    let wheelSize: String
    let notes: String
}

// MARK: - Maintenance Item

struct FactoryMaintenanceItem: Identifiable, Hashable {
    let id = UUID()
    let title: String
    let interval: String
    let notes: String
    let confidence: KnowledgeConfidence
}

// MARK: - Known Concern

struct KnownVehicleConcern: Identifiable, Hashable {
    let id = UUID()
    let title: String
    let affectedConfigurations: String
    let symptoms: [String]
    let inspectionFirst: [String]
    let notes: String
    let confidence: KnowledgeConfidence
}

// MARK: - Safety Resource

struct VehicleSafetyResource: Identifiable, Hashable {
    let id = UUID()
    let title: String
    let explanation: String
    let requiresVINCheck: Bool
    let confidence: KnowledgeConfidence
}

// MARK: - Owner Resource

struct VehicleOwnerResource: Identifiable, Hashable {
    let id = UUID()
    let title: String
    let resourceType: String
    let organization: String
    let notes: String
}

// MARK: - Vehicle Knowledge Profile

struct VehicleKnowledgeProfile: Identifiable, Hashable {
    let id = UUID()

    let manufacturer: String
    let model: String
    let generation: String
    let market: String

    let year: Int
    let transmission: String?
    let trim: String?

    let bodyStyle: String
    let engine: EngineSpecification
    let drivetrain: DrivetrainSpecification

    let fluids: [FluidSpecification]
    let tires: [TireSpecification]
    let maintenanceItems: [FactoryMaintenanceItem]
    let knownConcerns: [KnownVehicleConcern]
    let safetyResources: [VehicleSafetyResource]
    let ownerResources: [VehicleOwnerResource]
    let sources: [KnowledgeSource]

    var displayName: String {
        "\(year) \(manufacturer) \(model)"
    }

    func matches(
        manufacturer selectedManufacturer: String,
        model selectedModel: String,
        year selectedYear: Int,
        transmission selectedTransmission: String?
    ) -> Bool {
        let makeMatches =
            manufacturer.caseInsensitiveCompare(
                selectedManufacturer
            ) == .orderedSame

        let modelMatches =
            model.caseInsensitiveCompare(
                selectedModel
            ) == .orderedSame

        let yearMatches = year == selectedYear

        let transmissionMatches: Bool

        if let transmission,
           let selectedTransmission,
           !selectedTransmission.isEmpty,
           selectedTransmission != "Not confirmed" {

            transmissionMatches =
                transmission.caseInsensitiveCompare(
                    selectedTransmission
                ) == .orderedSame
        } else {
            transmissionMatches = true
        }

        return makeMatches &&
            modelMatches &&
            yearMatches &&
            transmissionMatches
    }
}

// MARK: - Vehicle Knowledge Database

enum VehicleKnowledgeDatabase {

    static let profiles: [VehicleKnowledgeProfile] = [
        nissan350Z2006Manual
    ]

    static func profile(
        manufacturer: String,
        model: String,
        year: Int,
        transmission: String?
    ) -> VehicleKnowledgeProfile? {
        profiles.first {
            $0.matches(
                manufacturer: manufacturer,
                model: model,
                year: year,
                transmission: transmission
            )
        }
    }

    // MARK: - 2006 Nissan 350Z 6-Speed Manual

    static let nissan350Z2006Manual =
        VehicleKnowledgeProfile(

            manufacturer: "Nissan",
            model: "350Z",
            generation: "Z33",
            market: "United States",

            year: 2006,
            transmission: "6-Speed Manual",
            trim: nil,

            bodyStyle: "Two-door, two-seat sports car",

            engine: EngineSpecification(
                code: "VQ35DE Rev-Up",
                family: "VQ",
                displacementLiters: 3.5,
                cylinders: 6,
                aspiration: "Naturally aspirated",
                fuelType: "Gasoline",
                notes:
                    """
                    The 2006 U.S.-market six-speed manual 350Z used \
                    the higher-revving VQ35DE Rev-Up configuration. \
                    Engine identity should still be confirmed on an \
                    individual vehicle if its replacement history is unknown.
                    """
            ),

            drivetrain: DrivetrainSpecification(
                layout: "Front-engine",
                drivenWheels: "Rear-wheel drive",
                differentialDescription:
                    """
                    Differential equipment can depend on trim and original \
                    configuration. OpenHood should not assume a limited-slip \
                    differential until the trim or vehicle equipment is confirmed.
                    """
            ),

            fluids: [
                FluidSpecification(
                    system: "Engine Oil",
                    recommendedSpecification:
                        "Use the viscosity and quality specification listed in the factory owner’s manual",
                    capacity: nil,
                    notes:
                        """
                        Capacity is intentionally awaiting direct verification \
                        from the correct Nissan publication before OpenHood \
                        displays a numerical value.
                        """,
                    confidence: .factoryVerified
                ),

                FluidSpecification(
                    system: "Engine Coolant",
                    recommendedSpecification:
                        "Nissan-approved coolant specification",
                    capacity: nil,
                    notes:
                        """
                        Total system capacity can vary by configuration and \
                        service procedure. OpenHood must distinguish a drain-and-fill \
                        amount from total dry-system capacity.
                        """,
                    confidence: .factoryVerified
                ),

                FluidSpecification(
                    system: "Manual Transmission Fluid",
                    recommendedSpecification:
                        "Factory-specified manual transmission lubricant",
                    capacity: nil,
                    notes:
                        """
                        The exact lubricant specification and service-fill \
                        quantity will be entered only after verification against \
                        Nissan service information.
                        """,
                    confidence: .factoryVerified
                ),

                FluidSpecification(
                    system: "Differential Fluid",
                    recommendedSpecification:
                        "Factory-specified differential lubricant",
                    capacity: nil,
                    notes:
                        """
                        Differential type and fluid requirements should be \
                        confirmed from the vehicle configuration before service.
                        """,
                    confidence: .factoryVerified
                ),

                FluidSpecification(
                    system: "Brake and Clutch Fluid",
                    recommendedSpecification:
                        "Factory-approved brake-fluid specification",
                    capacity: nil,
                    notes:
                        """
                        Brake and hydraulic-clutch condition should be evaluated \
                        by fluid age, contamination, moisture, leaks, and pedal feel.
                        """,
                    confidence: .factoryVerified
                )
            ],

            tires: [
                TireSpecification(
                    position: "Front",
                    size: "Configuration dependent",
                    wheelSize: "Trim dependent",
                    notes:
                        """
                        The 350Z used staggered tire configurations on many trims. \
                        OpenHood will populate the exact original size after the \
                        selected trim is confirmed.
                        """
                ),

                TireSpecification(
                    position: "Rear",
                    size: "Configuration dependent",
                    wheelSize: "Trim dependent",
                    notes:
                        """
                        Do not assume the front and rear tire sizes match. \
                        Confirm the door-jamb label and installed wheel package.
                        """
                )
            ],

            maintenanceItems: [
                FactoryMaintenanceItem(
                    title: "Engine Oil and Filter",
                    interval:
                        "Follow the applicable Nissan maintenance schedule and operating conditions",
                    notes:
                        """
                        OpenHood will later calculate the next service using \
                        mileage, time, driving conditions, and the owner’s \
                        confirmed service history.
                        """,
                    confidence: .factoryVerified
                ),

                FactoryMaintenanceItem(
                    title: "Tires",
                    interval:
                        "Inspect regularly and at scheduled maintenance visits",
                    notes:
                        """
                        Inspect pressure, tread depth, age, cracking, damage, \
                        uneven wear, and staggered placement.
                        """,
                    confidence: .factoryVerified
                ),

                FactoryMaintenanceItem(
                    title: "Brake System",
                    interval:
                        "Inspect at scheduled maintenance visits and whenever symptoms appear",
                    notes:
                        """
                        Inspect pad thickness, rotor condition, fluid condition, \
                        hoses, leaks, pedal behavior, and parking-brake operation.
                        """,
                    confidence: .factoryVerified
                ),

                FactoryMaintenanceItem(
                    title: "Cooling System",
                    interval:
                        "Inspect routinely and whenever temperature behavior changes",
                    notes:
                        """
                        Inspect coolant level only under safe conditions, along \
                        with leaks, hoses, radiator condition, reservoir behavior, \
                        fan operation, and signs of trapped air.
                        """,
                    confidence: .factoryVerified
                ),

                FactoryMaintenanceItem(
                    title: "Drive Belts and Hoses",
                    interval:
                        "Inspect at scheduled maintenance visits",
                    notes:
                        """
                        Look for cracking, glazing, fraying, contamination, \
                        swelling, softness, leakage, and improper tension.
                        """,
                    confidence: .factoryVerified
                )
            ],

            knownConcerns: [
                KnownVehicleConcern(
                    title: "Oil Consumption Evaluation",
                    affectedConfigurations:
                        "Some VQ35DE Rev-Up-equipped vehicles may warrant closer monitoring",
                    symptoms: [
                        "Oil level drops between services",
                        "Low-oil warning signs",
                        "Oil smoke",
                        "Engine noise associated with low oil",
                        "Unknown previous oil-consumption history"
                    ],
                    inspectionFirst: [
                        "Confirm the oil level correctly",
                        "Inspect for external leakage",
                        "Document mileage and oil added",
                        "Check crankcase-ventilation condition",
                        "Inspect spark plugs when justified",
                        "Perform mechanical testing only when evidence supports it"
                    ],
                    notes:
                        """
                        OpenHood must present this as an inspection concern, \
                        not a diagnosis. Parts should never be replaced merely \
                        because the vehicle uses a Rev-Up engine.
                        """,
                    confidence: .professionallyDocumented
                ),

                KnownVehicleConcern(
                    title: "Uneven Tire Wear",
                    affectedConfigurations:
                        "All configurations, especially modified or misaligned vehicles",
                    symptoms: [
                        "Inner-edge wear",
                        "Rapid tire wear",
                        "Vehicle pulling",
                        "Steering wheel off-center",
                        "Road noise or vibration"
                    ],
                    inspectionFirst: [
                        "Measure tread depth across each tire",
                        "Confirm tire pressure",
                        "Inspect suspension and steering play",
                        "Confirm wheel and tire sizes",
                        "Perform alignment measurements"
                    ],
                    notes:
                        """
                        Tire replacement alone does not correct the cause of \
                        abnormal wear. Alignment and worn-component evidence \
                        should guide the repair.
                        """,
                    confidence: .professionallyDocumented
                ),

                KnownVehicleConcern(
                    title: "Cooling-Fan and Overheating Diagnosis",
                    affectedConfigurations:
                        "Vehicles displaying rising temperature at idle or low speed",
                    symptoms: [
                        "Temperature rises while stationary",
                        "Cooling fans fail to operate",
                        "Coolant reservoir overflows",
                        "Air conditioning performance changes at idle",
                        "Fan fuse or electrical faults"
                    ],
                    inspectionFirst: [
                        "Verify coolant level when safely cold",
                        "Command or observe fan operation",
                        "Inspect fan fuses and electrical supply",
                        "Check for leaks",
                        "Verify thermostat and coolant circulation only if evidence requires it",
                        "Check for trapped air after cooling-system service"
                    ],
                    notes:
                        """
                        An overheating symptom requires testing. OpenHood must \
                        not automatically blame the thermostat, water pump, \
                        radiator, head gasket, or fan assembly.
                        """,
                    confidence: .professionallyDocumented
                )
            ],

            safetyResources: [
                VehicleSafetyResource(
                    title: "VIN-Specific Recall Check",
                    explanation:
                        """
                        Model-year information cannot prove whether a particular \
                        vehicle has an open recall. OpenHood should direct the \
                        owner to perform an official VIN-based recall lookup.
                        """,
                    requiresVINCheck: true,
                    confidence: .governmentVerified
                ),

                VehicleSafetyResource(
                    title: "Airbag Recall Verification",
                    explanation:
                        """
                        Certain older Nissan vehicles have been included in \
                        serious airbag-recall actions. The exact status must \
                        always be checked using the individual VIN.
                        """,
                    requiresVINCheck: true,
                    confidence: .governmentVerified
                )
            ],

            ownerResources: [
                VehicleOwnerResource(
                    title: "2006 Nissan 350Z Owner’s Manual",
                    resourceType: "Owner Manual",
                    organization: "Nissan",
                    notes:
                        """
                        Primary source for operating instructions, warnings, \
                        basic specifications, fluids, capacities, and owner checks.
                        """
                ),

                VehicleOwnerResource(
                    title: "2006 Nissan Warranty Information Booklet",
                    resourceType: "Warranty Publication",
                    organization: "Nissan",
                    notes:
                        """
                        Primary source for original warranty and emissions-related \
                        coverage information.
                        """
                ),

                VehicleOwnerResource(
                    title: "NHTSA Vehicle and Recall Lookup",
                    resourceType: "Safety and Recall Resource",
                    organization:
                        "National Highway Traffic Safety Administration",
                    notes:
                        """
                        Use the VIN lookup for the current recall status of the \
                        individual vehicle.
                        """
                )
            ],

            sources: [
                KnowledgeSource(
                    title: "2006 Nissan 350Z Owner’s Manual",
                    organization: "Nissan",
                    confidence: .factoryVerified,
                    referenceNote:
                        "Official Nissan publication for the 2006 model year"
                ),

                KnowledgeSource(
                    title: "2006 Nissan Warranty Information Booklet",
                    organization: "Nissan",
                    confidence: .factoryVerified,
                    referenceNote:
                        "Official Nissan warranty and emissions publication"
                ),

                KnowledgeSource(
                    title: "2006 Nissan 350Z Vehicle Record",
                    organization:
                        "National Highway Traffic Safety Administration",
                    confidence: .governmentVerified,
                    referenceNote:
                        "Government safety and recall reference"
                )
            ]
        )
}
