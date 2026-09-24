import Foundation

/// A type-safe product identifier.
///
/// Use it in place of raw strings when configuring products or querying
/// entitlements, so typos become compile-time errors instead of silent
/// mismatches. It is constructible from string literals, keeping call sites
/// natural:
///
///     configuration.setLifetimeProductIDs(["premium_lifetime"])
///     store.hasEntitlement(ProductID("premium_lifetime"))
public struct ProductID: Hashable, Sendable, ExpressibleByStringLiteral {

    /// The underlying string identifier used by the store.
    public let rawValue: String

    /// Creates an identifier from a string.
    public init(_ rawValue: String) {
        self.rawValue = rawValue
    }

    /// Creates an identifier from a string literal.
    public init(stringLiteral value: String) {
        self.rawValue = value
    }
}
