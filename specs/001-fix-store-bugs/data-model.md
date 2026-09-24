# Data Model: Fix Store Bugs & Library Stability Rules

**Feature**: specs/001-fix-store-bugs | **Date**: 2026-09-24

Entities from the spec, with the fields and state transitions the fixes must respect. No persisted entities are added; all state is in-memory and sourced from the platform store.

## Entity: Transaction (platform-delivered)

A purchase record delivered by the store runtime. Read-only to this library.

| Field | Meaning | Used by fixes |
|---|---|---|
| productID | Which configured/unknown product this record belongs to | US1 scope-clearing, US5 completion |
| verification outcome | verified / unverified | Unverified → ignore, no completion |
| lifecycle status | active / expired (`expirationDate` past) / revoked (`revocationDate` set) | US1 clearing rules |
| completion state | delivered → completed | US5 terminal-state rule |

**State transitions**:
- delivered + verified + unknown product → completed, no state change (new behavior)
- delivered + verified + revoked + known product → clears that product's state → completed
- delivered + verified + expired + known product → clears that product's subscription record **only if it is the recorded active subscription** (new behavior) → not completed (expired entitlements are skipped, matching platform sample behavior)
- delivered + verified + active + known product → sets that product's state → completed
- delivered + unverified → no state change, no completion (unchanged, documented)

## Entity: Product

An item the app sells.

| Field | Meaning |
|---|---|
| identifier | Unique string from store configuration |
| kind | subscription or lifetime (resolved from Configuration lists) |

Validation rules: identifiers appearing in both lists is a configuration error (lifetime wins in today's resolution order — behavior preserved, not changed). Unknown identifier resolves to `.none` (public enum member retained).

## Entity: Configuration (developer-provided)

| Field | Meaning | Safe default when uninitialized (FR-007) |
|---|---|---|
| subscriptionIDs | Subscription product identifiers | `[]` |
| lifetimeIDs | Lifetime product identifiers | `[]` |
| termsURL | Terms of Service URL string | `nil` |
| privacyURL | Privacy Policy URL string | `nil` |

Validation: each URL field must be consumed exactly by its own presentation (US2 fix — no cross-wiring).

## Entity: Store State (app-visible entitlement status)

| Field | Type | Notes |
|---|---|---|
| lifetimeActive | Bool | Set only by lifetime transactions |
| activeSubscriptionID | String? | Set/cleared only by transactions whose productID matches (US1) |
| isPremium (derived) | Bool | `lifetimeActive OR activeSubscriptionID != nil` |

**State transition guarantees after fix**:
1. Clearing is product-scoped: no transition may unset a field for product A due to a transaction of product B.
2. Delivery order does not affect final state (idempotent transitions).
3. Reading any field before initialization returns the safe default; reading never crashes.
4. Initialization is idempotent: N calls ≡ 1 call for listeners and final state.
