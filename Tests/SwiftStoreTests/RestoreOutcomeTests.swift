import Foundation
import Testing
@testable import SwiftStore

struct RestoreOutcomeTests {

    @Test("Zero verified entitlements map to nothingToRestore")
    func zeroMapsToNothingToRestore() {
        #expect(RestoreOutcome.fromEntitlementCount(0) == .nothingToRestore)
    }

    @Test("Positive verified entitlement counts map to restored(count:)")
    func positiveCountsMapToRestored() {
        #expect(RestoreOutcome.fromEntitlementCount(1) == .restored(count: 1))
        #expect(RestoreOutcome.fromEntitlementCount(5) == .restored(count: 5))
    }

    @Test("RestoreOutcome is equatable and sendable-friendly")
    func outcomeEquality() {
        #expect(RestoreOutcome.restored(count: 2) != .restored(count: 3))
        #expect(RestoreOutcome.restored(count: 2) == .restored(count: 2))
        #expect(RestoreOutcome.nothingToRestore != .restored(count: 0))
    }
}
