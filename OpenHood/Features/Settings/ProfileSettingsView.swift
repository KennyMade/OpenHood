import SwiftUI

struct ProfileSettingsView: View {
    @EnvironmentObject private var garageStore: GarageStore
    @EnvironmentObject private var incidentStore: IncidentStore
    @State private var isConfirmingErase = false
    /// Backs the Home screen's personalized greeting (VehicleHomeView.
    /// timeBasedGreeting) via the same "ownerDisplayName" AppStorage key.
    /// Optional by design — an empty value just means the greeting falls
    /// back to plain "Good morning"/"Good afternoon"/"Good evening" with
    /// no name suffix, so nobody is forced to fill this in.
    @AppStorage("ownerDisplayName") private var ownerDisplayName: String = ""

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
            Section {
                LabeledContent("Your name") {
                    TextField("Optional", text: $ownerDisplayName)
                        .multilineTextAlignment(.trailing)
                }
                LabeledContent("Status", value: "Local profile")
                LabeledContent("Account", value: "No account connected")
                LabeledContent("Active vehicle", value: activeVehicleName)
                LabeledContent(
                    "Vehicles in Garage",
                    value: garageStore.vehicles.count.formatted()
                )
            } header: {
                Text("Profile")
            } footer: {
                Text("Your name is used only for the greeting on the Home screen and is stored on this device.")
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
                NavigationLink("Privacy Policy") { PrivacyPolicyView() }
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

/// Separate from LegalDisclaimerView on purpose — a privacy policy and a
/// liability disclaimer are two different documents with two different
/// jobs (data practices vs. limiting liability), and Apple's App Store
/// Connect requires a privacy policy specifically before an app can go
/// through TestFlight external testing or App Store submission. This
/// content is a factual description of what OpenHood actually does,
/// verified directly against the codebase rather than assumed: no
/// network calls, no analytics or tracking SDKs, and no camera/location/
/// contacts permission requests exist anywhere in the project as of this
/// writing (checked via full-project search, 2026-08-08). Garage
/// vehicles, incident reports, saved guidance, and the optional display
/// name are all stored with plain local UserDefaults — see
/// GaragePersistence.swift and IncidentPersistence.swift.
///
/// This in-app screen is necessary but not sufficient on its own: Apple's
/// App Store Connect requires a privacy policy URL (a real, publicly
/// hosted web page), not just in-app text, in the TestFlight/App Store
/// metadata. This content should be published at a public URL (a simple
/// static page works fine) before setting up external TestFlight testing
/// or App Store submission.
struct PrivacyPolicyView: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                Text("Privacy Policy")
                    .font(.largeTitle)
                    .fontWeight(.bold)

                Text("This describes what OpenHood does and does not do with your information. It is provided as general information and is not a substitute for advice from a licensed attorney.")
                    .font(.footnote)
                    .foregroundStyle(.secondary)

                privacySection(
                    title: "What OpenHood collects",
                    body: "OpenHood only stores what you enter yourself: vehicle details you add to your Garage, incident reports and guidance you save through Something Happened, and an optional display name. OpenHood does not collect anything automatically, and does not ask for your name, email, phone number, or any account information to use the app."
                )

                privacySection(
                    title: "Where your information is stored",
                    body: "Everything is stored locally on your device only, using Apple's standard on-device app storage. OpenHood has no servers, no account system, and no cloud synchronization — your information never leaves your device through OpenHood."
                )

                privacySection(
                    title: "What OpenHood does not do",
                    body: "OpenHood does not use analytics, advertising, or tracking services of any kind. It does not request access to your camera, location, contacts, photos, or microphone. It does not share, sell, or transmit your information to any third party, because it has no network connection through which to do so."
                )

                privacySection(
                    title: "Apple's own data",
                    body: "Apple may independently collect standard operational data through the App Store or TestFlight, such as crash reports (only if you opt in through your device settings) or download and usage statistics. This is governed by Apple's own privacy policy, not OpenHood's, and OpenHood has no access to it."
                )

                privacySection(
                    title: "Deleting your information",
                    body: "You can permanently remove everything OpenHood has stored at any time using \"Erase OpenHood Data\" in Profile & Settings. This cannot be undone."
                )

                privacySection(
                    title: "If this changes",
                    body: "If a future version of OpenHood adds a feature that transmits data anywhere — such as cloud sync or an online vehicle-lookup service — this policy will be updated to describe it clearly before that feature is available, not after."
                )

                Text("Last reviewed against the app's actual code on August 8, 2026. This policy will be kept in sync as OpenHood's features change.")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
                    .padding(.top, 8)
            }
            .padding(24)
        }
        .background(Color(.systemGroupedBackground))
        .navigationTitle("Privacy Policy")
        .navigationBarTitleDisplayMode(.inline)
    }

    @ViewBuilder
    private func privacySection(title: String, body: String) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.headline)
            Text(body)
                .foregroundStyle(.secondary)
        }
    }
}
