import Foundation
import StoreKit

/// Internal marker for the pipeline that delivered a transaction. Distinguishes
/// live purchases from entitlement syncs when choosing the event to emit.
enum DeliverySource {
    /// `Transaction.updates` — live purchases and renewals.
    case liveUpdates
    /// `Transaction.currentEntitlements` — entitlement sync.
    case currentEntitlements
    /// `Transaction.unfinished` — interrupted transactions completing.
    case unfinished
}

/// Transaction-level facts extracted once per delivery. Deliberately
/// configuration-independent: classification is applied per instance.
struct TransactionFacts: Equatable, Sendable {
    let productID: String
    let isRevoked: Bool
    let isExpired: Bool
    /// The subscription is expired but shielded by the platform's billing
    /// retry / grace period — access must be retained.
    let isGraceProtected: Bool
    /// Delivered live and the platform reason is a first purchase (not renewal).
    let isFreshPurchase: Bool
}

/// The outcome broadcast to every registered instance after the pipeline's
/// single completion decision for a delivered transaction.
enum PipelineOutcome: Sendable {
    /// The transaction failed verification. Never finished; instances emit
    /// `.transactionUnverified` and change no state.
    case unverified
    /// A verified transaction with its extracted facts.
    case verified(TransactionFacts)
}

/// The process-wide transaction monitoring pipeline.
///
/// Owns the three StoreKit delivery loops (`unfinished`, `currentEntitlements`,
/// `updates`) and starts them exactly once per process, no matter how many
/// `SwiftStore` instances exist. For each delivered transaction it verifies it,
/// extracts facts, makes the completion decision **once**, and broadcasts the
/// outcome to every registered instance. Instances apply outcomes against their
/// own configuration, keeping their entitlement state independent.
@MainActor
final class TransactionPipeline {

    static let shared = TransactionPipeline()

    private var loopsStarted = false
    private var startupEntitlementSyncFinished = false
    private var sinks: [ObjectIdentifier: Sink] = [:]
    /// Completion decisions already made — guarantees one decision per
    /// transaction per process even when the same transaction arrives on
    /// several pipelines (for example `unfinished` and `currentEntitlements`
    /// during startup).
    private var decidedTransactionIDs = Set<UInt64>()

    private final class Sink {
        weak var instance: SwiftStore?

        init(instance: SwiftStore) {
            self.instance = instance
        }
    }

    private init() {}

    /// Registers an instance as an outcome sink and starts the loops if this
    /// is the first registration. A late-registering instance (after the
    /// startup entitlement sync has drained) receives its own entitlements
    /// replay so it catches up with current entitlements.
    func register(_ instance: SwiftStore) {
        sinks[ObjectIdentifier(instance)] = Sink(instance: instance)
        startIfNeeded()

        guard startupEntitlementSyncFinished else { return }
        Task {
            for await result in Transaction.currentEntitlements {
                // Stop replaying if the instance left the registry.
                guard sinks[ObjectIdentifier(instance)] != nil else { break }
                await process(result, source: .currentEntitlements, only: instance)
            }
        }
    }

    /// Broadcasts an outcome to every registered instance (used by the
    /// processing path and by tests).
    func broadcast(_ outcome: PipelineOutcome) {
        pruneDeallocatedSinks()
        for sink in sinks.values {
            sink.instance?.apply(outcome: outcome)
        }
    }

    // MARK: - Private

    private func startIfNeeded() {
        guard !loopsStarted else { return }
        loopsStarted = true

        Task {
            for await result in Transaction.unfinished {
                await process(result, source: .unfinished)
            }
        }
        Task {
            for await result in Transaction.currentEntitlements {
                await process(result, source: .currentEntitlements)
            }
            startupEntitlementSyncFinished = true
        }
        Task {
            for await result in Transaction.updates {
                await process(result, source: .liveUpdates)
            }
        }
    }

    /// Verifies a delivered transaction, makes the completion decision once,
    /// and delivers the outcome to every sink — or to a single targeted
    /// instance during registration replay.
    private func process(
        _ verificationResult: VerificationResult<Transaction>,
        source: DeliverySource,
        only: SwiftStore? = nil
    ) async {
        // Transactions that fail verification are intentionally ignored and
        // never finished: their contents are untrusted and must not grant
        // entitlements or be acknowledged.
        guard case .verified(let transaction) = verificationResult else {
            deliver(.unverified, to: only)
            return
        }

        // One completion decision per transaction, per process. Targeted
        // replay skips this gate — it exists to catch an instance up, and
        // re-finishing finished transactions is a harmless no-op.
        if only == nil {
            guard decidedTransactionIDs.insert(transaction.id).inserted else { return }
        }

        let now = Date()
        let isExpired = transaction.expirationDate.map { $0 < now } ?? false
        // Grace signal: the platform keeps delivering a grace-protected
        // subscription through `currentEntitlements` even after its
        // expiration date (billing retry / grace period), while genuinely
        // expired deliveries arrive via `updates`/`unfinished`. Renewal-info
        // grace fields live on `Product.SubscriptionInfo.RenewalInfo`, not on
        // `Transaction`, so the delivery pipeline is the available signal.
        let isGraceProtected = isExpired && source == .currentEntitlements

        let facts = TransactionFacts(
            productID: transaction.productID,
            isRevoked: transaction.revocationDate != nil,
            isExpired: isExpired,
            isGraceProtected: isGraceProtected,
            isFreshPurchase: only == nil && source == .liveUpdates && transaction.reason == .purchase
        )

        // Completion decision (once): finished for revocations and active
        // entitlements; never for expired or grace-protected deliveries —
        // matching the platform's sample behavior.
        if !isExpired {
            await transaction.finish()
        }

        deliver(.verified(facts), to: only)
    }

    private func deliver(_ outcome: PipelineOutcome, to only: SwiftStore?) {
        if let only {
            only.apply(outcome: outcome)
        } else {
            broadcast(outcome)
        }
    }

    private func pruneDeallocatedSinks() {
        sinks = sinks.filter { $0.value.instance != nil }
    }
}
