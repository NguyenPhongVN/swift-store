# Research: API Hardening (Additive Improvements)

**Feature**: specs/002-api-hardening | **Date**: 2026-09-25
All unknowns resolvable from established platform guidance and verified repository facts; spec has zero [NEEDS CLARIFICATION] markers.

## R1. Event surface shape (US1, FR-001/002/003)

- **Decision**: A single `Sendable, Equatable` enum `StoreEvent` with cases `entitlementChanged(productID:isActive:)`, `purchaseFinished(productID:)`, `transactionUnverified`, `restoreFinished`; delivery through one optional callback slot on the store (`onEvent`), invoked on the main actor in occurrence order.
- **Rationale**: A closure slot on the `@MainActor` store is the smallest mechanism that satisfies UI-safe, ordered delivery with zero new dependencies or threading surface. Integrators needing fan-out multiplex on their side (documented assumption). `Equatable` enables test assertions.
- **Alternatives considered**: (a) `AsyncStream` — better for multiple consumers but introduces buffering/lifetime semantics and back-pressure decisions far beyond spec need; (b) delegate protocol — more boilerplate, same single-slot reality; (c) NotificationCenter — untyped, stringly, global. Rejected.
- **Purchase vs renewal distinction**: `Transaction.reason` (purchase/renewal) distinguishes a first purchase from a renewal, so `purchaseFinished` can be emitted honestly from the live-updates pipeline; other verified deliveries map to `entitlementChanged`. Delivery pipeline (updates vs entitlements vs unfinished) is passed to the internal handler as a private context parameter — internal signature change allowed.

## R2. Standalone instances (US3, FR-005/006)

- **Decision**: Widen `init()` from `private` to `public` (additive — it was never public) and add sugar `static func make() -> SwiftStore`. Expose `public var isInitialized: Bool { get }` backed by a renamed private flag to avoid name collision.
- **Rationale**: Instances share no state by construction (each has its own configuration/flags), so independence is free; the singleton remains untouched for existing consumers. Widening access of a non-public member adds surface without removing any.
- **Alternatives considered**: keeping init private and returning an internal instance through a factory — same thing with more indirection; rejected for clarity.

## R3. Type-safe identifiers (US4, FR-007)

- **Decision**: New value type `ProductID` (`Hashable, Sendable, ExpressibleByStringLiteral`, exposes `rawValue`), plus additive configuration setters accepting `[ProductID]` and an additive `hasEntitlement(_:)` query on the store. String APIs unchanged.
- **Rationale**: Literal-expressible means call sites read like strings; compile-time type prevents accidental mixing with unrelated identifiers. Storing remains string-based internally so behavior is byte-identical.
- **Alternatives considered**: enum of known IDs — impossible in a library (IDs are app-defined); protocol witness — overkill. Rejected.

## R4. Validated legal links (US4, FR-008)

- **Decision**: New computed accessors `termsLink` / `privacyLink` returning `URL?` — `nil` when unset, empty, or unparseable; existing `termsURL` / `privacyURL` strings unchanged.
- **Rationale**: Fail-soft validation at the boundary; distinct names avoid overload ambiguity with the frozen string properties.

## R5. Restore + subscription management (US5, FR-009/010)

- **Decision**: `func restorePurchases() async` wraps the platform's store-sync, guarded by an in-flight flag (rapid repeat calls are no-ops) and emits `restoreFinished`. `func showManageSubscriptions(in:)` (iOS, scene parameter) / `showManageSubscriptions()` (other platforms) presents the system management surface, conditionally compiled so the core stays platform-neutral.
- **Rationale**: Uses the platform's standard system surfaces directly; no new entitlement logic. The in-flight guard implements the spec's "no duplicate prompts" edge case.

## R6. Deprecation of the writable pathway; classification naming (US2, US6, FR-004/011/012)

- **Decision**: (a) Annotate the `WritableKeyPath` subscript on `SwiftStoreState` with `@available(*, deprecated, ...)` naming the supported read-only usage — it compiles and behaves identically. (b) Add `public typealias StoreConfiguration = SSConfiguration`. (c) Add a NEW enum `ProductClassification { lifetime, subscription, unrecognized }` with an additive `classify(_:)` query, and annotate the existing `ProductType.none` case as deprecated while remaining functional.
- **Rationale**: Deprecation annotations add surface without changing behavior — fully compliant. Critically, **adding an `unknown` case to the existing public `ProductType` was evaluated and REJECTED**: Swift source packages compile consumers from source, and a new case breaks their exhaustive `switch` statements — a violation of Constitution I in spirit even though it is "additive". A new enum sidesteps this entirely.
- **Alternatives considered**: adding the case and accepting switch breakage — rejected; silent typealias-only rename — doesn't satisfy the classification requirement.

## R7. Desktop platform + test target (US7, FR-013/016)

- **Decision**: Add `.macOS(.v14)` to the package platforms (additive; baseline chosen to match framework availability of the APIs already used, fixing the known `swift build` host failure) and add an SPM `SwiftStoreTests` target using the toolchain's bundled Swift Testing framework. Tests cover classification, identifier mapping, link validation, safe defaults/pre-init state, factory isolation, config builders — all main-actor-annotated, no network, no live store.
- **Rationale**: Pure logic requires no store runtime; `swift test` then runs on any desktop machine, satisfying the spec's fast-loop requirement and giving this multi-consumer library its first regression net.
- **Alternatives considered**: StoreKitTest automation — heavyweight, needs .storekit session plumbing; deferred. XCTest — no advantage over bundled Swift Testing on this toolchain.

## R8. Change log (US8, FR-014)

- **Decision**: Add `CHANGELOG.md` (Keep-a-Changelog format) with this feature's additions/deprecations and an explicit no-removals statement; standing instruction in the file to update it every release.
- **Rationale**: Standard, tool-readable, satisfies the one-minute upgrade-safety criterion.
