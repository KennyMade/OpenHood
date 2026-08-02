import SwiftUI

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
