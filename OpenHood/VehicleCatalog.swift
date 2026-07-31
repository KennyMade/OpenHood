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

// MARK: - Vehicle Configuration

struct VehicleYearConfiguration: Identifiable, Hashable {
    let year: Int
    let transmissions: [String]
    let trims: [String]

    var id: Int {
        year
    }
}

// MARK: - Vehicle Model

struct VehicleModel: Identifiable, Hashable {
    let id = UUID()
    let name: String
    let configurations: [VehicleYearConfiguration]

    init(
        name: String,
        configurations: [VehicleYearConfiguration] = []
    ) {
        self.name = name
        self.configurations = configurations
    }

    var supportedYears: [Int] {
        configurations
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
}

// MARK: - Vehicle Make

struct VehicleMake: Identifiable, Hashable {
    let id = UUID()
    let name: String
    let region: VehicleRegion
    let models: [VehicleModel]

    var modelCountText: String {
        if models.isEmpty {
            return "Coming Soon"
        }

        if models.count == 1 {
            return "1 model"
        }

        return "\(models.count) models"
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
                            ]
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
                    ]
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
            ]
        ),

        VehicleMake(
            name: "Toyota",
            region: .japanese,
            models: [
                VehicleModel(name: "Corolla"),
                VehicleModel(name: "Camry"),
                VehicleModel(name: "Tacoma"),
                VehicleModel(name: "4Runner"),
                VehicleModel(name: "Tundra"),
                VehicleModel(name: "GR86"),
                VehicleModel(name: "Supra Mk4"),
                VehicleModel(name: "Supra A90"),
                VehicleModel(name: "GR Corolla"),
                VehicleModel(name: "Prius"),
                VehicleModel(name: "RAV4"),
                VehicleModel(name: "Highlander"),
                VehicleModel(name: "Land Cruiser")
            ]
        ),

        VehicleMake(
            name: "Honda",
            region: .japanese,
            models: [
                VehicleModel(name: "Civic"),
                VehicleModel(name: "Civic Type R"),
                VehicleModel(name: "S2000"),
                VehicleModel(name: "NSX")
            ]
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
            $0.region == region
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
        make(named: makeName)?.models ?? []
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
}
