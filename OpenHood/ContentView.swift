import SwiftUI
import Combine

// MARK: - Vehicle Onboarding Data

final class VehicleOnboardingData: ObservableObject {
    @Published var manufacturer = ""
    @Published var model = ""
    @Published var year = ""
    @Published var transmission = ""
    @Published var trim = ""
    @Published var mileage = ""

    var vehicleName: String {
        let pieces = [year, manufacturer, model]
            .filter { !$0.isEmpty }

        if pieces.isEmpty {
            return "Your Vehicle"
        }

        return pieces.joined(separator: " ")
    }

    var transmissionDisplay: String {
        transmission.isEmpty ? "Transmission not confirmed" : transmission
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
                VehicleIntroView()
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
    }
}

// MARK: - Introduction

struct VehicleIntroView: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            Spacer()

            Image(systemName: "steeringwheel")
                .font(.system(size: 54))

            Text("Build your car’s digital home.")
                .font(.largeTitle)
                .fontWeight(.bold)

            Text(
                "Add the details once. OpenHood will use them to help you understand, care for, and plan around your actual vehicle."
            )
            .font(.title3)
            .foregroundStyle(.secondary)

            Spacer()

            NavigationLink {
                AddVehicleView()
            } label: {
                Text("Continue")
                    .font(.headline)
                    .frame(maxWidth: .infinity)
                    .padding()
            }
            .buttonStyle(.borderedProminent)
        }
        .padding(24)
    }
}

// MARK: - Add Vehicle Method

struct AddVehicleView: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                VStack(alignment: .leading, spacing: 10) {
                    Text("Add your vehicle")
                        .font(.largeTitle)
                        .fontWeight(.bold)

                    Text(
                        "Scan your VIN for a faster setup, or choose your vehicle manually."
                    )
                    .font(.body)
                    .foregroundStyle(.secondary)
                }

                NavigationLink {
                    VINScannerPreparationView()
                } label: {
                    ChoiceCard(
                        icon: "viewfinder",
                        title: "Scan your VIN",
                        subtitle: "Use your camera to identify your vehicle"
                    )
                }
                .buttonStyle(.plain)

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

                VStack(alignment: .leading, spacing: 8) {
                    Label(
                        "Where can I find my VIN?",
                        systemImage: "info.circle.fill"
                    )
                    .font(.headline)

                    Text(
                        "Look through the driver-side windshield or check the label inside the driver-side door jamb."
                    )
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                }
                .padding(18)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(.thinMaterial)
                .clipShape(
                    RoundedRectangle(cornerRadius: 20)
                )
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
                VStack(alignment: .leading, spacing: 8) {
                    Text("Choose your manufacturer")
                        .font(.largeTitle)
                        .fontWeight(.bold)

                    Text("Start by selecting the company that made your vehicle.")
                        .font(.body)
                        .foregroundStyle(.secondary)
                }

                ForEach(VehicleRegion.allCases) { region in
                    manufacturerSection(for: region)
                }
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
        selectedMake?.models ?? []
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 22) {
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

// MARK: - Year

struct YearView: View {
    @EnvironmentObject private var vehicle: VehicleOnboardingData

    private var selectedModel: VehicleModel? {
        VehicleCatalog.model(
            makeName: vehicle.manufacturer,
            modelName: vehicle.model
        )
    }

    private var years: [Int] {
        selectedModel?.supportedYears ?? []
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 22) {
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
                    LazyVGrid(
                        columns: [
                            GridItem(.flexible()),
                            GridItem(.flexible())
                        ],
                        spacing: 14
                    ) {
                        ForEach(years, id: \.self) { year in
                            NavigationLink {
                                TransmissionView()
                                    .onAppear {
                                        vehicle.year = String(year)
                                        vehicle.transmission = ""
                                        vehicle.trim = ""
                                    }
                            } label: {
                                Text(String(year))
                                    .font(.title2)
                                    .fontWeight(.bold)
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 22)
                                    .background(.thinMaterial)
                                    .clipShape(
                                        RoundedRectangle(cornerRadius: 18)
                                    )
                                    .overlay {
                                        RoundedRectangle(cornerRadius: 18)
                                            .stroke(
                                                Color.secondary.opacity(0.12),
                                                lineWidth: 1
                                            )
                                    }
                            }
                            .buttonStyle(.plain)
                        }
                    }
                }
            }
            .padding(24)
        }
        .navigationTitle("Year")
        .navigationBarTitleDisplayMode(.inline)
    }
}

// MARK: - Transmission

struct TransmissionView: View {
    @EnvironmentObject private var vehicle: VehicleOnboardingData

    private var selectedYear: Int? {
        Int(vehicle.year)
    }

    private var configuration: VehicleYearConfiguration? {
        guard let selectedYear else {
            return nil
        }

        return VehicleCatalog.configuration(
            makeName: vehicle.manufacturer,
            modelName: vehicle.model,
            year: selectedYear
        )
    }

    private var transmissions: [String] {
        configuration?.transmissions ?? []
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 18) {
                VStack(spacing: 9) {
                    Text("Choose your transmission")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .multilineTextAlignment(.center)

                    Text(vehicle.vehicleName)
                        .font(.body)
                        .foregroundStyle(.secondary)
                }
                .padding(.bottom, 6)

                if transmissions.isEmpty {
                    Text("Transmission information is not available yet.")
                        .font(.body)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(24)
                } else {
                    ForEach(transmissions, id: \.self) { transmission in
                        transmissionLink(
                            title: transmission
                        )
                    }
                }

                NavigationLink {
                    TrimView()
                        .onAppear {
                            vehicle.transmission = "Not confirmed"
                            vehicle.trim = ""
                        }
                } label: {
                    ChoiceCard(
                        icon: "questionmark.circle.fill",
                        title: "I’m not sure",
                        subtitle: "You can confirm this later"
                    )
                }
                .buttonStyle(.plain)
            }
            .padding(24)
        }
        .navigationTitle("Transmission")
        .navigationBarTitleDisplayMode(.inline)
    }

    private func transmissionLink(
        title: String
    ) -> some View {
        NavigationLink {
            TrimView()
                .onAppear {
                    vehicle.transmission = title
                    vehicle.trim = ""
                }
        } label: {
            ChoiceCard(
                icon: transmissionIcon(for: title),
                title: title,
                subtitle: transmissionSubtitle(for: title)
            )
        }
        .buttonStyle(.plain)
    }

    private func transmissionIcon(
        for transmission: String
    ) -> String {
        if transmission.localizedCaseInsensitiveContains("manual") {
            return "gearshape.2.fill"
        }

        return "gearshape.fill"
    }

    private func transmissionSubtitle(
        for transmission: String
    ) -> String {
        if transmission.localizedCaseInsensitiveContains("manual") {
            return "Driver-operated gear selection"
        }

        return "Automatic gear selection"
    }
}

// MARK: - Trim

struct TrimView: View {
    @EnvironmentObject private var vehicle: VehicleOnboardingData

    private var selectedYear: Int? {
        Int(vehicle.year)
    }

    private var configuration: VehicleYearConfiguration? {
        guard let selectedYear else {
            return nil
        }

        return VehicleCatalog.configuration(
            makeName: vehicle.manufacturer,
            modelName: vehicle.model,
            year: selectedYear
        )
    }

    private var trims: [String] {
        configuration?.trims ?? []
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 18) {
                VStack(spacing: 9) {
                    Text("Choose your trim")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .multilineTextAlignment(.center)

                    Text(
                        "Select the version that best matches your \(vehicle.year) \(vehicle.model)."
                    )
                    .font(.body)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                }
                .padding(.bottom, 6)

                if trims.isEmpty {
                    Text("Trim information is not available yet.")
                        .font(.body)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(24)
                } else {
                    ForEach(trims, id: \.self) { trim in
                        trimLink(title: trim)
                    }
                }

                NavigationLink {
                    MileageView()
                        .onAppear {
                            vehicle.trim = "Not confirmed"
                        }
                } label: {
                    ChoiceCard(
                        icon: "questionmark.circle.fill",
                        title: "I’m not sure",
                        subtitle: "You can confirm this later"
                    )
                }
                .buttonStyle(.plain)
            }
            .padding(24)
        }
        .navigationTitle("Trim")
        .navigationBarTitleDisplayMode(.inline)
    }

    private func trimLink(
        title: String
    ) -> some View {
        NavigationLink {
            MileageView()
                .onAppear {
                    vehicle.trim = title
                }
        } label: {
            ChoiceCard(
                icon: trimIcon(for: title),
                title: title,
                subtitle: trimSubtitle(for: title)
            )
        }
        .buttonStyle(.plain)
    }

    private func trimIcon(
        for trim: String
    ) -> String {
        if trim.localizedCaseInsensitiveContains("NISMO") {
            return "flag.checkered"
        }

        if trim.localizedCaseInsensitiveContains("Roadster") {
            return "sun.max.fill"
        }

        if trim.localizedCaseInsensitiveContains("Track") {
            return "gauge.with.dots.needle.67percent"
        }

        return "car.side.fill"
    }

    private func trimSubtitle(
        for trim: String
    ) -> String {
        if trim.localizedCaseInsensitiveContains("NISMO") {
            return "NISMO performance configuration"
        }

        if trim.localizedCaseInsensitiveContains("Roadster") {
            return "Convertible configuration"
        }

        if trim.localizedCaseInsensitiveContains("Track") {
            return "Track-focused equipment"
        }

        if trim.localizedCaseInsensitiveContains("Touring") {
            return "Comfort and premium equipment"
        }

        if trim.localizedCaseInsensitiveContains("Performance") {
            return "Performance-focused equipment"
        }

        if trim.localizedCaseInsensitiveContains("Anniversary") {
            return "Special-edition configuration"
        }

        return "Factory trim configuration"
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
                        "154,000",
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
                    MaintenanceKnowledgeView()
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
                    MaintenanceKnowledgeView()
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

                NavigationLink {
                    VehicleHomeView()
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

                NavigationLink {
                    VehicleHomeView()
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

                NavigationLink {
                    VehicleHomeView()
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

                NavigationLink {
                    VehicleHomeView()
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

            NavigationLink {
                VehicleHomeView()
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

    var body: some View {
        ScrollView {
            VStack(spacing: 22) {
                VStack(alignment: .leading, spacing: 5) {
                    Text("Good afternoon")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)

                    Text("What brings you under the hood?")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                }
                .frame(
                    maxWidth: .infinity,
                    alignment: .leading
                )

                NavigationLink {
                    VehicleDashboardView()
                } label: {
                    VehicleStageCard()
                }
                .buttonStyle(.plain)

                NavigationLink {
                    SomethingHappenedPlaceholderView()
                } label: {
                    SomethingHappenedCard()
                }
                .buttonStyle(.plain)

                HStack(spacing: 14) {
                    NavigationLink {
                      LearnMyCarView()
                    } label: {
                        CompactHomeCard(
                            icon: "book.closed.fill",
                            title: "Learn",
                            subtitle: "Understand your car"
                        )
                    }
                    .buttonStyle(.plain)

                    NavigationLink {
                    VehiclePlanView()
                    } label: {
                        CompactHomeCard(
                            icon: "wrench.and.screwdriver.fill",
                            title: "Plan",
                            subtitle: "Build what comes next"
                        )
                    }
                    .buttonStyle(.plain)
                }

                Spacer(minLength: 20)
            }
            .padding(20)
        }
        .background(Color(.systemGroupedBackground))
        .navigationTitle("OpenHood")
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(true)
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
// MARK: - Vehicle Dashboard

struct VehicleDashboardView: View {
    @EnvironmentObject private var vehicle: VehicleOnboardingData

    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                VStack(alignment: .leading, spacing: 5) {
                    Text(vehicle.vehicleName)
                        .font(.largeTitle)
                        .fontWeight(.bold)

                    Text("Your complete vehicle overview")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                .frame(maxWidth: .infinity, alignment: .leading)

                VehicleProfileProgressCard()

                HomeSectionHeader(
                    title: "Vehicle health",
                    subtitle: "What OpenHood currently knows"
                )

                NavigationLink {
                    PlaceholderDestinationView(
                        title: "Vehicle Health",
                        message: "Your vehicle-health baseline will appear here after you confirm service history, symptoms, and inspection information."
                    )
                } label: {
                    VehicleHealthCard()
                }
                .buttonStyle(.plain)

                HomeSectionHeader(
                    title: "Maintenance",
                    subtitle: "Stay ahead of what comes next"
                )

                NavigationLink {
                    PlaceholderDestinationView(
                        title: "Maintenance Plan",
                        message: "OpenHood will build a maintenance plan using your mileage, vehicle configuration, service history, and factory guidance."
                    )
                } label: {
                    MaintenanceSummaryCard()
                }
                .buttonStyle(.plain)

                HomeSectionHeader(
                    title: "Service history",
                    subtitle: "Everything done to your vehicle"
                )

                NavigationLink {
                    PlaceholderDestinationView(
                        title: "Service History",
                        message: "Add repairs, maintenance, inspections, receipts, dates, mileage, parts, and shop information here."
                    )
                } label: {
                    ServiceHistoryCard()
                }
                .buttonStyle(.plain)

                HomeSectionHeader(
                    title: "Help nearby",
                    subtitle: "Find the right place for the problem"
                )

                NavigationLink {
                    PlaceholderDestinationView(
                        title: "Nearby Shops",
                        message: "OpenHood will match nearby repair shops and service centers to your vehicle and selected problem."
                    )
                } label: {
                    NearbyShopsCard()
                }
                .buttonStyle(.plain)

                HomeSectionHeader(
                    title: "Vehicle resources",
                    subtitle: "Knowledge, documents, and ownership tools"
                )

                LazyVGrid(
                    columns: [
                        GridItem(.flexible()),
                        GridItem(.flexible())
                    ],
                    spacing: 14
                ) {
                    NavigationLink {
                        PlaceholderDestinationView(
                            title: "Specifications",
                            message: "Engine, drivetrain, fluids, capacities, tires, and factory specifications will live here."
                        )
                    } label: {
                        CompactHomeCard(
                            icon: "gauge.with.dots.needle.50percent",
                            title: "Specs",
                            subtitle: "Factory information"
                        )
                    }
                    .buttonStyle(.plain)

                    NavigationLink {
                        PlaceholderDestinationView(
                            title: "Documents",
                            message: "Receipts, inspections, manuals, estimates, warranties, and reports will live here."
                        )
                    } label: {
                        CompactHomeCard(
                            icon: "doc.text.fill",
                            title: "Documents",
                            subtitle: "Keep every record"
                        )
                    }
                    .buttonStyle(.plain)

                    NavigationLink {
                        PlaceholderDestinationView(
                            title: "Known Concerns",
                            message: "Known concerns and inspection-first guidance for your \(vehicle.model) will live here."
                        )
                    } label: {
                        CompactHomeCard(
                            icon: "exclamationmark.triangle.fill",
                            title: "Concerns",
                            subtitle: "Know what to inspect"
                        )
                    }
                    .buttonStyle(.plain)

                    NavigationLink {
                        PlaceholderDestinationView(
                            title: "Owner Resources",
                            message: "Owner manuals, recall resources, and factory publications will live here."
                        )
                    } label: {
                        CompactHomeCard(
                            icon: "books.vertical.fill",
                            title: "Resources",
                            subtitle: "Manuals and recalls"
                        )
                    }
                    .buttonStyle(.plain)
                }

                Spacer(minLength: 30)
            }
            .padding(20)
        }
        .background(Color(.systemGroupedBackground))
        .navigationTitle("My Vehicle")
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

// MARK: - Profile Progress

struct VehicleProfileProgressCard: View {
    @EnvironmentObject private var vehicle: VehicleOnboardingData

    private var completedFields: Int {
        [
            vehicle.manufacturer,
            vehicle.model,
            vehicle.year,
            vehicle.transmission,
            vehicle.trim,
            vehicle.mileage
        ]
        .filter {
            !$0.isEmpty &&
            $0 != "Not confirmed"
        }
        .count
    }

    private var completion: Double {
        Double(completedFields) / 6.0
    }

    private var completionPercentage: Int {
        Int(completion * 100)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Vehicle profile")
                        .font(.headline)

                    Text("\(completionPercentage)% complete")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }

                Spacer()

                Image(systemName: "checklist")
                    .font(.title2)
            }

            ProgressView(value: completion)
                .tint(.primary)

            Text(
                "A more complete profile helps OpenHood provide more relevant maintenance and diagnostic guidance."
            )
            .font(.caption)
            .foregroundStyle(.secondary)
        }
        .padding(20)
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
                Text("Find nearby help")
                    .font(.title3)
                    .fontWeight(.bold)

                Text(
                    "Search for dealerships, independent repair shops, specialists, and service centers matched to your problem."
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

struct SomethingHappenedPlaceholderView: View {
    @EnvironmentObject private var vehicle: VehicleOnboardingData

    var body: some View {
        VStack(spacing: 18) {
            Spacer()

            Image(systemName: "waveform.and.magnifyingglass")
                .font(.system(size: 58))

            Text("Something happened")
                .font(.largeTitle)
                .fontWeight(.bold)

            Text(
                "Tell OpenHood what happened with your \(vehicle.model) using a photo, your voice, or text."
            )
            .font(.title3)
            .foregroundStyle(.secondary)
            .multilineTextAlignment(.center)

            Spacer()
        }
        .padding(24)
        .navigationTitle("Something Happened")
        .navigationBarTitleDisplayMode(.inline)
    }
}

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
