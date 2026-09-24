import Testing
@testable import SwiftStore

@MainActor
struct ClassificationTests {

    @Test("Classification precedence: subscription first, lifetime, then unrecognized")
    func precedenceAndUnrecognized() {
        let config = SSConfiguration()
            .setSubscriptionIDs(["s1"])
            .setLifetimeIDs(["l1"])

        #expect(config.classify("s1") == .subscription)
        #expect(config.classify("l1") == .lifetime)
        #expect(config.classify("nope") == .unrecognized)
    }

    @Test("String and ProductID classification agree")
    func stringAndProductIDAgree() {
        let config = SSConfiguration()
            .setSubscriptionIDs(["s1"])
            .setLifetimeIDs(["l1"])

        #expect(config.classify(ProductID("s1")) == config.classify("s1"))
        #expect(config.classify(ProductID("l1")) == config.classify("l1"))
        #expect(config.classify(ProductID("nope")) == config.classify("nope"))
    }

    @Test("StoreConfiguration alias resolves to the configuration type")
    func aliasResolves() {
        let config: StoreConfiguration = SSConfiguration()
        #expect(config.classify("anything") == .unrecognized)
    }
}
