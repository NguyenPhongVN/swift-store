import SwiftUI
import SwiftStore

struct ContentView: View {
    
    @State private var isPresented: Bool = false
    @State private var isPresentedPreview: Bool = false
    @State private var isAnimating = false
    @State private var showFeatures = false
    
    @SwiftStoreState
    private var ssState
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 32) {
                    // Header Section
                    headerSection
                    
                    // Premium Status Card
                    premiumStatusCard
                    
                    // Features Section
                    featuresSection
                    
                    // Action Buttons
                    actionButtonsSection
                    
                    // Developer Tools
                    developerToolsSection
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 20)
            }
            .background(
                LinearGradient(
                    colors: [.blue.opacity(0.1), .purple.opacity(0.1)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
            .navigationTitle("SwiftStore Demo")
            .navigationBarTitleDisplayMode(.large)
        }
        .fullScreenCover(isPresented: $isPresented) {
            PaywallView()
        }
        .fullScreenCover(isPresented: $isPresentedPreview) {
            PreviewView()
        }
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
        VStack(spacing: 16) {
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [.blue, .purple],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 100, height: 100)
                    .scaleEffect(isAnimating ? 1.0 : 0.8)
                    .animation(.spring(response: 0.6, dampingFraction: 0.8), value: isAnimating)
                
                Image(systemName: "crown.fill")
                    .font(.system(size: 40))
                    .foregroundStyle(.white)
            }
            
            Text("SwiftStore Demo")
                .font(.largeTitle)
                .fontWeight(.bold)
                .foregroundStyle(.primary)
                .opacity(isAnimating ? 1 : 0)
                .offset(y: isAnimating ? 0 : 20)
                .animation(.easeOut(duration: 0.6).delay(0.2), value: isAnimating)
            
            Text("Experience premium subscription management")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .opacity(isAnimating ? 1 : 0)
                .offset(y: isAnimating ? 0 : 20)
                .animation(.easeOut(duration: 0.6).delay(0.4), value: isAnimating)
        }
    }
    
    // MARK: - Premium Status Card
    private var premiumStatusCard: some View {
        VStack(spacing: 16) {
            HStack {
                Image(systemName: ssState.isPremium ? "checkmark.circle.fill" : "xmark.circle.fill")
                    .font(.title2)
                    .foregroundStyle(ssState.isPremium ? .green : .red)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(ssState.isPremium ? "Premium Active" : "Free Version")
                        .font(.headline)
                        .fontWeight(.semibold)
                    
                    Text(ssState.isPremium ? "All features unlocked" : "Upgrade to unlock premium features")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                
                Spacer()
                
                if ssState.isPremium {
                    Text("✨")
                        .font(.title2)
                }
            }
            
            if let activeSubscription = ssState.activeSubscription {
                HStack {
                    Text("Active Plan:")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    
                    Text(activeSubscription)
                        .font(.caption)
                        .fontWeight(.medium)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 2)
                        .background(.blue.opacity(0.2), in: Capsule())
                }
            }
        }
        .padding(20)
        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 16))
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(ssState.isPremium ? .green.opacity(0.3) : .red.opacity(0.3), lineWidth: 1)
        )
        .scaleEffect(showFeatures ? 1.0 : 0.9)
        .opacity(showFeatures ? 1.0 : 0.0)
        .animation(.spring(response: 0.6, dampingFraction: 0.8).delay(0.6), value: showFeatures)
    }
    
    // MARK: - Features Section
    private var featuresSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Features")
                .font(.title2)
                .fontWeight(.bold)
                .foregroundStyle(.primary)
            
            VStack(spacing: 12) {
                FeatureRow(
                    icon: "creditcard.fill",
                    title: "StoreKit 2 Integration",
                    description: "Modern subscription management",
                    isAvailable: true
                )
                
                FeatureRow(
                    icon: "creditcard.fill",
                    title: "Premium Subscriptions",
                    description: "Flexible billing options",
                    isAvailable: ssState.isPremium
                )
                
                FeatureRow(
                    icon: "chart.line.uptrend.xyaxis",
                    title: "Analytics Dashboard",
                    description: "Track subscription metrics",
                    isAvailable: ssState.isPremium
                )
                
                FeatureRow(
                    icon: "person.crop.circle.badge.checkmark",
                    title: "User Management",
                    description: "Manage user subscriptions",
                    isAvailable: ssState.isPremium
                )
            }
        }
        .scaleEffect(showFeatures ? 1.0 : 0.9)
        .opacity(showFeatures ? 1.0 : 0.0)
        .animation(.spring(response: 0.6, dampingFraction: 0.8).delay(0.8), value: showFeatures)
    }
    
    // MARK: - Action Buttons Section
    private var actionButtonsSection: some View {
        VStack(spacing: 16) {
            Button(action: {
                isPresented = true
            }) {
                HStack(spacing: 12) {
                    Image(systemName: ssState.isPremium ? "crown.fill" : "crown")
                        .font(.title3)
                    
                    Text(ssState.isPremium ? "Manage Subscription" : "Upgrade to Premium")
                        .font(.headline)
                        .fontWeight(.semibold)
                }
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .background(
                    LinearGradient(
                        colors: [.blue, .purple],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .clipShape(RoundedRectangle(cornerRadius: 16))
            }
            
            Button(action: {
                isPresentedPreview = true
            }) {
                HStack(spacing: 12) {
                    Image(systemName: "eye.fill")
                        .font(.title3)
                    
                    Text("View Examples")
                        .font(.headline)
                        .fontWeight(.semibold)
                }
                .foregroundStyle(.blue)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .background(.blue.opacity(0.1), in: RoundedRectangle(cornerRadius: 16))
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(.blue, lineWidth: 2)
                )
            }
        }
        .scaleEffect(showFeatures ? 1.0 : 0.9)
        .opacity(showFeatures ? 1.0 : 0.0)
        .animation(.spring(response: 0.6, dampingFraction: 0.8).delay(1.0), value: showFeatures)
    }
    
    // MARK: - Developer Tools Section
    private var developerToolsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Developer Tools")
                .font(.title3)
                .fontWeight(.semibold)
                .foregroundStyle(.primary)
            
            VStack(spacing: 8) {
                InfoRow(title: "StoreKit Configuration", value: "Enabled")
                InfoRow(title: "Active Products", value: "\(Constants.allProducts.count)")
                InfoRow(title: "Group ID", value: Constants.groupID)
                InfoRow(title: "App Version", value: "1.0.0")
            }
        }
        .padding(16)
        .background(.quaternary.opacity(0.5), in: RoundedRectangle(cornerRadius: 12))
        .scaleEffect(showFeatures ? 1.0 : 0.9)
        .opacity(showFeatures ? 1.0 : 0.0)
        .animation(.spring(response: 0.6, dampingFraction: 0.8).delay(1.2), value: showFeatures)
    }
}

// MARK: - Feature Row Component
struct FeatureRow: View {
    let icon: String
    let title: String
    let description: String
    let isAvailable: Bool
    
    var body: some View {
        HStack(spacing: 16) {
            ZStack {
                RoundedRectangle(cornerRadius: 8)
                    .fill(isAvailable ? .green.opacity(0.2) : .gray.opacity(0.2))
                    .frame(width: 40, height: 40)
                
                Image(systemName: icon)
                    .font(.title3)
                    .foregroundStyle(isAvailable ? .green : .gray)
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.headline)
                    .fontWeight(.medium)
                    .foregroundStyle(.primary)
                
                Text(description)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            
            Spacer()
            
            Image(systemName: isAvailable ? "checkmark.circle.fill" : "lock.fill")
                .font(.title3)
                .foregroundStyle(isAvailable ? .green : .gray)
        }
        .padding(.vertical, 4)
    }
}

// MARK: - Info Row Component
struct InfoRow: View {
    let title: String
    let value: String
    
    var body: some View {
        HStack {
            Text(title)
                .font(.caption)
                .foregroundStyle(.secondary)
            
            Spacer()
            
            Text(value)
                .font(.caption)
                .fontWeight(.medium)
                .foregroundStyle(.primary)
        }
    }
}

#Preview {
    ContentView()
}
