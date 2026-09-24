import Foundation
import Observation
import StoreKit

/// Main store class for handling in-app purchases and subscription management
///
/// `SwiftStore` is a singleton class that provides a simple interface for managing
/// in-app purchases, subscriptions, and lifetime purchases in iOS applications.
/// It automatically handles transaction verification, entitlement management, and
/// state updates using StoreKit 2.
///
/// ## Features
/// - **Automatic Transaction Handling**: Processes unfinished and current entitlements
/// - **Real-time Updates**: Monitors transaction updates and updates state accordingly
/// - **Premium Status Tracking**: Provides easy access to premium subscription status
/// - **SwiftUI Integration**: Works seamlessly with `@SwiftStoreState` property wrapper
/// - **Transaction Verification**: Built-in StoreKit transaction verification
///
/// ## Usage
/// ```swift
/// // Initialize with configuration
/// let configuration = SSConfiguration()
/// configuration.subscriptionIDs = ["monthly_premium"]
/// configuration.lifetimeIDs = ["lifetime_premium"]
/// SwiftStore.shared.initialize(configuration: configuration)
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
    /// Returns `nil` before `initialize(configuration:)` is called.
    public var termsURL: String? {
        configuration?.termsURL
    }

    /// URL for the Privacy Policy page
    ///
    /// This URL is set through the configuration and can be used to
    /// display privacy policy links in your app's UI.
    /// Returns `nil` before `initialize(configuration:)` is called.
    public var privacyURL: String? {
        configuration?.privacyURL
    }

    /// Combined array of all configured product identifiers
    ///
    /// Returns an empty array before `initialize(configuration:)` is called.
    public var productIDs: [String] {
        configuration?.productIDs ?? []
    }
    
    // MARK: - Private Properties
    
    /// Internal configuration object containing product IDs and settings
    ///
    /// `nil` until `initialize(configuration:)` is called; accessors return safe
    /// defaults instead of crashing when the store has not been initialized.
    private var configuration: SSConfiguration?

    /// Whether `initialize(configuration:)` has already started its monitoring tasks
    ///
    /// `Transaction.updates` is an infinite sequence, so initialization must only
    /// start it once even if `initialize` is called repeatedly.
    private var isInitialized = false
    
    // MARK: - Initialization
    
    /// Private initializer to enforce singleton pattern
    ///
    /// The initializer is private to ensure only one instance of SwiftStore
    /// exists throughout the application lifecycle.
    private init() {
        
    }
    
    // MARK: - Public Methods
    
    /// Initializes the SwiftStore with the provided configuration
    ///
    /// This method must be called before using any other SwiftStore functionality.
    /// It sets up the configuration and starts monitoring for transaction updates.
    /// Calling it again is safe: the configuration is refreshed, but the transaction
    /// monitoring tasks are only started on the first call, so no duplicate
    /// processing occurs.
    ///
    /// The initialization process includes:
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
        guard !isInitialized else { return self }
        isInitialized = true

        // Because the tasks below capture 'self' in their closures, this object must be fully initialized before this point.
        Task(priority: .background) {
            // Finish any unfinished transactions -- for example, if the app was terminated before finishing a transaction.
            for await verificationResult in Transaction.unfinished {
                await handle(updatedTransaction: verificationResult)
            }

            // Fetch current entitlements for all product types except consumables.
            for await verificationResult in Transaction.currentEntitlements {
                await handle(updatedTransaction: verificationResult)
            }
        }
        Task(priority: .background) {
            for await verificationResult in Transaction.updates {
                await handle(updatedTransaction: verificationResult)
            }
        }


        return self
    }
    
    // MARK: - Private Methods
    
    /// Handles transaction updates and updates the store state accordingly
    ///
    /// This method processes StoreKit transaction verification results and updates
    /// the appropriate store properties based on the transaction type and status.
    /// It handles these scenarios:
    ///
    /// 1. **Unverified Transactions**: Ignored entirely — no entitlement change and no
    ///    finish call, so untrusted content is never acknowledged (secure default).
    /// 2. **Revoked Transactions**: Removes access only to the product identified by
    ///    `transaction.productID`; the transaction is finished whether or not the
    ///    product is recognized, so it is not re-delivered on later launches.
    /// 3. **Expired Subscriptions**: Deactivates the recorded subscription only when
    ///    the expired transaction belongs to the product currently recorded as active.
    /// 4. **Valid Transactions**: Activates lifetime purchases or subscriptions. Verified
    ///    transactions for unrecognized products grant no entitlement but are still
    ///    finished to prevent indefinite re-delivery.
    ///
    /// State changes are scoped to the transaction's own product: an expired or revoked
    /// delivery can never clear another product's entitlement, so the final state does
    /// not depend on transaction delivery order. All state changes are automatically
    /// reflected in the UI through the `@Observable` protocol.
    ///
    /// - Parameter verificationResult: The StoreKit transaction verification result
    private func handle(updatedTransaction verificationResult: VerificationResult<Transaction>) async {
        // Transactions that fail verification are intentionally ignored and not finished:
        // their contents are untrusted and must not grant entitlements or be acknowledged.
        guard case .verified(let transaction) = verificationResult else { return }

        let productType = configuration?.getProductType(for: transaction.productID) ?? .none

        if transaction.revocationDate != nil {
            // Remove access to the product identified by `transaction.productID`.
            // `Transaction.revocationReason` provides details about the revoked transaction.
            if productType == .lifetime {
                activeLifeTime = false
            } else if productType == .subscription, activeSubscription == transaction.productID {
                // In an app that supports Family Sharing, there might be another entitlement that still provides access to the subscription.
                activeSubscription = nil
            }
            await transaction.finish()
            return
        }

        if let expirationDate = transaction.expirationDate, expirationDate < Date() {
            // Clear the recorded subscription only when the expired transaction is the
            // one currently recorded as active; another product's expiry must not
            // disable a still-valid subscription.
            if productType == .subscription, activeSubscription == transaction.productID {
                activeSubscription = nil
            }
            return
        }

        switch productType {
            case .lifetime:
                activeLifeTime = true
            case .subscription:
                activeSubscription = transaction.productID
            case .none:
                // A verified transaction for an unrecognized product grants no
                // entitlement here, but is still finished so the store does not
                // re-deliver it on every launch.
                break
        }
        await transaction.finish()
    }
}
