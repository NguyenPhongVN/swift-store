import Foundation
import Testing
@testable import SwiftStore

@MainActor
struct GraceDecisionTests {

    private func makeStore() -> SwiftStore {
        let store = SwiftStore.make()
        store.initialize(configuration: SSConfiguration().setSubscriptionIDs(["sub1"]))
        store.activeSubscription = "sub1"
        return store
    }

    @Test("Expired transaction within billing retry retains premium access")
    func graceRetainedForBillingRetry() {
        let store = makeStore()
        let facts = TransactionFacts(
            productID: "sub1",
            isRevoked: false,
            isExpired: true,
            isGraceProtected: true,
            isFreshPurchase: false
        )
        store.apply(outcome: .verified(facts))

        #expect(store.activeSubscription == "sub1")
        #expect(store.isPremium)
    }

    @Test("Expired transaction with a live grace window retains premium access")
    func graceRetainedForGraceWindow() {
        let store = makeStore()
        let facts = TransactionFacts(
            productID: "sub1",
            isRevoked: false,
            isExpired: true,
            isGraceProtected: true,
            isFreshPurchase: false
        )
        store.apply(outcome: .verified(facts))

        #expect(store.isPremium)
    }

    @Test("Plain expired transaction clears the recorded subscription")
    func plainExpiredClears() {
        let store = makeStore()
        let facts = TransactionFacts(
            productID: "sub1",
            isRevoked: false,
            isExpired: true,
            isGraceProtected: false,
            isFreshPurchase: false
        )
        var events: [StoreEvent] = []
        store.onEvent = { events.append($0) }

        store.apply(outcome: .verified(facts))

        #expect(store.activeSubscription == nil)
        #expect(!store.isPremium)
        #expect(events == [.entitlementChanged(productID: "sub1", isActive: false)])
    }

    @Test("Revocation clears access regardless of grace protection")
    func revocationWinsOverGrace() {
        let store = makeStore()
        let facts = TransactionFacts(
            productID: "sub1",
            isRevoked: true,
            isExpired: true,
            isGraceProtected: true,
            isFreshPurchase: false
        )
        store.apply(outcome: .verified(facts))

        #expect(store.activeSubscription == nil)
        #expect(!store.isPremium)
    }

    @Test("Expired unknown product produces no event and no state change")
    func expiredUnknownIsSilent() {
        let store = makeStore()
        var events: [StoreEvent] = []
        store.onEvent = { events.append($0) }

        let facts = TransactionFacts(
            productID: "unknown.product",
            isRevoked: false,
            isExpired: true,
            isGraceProtected: false,
            isFreshPurchase: false
        )
        store.apply(outcome: .verified(facts))

        #expect(events.isEmpty)
        #expect(store.activeSubscription == "sub1")
    }

    @Test("Fresh purchase emits purchaseFinished; renewal emits entitlementChanged")
    func freshPurchaseVersusRenewal() {
        let store = makeStore()

        var events: [StoreEvent] = []
        store.onEvent = { events.append($0) }

        store.apply(outcome: .verified(TransactionFacts(
            productID: "sub1", isRevoked: false, isExpired: false,
            isGraceProtected: false, isFreshPurchase: true
        )))
        #expect(events.last == .purchaseFinished(productID: "sub1"))

        store.apply(outcome: .verified(TransactionFacts(
            productID: "sub1", isRevoked: false, isExpired: false,
            isGraceProtected: false, isFreshPurchase: false
        )))
        #expect(events.last == .entitlementChanged(productID: "sub1", isActive: true))
    }
}
