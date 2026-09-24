# Implementation Plan: Fix Store Bugs & Library Stability Rules

**Branch**: `001-fix-store-bugs` | **Date**: 2026-09-24 | **Spec**: [spec.md](./spec.md)

**Input**: Feature specification from `/specs/001-fix-store-bugs/spec.md`

## Summary

Fix the six defects found in the code review of the SwiftStore library and its example app: (1) cross-product entitlement clearing on expired transactions, (2) mis-wired privacy URL constant, (3) non-deterministic product colors from per-process hash seeds, (4) non-idempotent initialization spawning duplicate `Transaction.updates` listeners, (5) unrecognized verified transactions never completed (re-delivered every launch), (6) implicit-unwrap crash risk when store is read before initialization, plus stale documentation. All fixes are internal behavior changes: the public API surface is frozen per Constitution Principle I (other projects consume this library).

## Technical Context

**Language/Version**: Swift 6.2 (package, swift-tools-version 6.2); example app built in Swift 5 language mode via Xcode 26 (iOS SDK 27)

**Primary Dependencies**: StoreKit 2 (`Transaction`, `Product`), SwiftUI, Observation (`@Observable`)

**Storage**: N/A — entitlement state is in-memory, sourced from StoreKit; no persistence added

**Testing**: Compile verification via `swift build` + `xcodebuild` (app target); validation scenarios via manual run on iOS Simulator with the scheme's StoreKit configuration file (see quickstart.md). Library has no test target today; adding a small Swift Testing target for pure logic (configuration, product-type resolution, stable hash) is permitted and desirable but must not alter the public API.

**Target Platform**: iOS 17+ (package), example app deployment target iOS 26; Apple Silicon simulator

**Project Type**: Swift library (SPM) + example/demo app (Xcode project referencing the local package)

**Performance Goals**: N/A — correctness fix; no measurable perf change required. One stable-hash computation per product render is negligible.

**Constraints**: Zero public API removals or signature changes (Constitution I); package and app must build with zero errors after every change; unverified transactions stay ignored/not completed (secure default).

**Scale/Scope**: 3 library source files (~370 LOC), 2 example app files touched (Constants.swift, ProductImage.swift), stale doc comments in SwiftStoreState.swift. 6 defects, 12 functional requirements.

## Constitution Check

*GATE: Must pass before Phase 0 research. Re-check after Phase 1 design.*

| Principle | Gate | Status |
|-----------|------|--------|
| I. Public API Stability | Diff of `public` members before/after = zero removals, zero signature changes. `private var configuration` type change (`SSConfiguration!` → `SSConfiguration?`) is internal-only and allowed. Behavior change of existing getters when uninitialized (crash → safe defaults) is mandated by spec FR-007. | ✅ PASS (by design) |
| II. Entitlement Correctness | Expired/revoked transactions clear only their own product's state; lifetime and subscription tracked independently | ✅ PASS (US1) |
| III. Deterministic Behavior | Product colors derived from identifier via a stable, launch-independent hash | ✅ PASS (US3) |
| IV. Safe Initialization | Idempotent `initialize`; out-of-order reads return safe defaults; no implicit force unwraps remain in library | ✅ PASS (US4) |
| V. Transaction Hygiene | Every verified transaction completed, including unknown products; unverified ignored per secure default | ✅ PASS (US5) |
| VI. Documentation Accuracy | Doc comments reference only real members; binding behavior described accurately | ✅ PASS (US6) |

**Post-Phase 1 re-check**: contracts/public-api.md enumerates the frozen surface; all planned edits touch private internals, one `private` stored property type, example-app internals, and doc comments. No violations.

## Project Structure

### Documentation (this feature)

```text
specs/001-fix-store-bugs/
├── plan.md              # This file
├── research.md          # Phase 0 output
├── data-model.md        # Phase 1 output
├── quickstart.md        # Phase 1 output
├── contracts/           # Phase 1 output
│   └── public-api.md
└── tasks.md             # Phase 2 output (/speckit-tasks — NOT created here)
```

### Source Code (repository root)

```text
Sources/SwiftStore/
├── SwiftStore.swift        # Singleton; transaction handling, initialization (US1, US4, US5)
├── SSConfiguration.swift   # Configuration + ProductType (no behavior changes planned)
└── SwiftStoreState.swift   # SwiftUI property wrapper (doc-comment fixes only, US6)

Examples/Examples/
├── Constants.swift         # Legal URL wiring fix (US2)
├── SubViews/ProductImage.swift  # Stable color hashing (US3)
└── (styles/previews retained as-is — unused code must stay, Constitution I)
```

**Structure Decision**: Existing two-module layout unchanged: `Sources/SwiftStore` (library, SPM product `SwiftStore`) and `Examples/Examples` (demo app). No new production modules; optionally a new `Tests/SwiftStoreTests` SPM test target (additive only).

## Complexity Tracking

> No constitution violations to justify — all gates pass by design.
