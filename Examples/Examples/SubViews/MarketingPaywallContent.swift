import SwiftUI
import StoreKit

/// Marketing content shown on the subscription store header.
struct MarketingPaywallContent: View {

    // MARK: - State

    @State private var isAnimating = false
    @State private var showFeatures = false

    // MARK: - Body

    var body: some View {
        VStack(spacing: 32) {
            // Header Section
            headerSection

            // Features Section
            featuresSection

            // Benefits Section
            benefitsSection

            // Testimonial Section
            testimonialSection

            Spacer()
        }
        .padding(.horizontal, 24)
        .padding(.top, 40)
        .foregroundStyle(.white)
        .containerBackground(
            LinearGradient(
                colors: [.blue, .purple, .indigo],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            ),
            for: .subscriptionStore
        )
        .onAppear {
            withAnimation(.easeInOut(duration: 0.8)) {
                isAnimating = true
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                    showFeatures = true
                }
            }
        }
    }

    // MARK: - Header Section

    private var headerSection: some View {
        VStack(spacing: 20) {
            // App Icon
            ZStack {
                Circle()
                    .fill(.white.opacity(0.2))
                    .frame(width: 100, height: 100)
                    .scaleEffect(isAnimating ? 1.0 : 0.8)
                    .animation(.spring(response: 0.6, dampingFraction: 0.8), value: isAnimating)

                Image(systemName: "crown.fill")
                    .font(.system(size: 50))
                    .foregroundStyle(.white)
            }

            // Main Title
            VStack(spacing: 12) {
                Text("Unlock Premium")
                    .font(.largeTitle)
                    .fontWeight(.black)
                    .fontDesign(.rounded)
                    .headerReveal(isAnimating, delay: 0.2)

                Text("Get unlimited access to all premium features")
                    .font(.title3)
                    .fontWeight(.medium)
                    .multilineTextAlignment(.center)
                    .headerReveal(isAnimating, delay: 0.4)
            }
        }
    }

    // MARK: - Features Section

    private var featuresSection: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("Premium Features")
                .font(.title2)
                .fontWeight(.bold)
                .slideIn(showFeatures, delay: 0.6)

            VStack(spacing: 16) {
                PremiumFeatureRow(
                    icon: "infinity",
                    title: "Unlimited Access",
                    description: "Access all content without restrictions",
                    delay: 0.8
                )

                PremiumFeatureRow(
                    icon: "eye.slash.fill",
                    title: "Ad-Free Experience",
                    description: "Enjoy your content without interruptions",
                    delay: 1.0
                )

                PremiumFeatureRow(
                    icon: "bolt.fill",
                    title: "Priority Support",
                    description: "Get help when you need it most",
                    delay: 1.2
                )

                PremiumFeatureRow(
                    icon: "star.fill",
                    title: "Early Access",
                    description: "Be the first to try new features",
                    delay: 1.4
                )

                PremiumFeatureRow(
                    icon: "chart.line.uptrend.xyaxis",
                    title: "Advanced Analytics",
                    description: "Track your progress with detailed insights",
                    delay: 1.6
                )

                PremiumFeatureRow(
                    icon: "cloud.fill",
                    title: "Cloud Sync",
                    description: "Access your data anywhere, anytime",
                    delay: 1.8
                )
            }
        }
    }

    // MARK: - Benefits Section

    private var benefitsSection: some View {
        VStack(spacing: 16) {
            HStack(spacing: 20) {
                BenefitCard(
                    icon: "clock.fill",
                    title: "Save Time",
                    description: "2x faster",
                    color: .green
                )

                BenefitCard(
                    icon: "dollarsign.circle.fill",
                    title: "Save Money",
                    description: "50% off",
                    color: .orange
                )

                BenefitCard(
                    icon: "heart.fill",
                    title: "Love It",
                    description: "4.9★ rating",
                    color: .red
                )
            }
        }
        .sectionRise(showFeatures, delay: 2.0)
    }

    // MARK: - Testimonial Section

    private var testimonialSection: some View {
        VStack(spacing: 12) {
            HStack(spacing: 4) {
                ForEach(0..<5) { _ in
                    Image(systemName: "star.fill")
                        .font(.caption)
                        .foregroundStyle(.yellow)
                }
            }

            Text("\"This app has completely transformed how I work. The premium features are absolutely worth it!\"")
                .font(.subheadline)
//                .fontStyle(.italic)
                .multilineTextAlignment(.center)
                .opacity(0.9)

            Text("- Sarah M., Premium User")
                .font(.caption)
                .opacity(0.7)
        }
        .padding(20)
        .background(.white.opacity(0.1), in: RoundedRectangle(cornerRadius: 16))
        .sectionRise(showFeatures, delay: 2.2)
    }
}

// MARK: - Reveal Animations

/// Fade + horizontal slide-in entrance (ease-out) shared by the section title
/// and the premium feature rows.
private struct SlideIn: ViewModifier {
    let isVisible: Bool
    let delay: Double

    func body(content: Content) -> some View {
        content
            .opacity(isVisible ? 1 : 0)
            .offset(x: isVisible ? 0 : -20)
            .animation(.easeOut(duration: 0.5).delay(delay), value: isVisible)
    }
}

/// Fade + vertical rise entrance (spring) shared by the benefits and
/// testimonial sections.
private struct SectionRise: ViewModifier {
    let isVisible: Bool
    let delay: Double

    func body(content: Content) -> some View {
        content
            .opacity(isVisible ? 1 : 0)
            .offset(y: isVisible ? 0 : 30)
            .animation(.spring(response: 0.6, dampingFraction: 0.8).delay(delay), value: isVisible)
    }
}

/// Header-text variant: smaller vertical rise with an ease-out curve.
private struct HeaderReveal: ViewModifier {
    let isVisible: Bool
    let delay: Double

    func body(content: Content) -> some View {
        content
            .opacity(isVisible ? 1 : 0)
            .offset(y: isVisible ? 0 : 20)
            .animation(.easeOut(duration: 0.6).delay(delay), value: isVisible)
    }
}

private extension View {
    func slideIn(_ isVisible: Bool, delay: Double) -> some View {
        modifier(SlideIn(isVisible: isVisible, delay: delay))
    }

    func sectionRise(_ isVisible: Bool, delay: Double) -> some View {
        modifier(SectionRise(isVisible: isVisible, delay: delay))
    }

    func headerReveal(_ isVisible: Bool, delay: Double) -> some View {
        modifier(HeaderReveal(isVisible: isVisible, delay: delay))
    }
}

// MARK: - Premium Feature Row Component

struct PremiumFeatureRow: View {
    let icon: String
    let title: String
    let description: String
    let delay: Double

    @State private var isVisible = false

    var body: some View {
        HStack(spacing: 16) {
            ZStack {
                RoundedRectangle(cornerRadius: 12)
                    .fill(.white.opacity(0.2))
                    .frame(width: 50, height: 50)

                Image(systemName: icon)
                    .font(.title2)
                    .foregroundStyle(.white)
            }

            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.headline)
                    .fontWeight(.semibold)

                Text(description)
                    .font(.subheadline)
                    .opacity(0.9)
            }

            Spacer()

            Image(systemName: "checkmark.circle.fill")
                .font(.title2)
                .foregroundStyle(.green)
        }
        .slideIn(isVisible, delay: delay)
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
                isVisible = true
            }
        }
    }
}

// MARK: - Benefit Card Component

struct BenefitCard: View {
    let icon: String
    let title: String
    let description: String
    let color: Color

    var body: some View {
        VStack(spacing: 8) {
            ZStack {
                Circle()
                    .fill(color.opacity(0.2))
                    .frame(width: 50, height: 50)

                Image(systemName: icon)
                    .font(.title2)
                    .foregroundStyle(color)
            }

            VStack(spacing: 2) {
                Text(title)
                    .font(.caption)
                    .fontWeight(.medium)

                Text(description)
                    .font(.caption2)
                    .fontWeight(.bold)
                    .foregroundStyle(color)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 12)
        .background(.white.opacity(0.1), in: RoundedRectangle(cornerRadius: 12))
    }
}
