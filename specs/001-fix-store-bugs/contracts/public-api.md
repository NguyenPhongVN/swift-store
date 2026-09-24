# Contract: SwiftStore Public API (Frozen Surface)

**Feature**: specs/001-fix-store-bugs | **Date**: 2026-09-24

Per Constitution Principle I, the members below are the library's public contract consumed by external projects. **This feature must not remove any member or change any signature.** Behavior changes are permitted only where the spec mandates them (FR-006, FR-007, FR-008, FR-001/002/003).

## Module `SwiftStore` — `SwiftStore.swift`

| Member | Signature (frozen) | Behavior changes allowed by this feature |
|---|---|---|
| `shared` | `public static let shared: SwiftStore` | none |
| `activeLifeTime` | `public var activeLifeTime: Bool` | set only by matching lifetime transactions |
| `activeSubscription` | `public var activeSubscription: String?` | cleared only by transactions whose productID equals the recorded value (FR-001) |
| `isPremium` | `public var isPremium: Bool { get }` | none (derivation unchanged) |
| `termsURL` | `public var termsURL: String? { get }` | returns `nil` instead of crashing before initialization (FR-007) |
| `privacyURL` | `public var privacyURL: String? { get }` | returns `nil` instead of crashing before initialization (FR-007) |
| `productIDs` | `public var productIDs: [String] { get }` | returns `[]` instead of crashing before initialization (FR-007) |
| `initialize(configuration:)` | `@discardableResult public func initialize(configuration: SSConfiguration) -> SwiftStore` | idempotent: repeat calls must not spawn duplicate listeners (FR-006) |

## Module `SwiftStore` — `SSConfiguration.swift`

| Member | Signature (frozen) |
|---|---|
| `ProductType` | `public enum ProductType { case lifetime, subscription, none }` |
| `SSConfiguration.init()` | `public init()` |
| `subscriptionIDs` / `lifetimeIDs` / `termsURL` / `privacyURL` | `public var` (types unchanged) |
| `setSubscriptionIDs(_:)` | `@discardableResult public func setSubscriptionIDs(_ ids: [String]) -> Self` |
| `setLifetimeIDs(_:)` | `@discardableResult public func setLifetimeIDs(_ ids: [String]) -> Self` |
| `setTermsURL(_:)` | `@discardableResult public func setTermsURL(_ url: String?) -> Self` |
| `setPrivacyURL(_:)` | `@discardableResult public func setPrivacyURL(_ url: String?) -> Self` |

Internal (not part of the frozen surface, may change): `productIDs` computed property, `getProductType(for:)`.

## Module `SwiftStore` — `SwiftStoreState.swift`

| Member | Signature (frozen) |
|---|---|
| `SwiftStoreState.init(_:)` | `public init(_ viewModel: SwiftStore = .shared)` |
| `wrappedValue` | `public var wrappedValue: SwiftStore { get }` |
| `projectedValue` | `public var projectedValue: Binding<SwiftStore> { get }` |
| `subscript(dynamicMember:)` (read) | `public subscript<U>(dynamicMember: KeyPath<SwiftStore, U>) -> U` |
| `subscript(dynamicMember:)` (read/write) | `public subscript<U>(dynamicMember: WritableKeyPath<SwiftStore, U>) -> U` |

Doc comments on these members may be corrected (FR-011); declarations may not.

## Example app (not a public contract)

`Examples/` app code may be edited freely (Constants URL wiring, ProductImage hashing) — it is a demo, not consumed externally. Unused example files (styles, previews, PurchaseExample, empty Package.swift) **must be retained** per the user's explicit requirement and Constitution I's spirit.

## Verification

Post-implementation, run the public-surface diff (quickstart.md §A): enumerate `public` declarations before vs. after; expect zero removals and zero signature changes.
