# Data Model: API Hardening (Additive Improvements)

**Feature**: specs/002-api-hardening | **Date**: 2026-09-25
Additive entities on top of the existing model (see specs/001-fix-store-bugs/data-model.md). No persisted entities; all in-memory.

## Entity: Store Event (NEW)

A discrete occurrence delivered to a registered subscriber.

| Variant | Payload | Emitted when |
|---|---|---|
| entitlementChanged | productID: String, isActive: Bool | A verified, recognized transaction settles a state transition (set or clear, including revocation and expiry clears) |
| purchaseFinished | productID: String | A verified first purchase arrives on the live-updates pipeline (distinguished from renewal by the transaction's own reason field) |
| transactionUnverified | — | A transaction fails verification (state untouched, transaction not completed — unchanged rule) |
| restoreFinished | — | A restore operation completes (including "nothing to restore") |

Validation rules: delivery on the UI actor, occurrence-ordered per subscriber; no events when no subscriber; unknown-product verified deliveries produce no event (nothing changed).

## Entity: Product Identifier (NEW)

A value type wrapping a product's unique identifier.

| Field | Meaning |
|---|---|
| rawValue | Underlying string identifier |

Rules: equality/hash by rawValue; constructible from a string literal; conversion to/from string always lossless. Identifiers created from `ProductID` and raw strings with the same characters MUST classify and match identically.

## Entity: Product Classification (NEW)

Explicit classification result: lifetime | subscription | unrecognized. Derived from the configuration lists (same precedence as today: subscription checked first, then lifetime, else unrecognized). Replaces the role of the deprecated classification value; the old type/case remains functional.

## Entity: Standalone Store Instance (NEW capability, same structure)

An independently constructed store context: own configuration slot, own initialization flag, own event slot, own entitlement state. Rules: fully isolated from `shared` and other instances (zero shared mutable state); same safe-default and idempotency rules as the singleton.

## Entity: Change Log Entry (NEW, documentation)

Dated record listing additions, deprecations, and an explicit no-removals statement per release.

## State transition notes

No existing state transition changes. Event emission is a read-only side effect appended AFTER each transition settles and after completion decisions (Constitution V order preserved: decide state → finish/complete → emit observation).
