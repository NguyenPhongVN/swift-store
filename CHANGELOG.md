# Changelog

All notable changes to the **SwiftStore** library are documented in this file.

The format follows [Keep a Changelog](https://keepachangelog.com/en/1.1.0/).
Update this file with every release so consumers can judge upgrade safety in under a minute.

## [Unreleased]

### Added

- `StoreEvent` — observable store occurrences: `entitlementChanged(productID:isActive:)`, `purchaseFinished(productID:)`, `transactionUnverified`, `restoreFinished`.
- `SwiftStore.onEvent` — main-actor, occurrence-ordered event subscription; behavior is unchanged when unset.
- `SwiftStore.init()` — now public, enabling standalone instances for tests, previews, and isolated environments (`shared` remains the default).
- `SwiftStore.make()` — factory sugar alongside `init()`.
- `SwiftStore.isInitialized` — whether the instance has been initialized with a configuration.
- `SwiftStore.hasEntitlement(_:)` — entitlement query accepting `ProductID`.
- `SwiftStore.restorePurchases() async` — restores previous purchases; finishes with a `restoreFinished` event; rapid repeat calls are no-ops (no duplicate system prompts).
- `SwiftStore.showManageSubscriptions(in:)` (iOS) / `showManageSubscriptions()` (other platforms) — presents the system subscription management screen.
- `ProductID` — type-safe product identifier (`Hashable`, `Sendable`, string-literal expressible).
- `SSConfiguration.setSubscriptionProductIDs(_:)` / `SSConfiguration.setLifetimeProductIDs(_:)` — `ProductID`-typed configuration setters (distinct names from the string setters to keep existing literal call sites unambiguous).
- `SwiftStore.termsLink` / `SwiftStore.privacyLink` — validated `URL?` accessors for the legal links (nil when unset or malformed); the string accessors `termsURL` / `privacyURL` are unchanged.
- `ProductClassification` — explicit classification: `subscription`, `lifetime`, `unrecognized`.
- `SSConfiguration.classify(_:)` — classification query for `String` and `ProductID`.
- `StoreConfiguration` — alias for `SSConfiguration`.
- macOS 14+ platform support (package now builds and tests from the command line on desktop).
- `SwiftStoreTests` — automated pure-logic test suite (`swift test`, no network or live store required).

### Deprecated

- `SwiftStoreState` writable dynamic-member subscript — assigning entitlement state from UI code warns at compile time; use read-only access via `wrappedValue` / dynamic member lookup. The subscript still compiles and behaves as before until the next major version.
- `ProductType.none` — use `ProductClassification.unrecognized` instead. The case still exists and behaves as before.

### Unchanged

- **No existing public member was removed and no public signature was changed.** All existing consumer code compiles as before (deprecated pathways warn but keep working).
