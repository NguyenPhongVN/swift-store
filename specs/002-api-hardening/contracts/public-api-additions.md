# Contract: Public API Additions & Deprecations (002-api-hardening)

**Feature**: specs/002-api-hardening | **Date**: 2026-09-25

This contract enumerates the DELTA for this feature. The frozen surface in `specs/001-fix-store-bugs/contracts/public-api.md` remains intact: **zero removals, zero signature changes**. Every item below is additive or a deprecation annotation.

## Additions

| Member | Signature | Serves |
|---|---|---|
| `StoreEvent` (new file) | `public enum StoreEvent: Sendable, Equatable { case entitlementChanged(productID: String, isActive: Bool), case purchaseFinished(productID: String), case transactionUnverified, case restoreFinished }` | US1 |
| `onEvent` | `public var onEvent: ((StoreEvent) -> Void)?` (main-actor delivery, occurrence-ordered) | US1 |
| `init()` access | `public init()` (widened from `private` — additive) | US3 |
| `make()` | `public static func make() -> SwiftStore` | US3 |
| `isInitialized` | `public var isInitialized: Bool { get }` | US3 |
| `restorePurchases()` | `public func restorePurchases() async` (in-flight guard; emits `.restoreFinished`) | US5 |
| `showManageSubscriptions(in:)` | iOS only (conditioned on `os(iOS)`): `public func showManageSubscriptions(in scene: UIWindowScene)` — the no-argument macOS variant planned in research R5 does not exist in the platform SDK (verified at compile time), so management presentation is iOS-scoped | US5 |
| `showManageSubscriptions()` | non-iOS platforms: `public func showManageSubscriptions()` | US5 |
| `hasEntitlement(_:)` | `public func hasEntitlement(_ id: ProductID) -> Bool` | US4 |
| `ProductID` (new file) | `public struct ProductID: Hashable, Sendable, ExpressibleByStringLiteral { public let rawValue: String; public init(_ rawValue: String); public init(stringLiteral: String) }` | US4 |
| ProductID config setters | `public func setSubscriptionProductIDs(_ ids: [ProductID]) -> Self`, `public func setLifetimeProductIDs(_ ids: [ProductID]) -> Self` — distinct names instead of overloads of the String setters, so existing string-literal call sites (e.g. `setSubscriptionIDs(["a", "b"])`) can never become ambiguous (implementation refinement of research R3) | US4 |
| `termsLink` | `public var termsLink: URL? { get }` — validated, nil when unset/invalid | US4 |
| `privacyLink` | `public var privacyLink: URL? { get }` — validated, nil when unset/invalid | US4 |
| `ProductClassification` | `public enum ProductClassification: Sendable, Equatable { case lifetime, subscription, unrecognized }` | US6 |
| `classify(_:)` | `public func classify(_ id: String) -> ProductClassification` + overload `classify(_ id: ProductID)` | US6 |
| `StoreConfiguration` | `public typealias StoreConfiguration = SSConfiguration` | US6 |
| macOS platform | `.macOS(.v14)` added to package platforms | US7 |
| `SwiftStoreTests` target | SPM test target, command-line runnable, no network/store | US7 |
| `CHANGELOG.md` | repository root, Keep-a-Changelog format | US8 |

## Deprecations (annotations only — all remain functional)

| Member | Annotation | Replacement guidance |
|---|---|---|
| `SwiftStoreState.subscript(dynamicMember: WritableKeyPath<SwiftStore, U>)` | `@available(*, deprecated, message: "Entitlement state is managed by the store and is read-only. Use wrappedValue / dynamic member lookup to read. Writable access will be removed in a future major version.")` | Read via KeyPath subscript / wrappedValue |
| `ProductType.none` (case only) | `@available(*, deprecated, message: "Use ProductClassification.unrecognized.")` | `ProductClassification.unrecognized` |

## Explicitly rejected during design (Constitution I)

- Adding `case unknown` to the existing public `ProductType` — would break consumers' exhaustive switches. New enum instead.
- Any rename/retype of `activeLifeTime`, `activeSubscription`, `termsURL`, `privacyURL` — deferred to next major with deprecation-first path (some already covered by additive alternatives above).

## Verification

1. Capture the public-surface listing before changes (baseline in this directory).
2. After implementation, diff: only additive lines and deprecation annotation lines may appear.
3. Deprecated usages must compile with warnings; all existing usage patterns compile warning-free (verified by the example app building with zero new warnings).
