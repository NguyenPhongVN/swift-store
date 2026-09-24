import Foundation
import Testing
@testable import SwiftStore

@MainActor
struct PipelineFanOutTests {

    @Test("One broadcast applies exactly once per registered instance")
    func fanOutAppliesOncePerInstance() {
        let a = SwiftStore.make()
        let b = SwiftStore.make()
        let c = SwiftStore.make()

        a.initialize(configuration: SSConfiguration().setSubscriptionIDs(["sub1"]))
        b.initialize(configuration: SSConfiguration().setSubscriptionIDs(["sub1"]))
        c.initialize(configuration: SSConfiguration().setSubscriptionIDs(["sub1"]))

        a.activeSubscription = "sub1"
        b.activeSubscription = "sub1"
        c.activeSubscription = "sub1"

        var aEvents: [StoreEvent] = []
        var bEvents: [StoreEvent] = []
        a.onEvent = { aEvents.append($0) }
        b.onEvent = { bEvents.append($0) }

        let facts = TransactionFacts(
            productID: "sub1",
            isRevoked: false,
            isExpired: false,
            isGraceProtected: false,
            isFreshPurchase: false
        )
        TransactionPipeline.shared.broadcast(.verified(facts))

        #expect(a.activeSubscription == "sub1")
        #expect(b.activeSubscription == "sub1")
        #expect(aEvents.count == 1)
        #expect(bEvents.count == 1)
    }

    @Test("Unverified outcome emits transactionUnverified without state change")
    func unverifiedOutcome() {
        let store = SwiftStore.make()
        store.initialize(configuration: SSConfiguration().setSubscriptionIDs(["sub1"]))
        store.activeSubscription = "sub1"

        var events: [StoreEvent] = []
        store.onEvent = { events.append($0) }

        store.apply(outcome: .unverified)

        #expect(events == [.transactionUnverified])
        #expect(store.activeSubscription == "sub1")
        #expect(store.isPremium)
    }
}
