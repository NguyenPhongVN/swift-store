import SwiftUI

/// Shared status presentation for product view styles: an icon in a tinted
/// gradient circle above a title and message, optionally with a retry button,
/// wrapped in a material card accented by `accentColor`.
///
/// Used by the failure / unavailable / unknown states of both custom product
/// view styles; per-state differences are passed in as parameters.
struct StatusCard: View {

    let iconName: String
    let iconTint: Color
    let circleGradientColors: [Color]
    let title: String
    let message: String
    var showsRetry: Bool = false
    let accentColor: Color

    var body: some View {
        VStack(spacing: 16) {
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: circleGradientColors,
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 60, height: 60)

                Image(systemName: iconName)
                    .font(.title2)
                    .foregroundStyle(iconTint)
            }

            VStack(spacing: 8) {
                Text(title)
                    .font(.headline)
                    .fontWeight(.semibold)

                Text(message)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
            }

            if showsRetry {
                Button("Retry") {
                    // Retry logic would be handled by the parent view
                }
                .buttonStyle(.borderedProminent)
                .controlSize(.large)
            }
        }
        .padding(24)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(.ultraThinMaterial)
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(accentColor.opacity(0.3), lineWidth: 1)
                )
        )
        .shadow(color: accentColor.opacity(0.2), radius: 15, x: 0, y: 8)
    }
}
