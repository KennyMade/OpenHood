import SwiftUI

enum PrimaryTab: Hashable {
    case home
    case garage
    case help
    case plan
    case learn
}

struct MainTabView: View {
    @State private var selectedTab: PrimaryTab = .home

    var body: some View {
        TabView(selection: $selectedTab) {
            Tab("Home", systemImage: "house.fill", value: .home) {
                NavigationStack {
                    VehicleHomeView()
                }
            }

            Tab("Garage", systemImage: "car.2.fill", value: .garage) {
                NavigationStack {
                    GarageView()
                }
            }

            Tab("Help", systemImage: "waveform.and.magnifyingglass", value: .help) {
                NavigationStack {
                    SomethingHappenedPlaceholderView()
                }
            }

            // Plan tab hidden for this build — not part of the app's
            // current story (Garage + Something Happened + Profile) while
            // it's still early. The Plan code itself (VehiclePlanView and
            // friends, ~1,274 lines) is untouched on disk, just not
            // presented here.
            // Tab("Plan", systemImage: "wrench.and.screwdriver.fill", value: .plan) {
            //     NavigationStack {
            //         VehiclePlanView()
            //     }
            // }

            Tab("Learn", systemImage: "book.closed.fill", value: .learn) {
                NavigationStack {
                    LearnMyCarView()
                }
            }
        }
    }
}
