import SwiftUI

struct ContentView: View {
    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                Spacer()

                Image(systemName: "car.side.fill")
                    .font(.system(size: 60))

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
}

struct VehicleIntroView: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            Spacer()

            Image(systemName: "steeringwheel")
                .font(.system(size: 54))

            Text("Let’s get to know your vehicle.")
                .font(.largeTitle)
                .fontWeight(.bold)

            Text("We’ll build your digital vehicle so you can explore it, learn from it, and personalize it.")
                .font(.title3)
                .foregroundStyle(.secondary)

            Spacer()

            NavigationLink {
                ManufacturerView()
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

struct ManufacturerView: View {
    var body: some View {
        VStack(spacing: 24) {
            Text("Choose your manufacturer")
                .font(.largeTitle)
                .fontWeight(.bold)
                .multilineTextAlignment(.center)

            NavigationLink {
                ModelView()
            } label: {
                VStack(spacing: 12) {
                    Image(systemName: "car.side.fill")
                        .font(.system(size: 48))

                    Text("Nissan")
                        .font(.title2)
                        .fontWeight(.semibold)
                }
                .frame(maxWidth: .infinity)
                .padding(30)
            }
            .buttonStyle(.bordered)

            Spacer()
        }
        .padding(24)
        .navigationTitle("Manufacturer")
        .navigationBarTitleDisplayMode(.inline)
    }
}
struct ModelView: View {
    var body: some View {
        VStack(spacing: 24) {
            Text("Choose your model")
                .font(.largeTitle)
                .fontWeight(.bold)
                .multilineTextAlignment(.center)

            NavigationLink {
                YearView()
            } label: {
                VStack(spacing: 12) {
                    Image(systemName: "car.side.fill")
                        .font(.system(size: 54))

                    Text("350Z")
                        .font(.title2)
                        .fontWeight(.semibold)

                    Text("Nissan")
                        .foregroundStyle(.secondary)
                }
                .frame(maxWidth: .infinity)
                .padding(30)
            }
            .buttonStyle(.bordered)

            Spacer()
        }
        .padding(24)
        .navigationTitle("Model")
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct YearView: View {
    var body: some View {
        VStack(spacing: 24) {
            Text("Choose your year")
                .font(.largeTitle)
                .fontWeight(.bold)

            Text("2006")
                .font(.system(size: 44, weight: .bold))
                .frame(maxWidth: .infinity)
                .padding(30)
                .background(.thinMaterial)
                .clipShape(RoundedRectangle(cornerRadius: 20))

            Spacer()
        }
        .padding(24)
        .navigationTitle("Year")
        .navigationBarTitleDisplayMode(.inline)
    }
}
#Preview {
    ContentView()
}
