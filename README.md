# SwiftStore

A modern, SwiftUI-friendly StoreKit 2 wrapper for iOS and macOS in-app purchases. SwiftStore handles transaction verification, entitlement management, and state updates for **subscription and lifetime (non-consumable) products** — with an observable event stream, standalone test instances, and type-safe product identifiers.

> Consumable products are not managed by this library.

## Features

- 🚀 **Easy Setup**: Closure-based configuration, safe to use with strict concurrency checking
- 📱 **SwiftUI Integration**: Built-in `@SwiftStoreState` property wrapper
- 🔄 **Single Transaction Pipeline**: Platform transactions verified, completed, and fanned out to every store instance exactly once per process
- 💰 **Product Types**: Subscription and lifetime (non-consumable) products
- 🛡️ **Transaction Verification**: Unverified transactions are ignored — never trusted, never acknowledged
- 🩹 **Grace Period Aware**: Subscriptions in the platform's billing grace period / retry keep access
- 📡 **Observable Events**: `onEvent` reports entitlement changes, purchases, verification failures, and restores
- 🧪 **Standalone Instances**: `make()` / `init()` for tests, previews, and isolated environments
- ⚡ **Observable State**: Uses Swift's Observation framework for reactive SwiftUI updates

## Requirements

- iOS 17+ / macOS 14+
- Swift 6.2 toolchain (Xcode 26+)

## Installation

### Swift Package Manager

1. In Xcode, go to **File** → **Add Package Dependencies…**
2. Enter the repository URL: `https://github.com/NguyenPhongVN/swift-store`
3. Select a version (dependency rule: *Up to Next Major from 1.0.0*) and add the **SwiftStore** product to your target

Or in your `Package.swift`:

```swift
dependencies: [
    .package(url: "https://github.com/NguyenPhongVN/swift-store", from: "1.0.0")
]
```

## Quick Start

### 1. Initialize the Store

Initialize in your app's entry point. The closure runs on the main actor, so this is safe with strict concurrency checking:

```swift
import SwiftUI
import SwiftStore

@main
struct MyApp: App {
    init() {
        SwiftStore.shared.initialize {
            $0.setSubscriptionIDs(["monthly_premium", "yearly_premium"])
            $0.setLifetimeIDs(["lifetime_premium"])
            $0.setTermsURL("https://yourapp.com/terms")
            $0.setPrivacyURL("https://yourapp.com/privacy")
        }
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
```

If you prefer an explicit configuration object, the classic variant works the same way:

```swift
let configuration = SSConfiguration()
configuration.subscriptionIDs = ["monthly_premium"]
configuration.lifetimeIDs = ["lifetime_premium"]
SwiftStore.shared.initialize(configuration: configuration)
```

### 2. Use It in SwiftUI Views

Use the `@SwiftStoreState` property wrapper for reactive state:

```swift
import SwiftUI
import SwiftStore

struct ContentView: View {
    @SwiftStoreState private var store

    var body: some View {
        VStack(spacing: 20) {
            if store.isPremium {
                Text("🎉 Premium Active!")
                if let subscription = store.activeSubscription {
                    Text("Active Subscription: \(subscription)")
                }
                if store.activeLifeTime {
                    Text("Lifetime Premium Active")
                }
            } else {
                Text("Upgrade to Premium")
            }
        }
        .padding()
    }
}
```

### 3. Sell Something

Purchases happen through the platform's StoreKit views, which report purchase progress (including Ask to Buy `.pending`) through their own callbacks:

```swift
import SwiftUI
import StoreKit

struct Paywall: View {
    var body: some View {
        SubscriptionStoreView(groupID: "YOUR_SUBSCRIPTION_GROUP_ID") {
            Text("Unlock Premium")
        }
    }
}
```

Once a purchase is approved, SwiftStore processes the transaction automatically and premium state updates.

## Observability

Subscribe to the event stream for analytics, logging, or UI hints:

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

Events are delivered on the main actor in occurrence order. Unverified transactions change no state; unrecognized verified products are completed but grant nothing.

## Restoring Purchases

```swift
// Distinguishable outcome; throws on failure (for example, offline).
let outcome = try await SwiftStore.shared.restore()
switch outcome {
case .restored(let count):
    print("Restored — \(count) active entitlements")
case .nothingToRestore:
    print("Nothing to restore")
}

// Legacy variant: reports via the .restoreFinished event only, never throws.
await SwiftStore.shared.restorePurchases()
```

## Standalone Instances (Tests & Previews)

Most apps use `shared`. For tests, previews, or isolated environments, create independent instances — each keeps its own configuration, state, and event slot, while platform monitoring still runs once per process:

```swift
let store = SwiftStore.make()
print(store.isInitialized) // false — safe defaults until initialized
store.initialize {
    $0.setLifetimeProductIDs([ProductID("lifetime_premium")])
}
```

## Behavior Guarantees

- **Single pipeline**: monitoring runs once per process; outcomes are applied once per initialized instance.
- **Product-scoped clearing**: one product's expiry or revocation never clears another product's entitlement.
- **Grace retention**: a subscription inside the platform's billing grace period (or billing retry) keeps access; access is removed only on true lapse.
- **Hygiene**: verified transactions are completed exactly once; unverified ones are ignored and never finished.
- **Type safety**: `ProductID` and `classify(_:)` avoid raw-string mistakes; `termsLink`/`privacyLink` give validated `URL?` accessors (no force-unwrapping).

## API Overview

### SwiftStore

```swift
public final class SwiftStore {
    public static let shared: SwiftStore
    public static func make() -> SwiftStore

    public var activeLifeTime: Bool         // managed by the store — writing deprecated
    public var activeSubscription: String?  // managed by the store — writing deprecated
    public var isPremium: Bool { get }

    public var termsURL: String?
    public var privacyURL: String?
    public var termsLink: URL?              // validated (nil when unset/malformed)
    public var privacyLink: URL?
    public var productIDs: [String]
    public var onEvent: ((StoreEvent) -> Void)?
    public var isInitialized: Bool

    public func initialize(_ configure: (SSConfiguration) -> Void) -> SwiftStore
    public func initialize(configuration: SSConfiguration) -> SwiftStore
    public func hasEntitlement(_ id: ProductID) -> Bool
    public func restore() async throws -> RestoreOutcome
    public func restorePurchases() async
    public func showManageSubscriptions(in scene: UIWindowScene)  // iOS only
}
```

### Configuration

```swift
public class SSConfiguration {          // typealias StoreConfiguration
    public init()
    public var subscriptionIDs: [String]
    public var lifetimeIDs: [String]
    public var termsURL: String?
    public var privacyURL: String?

    public func setSubscriptionIDs(_ ids: [String]) -> Self
    public func setLifetimeIDs(_ ids: [String]) -> Self
    public func setSubscriptionProductIDs(_ ids: [ProductID]) -> Self
    public func setLifetimeProductIDs(_ ids: [ProductID]) -> Self
    public func setTermsURL(_ url: String?) -> Self
    public func setPrivacyURL(_ url: String?) -> Self
    public func classify(_ id: String) -> ProductClassification
    public func classify(_ id: ProductID) -> ProductClassification
}
```

### Supporting Types

```swift
public enum StoreEvent: Sendable, Equatable {
    case entitlementChanged(productID: String, isActive: Bool)
    case purchaseFinished(productID: String)
    case transactionUnverified
    case restoreFinished
}

public struct ProductID: Hashable, Sendable, ExpressibleByStringLiteral {
    public let rawValue: String
}

public enum RestoreOutcome: Sendable, Equatable {
    case restored(count: Int)
    case nothingToRestore
}

public enum ProductClassification: Sendable, Equatable {
    case lifetime, subscription, unrecognized
}

public enum ProductType {              // legacy — kept for compatibility
    case lifetime, subscription
    @available(*, deprecated, message: "Use ProductClassification.unrecognized instead.")
    case none
}
```

### SwiftStoreState

```swift
@propertyWrapper
public struct SwiftStoreState: DynamicProperty {
    public init(_ viewModel: SwiftStore = .shared)
    public var wrappedValue: SwiftStore        // read store state
    public var projectedValue: Binding<SwiftStore>
}
```

> ⚠️ **Deprecated**: assigning entitlement state through `@SwiftStoreState` dynamic member lookup (for example `store.activeLifeTime = true`) is deprecated — entitlement state is managed by the store and treated as read-only. Writable access will be removed in a future major version.

## Documentation

- Full release history: [CHANGELOG.md](CHANGELOG.md)
- In-code documentation: ⌥-click any symbol in Xcode for Quick Help

## License

This project is licensed under the MIT License — see [LICENSE](LICENSE) for details.
