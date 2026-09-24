# Contract: Public API Additions — Production Hardening

**Feature**: specs/004-production-hardening | **Date**: 2026-09-25

Delta contract. The frozen surfaces (specs/001 contracts + specs/002 additions) remain intact: **zero removals, zero signature changes**.

## Additions

| Member | Signature | Serves |
|---|---|---|
| `initialize(_:)` closure variant | `public func initialize(_ configure: (SSConfiguration) -> Void) -> SwiftStore` — closure invoked synchronously on the main actor with a fresh configuration; same idempotency and chaining semantics as the existing variant | US3 |
| `restore()` | `public func restore() async throws -> RestoreOutcome` — platform restore; failures throw; overlapping calls await the same in-flight result; also emits the existing `.restoreFinished` event | US2 |
| `RestoreOutcome` (new file) | `public enum RestoreOutcome: Sendable, Equatable { case restored(count: Int), case nothingToRestore }` | US2 |
| LICENSE | MIT at repository root; README gains a License section | US6 |

## Internal changes (not part of the public contract)

- Per-instance monitoring loops replaced by an internal process-wide pipeline; instances register as weak sinks and apply broadcast outcomes against their own configuration. Public behavior: identical except grace-protected expiry no longer clears premium (the intended fix).
- Entitlement decision gains grace retention (US5) — behavioral fix, applied per instance.

## Documentation-only (US4)

- Doc comments + README section: Ask-to-Buy pending results surface through the platform's purchase callbacks (`.pending`); approval resolution flows through the pipeline as existing events. No new members — the platform exposes no pre-approval query.

## Deprecations

- None in this feature.

## Verification

1. Public-surface diff before/after: additions only.
2. `swift test`: new suites for the entitlement decision (grace + existing clearing rules), pipeline fan-out (N instances / 1 outcome / 1 completion), restore outcome mapping.
3. Example app + package builds green; existing `restorePurchases()` and `initialize(configuration:)` call sites (demo app) compile unchanged.
