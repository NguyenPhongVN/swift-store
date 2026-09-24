import Foundation

/// A discrete occurrence delivered to subscribers of the store's event stream.
///
/// Events make silent store activity observable — entitlement changes,
/// verification failures, purchases, and restore completions can be logged,
/// surfaced to users, or forwarded to analytics.
///
/// Delivery happens on the main actor in occurrence order. When no handler is
/// registered, the store behaves exactly as before and events are discarded.
public enum StoreEvent: Sendable, Equatable {

    /// A recognized product's entitlement state settled — granted or renewed
    /// (`isActive == true`), or cleared by revocation or expiry (`isActive == false`).
    case entitlementChanged(productID: String, isActive: Bool)

    /// A verified first purchase arrived on the live transaction pipeline.
    /// Renewals and entitlement restorations report `entitlementChanged` instead.
    case purchaseFinished(productID: String)

    /// A transaction failed verification. It is ignored — entitlement state is
    /// unchanged and the transaction is not completed (secure default).
    case transactionUnverified

    /// A restore operation finished, including when there was nothing to restore.
    case restoreFinished
}
