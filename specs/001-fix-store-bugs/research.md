# Research: Fix Store Bugs & Library Stability Rules

**Feature**: specs/001-fix-store-bugs | **Date**: 2026-09-24
All unknowns from the plan's Technical Context resolved; spec contains zero [NEEDS CLARIFICATION] markers. Decisions below are grounded in platform-documented StoreKit 2 guidance and verified facts about this repository.

## R1. Correct StoreKit 2 pattern for expiring/revoking entitlements (US1, FR-001/002/003)

- **Decision**: In the transaction handler, compare the incoming transaction's product identifier against the currently recorded `activeSubscription` before clearing it; clear lifetime/subscription state independently; never let one product's transaction mutate another product's state.
- **Rationale**: `Transaction.currentEntitlements` and `Transaction.updates` make no ordering guarantee across products, and an app may hold transactions for multiple products (this repo configures week/month/year + lifetime). Clearing state on any expired delivery can erase a still-valid entitlement. Scoping clears to the matching product id makes state transitions idempotent and order-independent.
- **Alternatives considered**: (a) Rebuild state from scratch on every delivery — heavier and still order-dependent mid-rebuild; (b) trust `currentEntitlements` to never deliver expired transactions — false under billing-retry/grace-period scenarios; rejected.

## R2. Stable hash for identifier → color (US3, FR-005)

- **Decision**: Replace `String.hashValue` with a small, self-contained FNV-1a hash over the identifier's UTF-8 bytes, then map to the existing palette by modulo.
- **Rationale**: Swift's `hashValue` is deliberately seeded per process (hardened against hash-flooding), so colors change every launch — exactly the reported defect. FNV-1a is ~10 lines, has no dependencies, stable forever by construction, and distributes short identifiers well enough for a 20-color palette.
- **Alternatives considered**: (a) map by index into the configured product array — changes whenever the product list is reordered; (b) `hashValue` with a fixed seed via `Hasher` — `Hasher` seed cannot be pinned by public API; (c) store colors per product — new persistence, out of scope. All rejected.

## R3. Idempotent initialization without changing public behavior (US4, FR-006/007)

- **Decision**: Add a private `isInitialized` flag; `initialize` stores configuration, starts the two background loops only on first call, and on repeat calls only replaces configuration (returning `self` as before). Replace `configuration: SSConfiguration!` with `SSConfiguration?`; the existing public getters (`termsURL`, `privacyURL`, `productIDs`) return `nil` / `[]` when configuration is absent. `isPremium` already defaults to `false`.
- **Rationale**: `Transaction.updates` is an infinite sequence; a second `initialize` would stack a second listener and double-process every transaction. The App struct's `init` re-running on framework re-entry is a real repeat path. Optional-with-defaults removes the implicit-unwrap crash while keeping every public signature identical.
- **Alternatives considered**: (a) precondition/require on uninitialized access — crashes, violates FR-007 and Constitution IV; (b) keep IUO and document "call initialize first" — status quo bug; (c) cancel and restart listeners on re-init — more moving parts, no consumer-visible benefit. Rejected.

## R4. Transaction lifecycle completion rules (US5, FR-008/009)

- **Decision**: Every verified transaction is finished exactly once — including products not present in the configuration (finish first, no state change). Unverified transactions remain ignored and unfinished (platform-recommended secure default), documented explicitly.
- **Rationale**: Unfinished verified transactions are re-delivered every launch (`Transaction.unfinished` exists precisely for that), causing permanent redundant work. Unknown verified products are not "wrong" — just not ours; completing them stops re-delivery without granting entitlement. Finishing an unverified transaction would acknowledge untrusted data.
- **Alternatives considered**: (a) leave unknown verified transactions unfinished and log — preserves today's leak; (b) finish unverified too — unsafe. Rejected.

## R5. Legal URL wiring (US2, FR-004)

- **Decision**: Fix the example constant so `privacyURL` is built from the privacy string; each presentation reads its own setting.
- **Rationale**: One-character root cause (`URL(string: termsString)!` assigned to `privacyURL`); the library's `subscriptionStorePolicyDestination` wiring already reads each URL from its own property.
- **Alternatives considered**: none — direct fix.

## R6. Documentation accuracy (US6, FR-011)

- **Decision**: Rewrite the stale doc comments in `SwiftStoreState` (remove `consumableCount`/`boughtNonConsumable` examples; describe `projectedValue` as a `Binding` to the store instance, not per-property two-way binding). No member names or signatures change.
- **Rationale**: Docs referencing non-existent members mislead integrating projects; Constitution VI treats this as a defect class.
- **Alternatives considered**: adding the missing members — scope creep, not requested; rejected.

## R7. Testing approach

- **Decision**: Gate on compilation (`swift build` for the package, `xcodebuild` for the app) + manual validation scenarios on the simulator using the scheme's StoreKit configuration (quickstart.md). Optionally add an SPM test target covering pure logic (product-type resolution, stable hash, config getters' safe defaults) — additive only.
- **Rationale**: Entitlement behaviors depend on StoreKit runtime; simulator + StoreKit Transaction Manager covers revocation, and the config's accelerated time-rate covers expiration. Pure-logic pieces are unit-testable without StoreKit.
- **Alternatives considered**: StoreKitTest automation framework — heavier setup, not required for this fix; noted as future work.
