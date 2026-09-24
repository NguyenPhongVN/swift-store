//
//  PaywallView.swift
//  Examples
//
//  Created by Computer on 10/6/25.
//

import StoreKit
import SwiftUI
import SwiftStore

/// The demo paywall: a SubscriptionStoreView with custom marketing content.
struct PaywallView: View {

    // MARK: - State

    @SwiftStoreState
    var ssState

    @Environment(\.dismiss) private var dismiss

    // MARK: - Body

    var body: some View {
        SubscriptionStoreView(
            groupID: Constants.groupID,
            visibleRelationships: ssState.isPremium ? .upgrade : .all) {
            PassMarketingContent()
#if !os(watchOS)
                .containerBackground(for: .subscriptionStoreFullHeight) {
                    SkyBackground()
                }
#endif
        }
#if os(iOS)
        .storeButton(.visible, for: .redeemCode)
#else
        .frame(width: 400, height: 550)
#endif
        .subscriptionStoreControlIcon { _, subscriptionInfo in
            Image(systemName: "wallet.pass")
            .foregroundStyle(.blue)
            .symbolVariant(.fill)
        }
        .backgroundStyle(.clear)
        .subscriptionStoreButtonLabel(.multiline)
        .subscriptionStorePickerItemBackground(.thinMaterial)
        .subscriptionStoreControlStyle(.pagedProminentPicker)
    }


}

/// Hero marketing content for the paywall: animated headline, feature cards,
/// and a benefits list.
struct PassMarketingContent: View {

    // MARK: - State

    @State private var isAnimating = false
    @State private var glowAnimation = false
    @State private var textAnimation = false

    // MARK: - Body

    var body: some View {
        VStack(spacing: 32) {
            // Hero Section
            VStack(spacing: 24) {
                heroIcon

                // Marketing Text with elegant gradients
                VStack(spacing: 16) {
                    Text("✨ Unlock Premium")
                        .font(.system(.largeTitle, design: .rounded, weight: .bold))
                        .foregroundStyle(
                            LinearGradient(
                                colors: [
                                    Color(red: 0.6, green: 0.3, blue: 0.9),  // Rich purple
                                    Color(red: 0.4, green: 0.5, blue: 0.95), // Deep blue
                                    Color(red: 0.3, green: 0.7, blue: 0.9),  // Ocean blue
                                    Color(red: 0.2, green: 0.8, blue: 0.8)   // Teal
                                ],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .multilineTextAlignment(.center)
                        .zoomIn(textAnimation, delay: 0.3)

                    VStack(spacing: 12) {
                        Text("Transform Your Experience")
                            .font(.system(.title2, design: .default, weight: .semibold))
                            .foregroundStyle(
                                LinearGradient(
                                    colors: [
                                        Color(red: 0.2, green: 0.2, blue: 0.3),  // Dark slate
                                        Color(red: 0.4, green: 0.4, blue: 0.6)   // Medium slate
                                    ],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .multilineTextAlignment(.center)
                            .zoomIn(textAnimation, delay: 0.5)

                        Text("Join thousands of users who've upgraded to premium and achieved their goals faster")
                            .font(.system(.body, design: .default, weight: .regular))
                            .foregroundStyle(Color(red: 0.4, green: 0.4, blue: 0.5))
                            .multilineTextAlignment(.center)
                            .lineLimit(nil)
                            .zoomIn(textAnimation, delay: 0.7)
                    }
                }
            }

            // Features Section
            VStack(spacing: 24) {
                VStack(spacing: 8) {
                    Text("🌟 Premium Features")
                        .font(.system(.title2, design: .default, weight: .bold))
                        .foregroundStyle(
                            LinearGradient(
                                colors: [
                                    Color(red: 0.8, green: 0.4, blue: 0.2),  // Warm orange
                                    Color(red: 0.9, green: 0.3, blue: 0.5),  // Coral pink
                                    Color(red: 0.7, green: 0.2, blue: 0.8)   // Deep purple
                                ],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .multilineTextAlignment(.center)
                        .zoomIn(textAnimation, delay: 0.9)

                    Text("Everything you need to succeed")
                        .font(.system(.subheadline, design: .default, weight: .regular))
                        .foregroundStyle(Color(red: 0.4, green: 0.4, blue: 0.5))
                        .multilineTextAlignment(.center)
                        .zoomIn(textAnimation, delay: 1.1)
                }

                featureCards
            }

            // CTA Section
            VStack(spacing: 20) {
                VStack(spacing: 12) {
                    Text("🎯 Limited Time Offer")
                        .font(.system(.title3, design: .default, weight: .bold))
                        .foregroundStyle(
                            LinearGradient(
                                colors: [
                                    Color(red: 0.9, green: 0.2, blue: 0.2),  // Deep red
                                    Color(red: 0.9, green: 0.4, blue: 0.1),  // Orange red
                                    Color(red: 0.9, green: 0.6, blue: 0.1)   // Golden orange
                                ],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .multilineTextAlignment(.center)
                        .zoomIn(textAnimation, delay: 2.1)

                    Text("Save 70% today only!")
                        .font(.system(.headline, design: .default, weight: .semibold))
                        .foregroundStyle(
                            LinearGradient(
                                colors: [
                                    Color(red: 0.1, green: 0.7, blue: 0.3),  // Forest green
                                    Color(red: 0.2, green: 0.8, blue: 0.5),  // Emerald
                                    Color(red: 0.3, green: 0.9, blue: 0.7)   // Mint
                                ],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .multilineTextAlignment(.center)
                        .zoomIn(textAnimation, delay: 2.3)
                }

                VStack(spacing: 12) {
                    BenefitRow(text: "Unlimited access", icon: "checkmark.circle.fill", delay: 2.5)
                    BenefitRow(text: "No ads", icon: "checkmark.circle.fill", delay: 2.7)
                    BenefitRow(text: "Premium support", icon: "checkmark.circle.fill", delay: 2.9)
                    BenefitRow(text: "All features", icon: "checkmark.circle.fill", delay: 3.1)
                }
            }
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 40)
        .onAppear {
            isAnimating = true
            glowAnimation = true
            textAnimation = true
        }
    }

    // MARK: - Hero Icon

    private var heroIcon: some View {
        ZStack {
            // Outer glow ring with elegant colors
            Circle()
                .fill(
                    RadialGradient(
                        colors: [
                            Color(red: 0.4, green: 0.2, blue: 0.8).opacity(0.4),  // Deep purple
                            Color(red: 0.2, green: 0.4, blue: 0.9).opacity(0.2),  // Royal blue
                            Color(red: 0.1, green: 0.6, blue: 0.8).opacity(0.1),  // Ocean blue
                            .clear
                        ],
                        center: .center,
                        startRadius: 20,
                        endRadius: 60
                    )
                )
                .frame(width: 120, height: 120)
                .scaleEffect(glowAnimation ? 1.15 : 1.0)
                .opacity(glowAnimation ? 0.6 : 0.3)
                .animation(.easeInOut(duration: 3).repeatForever(autoreverses: true), value: glowAnimation)

            // Main icon background with premium gradient
            Circle()
                .fill(
                    LinearGradient(
                        colors: [
                            Color(red: 0.5, green: 0.3, blue: 0.9),  // Rich purple
                            Color(red: 0.3, green: 0.5, blue: 0.95), // Deep blue
                            Color(red: 0.2, green: 0.7, blue: 0.9),  // Teal blue
                            Color(red: 0.1, green: 0.8, blue: 0.7)   // Emerald
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .frame(width: 88, height: 88)
                .shadow(color: Color(red: 0.3, green: 0.2, blue: 0.8).opacity(0.5), radius: 25, x: 0, y: 12)
//                        .scaleEffect(isAnimating ? 1.03 : 1.0)
//                        .animation(.easeInOut(duration: 2.5).repeatForever(autoreverses: true), value: isAnimating)

            // Inner shine effect
            Circle()
                .fill(
                    RadialGradient(
                        colors: [
                            .white.opacity(0.4),
                            .white.opacity(0.1),
                            .clear
                        ],
                        center: .topLeading,
                        startRadius: 0,
                        endRadius: 35
                    )
                )
                .frame(width: 88, height: 88)

            Image(systemName: "crown.fill")
                .font(.system(size: 36, weight: .medium))
                .foregroundStyle(
                    LinearGradient(
                        colors: [
                            .white,
                            Color(red: 1.0, green: 0.9, blue: 0.3),  // Gold
                            Color(red: 1.0, green: 0.8, blue: 0.2)   // Amber
                        ],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                .shadow(color: .black.opacity(0.4), radius: 4, x: 0, y: 2)
        }
    }

    // MARK: - Feature Cards

    private var featureCards: some View {
        LazyVGrid(columns: [
            GridItem(.flexible(), spacing: 12),
            GridItem(.flexible(), spacing: 12)
        ], spacing: 12) {
            FeatureCard(
                icon: "bolt.fill",
                title: "Lightning Fast",
                description: "10x faster performance",
                gradientColors: [
                    Color(red: 0.9, green: 0.5, blue: 0.1),  // Golden orange
                    Color(red: 1.0, green: 0.7, blue: 0.2)   // Amber
                ],
                delay: 1.3
            )

            FeatureCard(
                icon: "chart.line.uptrend.xyaxis",
                title: "Advanced Analytics",
                description: "Insights that matter",
                gradientColors: [
                    Color(red: 0.2, green: 0.5, blue: 0.9),  // Deep blue
                    Color(red: 0.3, green: 0.7, blue: 0.95)  // Sky blue
                ],
                delay: 1.5
            )

            FeatureCard(
                icon: "icloud.fill",
                title: "Cloud Sync",
                description: "Access anywhere, anytime",
                gradientColors: [
                    Color(red: 0.1, green: 0.7, blue: 0.8),  // Teal
                    Color(red: 0.2, green: 0.8, blue: 0.7)   // Emerald
                ],
                delay: 1.7
            )

            FeatureCard(
                icon: "star.fill",
                title: "Priority Support",
                description: "24/7 expert assistance",
                gradientColors: [
                    Color(red: 0.6, green: 0.3, blue: 0.8),  // Rich purple
                    Color(red: 0.8, green: 0.4, blue: 0.7)   // Magenta
                ],
                delay: 1.9
            )
        }
    }
}

// MARK: - Reveal Animations

private extension View {
    /// Zoom + fade entrance shared by the marketing texts.
    func zoomIn(_ isVisible: Bool, delay: Double) -> some View {
        scaleEffect(isVisible ? 1.0 : 0.8)
            .opacity(isVisible ? 1.0 : 0.0)
            .animation(.spring(response: 0.8, dampingFraction: 0.6).delay(delay), value: isVisible)
    }

    /// Zoom + fade entrance shared by cards and benefit rows.
    func popIn(_ isVisible: Bool, delay: Double) -> some View {
        scaleEffect(isVisible ? 1.0 : 0.8)
            .opacity(isVisible ? 1.0 : 0.0)
            .animation(.spring(response: 0.6, dampingFraction: 0.7).delay(delay), value: isVisible)
    }
}

// MARK: - Feature Card Component

struct FeatureCard: View {
    let icon: String
    let title: String
    let description: String
    let gradientColors: [Color]
    let delay: Double

    @State private var isVisible = false
    @State private var isHovered = false

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                ZStack {
                    // Gradient background circle
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: gradientColors,
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 40, height: 40)
                        .shadow(color: gradientColors.first?.opacity(0.3) ?? .clear, radius: 8, x: 0, y: 4)
                        .scaleEffect(isHovered ? 1.1 : 1.0)
                        .animation(.spring(response: 0.3, dampingFraction: 0.6), value: isHovered)

                    // Icon with white color
                    Image(systemName: icon)
                        .font(.system(size: 18, weight: .medium))
                        .foregroundStyle(.white)
                        .shadow(color: .black.opacity(0.2), radius: 1, x: 0, y: 1)
                }

                Spacer()
            }

            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.system(.headline, design: .default, weight: .semibold))
                    .foregroundStyle(
                        LinearGradient(
                            colors: gradientColors,
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .multilineTextAlignment(.leading)

                Text(description)
                    .font(.system(.caption, design: .default, weight: .regular))
                    .foregroundStyle(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
                    .multilineTextAlignment(.leading)
            }
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(.regularMaterial)
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(
                            LinearGradient(
                                colors: gradientColors.map { $0.opacity(0.2) },
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 1
                        )
                )
                .shadow(color: gradientColors.first?.opacity(0.1) ?? .clear, radius: 8, x: 0, y: 4)
        )
        .frame(minHeight: 100)
        .popIn(isVisible, delay: delay)
        .onAppear {
            isVisible = true
        }
        .onTapGesture {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                isHovered.toggle()
            }
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(title): \(description)")
    }
}

// MARK: - Benefit Row Component

struct BenefitRow: View {
    let text: String
    let icon: String
    let delay: Double

    @State private var isVisible = false
    @State private var isPulsing = false

    var body: some View {
        HStack(spacing: 12) {
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [
                                Color(red: 0.1, green: 0.7, blue: 0.3),  // Forest green
                                Color(red: 0.2, green: 0.8, blue: 0.5)   // Emerald
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 26, height: 26)
                    .shadow(color: Color(red: 0.1, green: 0.7, blue: 0.3).opacity(0.3), radius: 4, x: 0, y: 2)
                    .scaleEffect(isPulsing ? 1.15 : 1.0)
                    .opacity(isPulsing ? 0.8 : 1.0)
                    .animation(.easeInOut(duration: 1.8).repeatForever(autoreverses: true), value: isPulsing)

                Image(systemName: icon)
                    .font(.system(size: 13, weight: .medium))
                    .foregroundStyle(.white)
                    .shadow(color: .black.opacity(0.2), radius: 1, x: 0, y: 1)
            }

            Text(text)
                .font(.system(.subheadline, design: .default, weight: .medium))
                .foregroundStyle(Color(red: 0.2, green: 0.2, blue: 0.3))

            Spacer()
        }
        .popIn(isVisible, delay: delay)
        .onAppear {
            isVisible = true
            isPulsing = true
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(text)")
    }
}

/// Animated gradient sky with floating particles behind the paywall content.
struct SkyBackground: View {
    @State private var animateGradient = false
    @State private var animateParticles = false

    // Pre-defined colors to avoid complex expressions
    private let backgroundColors = [
        Color(red: 0.4, green: 0.2, blue: 0.8).opacity(0.08),
        Color(red: 0.2, green: 0.4, blue: 0.9).opacity(0.06),
        Color(red: 0.1, green: 0.6, blue: 0.8).opacity(0.04),
        Color(red: 0.1, green: 0.8, blue: 0.7).opacity(0.03),
        Color(.systemBackground)
    ]

    private let overlayColors = [
        Color(red: 0.8, green: 0.4, blue: 0.2).opacity(0.04),
        Color(red: 0.9, green: 0.3, blue: 0.5).opacity(0.03),
        Color(red: 0.7, green: 0.2, blue: 0.8).opacity(0.02),
        .clear
    ]

    private let particleColors: [[Color]] = [
        [Color(red: 0.6, green: 0.3, blue: 0.9), Color(red: 0.4, green: 0.5, blue: 0.95)],
        [Color(red: 0.2, green: 0.5, blue: 0.9), Color(red: 0.3, green: 0.7, blue: 0.95)],
        [Color(red: 0.1, green: 0.7, blue: 0.8), Color(red: 0.2, green: 0.8, blue: 0.7)],
        [Color(red: 0.9, green: 0.5, blue: 0.1), Color(red: 1.0, green: 0.7, blue: 0.2)],
        [Color(red: 0.8, green: 0.4, blue: 0.2), Color(red: 0.9, green: 0.3, blue: 0.5)],
        [Color(red: 0.1, green: 0.7, blue: 0.3), Color(red: 0.2, green: 0.8, blue: 0.5)]
    ]

    var body: some View {
        ZStack {
            // Main gradient background
            LinearGradient(
                colors: backgroundColors,
                startPoint: animateGradient ? .topLeading : .bottomTrailing,
                endPoint: animateGradient ? .bottomTrailing : .topLeading
            )
            .animation(.easeInOut(duration: 10).repeatForever(autoreverses: true), value: animateGradient)

            // Secondary gradient overlay
            LinearGradient(
                colors: overlayColors,
                startPoint: .topTrailing,
                endPoint: .bottomLeading
            )

            // Floating particles
            ForEach(0..<6, id: \.self) { index in
                ParticleView(
                    colors: particleColors[index],
                    index: index,
                    isAnimating: animateParticles
                )
            }

            // Radial gradient overlay
            RadialGradient(
                colors: [
                    Color(red: 0.3, green: 0.2, blue: 0.8).opacity(0.06),
                    Color(red: 0.2, green: 0.4, blue: 0.9).opacity(0.03),
                    .clear
                ],
                center: .center,
                startRadius: 60,
                endRadius: 350
            )
        }
        .ignoresSafeArea()
        .onAppear {
            animateGradient = true
            animateParticles = true
        }
    }
}

// Separate view for particles to simplify the main view
struct ParticleView: View {
    let colors: [Color]
    let index: Int
    let isAnimating: Bool

    // Computed properties to break up complex expressions
    private var particleGradient: LinearGradient {
        LinearGradient(
            colors: [
                colors[0].opacity(0.12),
                colors[1].opacity(0.04)
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }

    private var particleSize: CGSize {
        CGSize(
            width: CGFloat(25 + index * 12),
            height: CGFloat(12 + index * 6)
        )
    }

    private var particleOffset: CGSize {
        CGSize(
            width: CGFloat(-120 + index * 50),
            height: CGFloat(-80 + index * 25)
        )
    }

    private var particleAnimation: Animation {
        .easeInOut(duration: Double(4 + index) * 0.5)
        .repeatForever(autoreverses: true)
        .delay(Double(index) * 0.8)
    }

    var body: some View {
        Circle()
            .fill(particleGradient)
            .frame(width: particleSize.width, height: particleSize.height)
            .offset(x: particleOffset.width, y: particleOffset.height)
            .blur(radius: 1.5)
            .scaleEffect(isAnimating ? 1.15 : 0.85)
            .opacity(isAnimating ? 0.7 : 0.25)
            .animation(particleAnimation, value: isAnimating)
    }
}
