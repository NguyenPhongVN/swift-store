import SwiftUI
import StoreKit

/// A beautiful, modern ProductViewStyle with enhanced loading animations
/// Features gradient spinners, smooth transitions, and elegant visual effects
struct SpinnerWhenLoadingStyle: ProductViewStyle {
    @State private var rotationAngle: Double = 0
    @State private var pulseScale: CGFloat = 1.0
    @State private var isPressed = false
    @State private var showSuccessAnimation = false

    func makeBody(configuration: Configuration) -> some View {
        //        let state: Product.TaskState = .loading
        let state = configuration.state
        switch state {
            case .loading:
                VStack(spacing: 16) {
                    // Enhanced Spinner with Gradient
                    ZStack {
                        // Outer rotating ring
                        Circle()
                            .stroke(
                                LinearGradient(
                                    colors: [.blue.opacity(0.3), .purple.opacity(0.3)],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ),
                                lineWidth: 3
                            )
                            .frame(width: 40, height: 40)
                            .rotationEffect(.degrees(rotationAngle))
                            .animation(
                                .linear(duration: 2)
                                .repeatForever(autoreverses: false),
                                value: rotationAngle
                            )

                        // Inner pulsing circle
                        Circle()
                            .fill(
                                LinearGradient(
                                    colors: [.blue, .purple],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .frame(width: 16, height: 16)
                            .scaleEffect(pulseScale)
                            .animation(
                                .easeInOut(duration: 1)
                                .repeatForever(autoreverses: true),
                                value: pulseScale
                            )
                    }

                    // Loading Text with Typography
                    VStack(spacing: 4) {
                        Text("Loading Product")
                            .font(.headline)
                            .fontWeight(.semibold)
                            .foregroundStyle(.primary)

                        Text("Fetching the latest details...")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 24)
                .padding(.horizontal, 20)
                .spinnerCardBackground()
                .onAppear {
                    rotationAngle = 360
                    pulseScale = 1.2
                }

            case .success(let product):
                VStack(spacing: 20) {
                    HStack(spacing: 16) {
                        // Product Icon with Success Animation
                        ZStack {
                            RoundedRectangle(cornerRadius: 12)
                                .fill(
                                    LinearGradient(
                                        colors: [.green.opacity(0.1), .mint.opacity(0.1)],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )

                                .scaleEffect(showSuccessAnimation ? 1.1 : 1.0)
                                .animation(.easeInOut(duration: 0.6).delay(0.2), value: showSuccessAnimation)

                            configuration.icon
                                .font(.title2)
                                .foregroundStyle(
                                    LinearGradient(
                                        colors: [.green, .mint],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                        }
                        .frame(width: 24, height: 24)
                        // Product Information
                        VStack(alignment: .leading, spacing: 6) {
                            Text(product.displayName)
                                .font(.title3)
                                .fontWeight(.bold)
                                .foregroundStyle(.primary)
                                .multilineTextAlignment(.leading)
                                .opacity(showSuccessAnimation ? 1 : 0)
                                .offset(y: showSuccessAnimation ? 0 : 10)
                                .animation(.easeOut(duration: 0.5).delay(0.4), value: showSuccessAnimation)

                            Text(product.description)
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                                .lineLimit(2)
                                .multilineTextAlignment(.leading)
                                .opacity(showSuccessAnimation ? 1 : 0)
                                .offset(y: showSuccessAnimation ? 0 : 10)
                                .animation(.easeOut(duration: 0.5).delay(0.6), value: showSuccessAnimation)
                        }

                        Spacer()

                        // Price with Badge
                        VStack(alignment: .trailing, spacing: 6) {
                            Text(product.displayPrice)
                                .font(.title2)
                                .fontWeight(.black)
                                .foregroundStyle(
                                    LinearGradient(
                                        colors: [.green, .mint],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                                .opacity(showSuccessAnimation ? 1 : 0)
                                .scaleEffect(showSuccessAnimation ? 1 : 0.8)
                                .animation(.spring(response: 0.6, dampingFraction: 0.8).delay(0.8), value: showSuccessAnimation)
                        }
                    }
                }
                .padding(24)
                .spinnerCardBackground(cornerRadius: 24, strokeColors: [.green.opacity(0.3), .mint.opacity(0.3)])
                .shadow(color: .black.opacity(0.1), radius: 15, x: 0, y: 8)
                .shadow(color: .green.opacity(0.1), radius: 20, x: 0, y: 10)
                .onAppear {
                    withAnimation {
                        showSuccessAnimation = true
                    }
                }

            case .failure(let error):
                StatusCard(
                    iconName: "exclamationmark.triangle.fill",
                    iconTint: .orange,
                    circleGradientColors: [.orange.opacity(0.2), .red.opacity(0.2)],
                    title: "Unable to Load Product",
                    message: error.localizedDescription,
                    showsRetry: true,
                    accentColor: .orange
                )

            case .unavailable:
                StatusCard(
                    iconName: "xmark.circle.fill",
                    iconTint: .red,
                    circleGradientColors: [.red.opacity(0.2), .pink.opacity(0.2)],
                    title: "Product Unavailable",
                    message: "This product is currently not available for purchase.",
                    accentColor: .red
                )

            @unknown default:
                ProductView(configuration)
        }
    }
}

// MARK: - Shared Card Styling

private extension View {
    /// Material card background shared by this style's states. The loading
    /// state uses the defaults; the success state overrides corner radius and
    /// stroke colors.
    func spinnerCardBackground(cornerRadius: CGFloat = 20, strokeColors: [Color] = [.blue.opacity(0.2), .purple.opacity(0.2)]) -> some View {
        background(
            RoundedRectangle(cornerRadius: cornerRadius)
                .fill(.ultraThinMaterial)
                .overlay(
                    RoundedRectangle(cornerRadius: cornerRadius)
                        .stroke(
                            LinearGradient(
                                colors: strokeColors,
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 1
                        )
                )
        )
        .shadow(color: .black.opacity(0.1), radius: 10, x: 0, y: 5)
    }
}

#Preview("Spinner Loading Style") {
    VStack(spacing: 16) {

        // Multiple Products Preview
        VStack(spacing: 12) {
            ForEach(Array(Constants.products.enumerated()), id: \.offset) { offset, id in
                ProductView(id: id) {
                    ProductImage(productId: id)
                }
                .productViewStyle(SpinnerWhenLoadingStyle())
                .padding(.horizontal, 24)
            }
        }
    }
}
