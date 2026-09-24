import Foundation

/// The outcome of a completed restore operation.
public enum RestoreOutcome: Sendable, Equatable {

    /// The restore finished and the account currently holds `count` verified
    /// entitlements. Note: this is the total number of active entitlements
    /// after the restore, not a delta of newly added ones — the platform does
    /// not report which purchases were added by the restore.
    case restored(count: Int)

    /// The restore finished but the account holds no entitlements.
    case nothingToRestore

    /// Maps a post-restore verified entitlement count to an outcome.
    static func fromEntitlementCount(_ count: Int) -> RestoreOutcome {
        count == 0 ? .nothingToRestore : .restored(count: count)
    }
}
