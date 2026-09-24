import Foundation

/// Represents the type of in-app purchase product
public enum ProductType {
    /// One-time purchase product
    case lifetime
    /// Recurring subscription product
    case subscription
    /// Product not found or unrecognized
    ///
    /// - Deprecated: Use `ProductClassification.unrecognized` instead. The case
    /// remains functional; writable access patterns are unchanged and it will
    /// only be removed in a future major version.
    @available(*, deprecated, message: "Use ProductClassification.unrecognized instead.")
    case none
}

/// The explicit classification of a product identifier against a configuration.
public enum ProductClassification: Sendable, Equatable {
    /// Recurring subscription product.
    case subscription
    /// One-time purchase product.
    case lifetime
    /// Identifier not present in the configuration.
    case unrecognized
}

/// A friendlier alias for `SSConfiguration`.
public typealias StoreConfiguration = SSConfiguration

/// Configuration class for SwiftStore in-app purchase management
@Observable
public class SSConfiguration {
    
    // MARK: - Properties
    
    /// Array of subscription product identifiers from App Store Connect
    public var subscriptionIDs: [String] = []
    
    /// Array of lifetime (one-time purchase) product identifiers from App Store Connect
    public var lifetimeIDs: [String] = []
    
    /// URL for the Terms of Service page
    public var termsURL: String?
    
    /// URL for the Privacy Policy page
    public var privacyURL: String?
    
    // MARK: - Initialization
    
    /**
     * Initialize with default configuration
     */
    public init() {
        
    }
    
    // MARK: - Configuration Methods
    
    /**
     * Set subscription product IDs
     *
     * ## Parameters:
     * - `ids`: Array of subscription product IDs
     *
     * ## Returns:
     * Self for method chaining
     *
     * ## Example:
     * ```swift
     * config.setSubscriptionIDs(["com.myapp.monthly", "com.myapp.yearly"])
     * ```
     */
    @discardableResult
    public func setSubscriptionIDs(_ ids: [String]) -> Self {
        self.subscriptionIDs = ids
        return self
    }
    
    /**
     * Set lifetime product IDs
     *
     * ## Parameters:
     * - `ids`: Array of lifetime product IDs
     *
     * ## Returns:
     * Self for method chaining
     *
     * ## Example:
     * ```swift
     * config.setLifetimeIDs(["com.myapp.lifetime"])
     * ```
     */
    @discardableResult
    public func setLifetimeIDs(_ ids: [String]) -> Self {
        self.lifetimeIDs = ids
        return self
    }

    /**
     * Set subscription product IDs using type-safe identifiers.
     *
     * Identifiers are stored as strings, so behavior is identical to
     * `setSubscriptionIDs(_:)`; the distinct name keeps existing string-literal
     * call sites unambiguous.
     *
     * ## Parameters:
     * - `ids`: Array of subscription product identifiers
     *
     * ## Returns:
     * Self for method chaining
     */
    @discardableResult
    public func setSubscriptionProductIDs(_ ids: [ProductID]) -> Self {
        self.subscriptionIDs = ids.map(\.rawValue)
        return self
    }

    /**
     * Set lifetime product IDs using type-safe identifiers.
     *
     * Identifiers are stored as strings, so behavior is identical to
     * `setLifetimeIDs(_:)`; the distinct name keeps existing string-literal
     * call sites unambiguous.
     *
     * ## Parameters:
     * - `ids`: Array of lifetime product identifiers
     *
     * ## Returns:
     * Self for method chaining
     */
    @discardableResult
    public func setLifetimeProductIDs(_ ids: [ProductID]) -> Self {
        self.lifetimeIDs = ids.map(\.rawValue)
        return self
    }
    
    /**
     * Set Terms of Service URL
     *
     * ## Parameters:
     * - `url`: The URL string for terms of service
     *
     * ## Returns:
     * Self for method chaining
     *
     * ## Example:
     * ```swift
     * config.setTermsURL("https://myapp.com/terms")
     * ```
     */
    @discardableResult
    public func setTermsURL(_ url: String?) -> Self {
        self.termsURL = url
        return self
    }
    
    /**
     * Set Privacy Policy URL
     *
     * ## Parameters:
     * - `url`: The URL string for privacy policy
     *
     * ## Returns:
     * Self for method chaining
     *
     * ## Example:
     * ```swift
     * config.setPrivacyURL("https://myapp.com/privacy")
     * ```
     */
    @discardableResult
    public func setPrivacyURL(_ url: String?) -> Self {
        self.privacyURL = url
        return self
    }
    
    /// Combined array of all product identifiers
    var productIDs: [String] {
        subscriptionIDs + lifetimeIDs
    }

    /// Determines the classification for a given product identifier
    ///
    /// Subscription identifiers take precedence over lifetime identifiers when
    /// an identifier appears in both lists.
    /// - Parameter id: The product identifier to check
    /// - Returns: The explicit classification (subscription, lifetime, or unrecognized)
    public func classify(_ id: String) -> ProductClassification {
        if subscriptionIDs.contains(id) {
            return .subscription
        } else if lifetimeIDs.contains(id) {
            return .lifetime
        } else {
            return .unrecognized
        }
    }

    /// `ProductID` overload of `classify(_:)`.
    /// - Parameter id: The product identifier to check
    /// - Returns: The explicit classification (subscription, lifetime, or unrecognized)
    public func classify(_ id: ProductID) -> ProductClassification {
        classify(id.rawValue)
    }
}
