import Testing
@testable import SwiftStore

@MainActor
struct StoreEventTests {

    @Test("StoreEvent equality and pattern matching")
    func equalityAndMatching() {
        let event = StoreEvent.entitlementChanged(productID: "p1", isActive: true)

        #expect(event == .entitlementChanged(productID: "p1", isActive: true))
        #expect(event != .entitlementChanged(productID: "p1", isActive: false))
        #expect(event != .purchaseFinished(productID: "p1"))
        #expect(event != .transactionUnverified)
        #expect(event != .restoreFinished)

        guard case let .entitlementChanged(productID, isActive) = event else {
            Issue.record("Expected entitlementChanged")
            return
        }
        #expect(productID == "p1")
        #expect(isActive)
    }

    @Test("A fresh store instance has no event subscriber")
    func freshStoreHasNoSubscriber() {
        let store = SwiftStore.make()
        #expect(store.onEvent == nil)
    }
}
