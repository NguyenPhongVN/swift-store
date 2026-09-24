# Contract: README Accuracy — Real Surface to Document

**Feature**: specs/005-accurate-readme | **Date**: 2026-09-25

The rewritten README MUST document exactly this surface (verified current). Anything outside it MUST NOT be claimed as supported.

## Types

| Member | Notes for docs |
|---|---|
| `SwiftStore` (class, `@MainActor`, `@Observable`) | `shared`, `make()`, `init()`; properties: `activeLifeTime`, `activeSubscription`, `isPremium`, `termsURL`, `privacyURL`, `termsLink`, `privacyLink`, `productIDs`, `onEvent`, `isInitialized`; methods: `initialize(_:)` (closure), `initialize(configuration:)`, `hasEntitlement(_:)`, `restore() async throws`, `restorePurchases() async`, `showManageSubscriptions(in:)` (iOS only) |
| `SSConfiguration` (alias `StoreConfiguration`) | `subscriptionIDs`, `lifetimeIDs`, `termsURL`, `privacyURL`; builders `setSubscriptionIDs`, `setLifetimeIDs`, `setSubscriptionProductIDs`, `setLifetimeProductIDs`, `setTermsURL`, `setPrivacyURL`; `classify(_:)` (String / ProductID) |
| `SwiftStoreState` | `@SwiftStoreState` wrapper; read access; **writable subscript deprecated** |
| `StoreEvent` | `entitlementChanged(productID:isActive:)`, `purchaseFinished(productID:)`, `transactionUnverified`, `restoreFinished` |
| `ProductID` | string-literal type-safe identifier |
| `RestoreOutcome` | `restored(count:)`, `nothingToRestore` |
| `ProductClassification` | `lifetime`, `subscription`, `unrecognized` |
| `ProductType` | `lifetime`, `subscription`, `none` (**deprecated** → `ProductClassification.unrecognized`) |

## Behavior guarantees to state

1. Transaction monitoring runs once per process; outcomes fan out to every initialized instance; each instance's state is independent.
2. Clearing is product-scoped; subscriptions within the platform's billing grace period / retry keep access.
3. Unverified transactions are ignored and never finished; unrecognized verified products are finished but grant nothing.
4. No consumable support. No pre-approval (Ask to Buy) query — purchase-time `.pending` surfaces via platform purchase callbacks; approvals arrive as pipeline events.
5. Restore: throwing `restore()` reports outcome; legacy `restorePurchases()` unchanged.

## Requirements facts

- Platforms: iOS 17+, macOS 14+. Toolchain: Xcode 26+ (Swift 6.2). Repo URL: `https://github.com/NguyenPhongVN/swift-store`. First tagged version: 1.0.0. License: MIT (see LICENSE).
