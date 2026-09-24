# Research: Production Hardening

**Feature**: specs/004-production-hardening | **Date**: 2026-09-25

## R1. Single per-process pipeline (US1, FR-001/002/003)

- **Decision**: New internal `TransactionPipeline` (main-actor, process singleton) owns the three platform loops (`updates`, `unfinished`, `currentEntitlements`) and starts them once. `initialize` starts the pipeline (idempotent) and registers the instance as a weak sink. For each delivered transaction the pipeline verifies it, extracts transaction-level facts, makes the completion decision (finish or not) exactly once, and broadcasts an immutable outcome to all sinks. Each instance applies the outcome against **its own configuration** (classification, product-scoped clearing, events) — preserving the per-instance isolation promised in spec 002.
- **Rationale**: Completion and verification are process-global facts; entitlement semantics are per-instance. Splitting the two keeps spec 001's product-scoped clearing intact while eliminating duplicate monitoring, duplicate finishes, and duplicate events. Weak sinks mean deallocated test instances cost nothing and never leak.
- **Alternatives considered**: (a) forbid multiple instances entirely — breaks the isolation feature shipped in 002; (b) leader-election among instances — unnecessary complexity once the coordinator exists; (c) keep per-instance loops but dedupe at finish — doesn't fix duplicated events/state updates. Rejected.
- **Testability seam**: the transaction-level facts struct and the per-instance decision function are pure; the fan-out is testable by broadcasting synthetic outcomes to registered instances without any StoreKit runtime.

## R2. Restore outcome (US2, FR-004/005)

- **Decision**: New throwing API `restore() async throws -> RestoreOutcome` returning `.restored(count:)` or `.nothingToRestore`; failures throw. The existing `restorePurchases()` is refactored to call `restore()` and keeps its exact old behavior (`try?`, `.restoreFinished` event). Both share the in-flight guard (overlapping calls await the same in-flight result rather than no-op, so a second caller still receives a truthful outcome). Counting = verified entries in the entitlement sync after the platform restore operation: zero → nothing-to-restore, else → restored with count.
- **Rationale**: Adding cases to the public `StoreEvent` enum would break consumers' exhaustive switches (same constraint that shaped `ProductClassification` in spec 002), so outcome detail flows through a return value, not event cases. Distinct method name avoids overload ambiguity between throwing/non-throwing zero-parameter variants.
- **Alternatives considered**: enriching `.restoreFinished` with a payload — breaks exhaustive switches; counting via diffing entitlements before/after — heavier and racy; rejected.

## R3. Concurrency-friendly initialization (US3, FR-006)

- **Decision**: Additive closure variant `initialize(_ configure: (SSConfiguration) -> Void) -> SwiftStore`. The closure runs synchronously on the main actor inside initialization with a fresh configuration; the integrator captures only sendable values into it, so nothing non-sendable ever crosses an actor boundary. The existing `initialize(configuration:)` is untouched.
- **Rationale**: The friction is passing a non-Sendable configuration across actors; accepting a builder closure removes the crossing entirely without changing the configuration type (whose mutable-class nature is frozen by Constitution I). Distinct signatures (`configuration:` label vs trailing closure) mean no ambiguity.
- **Alternatives considered**: making `SSConfiguration` `@MainActor` — breaks off-main construction; a Sendable struct — replaces the existing type's semantics (breaking); documenting "construct on main" — leaves the friction in place. Rejected.

## R4. Ask to Buy pending visibility (US4, FR-009)

- **Decision**: Documentation plus verification of the resolution path. The platform provides no non-UI query for approval-pending purchases; purchase-time pending results are surfaced by the platform's purchase callbacks (`.pending`), and the eventual approval arrives through the normal pipeline as `purchaseFinished`/`entitlementChanged` — which already works. The library will document this flow (doc comments + README section).
- **Rationale**: Inventing a pending-purchases query would mislead integrators — there is no platform data source to back it. Honest constraint, recorded as a scope note in the plan.
- **Alternatives considered**: polling `Transaction.unfinished` for pending state — pending (deferred) transactions are not delivered there by the platform; rejected as incorrect.

## R5. Grace-period correctness (US5, FR-007/008)

- **Decision**: Transaction facts include `isGraceProtected`. The per-instance decision: an expired subscription that is grace-protected is **retained** (no clear, no event — nothing changed); a plain expired subscription clears exactly as today. Retention applies to subscriptions only (lifetime has no expiry).
- **Grace signal (implementation discovery, amends the plan)**: `Transaction` does not expose billing-retry/grace fields — those live on `Product.SubscriptionInfo.RenewalInfo`, which is unreachable at transaction-delivery time without product-scoped status lookups. The reliable signal available at delivery: the platform **keeps delivering a grace-protected subscription through `currentEntitlements` even after its expiration date**, while genuinely expired deliveries arrive via `updates`/`unfinished`. Therefore `isGraceProtected = isExpired && source == .currentEntitlements`. The pure decision function and its tests are unchanged — only the facts extraction differs from the plan's first sketch.
- **Rationale**: Follows the platform's own grace semantics — the pipeline signal is exactly "the platform still grants this entitlement". Rule lives in the pure decision function, fully unit-testable with synthetic facts.
- **Alternatives considered**: `RenewalInfo.isInBillingRetry`/`gracePeriodExpirationDate` — not available on `Transaction` (compile-time verified); product-scoped status queries per delivery — heavy and changes the architecture; rejected.

## R6. License (US6, FR-010)

- **Decision**: MIT license at repository root, copyright the project owner, referenced from a new License section in the README.
- **Rationale**: Standard permissive choice for an SPM library; unblocks legal usage by consuming projects.

## R7. Testing approach (FR-012)

- **Decision**: Command-line test suites for: the pure entitlement decision (grant / clear-by-revocation / clear-by-expiry / retain-grace / skip-unknown / skip-unverified mapping), pipeline fan-out (N instances, one broadcast → N applications, 1 completion, per-instance events once), and restore outcome mapping (count → outcome). Store-runtime paths (real sync, real delivery) stay manual per quickstart.
- **Rationale**: Pure seams chosen in R1/R2 make the highest-risk logic testable without StoreKit; runtime paths still gated by the manual checklist.
