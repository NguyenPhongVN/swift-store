# Data Model: Production Hardening

**Feature**: specs/004-production-hardening | **Date**: 2026-09-25
Additive/internal entities on top of specs/002 data model. No persisted state.

## Entity: Transaction Facts (NEW, internal)

Immutable snapshot of the transaction-level properties the pipeline needs — computed once per delivery.

| Field | Meaning |
|---|---|
| productID | Product identifier of the transaction |
| isRevoked | Platform revocation present |
| isExpired | Expiration date exists and is in the past |
| isGraceProtected | Billing retry active OR grace window extends beyond now |
| isFreshPurchase | Delivered on the live pipeline and the platform reason is a first purchase |

Rules: pure derivation from the delivered transaction and the current time; no store access. Lifetime products carry no expiration, so grace fields are irrelevant for them.

## Entity: Pipeline Outcome (NEW, internal)

The broadcast unit from pipeline to instances, after the completion decision:

| Variant | Payload | Completion |
|---|---|---|
| unverified | — | none (never finished — unchanged rule) |
| verified | facts (above) | finished once by the pipeline, except expired/grace-protected deliveries which are never finished (unchanged rule) |

Rules: computed once per process per delivery; broadcast to all registered sinks in registration order; sinks whose instance died are skipped and pruned.

## Entity: Instance Application (per-instance, internal)

Each instance applies a verified outcome against its own configuration:

| Condition (instance view) | State effect | Event emitted by instance |
|---|---|---|
| revoked + lifetime | clear lifetime | entitlementChanged(inactive) |
| revoked + subscription matching active | clear subscription | entitlementChanged(inactive) |
| revoked + unrecognized | none | none |
| expired + grace-protected | none (retained — NEW) | none |
| expired + subscription matching active | clear subscription | entitlementChanged(inactive) |
| active + recognized | grant lifetime / set subscription | purchaseFinished (fresh purchase) or entitlementChanged(active) |
| active + unrecognized | none | none |

Guarantees: identical per-instance semantics to pre-feature behavior, except grace-protected expiry no longer clears (the intended fix). Exactly one application per instance per outcome.

## Entity: Restore Outcome (NEW, public)

| Variant | Meaning |
|---|---|
| restored(count:) | Platform restore finished; N verified entitlements present afterwards |
| nothingToRestore | Restore finished; zero verified entitlements present |

Failures are thrown, not returned. The legacy restore call keeps emitting the legacy restore-finished event and never throws.

## State transition guarantees

1. Completion: exactly one finish decision per verified delivery, per process.
2. Fan-out: exactly one application per registered instance per outcome.
3. Grace: retention replaces clearing only for the grace-protected case; every other clearing rule from spec 001 is bit-for-bit unchanged.
4. Concurrency: configuration assembly for the new initialization path never crosses an actor boundary.
