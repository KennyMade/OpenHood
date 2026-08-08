import SwiftUI
import Combine

// MARK: - Vehicle Onboarding Data

enum VehicleProfileVerification: String, Codable {
    case verified
    case basicUnverified
}

final class VehicleOnboardingData: ObservableObject {
    @Published var manufacturer = ""
    @Published var model = ""
    @Published var year = ""
    @Published var bodyStyle = ""
    @Published var powertrain = ""
    @Published var drivetrain = ""
    @Published var drivetrainSystem = ""
    @Published var transmission = ""
    @Published var trim = ""
    @Published var mileage = ""
    @Published var profileVerification: VehicleProfileVerification = .verified

    var vehicleName: String {
        let pieces = [year, manufacturer, model]
            .filter { !$0.isEmpty }

        if pieces.isEmpty {
            return "Your Vehicle"
        }

        return pieces.joined(separator: " ")
    }

    var transmissionDisplay: String {
        transmission.isEmpty ? "Finish setting up your car" : transmission
    }

    var mileageDisplay: String {
        guard !mileage.isEmpty else {
            return "Not entered"
        }

        return "\(mileage) mi"
    }
}

// MARK: - Welcome

struct ContentView: View {
    @StateObject private var vehicle = VehicleOnboardingData()

    var body: some View {
        NavigationStack {
            WelcomeView()
        }
        .environmentObject(vehicle)
    }
}

struct WelcomeView: View {
    var body: some View {
        VStack(spacing: 20) {
            OnboardingProgressView(step: 1)

            Spacer()

            ZStack {
                Circle()
                    .fill(Color.primary.opacity(0.08))
                    .frame(width: 126, height: 126)

                Image(systemName: "car.side.fill")
                    .font(.system(size: 62))
            }

            Text("OpenHood")
                .font(.largeTitle)
                .fontWeight(.bold)

            Text("Get to know your vehicle like never before.")
                .font(.title3)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 35)

            Spacer()

            NavigationLink {
                ManufacturerView()
            } label: {
                Text("Get Started")
                    .font(.headline)
                    .frame(maxWidth: .infinity)
                    .padding()
            }
            .buttonStyle(.borderedProminent)
            .padding(.horizontal, 24)
            .padding(.bottom, 30)
        }
        .padding(.horizontal, 24)
    }
}

// MARK: - Onboarding Progress

struct OnboardingProgressView: View {
    let step: Int

    private let stepLabels = ["Welcome", "Vehicle", "Confirm"]

    var body: some View {
        VStack(spacing: 8) {
            HStack(spacing: 6) {
                ForEach(stepLabels.indices, id: \.self) { index in
                    Capsule()
                        .fill(
                            index < step
                                ? Color.primary
                                : Color.secondary.opacity(0.22)
                        )
                        .frame(height: 4)
                }
            }

            Text("Step \(step) of \(stepLabels.count) · \(stepLabels[step - 1])")
                .font(.caption)
                .foregroundStyle(.secondary)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(.top, 8)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("Step \(step) of \(stepLabels.count): \(stepLabels[step - 1])")
    }
}

// MARK: - Add Vehicle Method

struct AddVehicleView: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                // Deliberately no OnboardingProgressView here, unlike the
                // first-time setup screens it links into (Manufacturer/
                // Model/Year/Confirm) — those are genuinely shared with
                // first-time onboarding since picking a car is the same
                // task either way, but a "Step 2 of 3" bar on the entry
                // screen implied an existing user was restarting a
                // multi-step account setup, which they aren't.
                VStack(alignment: .leading, spacing: 10) {
                    Text("Add a vehicle")
                        .font(.largeTitle)
                        .fontWeight(.bold)

                    Text(
                        "Add another car to your garage."
                    )
                    .font(.body)
                    .foregroundStyle(.secondary)
                }

                NavigationLink {
                    ManufacturerView()
                } label: {
                    ChoiceCard(
                        icon: "car.side.fill",
                        title: "Choose manually",
                        subtitle: "Select the manufacturer, model, and year"
                    )
                }
                .buttonStyle(.plain)
            }
            .padding(24)
        }
        .navigationTitle("Add Vehicle")
        .navigationBarTitleDisplayMode(.inline)
    }
}

// MARK: - VIN Scanner Preparation

struct VINScannerPreparationView: View {
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                OnboardingProgressView(step: 2)

                ZStack {
                    RoundedRectangle(cornerRadius: 28)
                        .fill(.thinMaterial)
                        .frame(height: 250)

                    VStack(spacing: 18) {
                        Image(systemName: "viewfinder")
                            .font(.system(size: 64))
                            .fontWeight(.light)

                        Text("VIN Scanner")
                            .font(.title2)
                            .fontWeight(.bold)
                    }
                }

                VStack(spacing: 10) {
                    Text("Camera scanning is coming next")
                        .font(.title2)
                        .fontWeight(.bold)
                        .multilineTextAlignment(.center)

                    Text(
                        "OpenHood will use the camera to read the 17-character VIN and identify the vehicle information it can verify."
                    )
                    .font(.body)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                }

                VStack(alignment: .leading, spacing: 14) {
                    scannerInstruction(
                        number: "1",
                        text: "Locate the VIN through the windshield or inside the driver-side door."
                    )

                    scannerInstruction(
                        number: "2",
                        text: "Hold the camera steadily over the full 17-character VIN."
                    )

                    scannerInstruction(
                        number: "3",
                        text: "Review and confirm the vehicle information OpenHood finds."
                    )
                }
                .padding(20)
                .background(.thinMaterial)
                .clipShape(
                    RoundedRectangle(cornerRadius: 22)
                )

                NavigationLink {
                    ManufacturerView()
                } label: {
                    Text("Choose manually instead")
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 17)
                        .background(.thinMaterial)
                        .clipShape(
                            RoundedRectangle(cornerRadius: 18)
                        )
                }
                .buttonStyle(.plain)
            }
            .padding(24)
        }
        .navigationTitle("Scan VIN")
        .navigationBarTitleDisplayMode(.inline)
    }

    private func scannerInstruction(
        number: String,
        text: String
    ) -> some View {
        HStack(alignment: .top, spacing: 14) {
            Text(number)
                .font(.headline)
                .frame(width: 34, height: 34)
                .background(.primary)
                .foregroundStyle(.background)
                .clipShape(Circle())

            Text(text)
                .font(.body)
                .frame(
                    maxWidth: .infinity,
                    alignment: .leading
                )
        }
    }
}

// MARK: - Manufacturer

struct ManufacturerView: View {
    @EnvironmentObject private var vehicle: VehicleOnboardingData

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 26) {
                OnboardingProgressView(step: 2)

                VStack(alignment: .leading, spacing: 8) {
                    Text("Choose your manufacturer")
                        .font(.largeTitle)
                        .fontWeight(.bold)

                    Text("Start by selecting the company that made your vehicle.")
                        .font(.body)
                        .foregroundStyle(.secondary)
                }

                ForEach(
                    VehicleRegion.allCases.filter {
                        !VehicleCatalog.makes(in: $0).isEmpty
                    }
                ) { region in
                    manufacturerSection(for: region)
                }

                NavigationLink {
                    ManualVehicleEntryView()
                } label: {
                    ChoiceCard(
                        icon: "questionmark.circle",
                        title: "My vehicle isn’t listed",
                        subtitle: "Create a basic vehicle profile"
                    )
                }
                .buttonStyle(.plain)
            }
            .padding(24)
        }
        .navigationTitle("Manufacturer")
        .navigationBarTitleDisplayMode(.inline)
    }

    private func manufacturerSection(
        for region: VehicleRegion
    ) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(region.rawValue.uppercased())
                .font(.caption)
                .fontWeight(.bold)
                .foregroundStyle(.secondary)
                .tracking(1.2)

            ForEach(VehicleCatalog.makes(in: region)) { make in
                NavigationLink {
                    ModelView()
                        .onAppear {
                            vehicle.manufacturer = make.name
                            vehicle.model = ""
                        }
                } label: {
                    ManufacturerCard(make: make)
                }
                .buttonStyle(.plain)
            }
        }
    }
}

struct ManufacturerCard: View {
    let make: VehicleMake

    var body: some View {
        HStack(spacing: 16) {
            ZStack {
                RoundedRectangle(cornerRadius: 15)
                    .fill(Color.primary.opacity(0.08))
                    .frame(width: 52, height: 52)

                Image(systemName: "car.side.fill")
                    .font(.system(size: 24, weight: .semibold))
            }

            VStack(alignment: .leading, spacing: 4) {
                Text(make.name)
                    .font(.headline)

                Text(make.modelCountText)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }

            Spacer()

            Image(systemName: "chevron.right")
                .font(.subheadline)
                .fontWeight(.semibold)
                .foregroundStyle(.secondary)
        }
        .padding(18)
        .background(.thinMaterial)
        .clipShape(
            RoundedRectangle(cornerRadius: 20)
        )
        .overlay {
            RoundedRectangle(cornerRadius: 20)
                .stroke(
                    Color.secondary.opacity(0.12),
                    lineWidth: 1
                )
        }
    }
}

// MARK: - Model

struct ModelView: View {
    @EnvironmentObject private var vehicle: VehicleOnboardingData

    private var selectedMake: VehicleMake? {
        VehicleCatalog.make(named: vehicle.manufacturer)
    }

    private var models: [VehicleModel] {
        selectedMake?.supportedModels ?? []
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 22) {
                OnboardingProgressView(step: 2)

                VStack(alignment: .leading, spacing: 8) {
                    Text("Choose your model")
                        .font(.largeTitle)
                        .fontWeight(.bold)

                    Text(
                        vehicle.manufacturer.isEmpty
                            ? "Select the vehicle that belongs in your garage."
                            : "Select your \(vehicle.manufacturer)."
                    )
                    .font(.body)
                    .foregroundStyle(.secondary)
                }

                if models.isEmpty {
                    ComingSoonModelsCard(
                        manufacturer: vehicle.manufacturer
                    )
                } else {
                    ForEach(models) { model in
                        NavigationLink {
                            YearView()
                                .onAppear {
                                    vehicle.model = model.name
                                }
                        } label: {
                            ModelCard(
                                model: model.name,
                                manufacturer: vehicle.manufacturer
                            )
                        }
                        .buttonStyle(.plain)
                    }
                }

                NavigationLink {
                    ManualVehicleEntryView()
                } label: {
                    ChoiceCard(
                        icon: "questionmark.circle",
                        title: "My vehicle isn’t listed",
                        subtitle: "Create a basic vehicle profile"
                    )
                }
                .buttonStyle(.plain)
            }
            .padding(24)
        }
        .navigationTitle(
            vehicle.manufacturer.isEmpty
                ? "Model"
                : vehicle.manufacturer
        )
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct ModelCard: View {
    let model: String
    let manufacturer: String

    var body: some View {
        HStack(spacing: 16) {
            ZStack {
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color.primary.opacity(0.08))
                    .frame(width: 58, height: 58)

                Image(systemName: "car.side.fill")
                    .font(.system(size: 27, weight: .semibold))
            }

            VStack(alignment: .leading, spacing: 4) {
                Text(model)
                    .font(.title3)
                    .fontWeight(.semibold)

                Text(manufacturer)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }

            Spacer()

            Image(systemName: "chevron.right")
                .font(.subheadline)
                .fontWeight(.semibold)
                .foregroundStyle(.secondary)
        }
        .padding(18)
        .background(.thinMaterial)
        .clipShape(
            RoundedRectangle(cornerRadius: 20)
        )
        .overlay {
            RoundedRectangle(cornerRadius: 20)
                .stroke(
                    Color.secondary.opacity(0.12),
                    lineWidth: 1
                )
        }
    }
}

struct ComingSoonModelsCard: View {
    let manufacturer: String

    var body: some View {
        VStack(spacing: 18) {
            ZStack {
                Circle()
                    .fill(Color.primary.opacity(0.08))
                    .frame(width: 88, height: 88)

                Image(systemName: "car.2.fill")
                    .font(.system(size: 38))
            }

            VStack(spacing: 8) {
                Text("Models coming soon")
                    .font(.title2)
                    .fontWeight(.bold)

                Text(
                    "The \(manufacturer) model list has not been added yet. Go back and choose one of the currently supported manufacturers."
                )
                .font(.body)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(28)
        .background(.thinMaterial)
        .clipShape(
            RoundedRectangle(cornerRadius: 24)
        )
    }
}

// MARK: - Manual Vehicle Entry

/// Fallback entry point for a vehicle whose manufacturer or model isn't in
/// the catalog yet. Reachable from both ManufacturerView and ModelView.
/// Feeds the same YearView used by catalog vehicles, so a manufacturer/model
/// with no verified year data falls through to ManualVehicleYearView exactly
/// like a catalog vehicle with no verified years would.
struct ManualVehicleEntryView: View {
    @EnvironmentObject private var vehicle: VehicleOnboardingData

    @State private var manufacturer = ""
    @State private var model = ""

    private enum Field {
        case manufacturer
        case model
    }

    @FocusState private var focusedField: Field?

    private var canContinue: Bool {
        !manufacturer.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
        !model.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    var body: some View {
        VStack(spacing: 24) {
            OnboardingProgressView(step: 2)

            VStack(spacing: 9) {
                Text("Enter your vehicle")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .multilineTextAlignment(.center)

                Text("Type your manufacturer and model. OpenHood will still provide general guidance.")
                    .font(.body)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
            }

            VStack(spacing: 14) {
                TextField("Manufacturer", text: $manufacturer)
                    .textInputAutocapitalization(.words)
                    .focused($focusedField, equals: .manufacturer)
                    .padding(18)
                    .background(.thinMaterial)
                    .clipShape(RoundedRectangle(cornerRadius: 16))

                TextField("Model", text: $model)
                    .textInputAutocapitalization(.words)
                    .focused($focusedField, equals: .model)
                    .padding(18)
                    .background(.thinMaterial)
                    .clipShape(RoundedRectangle(cornerRadius: 16))
            }

            VStack(alignment: .leading, spacing: 7) {
                Label("Basic vehicle profile", systemImage: "info.circle.fill")
                    .font(.headline)

                Text(
                    "General guidance is available, but vehicle-specific configuration details have not been verified."
                )
                .font(.subheadline)
                .foregroundStyle(.secondary)
            }
            .padding(18)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(.thinMaterial)
            .clipShape(RoundedRectangle(cornerRadius: 20))

            Spacer()

            NavigationLink {
                YearView()
                    .onAppear {
                        vehicle.manufacturer = manufacturer.trimmingCharacters(in: .whitespacesAndNewlines)
                        vehicle.model = model.trimmingCharacters(in: .whitespacesAndNewlines)
                    }
            } label: {
                Text("Continue")
                    .font(.headline)
                    .frame(maxWidth: .infinity)
                    .padding()
            }
            .buttonStyle(.borderedProminent)
            .disabled(!canContinue)
        }
        .padding(24)
        .navigationTitle("Vehicle Details")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            if manufacturer.isEmpty {
                manufacturer = vehicle.manufacturer
            }

            focusedField = manufacturer.isEmpty ? .manufacturer : .model
        }
    }
}

// MARK: - Year

struct YearView: View {
    @EnvironmentObject private var vehicle: VehicleOnboardingData
    @State private var selectedYear: Int?

    private var selectedModel: VehicleModel? {
        VehicleCatalog.model(
            makeName: vehicle.manufacturer,
            modelName: vehicle.model
        )
    }

    private var years: [Int] {
        selectedModel?.productionYears ?? []
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 22) {
                OnboardingProgressView(step: 2)

                VStack(alignment: .leading, spacing: 8) {
                    Text("Choose your year")
                        .font(.largeTitle)
                        .fontWeight(.bold)

                    Text(
                        "What year is your \(vehicle.manufacturer) \(vehicle.model)?"
                    )
                    .font(.body)
                    .foregroundStyle(.secondary)
                }

                if years.isEmpty {
                    VStack(spacing: 18) {
                        Image(systemName: "calendar.badge.exclamationmark")
                            .font(.system(size: 44))

                        Text("Detailed years coming soon")
                            .font(.title2)
                            .fontWeight(.bold)

                        Text(
                            "OpenHood does not have verified year information for the \(vehicle.manufacturer) \(vehicle.model) yet."
                        )
                        .font(.body)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(28)
                    .background(.thinMaterial)
                    .clipShape(
                        RoundedRectangle(cornerRadius: 24)
                    )
                } else {
                    Picker("Year", selection: $selectedYear) {
                        ForEach(years, id: \.self) { year in
                            Text(String(year))
                                .font(.title2)
                                .fontWeight(.bold)
                                .tag(Optional(year))
                        }
                    }
                    .pickerStyle(.wheel)
                    .labelsHidden()
                    .frame(maxWidth: .infinity)

                    NavigationLink {
                        VehicleConfirmationView()
                            .onAppear {
                                if let selectedYear {
                                    applyVehicleYear(selectedYear, to: vehicle)
                                }
                            }
                    } label: {
                        Text("Continue")
                            .font(.headline)
                            .frame(maxWidth: .infinity)
                            .padding()
                    }
                    .buttonStyle(.borderedProminent)
                    .disabled(selectedYear == nil)
                }

                NavigationLink {
                    ManualVehicleYearView()
                } label: {
                    ChoiceCard(
                        icon: "calendar.badge.questionmark",
                        title: "My year isn’t listed",
                        subtitle: "Create a basic vehicle profile"
                    )
                }
                .buttonStyle(.plain)
            }
            .padding(24)
        }
        .navigationTitle("Year")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            if selectedYear == nil {
                selectedYear = years.first
            }
        }
        // Catching up defaulting via .onChange as well as .onAppear:
        // ModelView's NavigationLink sets vehicle.model in its own
        // .onAppear on this same YearView instance, and child .onAppear
        // callbacks fire before a parent's, so `years` (which depends on
        // vehicle.model) can still be empty at the moment the .onAppear
        // above runs. Once vehicle.model actually lands, `years`
        // recomputes and this catches the default that .onAppear missed.
        .onChange(of: years) { _, newYears in
            if selectedYear == nil {
                selectedYear = newYears.first
            }
        }
    }
}

struct ManualVehicleYearView: View {
    @EnvironmentObject private var vehicle: VehicleOnboardingData

    @State private var year = ""
    @FocusState private var yearFieldIsFocused: Bool

    private var canContinue: Bool {
        year.count == 4 && Int(year) != nil
    }

    var body: some View {
        VStack(spacing: 24) {
            OnboardingProgressView(step: 2)

            VStack(spacing: 9) {
                Text("Enter your model year")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .multilineTextAlignment(.center)

                Text("Enter the four-digit year for your \(vehicle.model).")
                    .font(.body)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
            }

            TextField("Year", text: $year)
                .keyboardType(.numberPad)
                .focused($yearFieldIsFocused)
                .font(.system(size: 42, weight: .semibold, design: .rounded))
                .multilineTextAlignment(.center)
                .padding(22)
                .background(.thinMaterial)
                .clipShape(RoundedRectangle(cornerRadius: 20))
                .onChange(of: year) { _, newValue in
                    year = String(newValue.filter(\.isNumber).prefix(4))
                }

            VStack(alignment: .leading, spacing: 7) {
                Label("Basic vehicle profile", systemImage: "info.circle.fill")
                    .font(.headline)

                Text(
                    "General guidance is available, but some vehicle-specific information has not been verified."
                )
                .font(.subheadline)
                .foregroundStyle(.secondary)
            }
            .padding(18)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(.thinMaterial)
            .clipShape(RoundedRectangle(cornerRadius: 20))

            Spacer()

            NavigationLink {
                VehicleConfirmationView()
                    .onAppear {
                        if let yearNumber = Int(year) {
                            applyVehicleYear(yearNumber, to: vehicle)
                        }
                    }
            } label: {
                Text("Continue")
                    .font(.headline)
                    .frame(maxWidth: .infinity)
                    .padding()
            }
            .buttonStyle(.borderedProminent)
            .disabled(!canContinue)
        }
        .padding(24)
        .navigationTitle("Model Year")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            yearFieldIsFocused = true
        }
    }
}

/// Sets the vehicle's year and silently fills in whatever the catalog
/// unambiguously knows for that make/model/year. Fields the catalog has no
/// single confirmed answer for are left blank ("not confirmed") rather than
/// forcing the owner to answer a screen about them.
private func applyVehicleYear(
    _ year: Int,
    to vehicle: VehicleOnboardingData
) {
    vehicle.year = String(year)

    let autoFill = VehicleCatalog.autoFillConfiguration(
        makeName: vehicle.manufacturer,
        modelName: vehicle.model,
        year: year
    )

    vehicle.bodyStyle = autoFill?.bodyStyle ?? ""
    vehicle.powertrain = autoFill?.powertrain ?? ""
    vehicle.drivetrain = autoFill?.drivetrain ?? ""
    vehicle.drivetrainSystem = autoFill?.drivetrainSystem ?? ""
    vehicle.transmission = autoFill?.transmission ?? ""
    vehicle.trim = autoFill?.trim ?? ""

    let confirmedAnyDetail = [
        autoFill?.bodyStyle,
        autoFill?.powertrain,
        autoFill?.drivetrain,
        autoFill?.drivetrainSystem,
        autoFill?.transmission,
        autoFill?.trim
    ].contains { $0 != nil }

    vehicle.profileVerification = confirmedAnyDetail ? .verified : .basicUnverified
}

// MARK: - Confirmation

struct VehicleConfirmationView: View {
    @EnvironmentObject private var vehicle: VehicleOnboardingData
    @EnvironmentObject private var garageStore: GarageStore
    @EnvironmentObject private var onboardingSession: OnboardingSession

    private var confirmedDetails: [(label: String, value: String)] {
        [
            ("Body style", vehicle.bodyStyle),
            ("Powertrain", vehicle.powertrain),
            ("Drivetrain", vehicle.drivetrain),
            ("Transmission", vehicle.transmission),
            ("Trim", vehicle.trim)
        ].filter { !$0.1.isEmpty }
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                OnboardingProgressView(step: 3)

                VStack(spacing: 14) {
                    ZStack {
                        Circle()
                            .fill(Color.primary.opacity(0.08))
                            .frame(width: 88, height: 88)

                        Image(systemName: "checkmark.circle.fill")
                            .font(.system(size: 40))
                    }

                    VStack(spacing: 9) {
                        Text(vehicle.vehicleName)
                            .font(.largeTitle)
                            .fontWeight(.bold)
                            .multilineTextAlignment(.center)

                        Text(
                            vehicle.profileVerification == .verified
                                ? "OpenHood recognizes this vehicle and filled in what it knows."
                                : "OpenHood has added this vehicle to your garage."
                        )
                        .font(.body)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                    }
                }
                .padding(.top, 8)

                if !confirmedDetails.isEmpty {
                    VStack(spacing: 0) {
                        ForEach(Array(confirmedDetails.enumerated()), id: \.offset) { index, detail in
                            if index > 0 {
                                Divider()
                            }

                            GarageDetailRow(title: detail.label, value: detail.value)
                        }
                    }
                    .background(.thinMaterial)
                    .clipShape(RoundedRectangle(cornerRadius: 20))
                }

                VStack(alignment: .leading, spacing: 7) {
                    Label("You’re set — details can wait", systemImage: "info.circle.fill")
                        .font(.headline)

                    Text(
                        "Mileage and maintenance history are optional and can be added later from this vehicle's profile. You can add more vehicles anytime from the Garage tab."
                    )
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                }
                .padding(18)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(Color.primary.opacity(0.06))
                .clipShape(RoundedRectangle(cornerRadius: 18))

                Spacer(minLength: 12)

                Button {
                    onboardingSession.complete(
                        vehicle: vehicle,
                        garageStore: garageStore
                    )
                } label: {
                    Text("Enter OpenHood")
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .padding()
                }
                .buttonStyle(.borderedProminent)
            }
            .padding(24)
        }
        .navigationTitle("Confirm Vehicle")
        .navigationBarTitleDisplayMode(.inline)
    }
}

// MARK: - Mileage

struct MileageView: View {
    @EnvironmentObject private var vehicle: VehicleOnboardingData

    @State private var mileage = ""
    @FocusState private var mileageFieldIsFocused: Bool

    private var mileageNumber: Int? {
        Int(mileage.filter(\.isNumber))
    }

    private var canContinue: Bool {
        guard let mileageNumber else {
            return false
        }

        return mileageNumber >= 0 && mileageNumber <= 2_000_000
    }

    private var formattedMileage: Binding<String> {
        Binding(
            get: {
                mileage
            },
            set: { newValue in
                let digits = newValue.filter(\.isNumber)

                guard !digits.isEmpty,
                      let number = Int(digits) else {
                    mileage = ""
                    return
                }

                mileage = number.formatted()
            }
        )
    }

    var body: some View {
        VStack(spacing: 24) {
            VStack(spacing: 10) {
                Text("What is your current mileage?")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .multilineTextAlignment(.center)

                Text(
                    "This helps OpenHood understand which maintenance items may be worth reviewing."
                )
                .font(.body)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
            }

            Spacer()

            VStack(spacing: 14) {
                HStack(
                    alignment: .firstTextBaseline,
                    spacing: 10
                ) {
                    TextField(
                        "0",
                        text: formattedMileage
                    )
                    .keyboardType(.numberPad)
                    .focused($mileageFieldIsFocused)
                    .font(
                        .system(
                            size: 46,
                            weight: .semibold,
                            design: .rounded
                        )
                    )
                    .multilineTextAlignment(.center)
                    .minimumScaleFactor(0.6)

                    Text("miles")
                        .font(.title3)
                        .foregroundStyle(.secondary)
                }
                .padding(.horizontal, 22)
                .padding(.vertical, 26)
                .background(
                    RoundedRectangle(cornerRadius: 24)
                        .fill(.thinMaterial)
                )
                .overlay {
                    RoundedRectangle(cornerRadius: 24)
                        .stroke(
                            mileageFieldIsFocused
                                ? Color.accentColor
                                : Color.secondary.opacity(0.2),
                            lineWidth: mileageFieldIsFocused ? 2 : 1
                        )
                }
                .animation(
                    .easeInOut(duration: 0.2),
                    value: mileageFieldIsFocused
                )

                Text("You can update this later.")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            }

            Spacer()

            VStack(spacing: 12) {
                NavigationLink {
                    nextVehicleSetupDestination(vehicle: vehicle)
                        .onAppear {
                            vehicle.mileage = mileage
                        }
                } label: {
                    Text("Continue")
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .padding()
                }
                .buttonStyle(.borderedProminent)
                .disabled(!canContinue)

                NavigationLink {
                    nextVehicleSetupDestination(vehicle: vehicle)
                        .onAppear {
                            vehicle.mileage = ""
                        }
                } label: {
                    Text("I’m not sure")
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 10)
                }
                .buttonStyle(.plain)
                .foregroundStyle(.secondary)
            }
        }
        .padding(24)
        .navigationTitle("Mileage")
        .navigationBarTitleDisplayMode(.inline)
        .contentShape(Rectangle())
        .onTapGesture {
            mileageFieldIsFocused = false
        }
        .onAppear {
            mileage = vehicle.mileage
            mileageFieldIsFocused = true
        }
        .toolbar {
            ToolbarItemGroup(placement: .keyboard) {
                Spacer()

                Button("Done") {
                    mileageFieldIsFocused = false
                }
            }
        }
    }
}

// MARK: - Vehicle Setup: Missing Specs

/// Only reached from FinishVehicleSetupView's flow (MileageView is not used
/// anywhere else) — "Finish setting up this vehicle" is the one place a
/// vehicle can still be missing trim/transmission after the fact, since the
/// main onboarding confirmation screen completes the vehicle directly
/// without ever visiting MileageView. Decides which of transmission/trim
/// (if either) still needs asking, so a vehicle the catalog already
/// auto-filled never sees an extra screen, and completedFieldCount can
/// actually reach 6/6 for vehicles the catalog couldn't auto-fill.
@ViewBuilder
private func nextVehicleSetupDestination(vehicle: VehicleOnboardingData) -> some View {
    if vehicle.transmission.isEmpty {
        VehicleSetupTransmissionView()
    } else if vehicle.trim.isEmpty {
        VehicleSetupTrimView()
    } else {
        MaintenanceKnowledgeView()
    }
}

struct VehicleSetupTransmissionView: View {
    @EnvironmentObject private var vehicle: VehicleOnboardingData

    private let choices: [(title: String, icon: String, subtitle: String)] = [
        ("Automatic", "a.circle.fill", "Shifts on its own"),
        ("Manual", "m.circle.fill", "Foot clutch and gear shifter"),
        ("I’m not sure", "questionmark.circle.fill", "Skip for now")
    ]

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 22) {
                VStack(alignment: .leading, spacing: 8) {
                    Text("What transmission does it have?")
                        .font(.largeTitle)
                        .fontWeight(.bold)

                    Text("This is self-reported — OpenHood hasn't verified it.")
                        .font(.body)
                        .foregroundStyle(.secondary)
                }

                ForEach(choices, id: \.title) { choice in
                    NavigationLink {
                        nextDestination(for: choice.title)
                            .onAppear {
                                vehicle.transmission = choice.title
                            }
                    } label: {
                        ChoiceCard(
                            icon: choice.icon,
                            title: choice.title,
                            subtitle: choice.subtitle
                        )
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(24)
        }
        .navigationTitle("Transmission")
        .navigationBarTitleDisplayMode(.inline)
    }

    @ViewBuilder
    private func nextDestination(for choice: String) -> some View {
        if choice == "Automatic" {
            VehicleSetupAutomaticTypeView()
        } else if vehicle.trim.isEmpty {
            VehicleSetupTrimView()
        } else {
            MaintenanceKnowledgeView()
        }
    }
}

struct VehicleSetupAutomaticTypeView: View {
    @EnvironmentObject private var vehicle: VehicleOnboardingData

    private let choices: [(title: String, savedValue: String, icon: String, subtitle: String)] = [
        ("Traditional automatic", "Automatic", "a.circle.fill", "Torque converter, shifts through fixed gears"),
        ("CVT (continuously variable)", "CVT (continuously variable)", "infinity.circle.fill", "Continuously variable transmission"),
        ("Not sure", "Automatic", "questionmark.circle.fill", "Skip for now")
    ]

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 22) {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Traditional automatic, or CVT?")
                        .font(.largeTitle)
                        .fontWeight(.bold)

                    Text("This is self-reported — OpenHood hasn't verified it.")
                        .font(.body)
                        .foregroundStyle(.secondary)
                }

                ForEach(choices, id: \.title) { choice in
                    NavigationLink {
                        nextDestination()
                            .onAppear {
                                vehicle.transmission = choice.savedValue
                            }
                    } label: {
                        ChoiceCard(
                            icon: choice.icon,
                            title: choice.title,
                            subtitle: choice.subtitle
                        )
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(24)
        }
        .navigationTitle("Transmission")
        .navigationBarTitleDisplayMode(.inline)
    }

    @ViewBuilder
    private func nextDestination() -> some View {
        if vehicle.trim.isEmpty {
            VehicleSetupTrimView()
        } else {
            MaintenanceKnowledgeView()
        }
    }
}

struct VehicleSetupTrimView: View {
    @EnvironmentObject private var vehicle: VehicleOnboardingData

    @State private var trimText = ""
    @FocusState private var trimFieldIsFocused: Bool

    /// Same pattern as "My year isn't listed"/ManualVehicleYearView: offer
    /// known choices when the catalog has them for this exact make/model/
    /// year, otherwise fall back to plain text entry with a skip option.
    private var catalogTrims: [String] {
        guard let year = Int(vehicle.year) else { return [] }
        return VehicleCatalog.configuration(
            makeName: vehicle.manufacturer,
            modelName: vehicle.model,
            year: year
        )?.trims ?? []
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("What trim is it?")
                .font(.largeTitle)
                .fontWeight(.bold)

            Text("This is self-reported — OpenHood hasn't verified it.")
                .font(.body)
                .foregroundStyle(.secondary)
        }
    }

    var body: some View {
        Group {
            if catalogTrims.isEmpty {
                manualEntry
            } else {
                catalogChoices
            }
        }
        .navigationTitle("Trim")
        .navigationBarTitleDisplayMode(.inline)
    }

    @ViewBuilder
    private var catalogChoices: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 22) {
                header

                ForEach(catalogTrims, id: \.self) { trim in
                    NavigationLink {
                        MaintenanceKnowledgeView()
                            .onAppear {
                                vehicle.trim = trim
                            }
                    } label: {
                        ChoiceCard(
                            icon: "checkmark.seal.fill",
                            title: trim,
                            subtitle: "Factory trim level"
                        )
                    }
                    .buttonStyle(.plain)
                }

                NavigationLink {
                    MaintenanceKnowledgeView()
                        .onAppear {
                            vehicle.trim = "I’m not sure"
                        }
                } label: {
                    ChoiceCard(
                        icon: "questionmark.circle.fill",
                        title: "I’m not sure",
                        subtitle: "Skip for now"
                    )
                }
                .buttonStyle(.plain)
            }
            .padding(24)
        }
    }

    @ViewBuilder
    private var manualEntry: some View {
        VStack(spacing: 24) {
            header

            TextField("Trim (e.g. LX, EX, Sport)", text: $trimText)
                .textInputAutocapitalization(.words)
                .focused($trimFieldIsFocused)
                .font(.system(size: 28, weight: .semibold, design: .rounded))
                .multilineTextAlignment(.center)
                .padding(18)
                .background(.thinMaterial)
                .clipShape(RoundedRectangle(cornerRadius: 20))

            Spacer()

            VStack(spacing: 12) {
                NavigationLink {
                    MaintenanceKnowledgeView()
                        .onAppear {
                            vehicle.trim = trimText.trimmingCharacters(in: .whitespacesAndNewlines)
                        }
                } label: {
                    Text("Continue")
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .padding()
                }
                .buttonStyle(.borderedProminent)
                .disabled(trimText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)

                NavigationLink {
                    MaintenanceKnowledgeView()
                        .onAppear {
                            vehicle.trim = "I’m not sure"
                        }
                } label: {
                    Text("I’m not sure")
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 10)
                }
                .buttonStyle(.plain)
                .foregroundStyle(.secondary)
            }
        }
        .padding(24)
        .contentShape(Rectangle())
        .onTapGesture {
            trimFieldIsFocused = false
        }
    }
}

// MARK: - Maintenance Knowledge

struct MaintenanceKnowledgeView: View {
    var body: some View {
        VStack(spacing: 24) {
            VStack(spacing: 10) {
                Text("How much do you know about its recent maintenance?")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .multilineTextAlignment(.center)

                Text("Choose the answer that feels closest. You can update this later.")
                    .font(.body)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
            }

            NavigationLink {
                MaintenanceMemoryView()
            } label: {
                ChoiceCard(
                    icon: "text.bubble.fill",
                    title: "I know most of it",
                    subtitle: "Tell OpenHood what has been done"
                )
            }
            .buttonStyle(.plain)

            NavigationLink {
                MaintenanceServicesView()
            } label: {
                ChoiceCard(
                    icon: "list.bullet.clipboard.fill",
                    title: "I know some of it",
                    subtitle: "Select the services you remember"
                )
            }
            .buttonStyle(.plain)

            NavigationLink {
                MaintenanceBaselineView()
            } label: {
                ChoiceCard(
                    icon: "questionmark.circle.fill",
                    title: "I don’t know",
                    subtitle: "Help me establish a baseline"
                )
            }
            .buttonStyle(.plain)

            Spacer()
        }
        .padding(24)
        .navigationTitle("Maintenance")
        .navigationBarTitleDisplayMode(.inline)
    }
}

// MARK: - I Know Most

struct MaintenanceMemoryView: View {
    @EnvironmentObject private var vehicle: VehicleOnboardingData
    @EnvironmentObject private var garageStore: GarageStore
    @EnvironmentObject private var onboardingSession: OnboardingSession

    @State private var maintenanceNotes = ""

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 22) {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Tell OpenHood what was done")
                        .font(.largeTitle)
                        .fontWeight(.bold)

                    Text(
                        "Type the work you remember in your own words. It does not need to be organized."
                    )
                    .font(.body)
                    .foregroundStyle(.secondary)
                }

                VStack(alignment: .leading, spacing: 12) {
                    Label(
                        "Example",
                        systemImage: "lightbulb.fill"
                    )
                    .font(.headline)

                    Text(
                        "Valve cover gaskets, spark plugs, six coils, front brakes, cooling fans, catalytic converters, and an oil change."
                    )
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                }
                .padding(18)
                .background(Color.primary.opacity(0.06))
                .clipShape(
                    RoundedRectangle(cornerRadius: 18)
                )

                ZStack(alignment: .topLeading) {
                    TextEditor(text: $maintenanceNotes)
                        .frame(minHeight: 210)
                        .padding(12)
                        .scrollContentBackground(.hidden)

                    if maintenanceNotes.isEmpty {
                        Text("Start typing the work you remember…")
                            .foregroundStyle(.secondary)
                            .padding(.horizontal, 18)
                            .padding(.vertical, 20)
                            .allowsHitTesting(false)
                    }
                }
                .background(.thinMaterial)
                .clipShape(
                    RoundedRectangle(cornerRadius: 20)
                )
                .overlay {
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(
                            Color.secondary.opacity(0.15),
                            lineWidth: 1
                        )
                }

                Button {
                    onboardingSession.complete(
                        vehicle: vehicle,
                        garageStore: garageStore
                    )
                } label: {
                    Text("Continue")
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .padding()
                }
                .buttonStyle(.borderedProminent)
                .disabled(
                    maintenanceNotes
                        .trimmingCharacters(in: .whitespacesAndNewlines)
                        .isEmpty
                )

                Button {
                    onboardingSession.complete(
                        vehicle: vehicle,
                        garageStore: garageStore
                    )
                } label: {
                    Text("Skip for now")
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 10)
                }
                .buttonStyle(.plain)
                .foregroundStyle(.secondary)
            }
            .padding(24)
        }
        .navigationTitle("Recent Work")
        .navigationBarTitleDisplayMode(.inline)
    }
}

// MARK: - I Know Some

enum MaintenanceService: String, CaseIterable, Identifiable {
    case oilChange = "Oil change"
    case brakes = "Brakes"
    case tires = "Tires"
    case battery = "Battery"
    case sparkPlugs = "Spark plugs"
    case coolant = "Coolant"
    case transmission = "Transmission"
    case suspension = "Suspension"
    case beltsAndHoses = "Belts & hoses"
    case airFilters = "Air filters"
    case alignment = "Alignment"
    case other = "Something else"

    var id: String {
        rawValue
    }

    var icon: String {
        switch self {
        case .oilChange:
            return "drop.fill"
        case .brakes:
            return "circle.circle.fill"
        case .tires:
            return "circle.grid.cross.fill"
        case .battery:
            return "battery.100percent"
        case .sparkPlugs:
            return "bolt.fill"
        case .coolant:
            return "thermometer.medium"
        case .transmission:
            return "gearshape.2.fill"
        case .suspension:
            return "arrow.up.and.down"
        case .beltsAndHoses:
            return "link"
        case .airFilters:
            return "wind"
        case .alignment:
            return "scope"
        case .other:
            return "plus.circle.fill"
        }
    }

    var subtitle: String {
        switch self {
        case .oilChange:
            return "Engine oil or filter"
        case .brakes:
            return "Pads, rotors, or brake fluid"
        case .tires:
            return "Replacement, rotation, or repair"
        case .battery:
            return "Battery or charging work"
        case .sparkPlugs:
            return "Plugs, coils, or ignition work"
        case .coolant:
            return "Cooling system or overheating work"
        case .transmission:
            return "Fluid, clutch, or transmission work"
        case .suspension:
            return "Shocks, struts, bushings, or arms"
        case .beltsAndHoses:
            return "Accessory belts or engine hoses"
        case .airFilters:
            return "Engine or cabin air filters"
        case .alignment:
            return "Wheel alignment or steering correction"
        case .other:
            return "Add another service you remember"
        }
    }
}

struct MaintenanceServicesView: View {
    @EnvironmentObject private var vehicle: VehicleOnboardingData
    @EnvironmentObject private var garageStore: GarageStore
    @EnvironmentObject private var onboardingSession: OnboardingSession

    @State private var selectedServices: Set<MaintenanceService> = []

    var body: some View {
        ScrollView {
            VStack(spacing: 18) {
                VStack(spacing: 8) {
                    Text("What work do you remember?")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .multilineTextAlignment(.center)

                    Text(
                        "Add whatever comes to mind. It does not need to be complete."
                    )
                    .font(.body)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                }
                .padding(.bottom, 6)

                ForEach(MaintenanceService.allCases) { service in
                    Button {
                        toggle(service)
                    } label: {
                        MaintenanceServiceCard(
                            service: service,
                            isSelected: selectedServices.contains(service)
                        )
                    }
                    .buttonStyle(.plain)
                }

                Button {
                    onboardingSession.complete(
                        vehicle: vehicle,
                        garageStore: garageStore
                    )
                } label: {
                    Text("Continue")
                        .font(.headline)
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(
                            selectedServices.isEmpty
                                ? Color.secondary.opacity(0.35)
                                : Color.primary
                        )
                        .clipShape(
                            RoundedRectangle(cornerRadius: 18)
                        )
                }
                .buttonStyle(.plain)
                .disabled(selectedServices.isEmpty)

                Button {
                    onboardingSession.complete(
                        vehicle: vehicle,
                        garageStore: garageStore
                    )
                } label: {
                    Text("I don’t remember any specific services")
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundStyle(.secondary)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 10)
                }
                .buttonStyle(.plain)
            }
            .padding(24)
        }
        .navigationTitle("Recent Work")
        .navigationBarTitleDisplayMode(.inline)
    }

    private func toggle(_ service: MaintenanceService) {
        if selectedServices.contains(service) {
            selectedServices.remove(service)
        } else {
            selectedServices.insert(service)
        }
    }
}

struct MaintenanceServiceCard: View {
    let service: MaintenanceService
    let isSelected: Bool

    var body: some View {
        HStack(spacing: 16) {
            ZStack {
                RoundedRectangle(cornerRadius: 14)
                    .fill(
                        isSelected
                            ? Color.white.opacity(0.16)
                            : Color.primary.opacity(0.08)
                    )
                    .frame(width: 48, height: 48)

                Image(systemName: service.icon)
                    .font(.system(size: 22, weight: .semibold))
                    .foregroundStyle(
                        isSelected
                            ? Color.white
                            : Color.primary
                    )
            }

            VStack(alignment: .leading, spacing: 4) {
                Text(service.rawValue)
                    .font(.headline)
                    .foregroundStyle(
                        isSelected
                            ? Color.white
                            : Color.primary
                    )

                Text(service.subtitle)
                    .font(.subheadline)
                    .foregroundStyle(
                        isSelected
                            ? Color.white.opacity(0.72)
                            : Color.secondary
                    )
                    .multilineTextAlignment(.leading)
            }

            Spacer()

            Image(
                systemName: isSelected
                    ? "checkmark.circle.fill"
                    : "circle"
            )
            .font(.title3)
            .foregroundStyle(
                isSelected
                    ? Color.white
                    : Color.secondary.opacity(0.55)
            )
        }
        .padding(18)
        .frame(maxWidth: .infinity)
        .background(
            isSelected
                ? AnyShapeStyle(Color.primary)
                : AnyShapeStyle(.thinMaterial)
        )
        .clipShape(
            RoundedRectangle(cornerRadius: 20)
        )
        .animation(
            .easeInOut(duration: 0.18),
            value: isSelected
        )
    }
}

// MARK: - I Do Not Know

struct MaintenanceBaselineView: View {
    @EnvironmentObject private var vehicle: VehicleOnboardingData
    @EnvironmentObject private var garageStore: GarageStore
    @EnvironmentObject private var onboardingSession: OnboardingSession

    var body: some View {
        VStack(spacing: 24) {
            Spacer()

            ZStack {
                Circle()
                    .fill(Color.primary.opacity(0.08))
                    .frame(width: 100, height: 100)

                Image(systemName: "list.clipboard.fill")
                    .font(.system(size: 42))
            }

            VStack(spacing: 10) {
                Text("That’s okay.")
                    .font(.largeTitle)
                    .fontWeight(.bold)

                Text(
                    "OpenHood will help you establish a maintenance baseline without assuming that work has or has not been completed."
                )
                .font(.title3)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
            }

            Spacer()

            Button {
                onboardingSession.complete(
                    vehicle: vehicle,
                    garageStore: garageStore
                )
            } label: {
                Text("Enter OpenHood")
                    .font(.headline)
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(Color.primary)
                    .clipShape(
                        RoundedRectangle(cornerRadius: 18)
                    )
            }
            .buttonStyle(.plain)
        }
        .padding(24)
        .navigationTitle("Maintenance")
        .navigationBarTitleDisplayMode(.inline)
    }
}

// MARK: - OpenHood Home

// MARK: - Vehicle Home
struct VehicleHomeView: View {
    @EnvironmentObject private var vehicle: VehicleOnboardingData
    @EnvironmentObject private var garageStore: GarageStore
    @AppStorage("ownerDisplayName") private var ownerDisplayName: String = ""

    /// Was a hardcoded "Good afternoon" regardless of actual time of day —
    /// genuinely wrong most of the day, not just unpersonalized. Falls
    /// back to no name suffix when ownerDisplayName is empty (the default
    /// for anyone who hasn't set it in Profile & Settings), so this is a
    /// pure improvement with no new failure mode for existing users.
    private var timeBasedGreeting: String {
        let hour = Calendar.current.component(.hour, from: Date())
        let timeOfDay: String
        switch hour {
        case 5..<12: timeOfDay = "Good morning"
        case 12..<17: timeOfDay = "Good afternoon"
        case 17..<22: timeOfDay = "Good evening"
        default: timeOfDay = "Good night"
        }
        let trimmedName = ownerDisplayName.trimmingCharacters(in: .whitespacesAndNewlines)
        return trimmedName.isEmpty ? timeOfDay : "\(timeOfDay), \(trimmedName)"
    }

    /// Rotates through a few friendly variants instead of always showing
    /// the exact same line — selected by day of year so it stays stable
    /// within a single day rather than changing on every screen visit,
    /// which would feel glitchy rather than intentional.
    private static let headlineVariants = [
        "What brings you under the hood?",
        "What's going on with your car?",
        "What do you want to look into today?",
        "What's on your mind about your vehicle?",
        "What can OpenHood help you figure out?"
    ]

    private var rotatingHeadline: String {
        let dayOfYear = Calendar.current.ordinality(of: .day, in: .year, for: Date()) ?? 1
        let index = dayOfYear % Self.headlineVariants.count
        return Self.headlineVariants[index]
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 22) {
                VStack(alignment: .leading, spacing: 5) {
                    Text(timeBasedGreeting)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)

                    Text(rotatingHeadline)
                        .font(.largeTitle)
                        .fontWeight(.bold)
                }
                .frame(
                    maxWidth: .infinity,
                    alignment: .leading
                )

                if let activeVehicle = garageStore.activeVehicle {
                    NavigationLink {
                        VehicleDetailView(vehicle: activeVehicle)
                    } label: {
                        VehicleStageCard()
                    }
                    .buttonStyle(.plain)
                }

                NavigationLink {
                    SomethingHappenedPlaceholderView()
                } label: {
                    SomethingHappenedCard()
                }
                .buttonStyle(.plain)

                Spacer(minLength: 20)
            }
            .padding(20)
        }
        .background(Color(.systemGroupedBackground))
        .navigationTitle("OpenHood")
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                NavigationLink {
                    ProfileSettingsView()
                } label: {
                    Image(systemName: "person.crop.circle")
                }
                .accessibilityLabel("Profile and settings")
            }
        }
    }
}
    // MARK: - Learn My Car

    struct LearnMyCarView: View {
        @EnvironmentObject private var vehicle: VehicleOnboardingData

        var body: some View {
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    VStack(alignment: .leading, spacing: 7) {
                        Text("Learn your car")
                            .font(.largeTitle)
                            .fontWeight(.bold)

                        Text(
                            "What would you like to know about your \(vehicle.model)?"
                        )
                        .font(.body)
                        .foregroundStyle(.secondary)
                    }

                    LearnHeroCard()

                    VStack(spacing: 14) {
                        NavigationLink {
                            LearnTopicPlaceholderView(
                                title: "How My Car Works",
                                icon: "car.side.fill",
                                message:
                                    """
                                    Explore your vehicle visually. Tap the engine, \
                                    brakes, cooling system, suspension, transmission, \
                                    or electrical system to understand what each part \
                                    does and how the systems work together.
                                    """
                            )
                        } label: {
                            LearnRowCard(
                                icon: "car.side.fill",
                                title: "How does my car work?",
                                subtitle: "Explore the major systems"
                            )
                        }
                        .buttonStyle(.plain)

                        NavigationLink {
                            PlaceholderDestinationView(
                                title: "Show Me How",
                                message: "Visual maintenance guides will be added here."
                            )
                        } label: {
                            LearnRowCard(
                                icon: "wrench.and.screwdriver.fill",
                                title: "Show me how",
                                subtitle: "Simple visual maintenance guides"
                            )
                        }
                        .buttonStyle(.plain)

                        NavigationLink {
                            PlaceholderDestinationView(
                                title: "Find a Fact",
                                message: "Vehicle specifications, fluids, manuals, and diagrams will be added here."
                            )
                        } label: {
                            LearnRowCard(
                                icon: "magnifyingglass",
                                title: "Find a fact",
                                subtitle: "Fluids, specifications, manuals, and diagrams"
                            )
                        }
                        .buttonStyle(.plain)

                        NavigationLink {
                            PlaceholderDestinationView(
                                title: "Ask a Question",
                                message: "Vehicle-specific questions and answers will be added here."
                            )
                        } label: {
                            LearnRowCard(
                                icon: "questionmark.bubble.fill",
                                title: "Ask a question",
                                subtitle: "Ask anything about your exact vehicle"
                            )
                        }
                        .buttonStyle(.plain)
                    }

                    Spacer(minLength: 30)
                }
                .padding(20)
            }
            .background(Color(.systemGroupedBackground))
            .navigationTitle("Learn My Car")
            .navigationBarTitleDisplayMode(.inline)
        }
    }

    // MARK: - Learn Guide Menu

    struct LearnHeroCard: View {
        var body: some View {
            VStack(alignment: .leading, spacing: 18) {
                HStack {
                    ZStack {
                        Circle()
                            .fill(Color.white.opacity(0.14))
                            .frame(width: 58, height: 58)

                        Image(systemName: "lightbulb.max.fill")
                            .font(.system(size: 26, weight: .semibold))
                            .foregroundStyle(.white)
                    }

                    Spacer()

                    Image(systemName: "sparkles")
                        .font(.title2)
                        .foregroundStyle(.white.opacity(0.8))
                }

                VStack(alignment: .leading, spacing: 7) {
                    Text("Your vehicle, explained simply")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundStyle(.white)

                    Text(
                        "Learn what parts do, where they are, how to inspect them, and what to consider before working on the vehicle."
                    )
                    .font(.subheadline)
                    .foregroundStyle(.white.opacity(0.76))
                }
            }
            .padding(22)
            .background(
                LinearGradient(
                    colors: [
                        Color.black,
                        Color.black.opacity(0.76)
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

    struct LearnSectionHeader: View {
        let title: String
        let subtitle: String

        var body: some View {
            VStack(alignment: .leading, spacing: 3) {
                Text(title)
                    .font(.title2)
                    .fontWeight(.bold)

                Text(subtitle)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.top, 4)
        }
    }

    struct LearnRowCard: View {
        let icon: String
        let title: String
        let subtitle: String

        var body: some View {
            HStack(spacing: 16) {
                ZStack {
                    RoundedRectangle(cornerRadius: 17)
                        .fill(Color.primary.opacity(0.08))
                        .frame(width: 56, height: 56)

                    Image(systemName: icon)
                        .font(.system(size: 23, weight: .semibold))
                }

                VStack(alignment: .leading, spacing: 5) {
                    Text(title)
                        .font(.headline)

                    Text(subtitle)
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

    struct FeaturedLearnGuideCard: View {
        let icon: String
        let title: String
        let subtitle: String
        let difficulty: String
        let estimatedTime: String

        var body: some View {
            VStack(alignment: .leading, spacing: 18) {
                HStack {
                    ZStack {
                        RoundedRectangle(cornerRadius: 18)
                            .fill(Color.primary)
                            .frame(width: 58, height: 58)

                        Image(systemName: icon)
                            .font(.system(size: 24, weight: .semibold))
                            .foregroundStyle(Color(.systemBackground))
                    }

                    Spacer()

                    Image(systemName: "arrow.up.right")
                        .font(.headline)
                        .foregroundStyle(.secondary)
                }

                VStack(alignment: .leading, spacing: 6) {
                    Text(title)
                        .font(.title3)
                        .fontWeight(.bold)

                    Text(subtitle)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }

                HStack(spacing: 10) {
                    Label(difficulty, systemImage: "wrench.fill")
                    Label(estimatedTime, systemImage: "clock.fill")
                }
                .font(.caption)
                .foregroundStyle(.secondary)
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

    struct OilChangeGuideView: View {
        @EnvironmentObject private var vehicle: VehicleOnboardingData

        var body: some View {
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Engine oil change")
                            .font(.largeTitle)
                            .fontWeight(.bold)

                        Text(vehicle.vehicleName)
                            .font(.headline)
                            .foregroundStyle(.secondary)

                        Text(
                            "This prototype demonstrates how OpenHood can eventually provide vehicle-specific visual guidance."
                        )
                        .font(.body)
                        .foregroundStyle(.secondary)
                    }

                    GuideSummaryCard()

                    VisualLocationPlaceholder(
                        title: "Locate the service points",
                        message:
                            """
                            A vehicle-specific diagram or interactive model will show \
                            the oil fill cap, dipstick, drain plug, filter, lift points, \
                            and any underbody panels that must be removed.
                            """
                    )

                    GuideStepCard(
                        number: 1,
                        title: "Confirm the correct supplies",
                        description:
                            """
                            Verify the factory oil specification, service-fill amount, \
                            filter, replacement washer, tools, and disposal container \
                            for the exact vehicle configuration.
                            """
                    )

                    GuideStepCard(
                        number: 2,
                        title: "Prepare the vehicle safely",
                        description:
                            """
                            Park on a stable surface, secure the vehicle, allow hot \
                            components to cool appropriately, and use verified lifting \
                            and support points when raising the vehicle.
                            """
                    )

                    GuideStepCard(
                        number: 3,
                        title: "Drain the old oil",
                        description:
                            """
                            Locate the verified drain plug, position the container, \
                            remove the plug carefully, and inspect the plug and sealing \
                            washer while the oil drains.
                            """
                    )

                    GuideStepCard(
                        number: 4,
                        title: "Replace the oil filter",
                        description:
                            """
                            Confirm the correct filter location and removal direction. \
                            Inspect the old gasket and prepare the replacement according \
                            to the verified service procedure.
                            """
                    )

                    GuideStepCard(
                        number: 5,
                        title: "Refill and verify",
                        description:
                            """
                            Reinstall components to verified specifications, add the \
                            correct initial amount, start the engine, inspect for leaks, \
                            wait as required, and confirm the final level correctly.
                            """
                    )

                    GuideStepCard(
                        number: 6,
                        title: "Record the service",
                        description:
                            """
                            Save the date, mileage, oil specification, quantity, filter, \
                            parts used, receipts, observations, and next planned service.
                            """
                    )

                    VStack(alignment: .leading, spacing: 8) {
                        Label(
                            "Verified data required",
                            systemImage: "exclamationmark.shield.fill"
                        )
                        .font(.headline)

                        Text(
                            "OpenHood should not display exact capacities, torque values, lift points, or procedures until they have been verified for the selected vehicle."
                        )
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                    }
                    .padding(18)
                    .background(Color(.secondarySystemGroupedBackground))
                    .clipShape(
                        RoundedRectangle(cornerRadius: 20)
                    )

                    Spacer(minLength: 30)
                }
                .padding(20)
            }
            .background(Color(.systemGroupedBackground))
            .navigationTitle("Oil Change")
            .navigationBarTitleDisplayMode(.inline)
        }
    }

    struct GuideSummaryCard: View {
        var body: some View {
            HStack {
                GuideSummaryItem(
                    title: "Difficulty",
                    value: "Beginner"
                )

                Divider()
                    .frame(height: 42)

                GuideSummaryItem(
                    title: "Time",
                    value: "30–60 min"
                )

                Divider()
                    .frame(height: 42)

                GuideSummaryItem(
                    title: "Record",
                    value: "Recommended"
                )
            }
            .padding(18)
            .background(Color(.secondarySystemGroupedBackground))
            .clipShape(
                RoundedRectangle(cornerRadius: 22)
            )
        }
    }

    struct GuideSummaryItem: View {
        let title: String
        let value: String

        var body: some View {
            VStack(spacing: 4) {
                Text(title)
                    .font(.caption)
                    .foregroundStyle(.secondary)

                Text(value)
                    .font(.caption)
                    .fontWeight(.semibold)
                    .multilineTextAlignment(.center)
            }
            .frame(maxWidth: .infinity)
        }
    }

    struct VisualLocationPlaceholder: View {
        let title: String
        let message: String

        var body: some View {
            VStack(spacing: 18) {
                ZStack {
                    RoundedRectangle(cornerRadius: 26)
                        .fill(Color.primary.opacity(0.07))
                        .frame(height: 230)

                    VStack(spacing: 14) {
                        Image(systemName: "car.side.fill")
                            .font(.system(size: 74))

                        Image(systemName: "viewfinder")
                            .font(.title2)
                            .foregroundStyle(.secondary)
                    }
                }

                VStack(alignment: .leading, spacing: 7) {
                    Text(title)
                        .font(.title3)
                        .fontWeight(.bold)

                    Text(message)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }
            .padding(18)
            .background(Color(.secondarySystemGroupedBackground))
            .clipShape(
                RoundedRectangle(cornerRadius: 24)
            )
        }
    }

    struct GuideStepCard: View {
        let number: Int
        let title: String
        let description: String

        var body: some View {
            HStack(alignment: .top, spacing: 15) {
                Text(String(number))
                    .font(.headline)
                    .foregroundStyle(Color(.systemBackground))
                    .frame(width: 38, height: 38)
                    .background(Color.primary)
                    .clipShape(Circle())

                VStack(alignment: .leading, spacing: 7) {
                    Text(title)
                        .font(.headline)

                    Text(description)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }
            .padding(18)
            .background(Color(.secondarySystemGroupedBackground))
            .clipShape(
                RoundedRectangle(cornerRadius: 22)
            )
        }
    }

    struct LearnTopicPlaceholderView: View {
        let title: String
        let icon: String
        let message: String

        var body: some View {
            VStack(spacing: 22) {
                Spacer()

                Image(systemName: icon)
                    .font(.system(size: 58))

                Text(title)
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .multilineTextAlignment(.center)

                Text(message)
                    .font(.body)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)

                Spacer()
            }
            .padding(28)
            .navigationTitle(title)
            .navigationBarTitleDisplayMode(.inline)
        }
    }

    struct CommunityKnowledgePlaceholderView: View {
        var body: some View {
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Community knowledge")
                            .font(.largeTitle)
                            .fontWeight(.bold)

                        Text(
                            "Useful owner patterns without presenting opinions as confirmed facts."
                        )
                        .font(.body)
                        .foregroundStyle(.secondary)
                    }

                    PlanPreviewCard(
                        title: "How it should work",
                        icon: "person.3.fill",
                        items: [
                            "Separate factory facts from owner experiences",
                            "Show how frequently a pattern was reported",
                            "Explain conflicting viewpoints",
                            "Link back to original discussions",
                            "Recommend verification before repairs"
                        ]
                    )

                    VStack(alignment: .leading, spacing: 9) {
                        Label(
                            "Community reports are evidence—not diagnosis",
                            systemImage: "shield.lefthalf.filled"
                        )
                        .font(.headline)

                        Text(
                            "OpenHood should use owner discussions to identify patterns and better questions, while verified service information and direct testing guide conclusions."
                        )
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                    }
                    .padding(20)
                    .background(Color(.secondarySystemGroupedBackground))
                    .clipShape(
                        RoundedRectangle(cornerRadius: 22)
                    )

                    Spacer(minLength: 30)
                }
                .padding(20)
            }
            .background(Color(.systemGroupedBackground))
            .navigationTitle("Community")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
// MARK: - Vehicle Stage Card

struct VehicleStageCard: View {
    @EnvironmentObject private var vehicle: VehicleOnboardingData

    var body: some View {
        VStack(spacing: 16) {
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 4) {
                    Text(vehicle.vehicleName)
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundStyle(.white)

                    Text(vehicle.transmissionDisplay)
                        .font(.subheadline)
                        .foregroundStyle(.white.opacity(0.65))
                }

                Spacer()

                Label(
                    "In Garage",
                    systemImage: "checkmark.circle.fill"
                )
                .font(.caption)
                .fontWeight(.semibold)
                .foregroundStyle(.green)
                .padding(.horizontal, 10)
                .padding(.vertical, 7)
                .background(Color.white.opacity(0.1))
                .clipShape(Capsule())
            }

            Spacer()

            ZStack {
                Ellipse()
                    .fill(Color.white.opacity(0.12))
                    .frame(width: 230, height: 28)
                    .blur(radius: 8)
                    .offset(y: 42)

                Image(systemName: "car.side.fill")
                    .font(.system(size: 104))
                    .foregroundStyle(.white)
            }

            Spacer()

            HStack {
                VehicleStat(
                    title: "Mileage",
                    value: vehicle.mileageDisplay
                )

                Divider()
                    .overlay(Color.white.opacity(0.18))
                    .frame(height: 35)

                VehicleStat(
                    title: "Trim",
                    value: vehicle.trim.isEmpty
                        ? "Unknown"
                        : vehicle.trim
                )

                Divider()
                    .overlay(Color.white.opacity(0.18))
                    .frame(height: 35)

                VehicleStat(
                    title: "Garage",
                    value: "1 car"
                )
            }
        }
        .padding(22)
        .frame(maxWidth: .infinity)
        .frame(height: 320)
        .background(
            LinearGradient(
                colors: [
                    Color.black.opacity(0.95),
                    Color.gray.opacity(0.72)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
        .clipShape(
            RoundedRectangle(cornerRadius: 30)
        )
        .overlay {
            RoundedRectangle(cornerRadius: 30)
                .stroke(
                    Color.white.opacity(0.09),
                    lineWidth: 1
                )
        }
    }
}

// MARK: - Vehicle Health

struct VehicleHealthCard: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 18) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Health baseline")
                        .font(.title3)
                        .fontWeight(.bold)

                    Text("Not completed yet")
                        .font(.subheadline)
                        .foregroundStyle(.orange)
                }

                Spacer()

                Image(systemName: "heart.text.square.fill")
                    .font(.system(size: 28))
            }

            ProgressView(value: 0.0)
                .tint(.orange)

            VStack(spacing: 0) {
                HealthSystemRow(
                    icon: "engine.combustion.fill",
                    title: "Engine",
                    status: "Not assessed"
                )

                Divider()

                HealthSystemRow(
                    icon: "thermometer.medium",
                    title: "Cooling",
                    status: "Not assessed"
                )

                Divider()

                HealthSystemRow(
                    icon: "circle.circle.fill",
                    title: "Brakes",
                    status: "Not assessed"
                )

                Divider()

                HealthSystemRow(
                    icon: "car.rear.road.lane",
                    title: "Suspension",
                    status: "Not assessed"
                )
            }

            HStack {
                Text("Start your baseline")
                    .font(.headline)

                Spacer()

                Image(systemName: "chevron.right")
                    .font(.caption)
                    .foregroundStyle(.secondary)
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

struct HealthSystemRow: View {
    let icon: String
    let title: String
    let status: String

    var body: some View {
        HStack(spacing: 13) {
            Image(systemName: icon)
                .font(.system(size: 18, weight: .semibold))
                .frame(width: 28)

            Text(title)
                .font(.subheadline)
                .fontWeight(.medium)

            Spacer()

            Text(status)
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .padding(.vertical, 13)
    }
}

// MARK: - Maintenance Summary

struct MaintenanceSummaryCard: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 18) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Upcoming maintenance")
                        .font(.title3)
                        .fontWeight(.bold)

                    Text("No schedule calculated yet")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }

                Spacer()

                Image(systemName: "calendar.badge.clock")
                    .font(.system(size: 27))
            }

            VStack(alignment: .leading, spacing: 10) {
                Label(
                    "Confirm your service history",
                    systemImage: "1.circle.fill"
                )

                Label(
                    "Add your current mileage",
                    systemImage: "2.circle.fill"
                )

                Label(
                    "Build your personalized schedule",
                    systemImage: "3.circle.fill"
                )
            }
            .font(.subheadline)

            HStack {
                Text("Build maintenance plan")
                    .font(.headline)

                Spacer()

                Image(systemName: "chevron.right")
                    .font(.caption)
                    .foregroundStyle(.secondary)
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

// MARK: - Service History

struct ServiceHistoryCard: View {
    var body: some View {
        HStack(spacing: 16) {
            ZStack {
                RoundedRectangle(cornerRadius: 18)
                    .fill(Color.primary.opacity(0.08))
                    .frame(width: 58, height: 58)

                Image(systemName: "clock.arrow.circlepath")
                    .font(.system(size: 25, weight: .semibold))
            }

            VStack(alignment: .leading, spacing: 5) {
                Text("No records added yet")
                    .font(.headline)

                Text(
                    "Log maintenance, repairs, inspections, and receipts."
                )
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.leading)
            }

            Spacer()

            Image(systemName: "chevron.right")
                .font(.caption)
                .foregroundStyle(.secondary)
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

// MARK: - Nearby Shops

struct NearbyShopsCard: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 18) {
            HStack {
                ZStack {
                    RoundedRectangle(cornerRadius: 18)
                        .fill(Color.primary.opacity(0.08))
                        .frame(width: 58, height: 58)

                    Image(systemName: "map.fill")
                        .font(.system(size: 25, weight: .semibold))
                }

                Spacer()

                Image(systemName: "location.fill")
                    .font(.title3)
                    .foregroundStyle(.secondary)
            }

            VStack(alignment: .leading, spacing: 6) {
                Text("Find a shop")
                    .font(.title3)
                    .fontWeight(.bold)

                Text(
                    "Search for dealerships, independent repair shops, specialists, and service centers near you."
                )
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.leading)
            }

            HStack {
                Label(
                    "Find shops",
                    systemImage: "magnifyingglass"
                )
                .font(.headline)

                Spacer()

                Image(systemName: "chevron.right")
                    .font(.caption)
                    .foregroundStyle(.secondary)
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

// MARK: - Maps Handoff

/// Zero-cost handoff to the user's own Maps app — no ratings API, no
/// network call this app makes, just a pre-filled search. Shared by the
/// incident-result "Find a shop" button (SomethingHappenedView, symptom-
/// specific repairSearchTerm), the Garage vehicle-detail "Find a shop"
/// card below, and the "Find a shop now" entry point on Something
/// Happened — all three use the exact same URL construction.
enum MapsHandoff {
    static func url(searchingFor searchTerm: String) -> URL? {
        var components = URLComponents(string: "http://maps.apple.com/")
        components?.queryItems = [
            URLQueryItem(name: "q", value: "\(searchTerm) near me")
        ]
        return components?.url
    }

    /// The generic term used wherever the search isn't tied to a specific
    /// reported problem (Garage vehicle detail, Something Happened's
    /// "Find a shop now" shortcut) — as opposed to a symptom-specific
    /// repairSearchTerm from an actual incident result.
    static let genericRepairSearchTerm = "auto repair shop"
}

// MARK: - Shared Home Components

struct HomeSectionHeader: View {
    let title: String
    let subtitle: String

    var body: some View {
        VStack(alignment: .leading, spacing: 3) {
            Text(title)
                .font(.title2)
                .fontWeight(.bold)

            Text(subtitle)
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
        .frame(
            maxWidth: .infinity,
            alignment: .leading
        )
        .padding(.top, 4)
    }
}

struct VehicleStat: View {
    let title: String
    let value: String

    var body: some View {
        VStack(spacing: 3) {
            Text(title)
                .font(.caption2)
                .foregroundStyle(.white.opacity(0.5))

            Text(value)
                .font(.caption)
                .fontWeight(.semibold)
                .foregroundStyle(.white)
                .lineLimit(1)
                .minimumScaleFactor(0.7)
        }
        .frame(maxWidth: .infinity)
    }
}

struct CompactHomeCard: View {
    let icon: String
    let title: String
    let subtitle: String

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack {
                Image(systemName: icon)
                    .font(.system(size: 22, weight: .semibold))

                Spacer()

                Image(systemName: "chevron.right")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Spacer()

            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.headline)

                Text(subtitle)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.leading)
            }
        }
        .padding(18)
        .frame(
            maxWidth: .infinity,
            minHeight: 145,
            alignment: .leading
        )
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

// MARK: - Temporary Destinations

struct PlaceholderDestinationView: View {
    let title: String
    let message: String

    var body: some View {
        VStack(spacing: 18) {
            Spacer()

            Text(title)
                .font(.largeTitle)
                .fontWeight(.bold)

            Text(message)
                .font(.title3)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)

            Spacer()
        }
        .padding(24)
        .navigationTitle(title)
        .navigationBarTitleDisplayMode(.inline)
    }
}

// MARK: - Reusable Components

struct ChoiceCard: View {
    let icon: String
    let title: String
    let subtitle: String

    var body: some View {
        HStack(spacing: 16) {
            Image(systemName: icon)
                .font(.system(size: 32))
                .frame(width: 42)

            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.title2)
                    .fontWeight(.semibold)

                Text(subtitle)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }

            Spacer()

            Image(systemName: "chevron.right")
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(20)
        .background(.thinMaterial)
        .clipShape(
            RoundedRectangle(cornerRadius: 20)
        )
    }
}

// MARK: - Preview

#Preview {
    ContentView()
}
