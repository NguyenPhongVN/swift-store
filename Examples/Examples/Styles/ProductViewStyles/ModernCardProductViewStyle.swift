import SwiftUI
import StoreKit

/// A premium, glassmorphism-inspired product view style with stunning visual effects
/// Features gradient backgrounds, sophisticated shadows, and smooth animations
struct ModernCardProductViewStyle: ProductViewStyle {
    @State private var isPressed = false

    func makeBody(configuration: Configuration) -> some View {
//        let state: Product.TaskState = .loading
        let state = configuration.state
        switch state {
            case .loading:
                HStack(spacing: 16) {
                    ProgressView()
                        .progressViewStyle(.circular)
                        .scaleEffect(1.2)
                        .tint(.blue)

                    VStack(alignment: .leading, spacing: 4) {
                        Text("Loading product...")
                            .font(.headline)
                            .fontWeight(.medium)
                        Text("Please wait while we fetch the details")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 24)
                .padding(.horizontal, 20)
                .demoCardBackground()

            case .success(let product):
                VStack(alignment: .leading, spacing: 20) {
                    HStack(spacing: 20) {
                        // Enhanced Product Icon with Gradient Background
                        configuration.icon
                            .font(.body)
                            .foregroundStyle(
                                LinearGradient(
                                    colors: [.blue, .purple],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .background {
                                LinearGradient(
                                    colors: [.blue.opacity(0.1), .purple.opacity(0.1)],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                                .clipShape(.circle)
                            }
                            .frame(width: 24, height: 24)
                        // Enhanced Product Info
                        VStack(alignment: .leading, spacing: 6) {
                            Text(product.displayName)
                                .font(.title3)
                                .fontWeight(.bold)
                                .foregroundStyle(.primary)
                                .multilineTextAlignment(.leading)

                            Text(product.description)
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                                .lineLimit(3)
                                .multilineTextAlignment(.leading)
                        }

                        Spacer()

                        // Enhanced Price with Badge Design
                        VStack(alignment: .trailing, spacing: 4) {
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

                            Text("Premium")
                                .font(.caption)
                                .fontWeight(.semibold)
                                .foregroundStyle(.white)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 2)
                                .background(
                                    Capsule()
                                        .fill(
                                            LinearGradient(
                                                colors: [.green, .mint],
                                                startPoint: .leading,
                                                endPoint: .trailing
                                            )
                                        )
                                )
                        }
                    }
                }
                .padding()
                .demoCardBackground()
                .scaleEffect(isPressed ? 0.98 : 1.0)
                .animation(.easeInOut(duration: 0.1), value: isPressed)
                .onTapGesture {
                    withAnimation(.easeInOut(duration: 0.1)) {
                        isPressed = true
                    }
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                        withAnimation(.easeInOut(duration: 0.1)) {
                            isPressed = false
                        }
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
                StatusCard(
                    iconName: "questionmark.circle.fill",
                    iconTint: .gray,
                    circleGradientColors: [.gray.opacity(0.2), .secondary.opacity(0.2)],
                    title: "Unknown State",
                    message: "An unexpected state occurred while loading the product.",
                    accentColor: .gray
                )
        }
    }
}

// MARK: - Shared Card Styling

private extension View {
    /// Gradient fill + stroke card background shared by the loading and
    /// success states of this style.
    func demoCardBackground() -> some View {
        background(
            RoundedRectangle(cornerRadius: 20)
                .fill(
                    LinearGradient(
                        colors: [.blue.opacity(0.1), .purple.opacity(0.1)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(
                            LinearGradient(
                                colors: [.blue.opacity(0.3), .purple.opacity(0.3)],
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

#Preview("Modern Card Style") {
    VStack(spacing: 12) {
        ForEach(Array(Constants.products.enumerated()), id: \.offset) { offset, id in
            ProductView(id: id) {
                ProductImage(productId: id)
            }
            .productViewStyle(ModernCardProductViewStyle())
            .padding(.horizontal, 24)
        }
    }
}
