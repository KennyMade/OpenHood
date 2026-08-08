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

// MARK: - Catalog Auto-Fill

extension VehicleYearConfiguration {
    /// Fields that every verified configuration for this year agrees on.
    /// A field is left nil when the year has no verified configurations, or
    /// when configurations disagree (e.g. multiple trims), since no single
    /// value could be silently filled in with confidence.
    var autoFillableConfiguration: VehicleVerifiedConfiguration {
        VehicleVerifiedConfiguration(
            bodyStyle: unambiguousValue(for: \.bodyStyle),
            powertrain: unambiguousValue(for: \.powertrain),
            drivetrain: unambiguousValue(for: \.drivetrain),
            drivetrainSystem: unambiguousValue(for: \.drivetrainSystem),
            transmission: unambiguousValue(for: \.transmission),
            trim: unambiguousValue(for: \.trim)
        )
    }

    private func unambiguousValue(
        for keyPath: KeyPath<VehicleVerifiedConfiguration, String?>
    ) -> String? {
        let values = Set(verifiedConfigurations.compactMap { $0[keyPath: keyPath] })
        return values.count == 1 ? values.first : nil
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

                VehicleModel(name: "370Z", availability: .supported),
                VehicleModel(name: "GT-R (R35)", availability: .supported),
                VehicleModel(name: "Silvia S15", availability: .supported),
                VehicleModel(name: "Sentra", availability: .supported),
                VehicleModel(name: "Altima", availability: .supported),
                VehicleModel(name: "Maxima", availability: .supported),
                VehicleModel(name: "Frontier", availability: .supported),
                VehicleModel(name: "Titan", availability: .supported),
                VehicleModel(name: "Pathfinder", availability: .supported),
                VehicleModel(name: "Rogue", availability: .supported),
                VehicleModel(name: "Murano", availability: .supported),
                VehicleModel(name: "Armada", availability: .supported),
                VehicleModel(name: "Kicks", availability: .supported),
                VehicleModel(name: "Versa", availability: .supported),
                VehicleModel(name: "Xterra", availability: .supported)
            ],
            availability: .supported
        ),

        VehicleMake(
            name: "Toyota",
            region: .japanese,
            models: [
                VehicleModel(name: "Corolla", availability: .supported),
                VehicleModel(name: "Camry", availability: .supported),
                VehicleModel(name: "Tacoma", availability: .supported),
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
                VehicleModel(name: "Tundra", availability: .supported),
                VehicleModel(name: "GR86", availability: .supported),
                VehicleModel(name: "Supra Mk4", availability: .supported),
                VehicleModel(name: "Supra A90", availability: .supported),
                VehicleModel(name: "GR Corolla", availability: .supported),
                VehicleModel(name: "Prius", availability: .supported),
                VehicleModel(name: "RAV4", availability: .supported),
                VehicleModel(name: "Highlander", availability: .supported),
                VehicleModel(name: "Land Cruiser", availability: .supported),
                VehicleModel(name: "Sienna", availability: .supported),
                VehicleModel(name: "Sequoia", availability: .supported),
                VehicleModel(name: "Avalon", availability: .supported),
                VehicleModel(name: "MR2", availability: .supported)
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
                VehicleModel(name: "Civic Type R", availability: .supported),
                VehicleModel(name: "S2000", availability: .supported),
                VehicleModel(name: "NSX", availability: .supported),
                VehicleModel(name: "Accord", availability: .supported),
                VehicleModel(name: "CR-V", availability: .supported),
                VehicleModel(name: "Pilot", availability: .supported),
                VehicleModel(name: "Odyssey", availability: .supported),
                VehicleModel(name: "Fit", availability: .supported),
                VehicleModel(name: "HR-V", availability: .supported),
                VehicleModel(name: "Ridgeline", availability: .supported)
            ],
            availability: .supported
        ),

        VehicleMake(
            name: "Mazda",
            region: .japanese,
            models: [
                VehicleModel(name: "MX-5 Miata", availability: .supported),
                VehicleModel(name: "Mazda3", availability: .supported),
                VehicleModel(name: "Mazda6", availability: .supported),
                VehicleModel(name: "CX-5", availability: .supported),
                VehicleModel(name: "CX-9", availability: .supported),
                VehicleModel(name: "CX-30", availability: .supported),
                VehicleModel(name: "RX-7", availability: .supported),
                VehicleModel(name: "RX-8", availability: .supported)
            ],
            availability: .supported
        ),

        VehicleMake(
            name: "Subaru",
            region: .japanese,
            models: [
                VehicleModel(name: "Impreza", availability: .supported),
                VehicleModel(name: "WRX", availability: .supported),
                VehicleModel(name: "WRX STI", availability: .supported),
                VehicleModel(name: "Outback", availability: .supported),
                VehicleModel(name: "Forester", availability: .supported),
                VehicleModel(name: "Crosstrek", availability: .supported),
                VehicleModel(name: "Legacy", availability: .supported),
                VehicleModel(name: "BRZ", availability: .supported)
            ],
            availability: .supported
        ),

        VehicleMake(
            name: "Mitsubishi",
            region: .japanese,
            models: [
                VehicleModel(name: "Lancer", availability: .supported),
                VehicleModel(name: "Lancer Evolution", availability: .supported),
                VehicleModel(name: "Eclipse", availability: .supported),
                VehicleModel(name: "Eclipse Cross", availability: .supported),
                VehicleModel(name: "Outlander", availability: .supported),
                VehicleModel(name: "Mirage", availability: .supported)
            ],
            availability: .supported
        ),

        // MARK: American

        VehicleMake(
            name: "Ford",
            region: .american,
            models: [
                VehicleModel(name: "Mustang", availability: .supported),
                VehicleModel(name: "F-150", availability: .supported),
                VehicleModel(name: "Explorer", availability: .supported),
                VehicleModel(name: "Escape", availability: .supported),
                VehicleModel(name: "Bronco", availability: .supported),
                VehicleModel(name: "Focus", availability: .supported),
                VehicleModel(name: "Fusion", availability: .supported),
                VehicleModel(name: "Edge", availability: .supported),
                VehicleModel(name: "Ranger", availability: .supported),
                VehicleModel(name: "Expedition", availability: .supported)
            ],
            availability: .supported
        ),

        VehicleMake(
            name: "Chevrolet",
            region: .american,
            models: [
                VehicleModel(name: "Camaro", availability: .supported),
                VehicleModel(name: "Corvette", availability: .supported),
                VehicleModel(name: "Silverado", availability: .supported),
                VehicleModel(name: "Malibu", availability: .supported),
                VehicleModel(name: "Equinox", availability: .supported),
                VehicleModel(name: "Tahoe", availability: .supported),
                VehicleModel(name: "Impala", availability: .supported),
                VehicleModel(name: "Cruze", availability: .supported),
                VehicleModel(name: "Suburban", availability: .supported),
                VehicleModel(name: "Colorado", availability: .supported)
            ],
            availability: .supported
        ),

        VehicleMake(
            name: "Dodge",
            region: .american,
            models: [
                VehicleModel(name: "Charger", availability: .supported),
                VehicleModel(name: "Challenger", availability: .supported),
                VehicleModel(name: "Durango", availability: .supported),
                VehicleModel(name: "Journey", availability: .supported),
                VehicleModel(name: "Viper", availability: .supported),
                VehicleModel(name: "Dart", availability: .supported)
            ],
            availability: .supported
        ),

        VehicleMake(
            name: "Ram",
            region: .american,
            models: [
                VehicleModel(name: "1500", availability: .supported),
                VehicleModel(name: "2500", availability: .supported),
                VehicleModel(name: "3500", availability: .supported)
            ],
            availability: .supported
        ),

        VehicleMake(
            name: "Jeep",
            region: .american,
            models: [
                VehicleModel(name: "Wrangler", availability: .supported),
                VehicleModel(name: "Grand Cherokee", availability: .supported),
                VehicleModel(name: "Cherokee", availability: .supported),
                VehicleModel(name: "Compass", availability: .supported),
                VehicleModel(name: "Gladiator", availability: .supported)
            ],
            availability: .supported
        ),

        VehicleMake(
            name: "GMC",
            region: .american,
            models: [
                VehicleModel(name: "Sierra", availability: .supported),
                VehicleModel(name: "Yukon", availability: .supported),
                VehicleModel(name: "Acadia", availability: .supported),
                VehicleModel(name: "Terrain", availability: .supported)
            ],
            availability: .supported
        ),

        // MARK: European

        VehicleMake(
            name: "BMW",
            region: .european,
            models: [
                VehicleModel(name: "3 Series", availability: .supported),
                VehicleModel(name: "5 Series", availability: .supported),
                VehicleModel(name: "X3", availability: .supported),
                VehicleModel(name: "X5", availability: .supported),
                VehicleModel(name: "M3", availability: .supported),
                VehicleModel(name: "M5", availability: .supported),
                VehicleModel(name: "1 Series", availability: .supported),
                VehicleModel(name: "Z4", availability: .supported)
            ],
            availability: .supported
        ),

        VehicleMake(
            name: "Audi",
            region: .european,
            models: [
                VehicleModel(name: "A4", availability: .supported),
                VehicleModel(name: "A6", availability: .supported),
                VehicleModel(name: "Q5", availability: .supported),
                VehicleModel(name: "Q7", availability: .supported),
                VehicleModel(name: "S4", availability: .supported),
                VehicleModel(name: "TT", availability: .supported),
                VehicleModel(name: "R8", availability: .supported),
                VehicleModel(name: "A3", availability: .supported)
            ],
            availability: .supported
        ),

        VehicleMake(
            name: "Mercedes-Benz",
            region: .european,
            models: [
                VehicleModel(name: "C-Class", availability: .supported),
                VehicleModel(name: "E-Class", availability: .supported),
                VehicleModel(name: "GLC", availability: .supported),
                VehicleModel(name: "GLE", availability: .supported),
                VehicleModel(name: "S-Class", availability: .supported),
                VehicleModel(name: "AMG GT", availability: .supported)
            ],
            availability: .supported
        ),

        VehicleMake(
            name: "Volkswagen",
            region: .european,
            models: [
                VehicleModel(name: "Golf", availability: .supported),
                VehicleModel(name: "GTI", availability: .supported),
                VehicleModel(name: "Jetta", availability: .supported),
                VehicleModel(name: "Passat", availability: .supported),
                VehicleModel(name: "Tiguan", availability: .supported),
                VehicleModel(name: "Atlas", availability: .supported),
                VehicleModel(name: "Beetle", availability: .supported)
            ],
            availability: .supported
        ),

        VehicleMake(
            name: "Porsche",
            region: .european,
            models: [
                VehicleModel(name: "911", availability: .supported),
                VehicleModel(name: "Cayman", availability: .supported),
                VehicleModel(name: "Boxster", availability: .supported),
                VehicleModel(name: "Macan", availability: .supported),
                VehicleModel(name: "Cayenne", availability: .supported),
                VehicleModel(name: "Panamera", availability: .supported),
                VehicleModel(name: "Taycan", availability: .supported)
            ],
            availability: .supported
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

    /// The subset of that year's configuration OpenHood can fill in without
    /// asking the owner, or nil if the catalog has no verified data for the
    /// exact make/model/year.
    static func autoFillConfiguration(
        makeName: String,
        modelName: String,
        year: Int
    ) -> VehicleVerifiedConfiguration? {
        verifiedConfiguration(
            makeName: makeName,
            modelName: modelName,
            year: year
        )?
        .autoFillableConfiguration
    }
}

// MARK: - Vehicle Fact Sheet (Learn tab: "Find a Fact")

/// Real, researched fluid/capacity/tire-pressure data for the vehicles
/// OpenHood has genuine verified configuration data for (350Z, 4Runner,
/// Civic — see the VehicleCatalog above). Cross-checked against multiple
/// independent sources (owner's-manual excerpts, oil-change reference
/// sites, tire-pressure reference sites) on 2026-08-08. Every fact card
/// built from this carries a "confirm against your door jamb sticker or
/// owner's manual" note, since exact figures can shift by trim/options
/// (e.g. a 4Runner with a rear seat heater takes more coolant) — same
/// hedge-honestly discipline as the Something Happened diagnostic
/// content, applied to fluid specs instead of symptom causes.
struct VehicleFactSheet {
    let make: String
    let model: String
    let engineOilType: String
    let engineOilCapacity: String
    let coolantType: String
    let coolantCapacity: String?
    let tirePressureFront: String
    let tirePressureRear: String
    let notes: String
}

extension VehicleFactSheet {
    static let all: [VehicleFactSheet] = [
        VehicleFactSheet(
            make: "Nissan",
            model: "350Z",
            engineOilType: "5W-30",
            engineOilCapacity: "Roughly 5.2 quarts with a filter change",
            coolantType: "Nissan Long Life Antifreeze/Coolant, or an equivalent",
            coolantCapacity: "Roughly 8.7 liters (about 9.2 quarts)",
            tirePressureFront: "35 PSI",
            tirePressureRear: "35 PSI",
            notes: "These figures are for the 3.5L VQ35HR engine used in the 2009 350Z. Always confirm against the sticker inside your driver's door jamb or your owner's manual before servicing — trim and tire size can shift the exact number."
        ),
        VehicleFactSheet(
            make: "Toyota",
            model: "4Runner",
            engineOilType: "0W-20 synthetic (5W-20 is an acceptable substitute if 0W-20 isn't available)",
            engineOilCapacity: "Roughly 6.4 quarts with a filter change",
            coolantType: "Toyota Super Long Life Coolant (red), or an equivalent ethylene-glycol coolant",
            coolantCapacity: "Roughly 10–11 quarts, depending on whether your 4Runner has a rear seat heater",
            tirePressureFront: "32 PSI",
            tirePressureRear: "32 PSI",
            notes: "These figures are for the 4.0L V6 used in the 2014 4Runner. Always confirm against the sticker inside your driver's door jamb or your owner's manual before servicing."
        ),
        VehicleFactSheet(
            make: "Honda",
            model: "Civic",
            engineOilType: "0W-20 full synthetic",
            engineOilCapacity: "Roughly 3.9 quarts with a filter change",
            coolantType: "Honda Type 2 coolant (blue)",
            coolantCapacity: nil,
            tirePressureFront: "33 PSI",
            tirePressureRear: "33 PSI",
            notes: "These figures are for the 1.8L 4-cylinder gasoline engine used in most 2013 Civic trims — the Hybrid and Natural Gas versions differ. OpenHood could not independently confirm the exact coolant capacity for this engine, so that figure isn't shown; check your owner's manual for it. Always confirm every figure against the sticker inside your driver's door jamb before servicing."
        ),
        VehicleFactSheet(
            make: "Toyota",
            model: "RAV4",
            engineOilType: "0W-16 full synthetic (some references list 0W-20 as an acceptable substitute)",
            engineOilCapacity: "Roughly 4.8 quarts with a filter change",
            coolantType: "Toyota Super Long Life Coolant (pink), or an equivalent",
            coolantCapacity: "Roughly 7.3 quarts",
            tirePressureFront: "33 PSI",
            tirePressureRear: "33 PSI",
            notes: "These figures are for the 2.5L 4-cylinder (A25A-FKS) used in the 2019 RAV4. Tire pressure commonly ranges 33–36 PSI by trim and tire size — always confirm against the sticker inside your driver's door jamb or your owner's manual before servicing."
        ),
        VehicleFactSheet(
            make: "Honda",
            model: "CR-V",
            engineOilType: "0W-20 full synthetic",
            engineOilCapacity: "Roughly 3.7 quarts with a filter change",
            coolantType: "Honda Long-Life Antifreeze/Coolant Type 2 (blue)",
            coolantCapacity: nil,
            tirePressureFront: "32 PSI",
            tirePressureRear: "32 PSI",
            notes: "These figures are for the 1.5L turbocharged 4-cylinder used in most 2019 CR-V trims. OpenHood could not independently confirm the exact coolant capacity for this engine, so that figure isn't shown; check your owner's manual for it. Always confirm every figure against the sticker inside your driver's door jamb before servicing."
        ),
        VehicleFactSheet(
            make: "Toyota",
            model: "Camry",
            engineOilType: "0W-16 full synthetic",
            engineOilCapacity: "Roughly 4.8 quarts with a filter change",
            coolantType: "Toyota Super Long Life Coolant (pink/red POAT formula), or an equivalent",
            coolantCapacity: "Roughly 6.4 quarts",
            tirePressureFront: "35 PSI",
            tirePressureRear: "35 PSI",
            notes: "These figures are for the 2.5L 4-cylinder used in the 2019 Camry — hybrid and V6 versions differ. Always confirm against the sticker inside your driver's door jamb or your owner's manual before servicing."
        ),
        VehicleFactSheet(
            make: "Honda",
            model: "Accord",
            engineOilType: "0W-20 full synthetic",
            engineOilCapacity: "Roughly 3.4 quarts with a filter change",
            coolantType: "Honda Long-Life Antifreeze/Coolant Type 2 (blue)",
            coolantCapacity: "Roughly 6.3 quarts (CVT models)",
            tirePressureFront: "32 PSI",
            tirePressureRear: "32 PSI",
            notes: "These figures are for the 1.5L turbocharged 4-cylinder used in most 2019 Accord trims — the 2.0L turbo and hybrid versions differ. Tire pressure commonly ranges 32–35 PSI by trim. Always confirm against the sticker inside your driver's door jamb or your owner's manual before servicing."
        ),
        VehicleFactSheet(
            make: "Ford",
            model: "F-150",
            engineOilType: "Motorcraft 5W-20 synthetic blend",
            engineOilCapacity: "Roughly 8.9 quarts with a filter change",
            coolantType: "Motorcraft Orange concentrated OAT antifreeze/coolant, or an equivalent",
            coolantCapacity: nil,
            tirePressureFront: "35 PSI",
            tirePressureRear: "35 PSI",
            notes: "These figures are for the 5.0L V8 used in the 2019 F-150 — other engine options (2.7L/3.5L EcoBoost, 3.3L V6) differ. Trucks with the Heavy-Duty Payload Package call for 40 PSI front and rear instead. OpenHood could not independently confirm the exact coolant capacity for this engine, so that figure isn't shown. Always confirm every figure against the sticker inside your driver's door jamb before servicing."
        ),
        VehicleFactSheet(
            make: "Chevrolet",
            model: "Silverado",
            engineOilType: "0W-20 full synthetic",
            engineOilCapacity: "Roughly 8 quarts with a filter change",
            coolantType: "Dex-Cool orange OAT coolant, or an equivalent",
            coolantCapacity: "Roughly 17.4 quarts (dry fill, mixed 50/50 with distilled water)",
            tirePressureFront: "32 PSI",
            tirePressureRear: "35 PSI",
            notes: "These figures are for the 5.3L V8 used in the 2019 Silverado 1500 — other engine options differ. Always confirm against the sticker inside your driver's door jamb or your owner's manual before servicing."
        ),
        VehicleFactSheet(
            make: "Toyota",
            model: "Corolla",
            engineOilType: "0W-20 full synthetic",
            engineOilCapacity: "Roughly 4.4 quarts with a filter change",
            coolantType: "Toyota Super Long Life Coolant, or an equivalent",
            coolantCapacity: nil,
            tirePressureFront: "35 PSI",
            tirePressureRear: "33 PSI",
            notes: "These figures are for the 1.8L 4-cylinder used in the 2019 Corolla — the hybrid version differs. OpenHood could not independently confirm the exact coolant capacity for this engine, so that figure isn't shown. Always confirm every figure against the sticker inside your driver's door jamb before servicing."
        ),
        VehicleFactSheet(
            make: "Nissan",
            model: "Rogue",
            engineOilType: "0W-20 full synthetic",
            engineOilCapacity: "Roughly 4.9 quarts with a filter change",
            coolantType: "Nissan Long Life Antifreeze/Coolant (green), or an equivalent",
            coolantCapacity: "Roughly 6.5 quarts",
            tirePressureFront: "33 PSI",
            tirePressureRear: "33 PSI",
            notes: "These figures are for the 2.5L 4-cylinder used in the 2019 Rogue. Always confirm against the sticker inside your driver's door jamb or your owner's manual before servicing."
        ),
        VehicleFactSheet(
            make: "Ram",
            model: "1500",
            engineOilType: "5W-20 full synthetic",
            engineOilCapacity: "Roughly 7 quarts with a filter change",
            coolantType: "Mopar MS-90032 OAT coolant, or an equivalent",
            coolantCapacity: nil,
            tirePressureFront: "35 PSI",
            tirePressureRear: "35 PSI",
            notes: "These figures are for the 5.7L HEMI V8 used in the 2019 Ram 1500 — other engine options (3.6L V6, eTorque) differ. Tire pressure commonly ranges 32–36 PSI by trim and payload package. OpenHood could not independently confirm the exact coolant capacity for this engine, so that figure isn't shown. Always confirm every figure against the sticker inside your driver's door jamb before servicing."
        ),
        VehicleFactSheet(
            make: "Jeep",
            model: "Wrangler",
            engineOilType: "0W-20 full synthetic",
            engineOilCapacity: "Roughly 5 quarts with a filter change",
            coolantType: "Mopar OAT coolant (typically orange, 5-year/100,000-mile formula) — not independently confirmed this pass",
            coolantCapacity: "Roughly 10.7 quarts",
            tirePressureFront: "37 PSI",
            tirePressureRear: "37 PSI",
            notes: "These figures are for the 3.6L V6 used in the 2019 Wrangler JL. Coolant type and tire pressure were not independently confirmed with full confidence for this pass — both vary meaningfully with the Wrangler's optional tire sizes. Always confirm against the sticker inside your driver's door jamb or your owner's manual before servicing."
        )
    ]

    static func lookup(make: String, model: String) -> VehicleFactSheet? {
        all.first {
            $0.make.caseInsensitiveCompare(make) == .orderedSame &&
            $0.model.caseInsensitiveCompare(model) == .orderedSame
        }
    }
}

// MARK: - Maintenance Guide (Learn tab: "Show Me How")

/// Universal, vehicle-independent basic-maintenance procedures — safe to
/// write without per-vehicle research since the steps (checking a
/// dipstick, reading a tire gauge, connecting jumper cables) are the same
/// well-established, non-controversial process across virtually every
/// gasoline passenger vehicle. Same tier as the general disclaimers
/// already in the app: reviewed general procedure, not vehicle-specific
/// guidance.
struct MaintenanceGuide: Identifiable {
    let id = UUID()
    let title: String
    let icon: String
    let estimatedTime: String
    let steps: [String]
    let safetyNote: String?
}

extension MaintenanceGuide {
    static let all: [MaintenanceGuide] = [
        MaintenanceGuide(
            title: "Check your engine oil level",
            icon: "drop.fill",
            estimatedTime: "5 minutes",
            steps: [
                "Park on level ground and let the engine sit for at least 5–10 minutes after driving so the oil can settle back into the pan.",
                "Open the hood and locate the oil dipstick — it usually has a brightly colored handle, often yellow or orange.",
                "Pull the dipstick out, wipe it clean with a rag or paper towel, then push it all the way back in.",
                "Pull it out again and check where the oil sits relative to the two marks or the hatched area near the tip.",
                "If the level is below the low mark, add oil a little at a time through the oil fill cap, rechecking after each addition — it's easy to overfill."
            ],
            safetyNote: "Wait for the engine to cool before touching anything under the hood — components can stay hot for a while after driving."
        ),
        MaintenanceGuide(
            title: "Check your tire pressure",
            icon: "gauge.with.needle.fill",
            estimatedTime: "10 minutes",
            steps: [
                "Check tires when they're cold — ideally before driving, or at least 3 hours after the vehicle has been driven.",
                "Find your vehicle's recommended pressure on the sticker inside the driver's door jamb, not the number printed on the tire itself (that's the tire's maximum, not the recommended setting).",
                "Remove the valve cap and press a tire gauge firmly onto the valve stem until the hissing stops.",
                "Read the pressure and compare it to the recommended number.",
                "Add air in short bursts if low, or press the small pin in the gauge tip to release air if too high, rechecking after each adjustment.",
                "Don't forget the spare tire, if your vehicle has one — it's often overlooked and can be critically low."
            ],
            safetyNote: nil
        ),
        MaintenanceGuide(
            title: "Jump-start a dead battery",
            icon: "bolt.fill",
            estimatedTime: "10–15 minutes",
            steps: [
                "Position the working vehicle close enough for the cables to reach, but not touching either vehicle.",
                "Turn off both vehicles and engage the parking brake on both.",
                "Connect the red (positive) clamp to the dead battery's positive terminal, then the other red clamp to the working battery's positive terminal.",
                "Connect the black (negative) clamp to the working battery's negative terminal, then the other black clamp to an unpainted metal surface on the dead vehicle's engine block — not to the dead battery itself.",
                "Start the working vehicle and let it run for a few minutes.",
                "Try starting the dead vehicle. If it starts, let both run for several minutes before disconnecting the cables in the reverse order you connected them.",
                "If it doesn't start after a couple of tries, the battery or another component may need a mechanic's attention rather than another jump."
            ],
            safetyNote: "Car batteries contain acid and can produce explosive gas. Keep sparks and flames away, don't lean over the battery while connecting cables, and stop if you smell burning or see smoke."
        )
    ]
}
