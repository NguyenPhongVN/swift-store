# Implementation Plan: Production Hardening

**Branch**: `004-production-hardening` (label only — commits go directly to `main`) | **Date**: 2026-09-25 | **Spec**: [spec.md](./spec.md)

**Input**: Feature specification from `/specs/004-production-hardening/spec.md`

## Summary

Fix the six P0 blockers in the SPM core: (1) a single per-process transaction pipeline replaces per-instance monitoring loops, fanning each verified outcome out to all initialized instances exactly once with one completion decision; (2) restore reports its real outcome via a new throwing API returning succeeded/nothing-to-restore while the existing call stays untouched; (3) a closure-based initialization path lets strict-concurrency projects configure the store without passing configuration across actor boundaries; (4) Ask-to-Buy pending visibility is delivered as documentation plus the already-working resolution pipeline (platform exposes no pre-approval query — see research R4); (5) the entitlement decision retains premium access during billing grace/retry and only clears on true lapse; (6) MIT license added. All public changes additive (Constitution I).

## Technical Context

**Language/Version**: Swift 6.2 (package); library targets iOS 17+ / macOS 14+

**Primary Dependencies**: StoreKit 2 (`Transaction`, `AppStore`), Observation, SwiftUI (wrapper only)

**Storage**: N/A

**Testing**: Swift Testing via SPM test target — new pure-logic suites for the entitlement decision (incl. grace), pipeline fan-out, and restore outcome mapping; library suite stays green; example app build gate unchanged

**Target Platform**: iOS 17+ / macOS 14+ (transaction grace fields and pipeline APIs are within these baselines)

**Project Type**: Swift library (SPM) — demo app untouched

**Performance Goals**: Fan-out is O(instances) per outcome on the main actor; no polling

**Constraints**: Zero public removals/signature changes; completion exactly once per process; unverified transactions stay ignored/not-finished; event emission stays main-actor and occurrence-ordered; adding cases to public enums is forbidden (would break consumer switches) — new payload detail requires new members

**Scale/Scope**: 1 new internal pipeline file, 1 new public outcome file, `SwiftStore.swift` restructure of initialization/restore, LICENSE + README license section, ~4 new test suites

## Constitution Check

*GATE: Must pass before Phase 0 research. Re-check after Phase 1 design.*

| Principle | Gate | Status |
|-----------|------|--------|
| I. Public API Stability | All public changes additive: closure `initialize(_:)`, throwing `restore()` returning `RestoreOutcome`; existing `restorePurchases()`/events unchanged. Internal monitoring refactor (loops → pipeline) is not part of the public contract | ✅ PASS |
| II. Entitlement Correctness | Grace protection fixes a wrong-clear defect (clears only on true lapse); product-scoped clearing rules unchanged; analyze gate REQUIRED before implement | ✅ PASS (analyze pending) |
| III. Deterministic Behavior | Fan-out order deterministic (registration order per broadcast); events per instance occurrence-ordered | ✅ PASS |
| IV. Safe Initialization | Uninitialized reads unchanged; pipeline start guarded once per process; late instances catch up via their own entitlement sync | ✅ PASS |
| V. Transaction Hygiene | Completion decision centralized: verified → finish once per process; unverified → never finished; expired/grace → never finished (unchanged rules) | ✅ PASS |
| VI. Documentation Accuracy | New members documented; README gains license section; pipeline behavior documented in doc comments | ✅ PASS |

**Post-Phase 1 re-check**: contracts/public-api-additions.md lists every addition; analyze pass verifies the grace decision cannot regress product-scoped clearing (spec 001 FR-001/002).

## Project Structure

### Documentation (this feature)

```text
specs/004-production-hardening/
├── plan.md                          # This file
├── research.md                      # Phase 0 output
├── data-model.md                    # Phase 1 output
├── quickstart.md                    # Phase 1 output
├── contracts/
│   └── public-api-additions.md      # Phase 1 output
└── tasks.md                         # Phase 2 output (/speckit-tasks)
```

### Source Code (repository root)

```text
Sources/SwiftStore/
├── SwiftStore.swift                 # initialize registers with pipeline; apply(outcome); closure init variant; restore refactor
├── TransactionPipeline.swift        # NEW: internal per-process pipeline, facts, decisions (pure, testable)
├── RestoreOutcome.swift             # NEW: public restore outcome type
└── (other files unchanged)
LICENSE                              # NEW: MIT
README.md                            # License section (only touch)
Tests/SwiftStoreTests/
├── GraceDecisionTests.swift         # NEW
├── PipelineFanOutTests.swift        # NEW
└── RestoreOutcomeTests.swift        # NEW
```

**Structure Decision**: Pipeline is internal (never part of the public contract); the only new public surface is the closure initializer, the throwing restore + outcome type, and the license file.

## Complexity Tracking

> No constitution violations. US4 scope is reduced to documentation + resolution-pipeline verification because the platform exposes no pre-approval pending query (research R4) — an honest constraint, not a violation.
