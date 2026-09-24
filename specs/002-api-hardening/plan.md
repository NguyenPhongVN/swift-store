# Implementation Plan: API Hardening (Additive Improvements)

**Branch**: `002-api-hardening` (label only — work commits directly to `main` per Constitution v1.2.0) | **Date**: 2026-09-25 | **Spec**: [spec.md](./spec.md)

**Input**: Feature specification from `/specs/002-api-hardening/spec.md`

## Summary

Additive API hardening for the SwiftStore library: an observable event surface (entitlement changes, verification failures, purchases, restore), a public factory for standalone store instances enabling DI/testing, initialization introspection, a type-safe product identifier, validated legal-link accessors, restore + subscription-management helpers, deprecation of the UI-writable entitlement pathway, a `StoreConfiguration` alias, an explicit `ProductClassification` with `unrecognized`, desktop platform declaration, a command-line-runnable test target, and a change log. Zero existing public members are removed or have signatures changed (Constitution I); the writable pathway is deprecated but functional.

## Technical Context

**Language/Version**: Swift 6.2 (package, swift-tools-version 6.2); example app in Swift 5 language mode via Xcode 26

**Primary Dependencies**: StoreKit 2 (`Transaction`, `AppStore`), SwiftUI, Observation

**Storage**: N/A — in-memory only

**Testing**: SPM test target (Swift Testing framework, ships with the toolchain) for pure logic — runs via `swift test` on desktop; example app via `xcodebuild`. No third-party dependencies.

**Target Platform**: iOS 17+ (existing) plus macOS 14+ (new, additive declaration); library core is platform-neutral, iOS-only surface is conditionally compiled

**Project Type**: Swift library (SPM) + example app

**Performance Goals**: Event dispatch is a single optional-callback invocation on the main actor; test suite under 10 seconds

**Constraints**: Zero public removals/signature changes; adding an `unknown` case to the existing `ProductType` enum would break consumers' exhaustive switches — therefore rejected (see research R6); unverified transactions stay ignored/not-finished; no new third-party dependencies

**Scale/Scope**: 3 library files modified + up to 2 new library files (event type, identifier type), Package.swift (platform + test target), new Tests target (~8 test files), CHANGELOG.md

## Constitution Check

*GATE: Must pass before Phase 0 research. Re-check after Phase 1 design.*

| Principle | Gate | Status |
|-----------|------|--------|
| I. Public API Stability | All changes additive or deprecation annotations; zero removals/signature changes. Making `init()` public is additive (was `private`, not part of public surface). Adding a case to public `ProductType` rejected as switch-exhaustiveness breaking; new `ProductClassification` enum instead. | ✅ PASS |
| II. Entitlement Correctness | Event emission is observation-only — reads state after transitions, never mutates; analyze gate required before implement | ✅ PASS (analyze pending) |
| III. Deterministic Behavior | Event order = occurrence order per subscriber; no new nondeterministic user-visible behavior | ✅ PASS |
| IV. Safe Initialization | `isInitialized` introspection; factory instances follow same safe-default rules; idempotency unchanged | ✅ PASS |
| V. Transaction Hygiene | No change to completion rules; events emitted after completion decisions | ✅ PASS |
| VI. Documentation Accuracy | CHANGELOG + updated doc comments required; deprecation messages name replacements | ✅ PASS |

**Post-Phase 1 re-check**: contracts/public-api-additions.md enumerates every addition/deprecation; diff gate after implementation must show additions + annotations only.

## Project Structure

### Documentation (this feature)

```text
specs/002-api-hardening/
├── plan.md                        # This file
├── research.md                    # Phase 0 output
├── data-model.md                  # Phase 1 output
├── quickstart.md                  # Phase 1 output
├── contracts/
│   └── public-api-additions.md    # Phase 1 output: additions/deprecations contract
└── tasks.md                       # Phase 2 output (/speckit-tasks)
```

### Source Code (repository root)

```text
Sources/SwiftStore/
├── SwiftStore.swift          # make()/init access, isInitialized, events, restore/manage, handler context
├── SSConfiguration.swift     # ProductClassification, classify(), ProductID setters
├── SwiftStoreState.swift     # deprecate writable subscript, docs
├── StoreEvent.swift          # NEW: event type
└── ProductID.swift           # NEW: identifier value type
Package.swift                 # macOS 14 platform + SwiftStoreTests target
Tests/SwiftStoreTests/        # NEW: pure-logic tests
CHANGELOG.md                  # NEW
```

**Structure Decision**: Existing modules unchanged; two small new library files for the new public value types keep the frozen files' diffs minimal and reviewable.

## Complexity Tracking

> No constitution violations. Note: the "add enum case" approach was evaluated and rejected in design (not a violation — a constraint honored); see research R6.
