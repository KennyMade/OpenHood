import Foundation

// MARK: - Vehicle Region

enum VehicleRegion: String, CaseIterable, Identifiable {
    case japanese = "Japanese"
    case american = "American"
    case european = "European"

    var id: String {
        rawValue
    }
}

enum VehicleCatalogAvailability: Hashable {
    case supported
    case hidden
}

struct VehicleVerifiedConfiguration: Hashable {
    let bodyStyle: String?
    let powertrain: String?
    let drivetrain: String?
    let drivetrainSystem: String?
    let transmission: String?
    let trim: String?

    init(
        bodyStyle: String? = nil,
        powertrain: String? = nil,
        drivetrain: String? = nil,
        drivetrainSystem: String? = nil,
        transmission: String? = nil,
        trim: String? = nil
    ) {
        self.bodyStyle = bodyStyle
        self.powertrain = powertrain
        self.drivetrain = drivetrain
        self.drivetrainSystem = drivetrainSystem
        self.transmission = transmission
        self.trim = trim
    }
}

// MARK: - Vehicle Configuration

struct VehicleYearConfiguration: Identifiable, Hashable {
    let year: Int
    let transmissions: [String]
    let trims: [String]
    let trimCompatibility: [String: [String]]
    let verifiedConfigurations: [VehicleVerifiedConfiguration]
    let availability: VehicleCatalogAvailability

    init(
        year: Int,
        transmissions: [String],
        trims: [String],
        trimCompatibility: [String: [String]] = [:],
        verifiedConfigurations: [VehicleVerifiedConfiguration] = [],
        availability: VehicleCatalogAvailability = .hidden
    ) {
        self.year = year
        self.transmissions = transmissions
        self.trims = trims
        self.trimCompatibility = trimCompatibility
        self.verifiedConfigurations = verifiedConfigurations
        self.availability = availability
    }

    var id: Int {
        year
    }

    func compatibleTrims(for transmission: String) -> [String] {
        if !verifiedConfigurations.isEmpty {
            return matchingConfigurations(transmission: transmission)
                .compactMap(\.trim)
                .uniqueSorted()
        }

        return trimCompatibility[transmission] ?? []
    }

    func matchingConfigurations(
        bodyStyle: String? = nil,
        powertrain: String? = nil,
        drivetrain: String? = nil,
        transmission: String? = nil,
        trim: String? = nil
    ) -> [VehicleVerifiedConfiguration] {
        verifiedConfigurations.filter { configuration in
            (bodyStyle == nil || configuration.bodyStyle == bodyStyle) &&
            (powertrain == nil || configuration.powertrain == powertrain) &&
            (drivetrain == nil || configuration.drivetrain == drivetrain) &&
            (transmission == nil || configuration.transmission == transmission) &&
            (trim == nil || configuration.trim == trim)
        }
    }
}

private extension Sequence where Element == String {
    func uniqueSorted() -> [String] {
        Array(Set(self)).sorted()
    }
}

// MARK: - Vehicle Model

struct VehicleModel: Identifiable, Hashable {
    let id = UUID()
    let name: String
    let productionYearRange: ClosedRange<Int>?
    let configurations: [VehicleYearConfiguration]
    let availability: VehicleCatalogAvailability

    init(
        name: String,
        productionYearRange: ClosedRange<Int>? = nil,
        configurations: [VehicleYearConfiguration] = [],
        availability: VehicleCatalogAvailability = .hidden
    ) {
        self.name = name
        self.productionYearRange = productionYearRange
        self.configurations = configurations
        self.availability = availability
    }

    var productionYears: [Int] {
        guard let productionYearRange else {
            return []
        }

        return productionYearRange.sorted(by: >)
    }

    var verifiedYears: [Int] {
        configurations
            .filter { $0.availability == .supported }
            .map(\.year)
            .sorted(by: >)
    }

    var hasDetailedData: Bool {
        !configurations.isEmpty
    }

    func configuration(
        for year: Int
    ) -> VehicleYearConfiguration? {
        configurations.first {
            $0.year == year
        }
    }

    func verifiedConfiguration(
        for year: Int
    ) -> VehicleYearConfiguration? {
        configurations.first {
            $0.year == year && $0.availability == .supported
        }
    }
}

// MARK: - Vehicle Make

struct VehicleMake: Identifiable, Hashable {
    let id = UUID()
    let name: String
    let region: VehicleRegion
    let models: [VehicleModel]
    let availability: VehicleCatalogAvailability

    init(
        name: String,
        region: VehicleRegion,
        models: [VehicleModel],
        availability: VehicleCatalogAvailability = .hidden
    ) {
        self.name = name
        self.region = region
        self.models = models
        self.availability = availability
    }

    var supportedModels: [VehicleModel] {
        models.filter { $0.availability == .supported }
    }

    var modelCountText: String {
        if supportedModels.isEmpty {
            return "Coming Soon"
        }

        if supportedModels.count == 1 {
            return "1 model"
        }

        return "\(supportedModels.count) models"
    }
}

// MARK: - Vehicle Catalog

struct VehicleCatalog {

    static let makes: [VehicleMake] = [

        // MARK: Japanese

        VehicleMake(
            name: "Nissan",
            region: .japanese,
            models: [
                VehicleModel(
                    name: "350Z",
                    productionYearRange: 2003...2009,
                    configurations: [

                        VehicleYearConfiguration(
                            year: 2009,
                            transmissions: [
                                "6-Speed Manual",
                                "5-Speed Automatic"
                            ],
                            trims: [
                                "Roadster Enthusiast",
                                "Roadster Touring",
                                "Roadster Grand Touring"
                            ]
                        ),

                        VehicleYearConfiguration(
                            year: 2008,
                            transmissions: [
                                "6-Speed Manual",
                                "5-Speed Automatic"
                            ],
                            trims: [
                                "Base",
                                "Enthusiast",
                                "Touring",
                                "Grand Touring",
                                "NISMO"
                            ]
                        ),

                        VehicleYearConfiguration(
                            year: 2007,
                            transmissions: [
                                "6-Speed Manual",
                                "5-Speed Automatic"
                            ],
                            trims: [
                                "Base",
                                "Enthusiast",
                                "Touring",
                                "Grand Touring",
                                "NISMO"
                            ]
                        ),

                        VehicleYearConfiguration(
                            year: 2006,
                            transmissions: [
                                "6-Speed Manual",
                                "5-Speed Automatic"
                            ],
                            trims: [
                                "Base",
                                "Enthusiast",
                                "Touring",
                                "Track",
                                "Grand Touring"
                            ],
                            trimCompatibility: [
                                "6-Speed Manual": [
                                    "Base",
                                    "Enthusiast",
                                    "Touring",
                                    "Grand Touring",
                                    "Track"
                                ],
                                "5-Speed Automatic": [
                                    "Enthusiast",
                                    "Touring",
                                    "Grand Touring"
                                ]
                            ],
                            availability: .supported
                        ),

                        VehicleYearConfiguration(
                            year: 2005,
                            transmissions: [
                                "6-Speed Manual",
                                "5-Speed Automatic"
                            ],
                            trims: [
                                "Base",
                                "Enthusiast",
                                "Performance",
                                "Touring",
                                "Track",
                                "35th Anniversary"
                            ]
                        ),

                        VehicleYearConfiguration(
                            year: 2004,
                            transmissions: [
                                "6-Speed Manual",
                                "5-Speed Automatic"
                            ],
                            trims: [
                                "Base",
                                "Enthusiast",
                                "Performance",
                                "Touring",
                                "Track"
                            ]
                        ),

                        VehicleYearConfiguration(
                            year: 2003,
                            transmissions: [
                                "6-Speed Manual",
                                "5-Speed Automatic"
                            ],
                            trims: [
                                "Base",
                                "Enthusiast",
                                "Performance",
                                "Touring",
                                "Track"
                            ]
                        )
                    ],
                    availability: .supported
                ),

                VehicleModel(name: "370Z"),
                VehicleModel(name: "GT-R (R35)"),
                VehicleModel(name: "Silvia S15"),
                VehicleModel(name: "Sentra"),
                VehicleModel(name: "Altima"),
                VehicleModel(name: "Maxima"),
                VehicleModel(name: "Frontier"),
                VehicleModel(name: "Titan"),
                VehicleModel(name: "Pathfinder"),
                VehicleModel(name: "Rogue"),
                VehicleModel(name: "Murano"),
                VehicleModel(name: "Armada")
            ],
            availability: .supported
        ),

        VehicleMake(
            name: "Toyota",
            region: .japanese,
            models: [
                VehicleModel(name: "Corolla"),
                VehicleModel(name: "Camry"),
                VehicleModel(name: "Tacoma"),
                VehicleModel(
                    name: "4Runner",
                    productionYearRange: 1984...2026,
                    configurations: [
                        VehicleYearConfiguration(
                            year: 2014,
                            transmissions: [
                                "5-Speed Automatic"
                            ],
                            trims: [
                                "SR5",
                                "SR5 Premium",
                                "Trail",
                                "Trail Premium",
                                "Limited"
                            ],
                            trimCompatibility: [
                                "5-Speed Automatic": [
                                    "SR5",
                                    "SR5 Premium",
                                    "Trail",
                                    "Trail Premium",
                                    "Limited"
                                ]
                            ],
                            verifiedConfigurations: [
                                VehicleVerifiedConfiguration(bodyStyle: "SUV", powertrain: "Gasoline V6", drivetrain: "2WD", drivetrainSystem: "Rear-wheel drive", transmission: "5-Speed Automatic", trim: "SR5"),
                                VehicleVerifiedConfiguration(bodyStyle: "SUV", powertrain: "Gasoline V6", drivetrain: "2WD", drivetrainSystem: "Rear-wheel drive", transmission: "5-Speed Automatic", trim: "SR5 Premium"),
                                VehicleVerifiedConfiguration(bodyStyle: "SUV", powertrain: "Gasoline V6", drivetrain: "2WD", drivetrainSystem: "Rear-wheel drive", transmission: "5-Speed Automatic", trim: "Limited"),
                                VehicleVerifiedConfiguration(bodyStyle: "SUV", powertrain: "Gasoline V6", drivetrain: "4WD", drivetrainSystem: "Part-time four-wheel drive", transmission: "5-Speed Automatic", trim: "SR5"),
                                VehicleVerifiedConfiguration(bodyStyle: "SUV", powertrain: "Gasoline V6", drivetrain: "4WD", drivetrainSystem: "Part-time four-wheel drive", transmission: "5-Speed Automatic", trim: "SR5 Premium"),
                                VehicleVerifiedConfiguration(bodyStyle: "SUV", powertrain: "Gasoline V6", drivetrain: "4WD", drivetrainSystem: "Part-time four-wheel drive", transmission: "5-Speed Automatic", trim: "Trail"),
                                VehicleVerifiedConfiguration(bodyStyle: "SUV", powertrain: "Gasoline V6", drivetrain: "4WD", drivetrainSystem: "Part-time four-wheel drive", transmission: "5-Speed Automatic", trim: "Trail Premium"),
                                VehicleVerifiedConfiguration(bodyStyle: "SUV", powertrain: "Gasoline V6", drivetrain: "4WD", drivetrainSystem: "Full-time multi-mode four-wheel drive", transmission: "5-Speed Automatic", trim: "Limited")
                            ],
                            availability: .supported
                        )
                    ],
                    availability: .supported
                ),
                VehicleModel(name: "Tundra"),
                VehicleModel(name: "GR86"),
                VehicleModel(name: "Supra Mk4"),
                VehicleModel(name: "Supra A90"),
                VehicleModel(name: "GR Corolla"),
                VehicleModel(name: "Prius"),
                VehicleModel(name: "RAV4"),
                VehicleModel(name: "Highlander"),
                VehicleModel(name: "Land Cruiser")
            ],
            availability: .supported
        ),

        VehicleMake(
            name: "Honda",
            region: .japanese,
            models: [
                VehicleModel(
                    name: "Civic",
                    productionYearRange: 1973...2026,
                    configurations: [
                        VehicleYearConfiguration(
                            year: 2013,
                            transmissions: [
                                "5-Speed Manual",
                                "5-Speed Automatic",
                                "6-Speed Manual",
                                "CVT"
                            ],
                            trims: [
                                "LX",
                                "EX",
                                "EX-L",
                                "HF",
                                "Hybrid",
                                "Natural Gas",
                                "Si"
                            ],
                            verifiedConfigurations: [
                                VehicleVerifiedConfiguration(bodyStyle: "Sedan", powertrain: "Gasoline", transmission: "5-Speed Manual", trim: "LX"),
                                VehicleVerifiedConfiguration(bodyStyle: "Sedan", powertrain: "Gasoline", transmission: "5-Speed Automatic", trim: "LX"),
                                VehicleVerifiedConfiguration(bodyStyle: "Sedan", powertrain: "Gasoline", transmission: "5-Speed Automatic", trim: "EX"),
                                VehicleVerifiedConfiguration(bodyStyle: "Sedan", powertrain: "Gasoline", transmission: "5-Speed Automatic", trim: "EX-L"),
                                VehicleVerifiedConfiguration(bodyStyle: "Sedan", powertrain: "Gasoline", transmission: "5-Speed Automatic", trim: "HF"),
                                VehicleVerifiedConfiguration(bodyStyle: "Sedan", powertrain: "Gasoline", transmission: "6-Speed Manual", trim: "Si"),
                                VehicleVerifiedConfiguration(bodyStyle: "Sedan", powertrain: "Hybrid", transmission: "CVT", trim: "Hybrid"),
                                VehicleVerifiedConfiguration(bodyStyle: "Sedan", powertrain: "Natural Gas", transmission: "5-Speed Automatic", trim: "Natural Gas"),
                                VehicleVerifiedConfiguration(bodyStyle: "Coupe", powertrain: "Gasoline", transmission: "5-Speed Manual", trim: "LX"),
                                VehicleVerifiedConfiguration(bodyStyle: "Coupe", powertrain: "Gasoline", transmission: "5-Speed Manual", trim: "EX"),
                                VehicleVerifiedConfiguration(bodyStyle: "Coupe", powertrain: "Gasoline", transmission: "5-Speed Automatic", trim: "LX"),
                                VehicleVerifiedConfiguration(bodyStyle: "Coupe", powertrain: "Gasoline", transmission: "5-Speed Automatic", trim: "EX"),
                                VehicleVerifiedConfiguration(bodyStyle: "Coupe", powertrain: "Gasoline", transmission: "5-Speed Automatic", trim: "EX-L"),
                                VehicleVerifiedConfiguration(bodyStyle: "Coupe", powertrain: "Gasoline", transmission: "6-Speed Manual", trim: "Si")
                            ],
                            availability: .supported
                        )
                    ],
                    availability: .supported
                ),
                VehicleModel(name: "Civic Type R"),
                VehicleModel(name: "S2000"),
                VehicleModel(name: "NSX")
            ],
            availability: .supported
        ),

        VehicleMake(
            name: "Mazda",
            region: .japanese,
            models: []
        ),

        VehicleMake(
            name: "Subaru",
            region: .japanese,
            models: []
        ),

        VehicleMake(
            name: "Mitsubishi",
            region: .japanese,
            models: []
        ),

        // MARK: American

        VehicleMake(
            name: "Ford",
            region: .american,
            models: []
        ),

        VehicleMake(
            name: "Chevrolet",
            region: .american,
            models: []
        ),

        VehicleMake(
            name: "Dodge",
            region: .american,
            models: []
        ),

        // MARK: European

        VehicleMake(
            name: "BMW",
            region: .european,
            models: []
        ),

        VehicleMake(
            name: "Audi",
            region: .european,
            models: []
        ),

        VehicleMake(
            name: "Mercedes-Benz",
            region: .european,
            models: []
        ),

        VehicleMake(
            name: "Volkswagen",
            region: .european,
            models: []
        ),

        VehicleMake(
            name: "Porsche",
            region: .european,
            models: []
        )
    ]

    // MARK: - Helpers

    static func makes(
        in region: VehicleRegion
    ) -> [VehicleMake] {
        makes.filter {
            $0.region == region && $0.availability == .supported
        }
    }

    static func make(
        named name: String
    ) -> VehicleMake? {
        makes.first {
            $0.name.caseInsensitiveCompare(name) == .orderedSame
        }
    }

    static func models(
        for makeName: String
    ) -> [VehicleModel] {
        make(named: makeName)?.supportedModels ?? []
    }

    static func model(
        makeName: String,
        modelName: String
    ) -> VehicleModel? {
        make(named: makeName)?
            .models
            .first {
                $0.name.caseInsensitiveCompare(modelName) == .orderedSame
            }
    }

    static func configuration(
        makeName: String,
        modelName: String,
        year: Int
    ) -> VehicleYearConfiguration? {
        model(
            makeName: makeName,
            modelName: modelName
        )?
        .configuration(for: year)
    }

    static func verifiedConfiguration(
        makeName: String,
        modelName: String,
        year: Int
    ) -> VehicleYearConfiguration? {
        model(
            makeName: makeName,
            modelName: modelName
        )?
        .verifiedConfiguration(for: year)
    }
}
