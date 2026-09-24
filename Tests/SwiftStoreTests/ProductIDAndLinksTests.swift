import Foundation
import Testing
@testable import SwiftStore

@MainActor
struct ProductIDAndLinksTests {

    @Test("ProductID literal, equality, hashing, and rawValue")
    func productIDBasics() {
        let literal: ProductID = "premium"
        let constructed = ProductID("premium")
        let other = ProductID("other")

        #expect(literal.rawValue == "premium")
        #expect(literal == constructed)
        #expect(literal != other)

        var set = Set<ProductID>()
        set.insert(literal)
        #expect(set.contains(ProductID("premium")))
        #expect(!set.contains(other))
    }

    @Test("hasEntitlement tracks lifetime and subscription state")
    func hasEntitlement() {
        let store = SwiftStore.make()
        store.initialize(
            configuration: SSConfiguration()
                .setLifetimeIDs(["life1"])
                .setSubscriptionIDs(["sub1"])
        )

        #expect(!store.hasEntitlement("life1"))
        #expect(!store.hasEntitlement(ProductID("sub1")))

        store.activeLifeTime = true
        #expect(store.hasEntitlement("life1"))
        #expect(!store.hasEntitlement(ProductID("sub1")))

        store.activeLifeTime = false
        store.activeSubscription = "sub1"
        #expect(store.hasEntitlement(ProductID("sub1")))
        #expect(!store.hasEntitlement("life1"))
    }

    @Test("Validated link accessors return nil for unset or malformed values")
    func validatedLinks() {
        let valid = SwiftStore.make()
        valid.initialize(
            configuration: SSConfiguration()
                .setTermsURL("https://example.com/terms")
                .setPrivacyURL("https://example.com/privacy")
        )
        #expect(valid.termsLink == URL(string: "https://example.com/terms"))
        #expect(valid.privacyLink == URL(string: "https://example.com/privacy"))

        let malformed = SwiftStore.make()
        malformed.initialize(
            configuration: SSConfiguration()
                .setTermsURL("not a url :: //")
                .setPrivacyURL("")
        )
        #expect(malformed.termsLink == nil)
        #expect(malformed.privacyLink == nil)
        #expect(malformed.termsURL == "not a url :: //")
    }
}
