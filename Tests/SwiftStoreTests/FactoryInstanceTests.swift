import Testing
@testable import SwiftStore

@MainActor
struct FactoryInstanceTests {

    @Test("Factory instances are independent of each other and of the shared instance")
    func instancesAreIndependent() {
        let a = SwiftStore.make()
        let b = SwiftStore.make()

        a.initialize(configuration: SSConfiguration().setLifetimeIDs(["a.lifetime"]))
        #expect(a.productIDs == ["a.lifetime"])
        #expect(b.productIDs.isEmpty)
        #expect(b.termsURL == nil)

        b.initialize(configuration: SSConfiguration().setSubscriptionIDs(["b.sub"]))
        #expect(b.productIDs == ["b.sub"])
        #expect(a.productIDs == ["a.lifetime"])
        #expect(a.isInitialized)
        #expect(b.isInitialized)
    }

    @Test("Instances report safe defaults before initialization")
    func safeDefaultsBeforeInit() {
        let store = SwiftStore.make()
        #expect(!store.isInitialized)
        #expect(!store.isPremium)
        #expect(store.productIDs.isEmpty)
        #expect(store.termsURL == nil)
        #expect(store.privacyURL == nil)
        #expect(store.termsLink == nil)
        #expect(store.privacyLink == nil)
    }
}
