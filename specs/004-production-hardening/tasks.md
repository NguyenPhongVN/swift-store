---
description: "Task list for Production Hardening (004)"
---

# Tasks: Production Hardening

**Input**: Design documents from `/specs/004-production-hardening/`

**Prerequisites**: plan.md, spec.md, research.md, data-model.md, contracts/public-api-additions.md, quickstart.md

**Tests**: REQUESTED (FR-012). Pure-logic suites: grace decision, pipeline fan-out, restore outcome mapping — command-line runnable, no network/store.

**Organization**: US1 is the architectural core (internal pipeline + per-instance apply). US5 (grace) rides the same decision function — implemented with US1. US2 (restore) and US3 (closure init) are independent public additions. US4/US6 are docs/files. All `SwiftStore.swift` work runs sequentially.

## Format: `[ID] [P?] [Story] Description`

- **[P]**: Can run in parallel (different files, no dependencies)
- **[Story]**: Which user story this task belongs to
- Include exact file paths in descriptions

---

## Phase 1: Setup

- [x] T001 Capture pre-change public API baseline: `grep -hn "public " Sources/SwiftStore/*.swift | sort > specs/004-production-hardening/public-api-baseline.txt` (46 lines, captured during planning)

---

## Phase 2: Foundational (Blocking Prerequisites)

None — the pipeline file is created within US1 (it IS the core work, not a prerequisite).

---

## Phase 3: User Story 1 — Transaction processed exactly once per app run (Priority: P1) 🎯 MVP

**Goal**: One per-process monitoring pipeline; outcomes fanned out to every instance exactly once; one completion decision (FR-001/002/003).

**Independent Test**: Fan-out suite: N instances, one synthetic outcome → N state applications, 1 completion (quickstart §B).

### Tests for User Story 1 (write first — compile failure counts as red)

- [x] T002 [P] [US1] Create Tests/SwiftStoreTests/PipelineFanOutTests.swift: registering three instances and broadcasting one synthetic verified outcome applies state once per instance; each subscriber receives exactly one event; unverified outcome emits `transactionUnverified` per subscriber without state change; a deallocated instance is skipped without crash

### Implementation for User Story 1

- [x] T003 [US1] Create Sources/SwiftStore/TransactionPipeline.swift (internal): main-actor process singleton owning the three platform loops started once (`startIfNeeded`); weak sink registry keyed by instance; delivery extracts internal `TransactionFacts` (productID, isRevoked, isExpired, isGraceProtected via billing-retry/grace window, isFreshPurchase), decides completion exactly once (verified+revoked/active → finish; unverified/expired/grace → no finish), broadcasts an internal `PipelineOutcome` to sinks in registration order
- [x] T004 [US1] Restructure Sources/SwiftStore/SwiftStore.swift (depends on T003): `initialize(configuration:)` and `initialize(_:)` start the pipeline and register the instance instead of spawning loops; replace `handle(updatedTransaction:source:)` with an internal per-instance `apply(outcome)` reproducing spec-001 semantics per own configuration (product-scoped clearing, fresh-purchase vs renewal events, unknown-product skip) — behavior identical except grace-protected expiry retains access (US5); deinit-safe weak registration

**Checkpoint**: Duplicate processing eliminated; per-instance semantics preserved (fan-out suite green).

---

## Phase 4: User Story 5 — Billing grace period keeps paying users unlocked (Priority: P1)

**Goal**: Grace-protected expired subscriptions retain access; true lapse clears as before (FR-007/008).

**Independent Test**: Decision suite with synthetic dates (quickstart §C).

### Tests for User Story 5 (write first)

- [x] T005 [P] [US5] Create Tests/SwiftStoreTests/GraceDecisionTests.swift: expired+billing-retry → retained; expired+grace window future → retained; expired plain → cleared; unexpired → granted; revoked → cleared regardless of grace; unknown product expired → no event either way

### Implementation for User Story 5

- [x] T006 [US5] Implement the grace rule inside the per-instance decision in Sources/SwiftStore/SwiftStore.swift (depends on T004): expired outcome with `isGraceProtected == true` retains state (no clear, no event); plain expired clears only when product matches the recorded active subscription — ship together with T004 (same decision function)

**Checkpoint**: Paying users in grace keep access; all other clearing rules bit-for-bit unchanged (suite green).

---

## Phase 5: User Story 2 — Restore reports its real outcome (Priority: P1)

**Goal**: Distinguishable restore results via additive throwing API (FR-004/005).

**Independent Test**: Mapping suite + manual offline restore (quickstart §D).

### Tests for User Story 2 (write first)

- [x] T007 [P] [US2] Create Tests/SwiftStoreTests/RestoreOutcomeTests.swift: entitlement count 0 maps to `.nothingToRestore`; count ≥ 1 maps to `.restored(count:)`; mapping is total (no other values)

### Implementation for User Story 2

- [x] T008 [US2] Create Sources/SwiftStore/RestoreOutcome.swift: `public enum RestoreOutcome: Sendable, Equatable { case restored(count: Int), case nothingToRestore }` with doc comments
- [x] T009 [US2] In Sources/SwiftStore/SwiftStore.swift (depends on T008): add `public func restore() async throws -> RestoreOutcome` — in-flight guard makes overlapping calls await the same result; platform sync failure throws (no success event); on completion counts verified entitlements to produce the outcome and emits the existing `.restoreFinished`; refactor existing `restorePurchases()` to delegate to `restore()` keeping its exact old behavior (`try?`, event emission, no-throw)

**Checkpoint**: Three restore outcomes distinguishable; legacy call unchanged.

---

## Phase 6: User Story 3 — Configuration crosses concurrency boundaries without friction (Priority: P1)

**Goal**: Closure-based initialization for strict-concurrency projects (FR-006).

**Independent Test**: Strict-concurrency compile check (quickstart §E).

- [x] T010 [US3] In Sources/SwiftStore/SwiftStore.swift: add `public func initialize(_ configure: (SSConfiguration) -> Void) -> SwiftStore` — builds a fresh configuration, invokes the closure synchronously on the main actor, then delegates to the existing registration path (same idempotency, chaining, and docs); existing `initialize(configuration:)` untouched

**Checkpoint**: Strict-concurrency scratch project compiles with zero diagnostics.

---

## Phase 7: User Story 4 & 6 — Pending visibility docs + License (Priority: P2)

**Goal**: Ask-to-Buy flow documented (FR-009); MIT license added (FR-010).

**Independent Test**: Docs review + LICENSE presence (quickstart §F/§G).

- [x] T011 [P] [US4] Document the Ask-to-Buy flow: doc comments on `SwiftStore` (event pipeline resolves approvals; purchase-time `.pending` surfaces via the platform's purchase callbacks) and a README section — no new members (platform exposes no pre-approval query)
- [x] T012 [P] [US6] Create LICENSE (MIT, copyright project owner 2026) at repository root; add License section to README.md

**Checkpoint**: Pending flow documented; license present and referenced.

---

## Phase 8: Polish & Cross-Cutting Concerns

- [x] T013 Public API gate: content-diff `grep -hn "public " Sources/SwiftStore/*.swift` against specs/004-production-hardening/public-api-baseline.txt — additions only (expect: closure `initialize(_:)`, `restore()`, `RestoreOutcome` members); zero removals/signature changes
- [x] T014 Build gates: `swift build`, `swift test` (all suites incl. new ones green), package iOS build, example app build — zero errors, no new warnings
- [x] T015 Run quickstart §B–§F automatable checks; record results in Notes

---

## Dependencies & Execution Order

- T001 (done) → T002/T003 → T004 → T006 (same decision function) → T009/T010 (same file) → T013–T015
- T005, T007, T008, T011, T012 are file-independent ([P])
- US4 (T011) can land any time after US1 (its "resolution flows through pipeline" claim must be true)

## Parallel Opportunities

```bash
# With T003/T004 (US1) in progress, these touch separate files:
Task: "T005 [P] [US5] GraceDecisionTests.swift"
Task: "T007 [P] [US2] RestoreOutcomeTests.swift"
Task: "T008 [P] [US2] RestoreOutcome.swift"
Task: "T011 [P] [US4] Ask-to-Buy docs"
Task: "T012 [P] [US6] LICENSE + README section"
```

## Implementation Strategy

US1+US5 together (one decision function — the architectural core), then US2 (restore), then US3 (closure init), then docs/license, then gates. MVP = US1 alone removes duplicate processing.

## Notes

- [P] tasks = different files, no dependencies
- Adding cases to public enums (`StoreEvent`, `ProductType`) is FORBIDDEN — restore detail flows via return value
- Grace rule: platform-defined windows only; retention is subscriptions-only (lifetime has no expiry)
- T013 results (2026-09-25): content-diff vs baseline — zero removals/signature changes; additions exactly per contract: closure `initialize(_:)`, `restore()`, `RestoreOutcome` (+ internal TransactionPipeline)
- T014 results: `swift build` green; `swift test` 21/21 across 7 suites (~0.02s); package iOS build + example app build BUILD SUCCEEDED, zero warnings
- T015 results: quickstart §B (fan-out + unverified), §C (grace decisions incl. revocation-wins-over-grace), §D (restore mapping) all covered by automated suites; §E strict-concurrency closure init compiles in this package (Swift 6 tools mode); §F docs implemented; §G LICENSE present + referenced
- Implementation discoveries: (1) grace signal = expired transaction delivered via `currentEntitlements` (platform keeps granting during grace); billing-retry/grace fields live on RenewalInfo, NOT Transaction — research R5 amended; (2) analyze finding H1: late-registering instances receive a personal `currentEntitlements` replay (dedupe gate bypassed for targeted replay; re-finish is a no-op)
