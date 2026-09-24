# SwiftStore

A modern, SwiftUI-friendly StoreKit wrapper for iOS in-app purchases. SwiftStore simplifies the integration of subscriptions, lifetime purchases, and consumable products in your iOS applications.

## Features

- 🚀 **Easy Setup**: Simple configuration with product IDs and URLs
- 📱 **SwiftUI Integration**: Built-in `@SwiftStoreState` property wrapper
- 🔄 **Automatic Transaction Handling**: Handles unfinished and current entitlements
- 💰 **Multiple Product Types**: Support for subscriptions, lifetime purchases, and consumables
- 🛡️ **Transaction Verification**: Built-in StoreKit transaction verification
- ⚡ **Observable**: Uses Swift's Observation framework for reactive updates

## Requirements

- iOS 17.0+
- Swift 6.2+
- Xcode 15.0+

## Installation

### Swift Package Manager

Add SwiftStore to your project using Swift Package Manager:

1. In Xcode, go to **File** → **Add Package Dependencies**
2. Enter the repository URL: `https://github.com/your-username/swift-store`
3. Select the version and add to your target

## Quick Start

### 1. Configure Your Products

First, create a configuration with your App Store Connect product IDs:

```swift
import SwiftStore

let configuration = SSConfiguration()
configuration.subscriptionIDs = ["monthly_premium", "yearly_premium"]
configuration.lifetimeIDs = ["lifetime_premium"]
configuration.termsURL = "https://yourapp.com/terms"
configuration.privacyURL = "https://yourapp.com/privacy"
```

### 2. Initialize SwiftStore

Initialize SwiftStore in your app's entry point:

```swift
import SwiftUI
import SwiftStore

@main
struct MyApp: App {
    init() {
        let configuration = SSConfiguration()
        configuration.subscriptionIDs = ["monthly_premium", "yearly_premium"]
        configuration.lifetimeIDs = ["lifetime_premium"]
        configuration.termsURL = "https://yourapp.com/terms"
        configuration.privacyURL = "https://yourapp.com/privacy"
        
        SwiftStore.shared.initialize(configuration: configuration)
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
```

### 3. Use in SwiftUI Views

Use the `@SwiftStoreState` property wrapper to access store state:

```swift
import SwiftUI
import SwiftStore

struct ContentView: View {
    @SwiftStoreState private var store
    
    var body: some View {
        VStack(spacing: 20) {
            // Check premium status
            if store.isPremium {
                Text("🎉 Premium Active!")
                    .font(.title)
                    .foregroundColor(.green)
            } else {
                Text("Upgrade to Premium")
                    .font(.title)
                    .foregroundColor(.blue)
            }
            
            // Show active subscription
            if let subscription = store.activeSubscription {
                Text("Active Subscription: \(subscription)")
            }
            
            // Show lifetime status
            if store.activeLifeTime {
                Text("Lifetime Premium Active")
            }
            
            // Purchase buttons
            Button("Purchase Lifetime") {
                // Handle lifetime purchase
            }
            .disabled(store.activeLifeTime)
            
            Button("Subscribe Monthly") {
                // Handle subscription purchase
            }
            .disabled(store.activeSubscription != nil)
        }
        .padding()
    }
}
```

## API Reference

### SSConfiguration

Configuration class for setting up your in-app purchase products.

```swift
public class SSConfiguration {
    /// Array of subscription product IDs from App Store Connect
    public var subscriptionIDs: [String] = []
    
    /// Array of lifetime product IDs from App Store Connect
    public var lifetimeIDs: [String] = []
    
    /// URL for Terms of Service page
    public var termsURL: String?
    
    /// URL for Privacy Policy page
    public var privacyURL: String?
}
```

### SwiftStore

Main store class that handles all in-app purchase operations.

```swift
public final class SwiftStore {
    /// Shared singleton instance
    static let shared = SwiftStore()
    
    /// Whether lifetime purchase is active
    public var activeLifeTime: Bool
    
    /// Currently active subscription product ID
    public var activeSubscription: String?
    
    /// Whether user has premium access (lifetime or subscription)
    public var isPremium: Bool
    
    /// Terms of Service URL
    public var termsURL: String?
    
    /// Privacy Policy URL
    public var privacyURL: String?
    
    /// Initialize the store with configuration
    public func initialize(configuration: SSConfiguration) -> SwiftStore
}
```

### SwiftStoreState

Property wrapper for SwiftUI integration.

```swift
@propertyWrapper
struct SwiftStoreState: DynamicProperty {
    /// Access to the SwiftStore instance
    var wrappedValue: SwiftStore
    
    /// Binding for two-way data binding
    var projectedValue: Binding<SwiftStore>
}
```

### ProductType

Enum representing different product types.

```swift
public enum ProductType {
    case lifetime    // One-time purchase
    case subscription // Recurring subscription
    case none        // Product not found
}
```

## Usage Examples

### Basic Premium Check

```swift
struct PremiumView: View {
    @SwiftStoreState private var store
    
    var body: some View {
        if store.isPremium {
            PremiumContentView()
        } else {
            UpgradePromptView()
        }
    }
}
```

### Subscription Management

```swift
struct SubscriptionView: View {
    @SwiftStoreState private var store
    
    var body: some View {
        VStack {
            if let activeSubscription = store.activeSubscription {
                Text("Active: \(activeSubscription)")
                Button("Manage Subscription") {
                    // Open subscription management
                }
            } else {
                Button("Subscribe Now") {
                    // Start subscription flow
                }
            }
        }
    }
}
```

### Terms and Privacy Links

```swift
struct SettingsView: View {
    @SwiftStoreState private var store
    
    var body: some View {
        List {
            if let termsURL = store.termsURL {
                Link("Terms of Service", destination: URL(string: termsURL)!)
            }
            
            if let privacyURL = store.privacyURL {
                Link("Privacy Policy", destination: URL(string: privacyURL)!)
            }
        }
    }
}
```

### Dynamic Member Lookup

The `@SwiftStoreState` property wrapper supports dynamic member lookup, allowing you to access properties directly:

```swift
struct MyView: View {
    @SwiftStoreState private var store
    
    var body: some View {
        VStack {
            // Direct property access
            Text("Premium: \(isPremium)")
            Text("Lifetime: \(activeLifeTime)")
            
            if let subscription = activeSubscription {
                Text("Subscription: \(subscription)")
            }
        }
    }
}
```

## Advanced Usage

### Custom Purchase Handling

While SwiftStore handles transaction verification automatically, you can extend it for custom purchase flows:

```swift
extension SwiftStore {
    func purchaseProduct(_ productID: String) async throws {
        // Your custom purchase logic here
        // SwiftStore will automatically handle the transaction verification
    }
}
```

### Monitoring Transaction Updates

SwiftStore automatically monitors transaction updates and updates the state accordingly. The store will:

- Handle unfinished transactions on app launch
- Process current entitlements
- Monitor for new transaction updates
- Update premium status automatically

### Observability & Purchases Pending Approval (Ask to Buy)

Subscribe to store events to observe what the pipeline processes — entitlement changes, first purchases, transactions that failed verification, and restore completion:

```swift
SwiftStore.shared.onEvent = { event in
    switch event {
    case .entitlementChanged(let productID, let isActive):
        print("Entitlement \(productID) is now \(isActive ? "active" : "inactive")")
    case .purchaseFinished(let productID):
        print("Purchase completed: \(productID)")
    case .transactionUnverified:
        print("A transaction failed verification and was ignored")
    case .restoreFinished:
        print("Restore finished")
    }
}
```

**Ask to Buy**: when a purchase is awaiting approval, the platform surfaces `.pending` through its purchase-time callbacks (for example `onInAppPurchaseResult` on `ProductView`, or the `purchase` environment action). Once the purchase is approved, the transaction arrives through SwiftStore's normal pipeline and is reported as a `purchaseFinished` event. The library intentionally exposes no pre-approval query — the platform does not provide one.

### Restoring Purchases

```swift
// Distinguishable outcome: success (with entitlement count), empty account,
// or failure (throws, for example when offline).
let outcome = try await SwiftStore.shared.restore()
switch outcome {
case .restored(let count):
    print("Restored — \(count) active entitlements")
case .nothingToRestore:
    print("Nothing to restore")
}

// Legacy call: unchanged behavior, reports via the .restoreFinished event only.
await SwiftStore.shared.restorePurchases()
```

## Best Practices

1. **Initialize Early**: Initialize SwiftStore in your app's entry point before any views are created
2. **Use Property Wrapper**: Always use `@SwiftStoreState` in SwiftUI views for reactive updates
3. **Handle Loading States**: Consider showing loading states while transactions are being processed
4. **Test Thoroughly**: Test with StoreKit's sandbox environment before releasing
5. **Handle Edge Cases**: Consider what happens when network is unavailable or transactions fail

## Troubleshooting

### Common Issues

1. **Products Not Loading**: Ensure your product IDs match exactly with App Store Connect
2. **Transactions Not Completing**: Check that you're testing with sandbox accounts
3. **State Not Updating**: Make sure you're using `@SwiftStoreState` in SwiftUI views

### Debug Tips

- Enable StoreKit testing in Xcode's scheme settings
- Use sandbox test accounts for testing
- Check the console for transaction verification logs

## License

This project is licensed under the MIT License - see the LICENSE file for details.

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## Support

If you encounter any issues or have questions, please open an issue on GitHub.
