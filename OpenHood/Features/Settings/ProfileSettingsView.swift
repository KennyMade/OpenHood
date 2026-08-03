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
                UnavailableSettingsRow(title: "Terms")
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
