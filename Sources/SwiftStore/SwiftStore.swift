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
    public var termsURL: String? {
        configuration.termsURL
    }
    
    /// URL for the Privacy Policy page
    ///
    /// This URL is set through the configuration and can be used to
    /// display privacy policy links in your app's UI.
    public var privacyURL: String? {
        configuration.privacyURL
    }
    
    public var productIDs: [String] {
        configuration.productIDs
    }
    
    // MARK: - Private Properties
    
    /// Internal configuration object containing product IDs and settings
    private var configuration: SSConfiguration!
    
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
    /// It handles three main scenarios:
    ///
    /// 1. **Revoked Transactions**: Removes access when transactions are revoked
    /// 2. **Expired Subscriptions**: Deactivates expired subscription access
    /// 3. **Valid Transactions**: Activates lifetime purchases or subscriptions
    ///
    /// The method only processes verified transactions and ignores unverified ones
    /// for security reasons. All state changes are automatically reflected in the
    /// UI through the `@Observable` protocol.
    ///
    /// - Parameter verificationResult: The StoreKit transaction verification result
    private func handle(updatedTransaction verificationResult: VerificationResult<Transaction>) async {
        // The code below handles only verified transactions; handle unverified transactions based on your business model.
        guard case .verified(let transaction) = verificationResult else { return }
        
        if let _ = transaction.revocationDate {
            // Remove access to the product identified by `transaction.productID`.
            // `Transaction.revocationReason` provides details about the revoked transaction.
            //            guard let productID = ProductID(rawValue: transaction.productID) else {
            guard configuration.productIDs.contains(transaction.productID) else {
                print("Unexpected product: \(transaction.productID).")
                return
            }
            let productType = configuration.getProductType(for: transaction.productID)
            switch productType {
                case .lifetime:
                    activeLifeTime = false
                case .subscription:
                    // In an app that supports Family Sharing, there might be another entitlement that still provides access to the subscription.
                    activeSubscription = nil
                case .none:
                    break
            }
            await transaction.finish()
            return
        } else if let expirationDate = transaction.expirationDate, expirationDate < Date() {
            // In an app that supports Family Sharing, there might be another entitlement that still provides access to the subscription.
            activeSubscription = nil
            return
        } else {
            let productType = configuration.getProductType(for: transaction.productID)
            switch productType {
                case .lifetime:
                    activeLifeTime = true
                case .subscription:
                    // In an app that supports Family Sharing, there might be another entitlement that already provides access to the subscription.
                    activeSubscription = transaction.productID
                case .none:
                    break
            }
            await transaction.finish()
            return
        }
    }
}
