import Foundation
import Observation
import StoreKit
#if os(iOS)
import UIKit
#endif

/// Main store class for handling in-app purchases and subscription management
///
/// `SwiftStore` is a singleton class that provides a simple interface for managing
/// in-app purchases, subscriptions, and lifetime purchases in iOS applications.
/// It automatically handles transaction verification, entitlement management, and
/// state updates using StoreKit 2.
///
/// ## Features
/// - **Automatic Transaction Handling**: One per-process pipeline verifies and
///   completes platform transactions, fanning outcomes out to every instance
/// - **Real-time Updates**: Monitors transaction updates and updates state accordingly
/// - **Premium Status Tracking**: Provides easy access to premium subscription status
/// - **Observability**: Subscribe to `onEvent` for entitlement, purchase, and failure events
/// - **SwiftUI Integration**: Works seamlessly with `@SwiftStoreState` property wrapper
/// - **Transaction Verification**: Built-in StoreKit transaction verification
///
/// ## Usage
/// ```swift
/// // Initialize with configuration
/// SwiftStore.shared.initialize {
///     $0.subscriptionIDs = ["monthly_premium"]
///     $0.lifetimeIDs = ["lifetime_premium"]
/// }
///
/// // Check premium status
/// if SwiftStore.shared.isPremium {
///     // User has premium access
/// }
/// ```
@MainActor
@Observable
public final class SwiftStore {

    // MARK: - Public Properties

    /// Shared singleton instance of SwiftStore
    ///
    /// Use this instance throughout your app to access store functionality.
    /// The singleton pattern ensures consistent state across your application.
    public static let shared = SwiftStore()

    /// Indicates whether a lifetime purchase is currently active
    ///
    /// This property is automatically updated when lifetime purchases are
    /// verified through StoreKit transactions.
    public var activeLifeTime: Bool = false

    /// Currently active subscription product identifier
    ///
    /// Contains the product ID of the active subscription, or `nil` if no
    /// subscription is currently active. This is automatically updated
    /// when subscription transactions are processed.
    public var activeSubscription: String? = nil

    /// Indicates whether the user has premium access
    ///
    /// Returns `true` if either a lifetime purchase is active or an active
    /// subscription exists. This is the primary property to check for
    /// premium features in your app.
    public var isPremium: Bool {
        return activeLifeTime || activeSubscription != nil
    }

    /// URL for the Terms of Service page
    ///
    /// This URL is set through the configuration and can be used to
    /// display terms of service links in your app's UI.
    /// Returns `nil` before `initialize` is called.
    public var termsURL: String? {
        configuration?.termsURL
    }

    /// URL for the Privacy Policy page
    ///
    /// This URL is set through the configuration and can be used to
    /// display privacy policy links in your app's UI.
    /// Returns `nil` before `initialize` is called.
    public var privacyURL: String? {
        configuration?.privacyURL
    }

    /// The validated Terms of Service link
    ///
    /// Parsed from `termsURL`; `nil` when unset or malformed, so link
    /// presentation never needs force-unwrapping in app code.
    public var termsLink: URL? {
        guard let termsURL else { return nil }
        return URL(string: termsURL)
    }

    /// The validated Privacy Policy link
    ///
    /// Parsed from `privacyURL`; `nil` when unset or malformed, so link
    /// presentation never needs force-unwrapping in app code.
    public var privacyLink: URL? {
        guard let privacyURL else { return nil }
        return URL(string: privacyURL)
    }

    /// Combined array of all configured product identifiers
    ///
    /// Returns an empty array before `initialize` is called.
    public var productIDs: [String] {
        configuration?.productIDs ?? []
    }

    /// Receives store events for observability — analytics, logging, or UI hints.
    ///
    /// Events (`StoreEvent`) are delivered on the main actor in occurrence
    /// order. The slot holds a single handler; multiplex to multiple consumers
    /// on your side. With no handler set, store behavior is unchanged.
    public var onEvent: ((StoreEvent) -> Void)?

    /// Whether this instance has been initialized with a configuration.
    ///
    /// Read-only accessors remain usable before initialization and return
    /// safe defaults; see `initialize`.
    public var isInitialized: Bool {
        return hasBeenInitialized
    }

    // MARK: - Private Properties

    /// Internal configuration object containing product IDs and settings
    ///
    /// `nil` until `initialize` is called; accessors return safe
    /// defaults instead of crashing when the store has not been initialized.
    private var configuration: SSConfiguration?

    /// Whether `initialize` has already registered this instance with the
    /// transaction pipeline.
    ///
    /// The pipeline's delivery loops start once per process; registration
    /// must only happen once even if `initialize` is called repeatedly.
    private var hasBeenInitialized = false

    /// In-flight restore task, shared by overlapping restore calls so a
    /// second caller awaits the same truthful outcome instead of re-prompting.
    private var restoreInFlight: Task<RestoreOutcome, Error>?

    // MARK: - Initialization

    /// Creates a standalone store instance.
    ///
    /// Most apps use `shared`. Create separate instances for tests, previews,
    /// or isolated store environments; every instance keeps its own
    /// configuration, entitlement state, and event slot. Platform transaction
    /// monitoring runs once per process and fans outcomes out to all instances.
    public init() {
    }

    /// Creates and returns a new standalone store instance.
    ///
    /// Equivalent to `init()`; see its documentation.
    public static func make() -> SwiftStore {
        return SwiftStore()
    }

    // MARK: - Public Methods

    /// Initializes the SwiftStore by assembling a configuration in a closure.
    ///
    /// The closure runs synchronously on the main actor with a fresh
    /// configuration, so nothing non-sendable ever crosses an actor boundary —
    /// convenient for apps built with strict concurrency checking. Capture
    /// only sendable values (strings, arrays) into the closure.
    ///
    /// Calling `initialize` again is safe: the configuration is refreshed, but
    /// the instance is only registered with the transaction pipeline once, so
    /// no duplicate processing occurs.
    ///
    /// - Parameter configure: A closure that populates a fresh configuration.
    /// - Returns: The SwiftStore instance for method chaining
    ///
    /// ## Example
    /// ```swift
    /// SwiftStore.shared.initialize {
    ///     $0.setSubscriptionIDs(["monthly_premium", "yearly_premium"])
    ///     $0.setLifetimeIDs(["lifetime_premium"])
    ///     $0.setTermsURL("https://yourapp.com/terms")
    ///     $0.setPrivacyURL("https://yourapp.com/privacy")
    /// }
    /// ```
    @discardableResult
    public func initialize(_ configure: (SSConfiguration) -> Void) -> SwiftStore {
        let configuration = SSConfiguration()
        configure(configuration)
        return initialize(configuration: configuration)
    }

    /// Initializes the SwiftStore with the provided configuration
    ///
    /// This method must be called before using any other SwiftStore functionality.
    /// It sets up the configuration and registers the instance with the
    /// per-process transaction pipeline. Calling it again is safe: the
    /// configuration is refreshed, but registration happens only once, so no
    /// duplicate processing occurs.
    ///
    /// The registration process includes:
    /// - Setting up the configuration with product IDs and URLs
    /// - Processing any unfinished transactions from previous app sessions
    /// - Fetching current entitlements for all configured products
    /// - Starting to monitor for new transaction updates
    ///
    /// - Parameter configuration: The configuration object containing product IDs and settings
    /// - Returns: The SwiftStore instance for method chaining
    ///
    /// ## Example
    /// ```swift
    /// let configuration = SSConfiguration()
    /// configuration.subscriptionIDs = ["monthly_premium", "yearly_premium"]
    /// configuration.lifetimeIDs = ["lifetime_premium"]
    /// configuration.termsURL = "https://yourapp.com/terms"
    /// configuration.privacyURL = "https://yourapp.com/privacy"
    ///
    /// SwiftStore.shared.initialize(configuration: configuration)
    /// ```
    @discardableResult
    public func initialize(configuration: SSConfiguration) -> SwiftStore {
        self.configuration = configuration
        guard !hasBeenInitialized else { return self }
        hasBeenInitialized = true

        TransactionPipeline.shared.register(self)
        return self
    }

    /// Returns whether this instance currently grants the entitlement for the
    /// given product — an active lifetime purchase or the recorded active
    /// subscription.
    ///
    /// Returns `false` before `initialize` is called.
    public func hasEntitlement(_ id: ProductID) -> Bool {
        guard let configuration else { return false }
        if activeLifeTime, configuration.lifetimeIDs.contains(id.rawValue) {
            return true
        }
        return activeSubscription == id.rawValue
    }

    /// Restores previously completed purchases and reports the outcome.
    ///
    /// - Returns: `.restored(count:)` when the account holds verified
    ///   entitlements after the restore (count = total active entitlements,
    ///   not a delta), or `.nothingToRestore` when it holds none.
    /// - Throws: When the platform restore fails (for example, offline). No
    ///   success event is emitted on failure.
    ///
    /// Completion also emits the existing `.restoreFinished` event. Overlapping
    /// calls await the same in-flight restore instead of re-prompting.
    public func restore() async throws -> RestoreOutcome {
        if let restoreInFlight {
            return try await restoreInFlight.value
        }
        let task = Task { () throws -> RestoreOutcome in
            try await AppStore.sync()
            defer { self.restoreInFlight = nil }
            let count = await Self.countVerifiedEntitlements()
            let outcome = RestoreOutcome.fromEntitlementCount(count)
            self.emit(.restoreFinished)
            return outcome
        }
        restoreInFlight = task
        return try await task.value
    }

    /// Restores previously completed purchases.
    ///
    /// Completion — including when there is nothing to restore — is reported as
    /// a `.restoreFinished` event. Rapid repeat calls while a restore is already
    /// in flight are no-ops, avoiding duplicate system prompts.
    ///
    /// Prefer `restore()` when you need to distinguish success, an empty
    /// account, or failure.
    public func restorePurchases() async {
        _ = try? await restore()
    }

#if os(iOS)
    /// Presents the system's subscription management screen.
    ///
    /// iOS only — other platforms have no programmatic management-screen API.
    ///
    /// - Parameter scene: The window scene to present from.
    public func showManageSubscriptions(in scene: UIWindowScene) {
        Task {
            try? await AppStore.showManageSubscriptions(in: scene)
        }
    }
#endif

    // MARK: - Pipeline Application

    /// Applies a pipeline outcome to this instance: classification runs against
    /// this instance's own configuration, so isolated instances stay isolated.
    ///
    /// Called by the transaction pipeline on the main actor.
    func apply(outcome: PipelineOutcome) {
        switch outcome {
        case .unverified:
            emit(.transactionUnverified)
        case .verified(let facts):
            apply(facts)
        }
    }

    /// Applies verified transaction facts to entitlement state.
    ///
    /// Clearing rules are product-scoped: an expired or revoked delivery can
    /// never clear another product's entitlement. A subscription within the
    /// platform's billing grace period (or in billing retry) is retained even
    /// though its expiration date has passed; access is removed only when the
    /// grace protection lapses.
    private func apply(_ facts: TransactionFacts) {
        let classification = configuration?.classify(facts.productID) ?? .unrecognized

        if facts.isRevoked {
            // Remove access to the product identified by `facts.productID`.
            if classification == .lifetime {
                activeLifeTime = false
                emit(.entitlementChanged(productID: facts.productID, isActive: false))
            } else if classification == .subscription, activeSubscription == facts.productID {
                // In an app that supports Family Sharing, there might be another entitlement that still provides access to the subscription.
                activeSubscription = nil
                emit(.entitlementChanged(productID: facts.productID, isActive: false))
            }
            return
        }

        if facts.isExpired {
            if facts.isGraceProtected {
                // The platform still honors the entitlement during billing
                // retry / grace — retain access and change nothing.
                return
            }
            // Clear the recorded subscription only when the expired transaction
            // is the one currently recorded as active; another product's expiry
            // must not disable a still-valid subscription.
            if classification == .subscription, activeSubscription == facts.productID {
                activeSubscription = nil
                emit(.entitlementChanged(productID: facts.productID, isActive: false))
            }
            return
        }

        // A verified transaction for an unrecognized product grants no
        // entitlement here; the pipeline already finished it so the store does
        // not re-deliver it on every launch. Nothing changed, so no event fires.
        guard classification != .unrecognized else { return }

        switch classification {
        case .lifetime:
            activeLifeTime = true
        case .subscription:
            activeSubscription = facts.productID
        case .unrecognized:
            break
        }
        emit(facts.isFreshPurchase
             ? .purchaseFinished(productID: facts.productID)
             : .entitlementChanged(productID: facts.productID, isActive: true))
    }

    // MARK: - Private Methods

    /// Counts verified entries in the current entitlement sync.
    private static func countVerifiedEntitlements() async -> Int {
        var count = 0
        for await result in Transaction.currentEntitlements {
            if case .verified = result {
                count += 1
            }
        }
        return count
    }

    /// Delivers an event to the subscriber, if one is registered.
    ///
    /// The store is main-actor isolated, so delivery happens on the main actor.
    private func emit(_ event: StoreEvent) {
        onEvent?(event)
    }
}
