import SwiftUI

struct ProfileSettingsView: View {
    @EnvironmentObject private var garageStore: GarageStore
    @EnvironmentObject private var incidentStore: IncidentStore
    @State private var isConfirmingErase = false

    private var activeVehicleName: String {
        guard let vehicle = garageStore.activeVehicle else {
            return "None"
        }

        let name = [vehicle.year.map(String.init), vehicle.make, vehicle.model]
            .compactMap { value in
                guard let value, !value.isEmpty else { return nil }
                return value
            }
            .joined(separator: " ")
        return name.isEmpty ? "Information needed" : name
    }

    private var version: String {
        Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String
            ?? "Not available"
    }

    private var build: String {
        Bundle.main.object(forInfoDictionaryKey: "CFBundleVersion") as? String
            ?? "Not available"
    }

    var body: some View {
        List {
            Section("Profile") {
                LabeledContent("Status", value: "Local profile")
                LabeledContent("Account", value: "No account connected")
                LabeledContent("Active vehicle", value: activeVehicleName)
                LabeledContent(
                    "Vehicles in Garage",
                    value: garageStore.vehicles.count.formatted()
                )
            }

            Section("About OpenHood") {
                LabeledContent("App", value: "OpenHood")
                LabeledContent("Version", value: version)
                LabeledContent("Build", value: build)
            }

            Section("Privacy and Data") {
                Text("Vehicle and Garage information is stored locally on this device.")
                Text("Help drafts, incidents, and saved guidance are stored locally on this device.")
                Text("No cloud synchronization or online account is currently connected.")
            }

            Section("Legal and Support") {
                UnavailableSettingsRow(title: "Privacy Policy")
                NavigationLink("Terms") { LegalDisclaimerView() }
                UnavailableSettingsRow(title: "Support")
            }

            Section {
                Button("Erase OpenHood Data", role: .destructive) {
                    isConfirmingErase = true
                }
            } footer: {
                Text("This controls OpenHood information stored by this app on this device.")
            }
        }
        .navigationTitle("Profile & Settings")
        .navigationBarTitleDisplayMode(.inline)
        .confirmationDialog(
            "Erase OpenHood Data?",
            isPresented: $isConfirmingErase,
            titleVisibility: .visible
        ) {
            Button("Erase OpenHood Data", role: .destructive) {
                incidentStore.eraseAll()
                garageStore.eraseAll()
            }

            Button("Cancel", role: .cancel) {}
        } message: {
            Text("This removes all saved vehicles, the active-vehicle selection, Help drafts, saved incidents, and saved guidance snapshots from this device.")
        }
    }
}

private struct UnavailableSettingsRow: View {
    let title: String

    var body: some View {
        LabeledContent(title, value: "Not configured yet")
    }
}

struct LegalDisclaimerView: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                Text("Terms and Disclaimer")
                    .font(.largeTitle)
                    .fontWeight(.bold)

                Text("This is general information, not legal advice. Consult an attorney for guidance specific to your situation.")
                    .font(.footnote)
                    .foregroundStyle(.secondary)

                disclaimerSection(
                    title: "Educational information only",
                    body: "OpenHood provides general automotive information intended to help you understand possible causes of a vehicle concern and prepare for a conversation with a qualified mechanic. It is not automotive, safety, legal, or financial advice, and it is not a diagnosis of your vehicle."
                )

                disclaimerSection(
                    title: "Not a substitute for professional inspection",
                    body: "OpenHood has not physically inspected your vehicle. Only a qualified mechanic, using direct inspection and testing, can confirm the actual cause of a vehicle concern. Always have your vehicle inspected by a qualified professional before making repair decisions."
                )

                disclaimerSection(
                    title: "Emergencies",
                    body: "If you are in immediate danger, experiencing a vehicle emergency, or unsure whether it is safe to continue driving, stop in a safe location and contact emergency services or roadside assistance. Do not rely on OpenHood in an emergency."
                )

                disclaimerSection(
                    title: "No guarantee of accuracy",
                    body: "OpenHood's content is reviewed against general automotive information, but vehicles, conditions, and situations vary. OpenHood does not guarantee that any information provided is complete, current, or accurate for your specific vehicle."
                )

                disclaimerSection(
                    title: "Your responsibility",
                    body: "Decisions about vehicle repair, maintenance, and safety are your responsibility. You should independently verify any information before acting on it, and you assume all risk associated with your use of OpenHood."
                )

                disclaimerSection(
                    title: "No professional relationship",
                    body: "Using OpenHood does not create a mechanic-client relationship, an inspection, or any professional relationship between you and OpenHood."
                )

                disclaimerSection(
                    title: "Limitation of liability",
                    body: "To the maximum extent permitted by law, OpenHood and its developer are not liable for any damages, losses, or costs arising from your use of the app or reliance on its content, including but not limited to vehicle damage, personal injury, or repair costs."
                )

                Text("These terms may be updated as OpenHood evolves. They are provided as general information and are not a substitute for advice from a licensed attorney.")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
                    .padding(.top, 8)
            }
            .padding(24)
        }
        .background(Color(.systemGroupedBackground))
        .navigationTitle("Terms")
        .navigationBarTitleDisplayMode(.inline)
    }

    @ViewBuilder
    private func disclaimerSection(title: String, body: String) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.headline)
            Text(body)
                .foregroundStyle(.secondary)
        }
    }
}
