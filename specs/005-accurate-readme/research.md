# Research: Accurate README

**Feature**: specs/005-accurate-readme | **Date**: 2026-09-25

## Inventory of wrong/stale claims in the current README (verified against code)

| # | Claim in README | Reality | Fix |
|---|---|---|---|
| 1 | Intro claims support for "consumable products" | Pipeline grants only configured subscriptions/lifetime; consumables are neither configured nor counted | State supported kinds: subscriptions + lifetime (non-consumable) |
| 2 | Requirements: "Xcode 15.0+" | Package uses swift-tools 6.2 → needs Xcode 26+ (Swift 6.2 toolchain) | "Xcode 26+ (Swift 6.2 toolchain)" |
| 3 | Requirements omit macOS | Package declares macOS 14+ | Add "macOS 14+" |
| 4 | Installation URL `https://github.com/your-username/swift-store` | Real remote: `https://github.com/NguyenPhongVN/swift-store`; versions start at 1.0.0 | Real URL + version guidance |
| 5 | Quick Start only shows `initialize(configuration:)` | Closure variant `initialize { ... }` is the strict-concurrency-friendly path | Document closure variant first, configuration variant second |
| 6 | API reference missing | `onEvent`, `StoreEvent`, `make()`, `init()`, `isInitialized`, `hasEntitlement(_:)`, `ProductID`, `termsLink`/`privacyLink`, `restore()`/`RestoreOutcome`, `restorePurchases()`, `showManageSubscriptions(in:)`, `ProductClassification`, `classify(_:)`, `StoreConfiguration`, deprecations | Full API reference rewrite |
| 7 | Terms/Privacy snippet uses `URL(string: termsURL)!` | Validated accessors exist: `termsLink`/`privacyLink` | Use validated accessors |
| 8 | "Purchase buttons" sample with empty handlers | Purchases happen through StoreKit views (`StoreView`, `SubscriptionStoreView`, `ProductView`) or the purchase environment | Point to the platform store views |
| 9 | `ProductType` listing shows `.none` without note | `.none` deprecated → `ProductClassification.unrecognized` | Note deprecation |
| 10 | No mention of: single per-process pipeline, grace retention, instance isolation, Ask to Buy boundary, license history link | All true behaviors worth documenting | Add sections; license section already exists (file added in 004) |

## R1. Structure of the rewritten README

- **Decision**: Order: intro (accurate scope) → requirements → installation (real URL/version) → quick start (closure init → status in views) → product kinds note → observability (`onEvent`, Ask to Buy) → restore → standalone instances & strict concurrency → behavior guarantees (single pipeline, grace, isolation) → API reference (grouped, correct) → docs/changelog links → license.
- **Rationale**: Mirrors the adopter journey; guarantees placed after the working basics so the document is usable front-to-back.
- **Alternatives considered**: minimal diff of the old README — rejected; the stale claims are structural (intro, requirements, API reference all wrong), so a rewrite is cleaner and provably complete.

## R2. Verification approach

- **Decision**: (1) member cross-check: every code-identifier mentioned in the README must exist in `Sources/SwiftStore/` (mechanical grep per identifier); (2) snippet compile: extract Quick Start and key snippets into a temporary scratch file compiled against the package; (3) claim scan: forbidden words ("consumable") absent from capability claims; (4) standard build gates still green.
- **Rationale**: Makes doc accuracy mechanically checkable rather than aspirational.
