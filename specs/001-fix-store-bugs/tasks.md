---
description: "Task list for Fix Store Bugs & Library Stability Rules"
---

# Tasks: Fix Store Bugs & Library Stability Rules

**Input**: Design documents from `/specs/001-fix-store-bugs/`

**Prerequisites**: plan.md, spec.md, research.md, data-model.md, contracts/public-api.md, quickstart.md

**Tests**: No automated test tasks — not requested. Validation uses quickstart.md scenarios (compile gates + simulator StoreKit scenarios).

**Organization**: Tasks grouped by user story. US1/US4/US5 all edit `Sources/SwiftStore/SwiftStore.swift`, so they run sequentially; US2, US3, US6 touch separate files and can run in parallel with anything.

## Format: `[ID] [P?] [Story] Description`

- **[P]**: Can run in parallel (different files, no dependencies)
- **[Story]**: Which user story this task belongs to (e.g., US1, US2, US3)
- Include exact file paths in descriptions

## Path Conventions

- Library: `Sources/SwiftStore/` (SPM product `SwiftStore`)
- Demo app: `Examples/Examples/` (Xcode project referencing the local package)

---

## Phase 1: Setup (Shared Infrastructure)

**Purpose**: Baseline capture and clean starting-point verification

- [x] T001 Capture baseline public API surface: run `grep -hn "public " Sources/SwiftStore/*.swift | sort > specs/001-fix-store-bugs/public-api-baseline.txt` (reference contract: specs/001-fix-store-bugs/contracts/public-api.md)
- [x] T002 Verify clean baseline: run `swift build` (package) and `xcodebuild -project Examples/Examples.xcodeproj -scheme Examples -destination 'generic/platform=iOS Simulator' -configuration Debug build`; both must succeed with zero errors before any edit
  - Note: `swift build` (macOS host) fails by design for this iOS-only package (`@Observable` needs macOS 14, host default is 12). Corrected gate: `xcodebuild -scheme SwiftStore -destination 'generic/platform=iOS Simulator' build` — passes. quickstart.md updated accordingly.

---

## Phase 2: Foundational (Blocking Prerequisites)

**Purpose**: None required — the six stories touch independent code paths; no shared infrastructure must be built first.

No tasks in this phase.

---

## Phase 3: User Story 1 — Premium status always matches real entitlements (Priority: P1) 🎯 MVP

**Goal**: Transaction handling clears only the transaction's own product's state; expired/revoked deliveries never disable other valid entitlements (spec FR-001/002/003).

**Independent Test**: Configure two products, deliver one active + one expired transaction in either order → the active entitlement always survives (quickstart.md §E).

### Implementation for User Story 1

- [x] T003 [US1] Rewrite the revocation branch of `handle(updatedTransaction:)` in Sources/SwiftStore/SwiftStore.swift: drop the early-return `productIDs.contains` guard; when the product is a known lifetime → set `activeLifeTime = false`; known subscription → set `activeSubscription = nil` only if `activeSubscription == transaction.productID`; then finish the transaction in every case (known or unknown) so revoked transactions are never re-delivered
- [x] T004 [US1] Rewrite the expiration and valid branches of `handle(updatedTransaction:)` in Sources/SwiftStore/SwiftStore.swift (depends on T003): expired transaction clears `activeSubscription` only when `transaction.productID == activeSubscription`, otherwise leaves state untouched; valid transaction sets `activeLifeTime = true` for lifetime products and `activeSubscription = transaction.productID` for subscription products; keep unverified transactions ignored with no state change

**Checkpoint**: With only this story done, premium state is order-independent and product-scoped (quickstart §E). Same-store-file stories US4/US5 build on this rewritten handler.

---

## Phase 4: User Story 2 — Legal links open the correct document (Priority: P1)

**Goal**: `privacyURL` derives from the privacy setting, terms from the terms setting (spec FR-004).

**Independent Test**: Set two different URL strings, tap each paywall link, each opens its own document (quickstart.md §B).

### Implementation for User Story 2

- [x] T005 [P] [US2] Fix cross-wired constant in Examples/Examples/Constants.swift: change `static let privacyURL = URL(string: termsString)!` to build from `privacyString`

**Checkpoint**: Each legal presentation reads its own configured URL.

---

## Phase 5: User Story 3 — Product appearance is stable across launches (Priority: P2)

**Goal**: Identifier-derived colors identical across launches/processes (spec FR-005, Constitution III).

**Independent Test**: Launch the app 3×; every product keeps the same color (quickstart.md §C).

### Implementation for User Story 3

- [x] T006 [P] [US3] Replace `productId.hashValue` with a self-contained FNV-1a hash over the identifier's UTF-8 bytes in `hexColor(for:)` in Examples/Examples/SubViews/ProductImage.swift; keep palette and modulo mapping unchanged; update the method's doc comment to describe stable hashing

**Checkpoint**: Colors deterministic per product id.

---

## Phase 6: User Story 4 — Safe and repeatable initialization (Priority: P2)

**Goal**: Idempotent `initialize`; out-of-order reads return safe defaults, never crash (spec FR-006/007, Constitution IV).

**Independent Test**: Read store properties before init (no crash: false/nil/[]), call `initialize` twice, behavior equals single init (quickstart.md §D).

### Implementation for User Story 4

- [x] T007 [US4] In Sources/SwiftStore/SwiftStore.swift (depends on T004, same file): change `private var configuration: SSConfiguration!` to `SSConfiguration?`; make `termsURL`/`privacyURL` return `nil` and `productIDs` return `[]` when configuration is absent; add a private initialization flag so the first `initialize` stores configuration and starts the two background transaction loops, while repeat calls only refresh configuration and return `self` without spawning duplicate listeners; keep every public signature identical per contracts/public-api.md

**Checkpoint**: Library is crash-free out of order; no duplicate monitoring on repeated init.

---

## Phase 7: User Story 5 — Every transaction reaches a terminal state (Priority: P3)

**Goal**: All verified transactions completed, including unknown products; unverified stay ignored/unfinished (spec FR-008/009, Constitution V).

**Independent Test**: Verified transaction for a product absent from configuration is not re-delivered next launch (quickstart.md §F).

### Implementation for User Story 5

- [x] T008 [US5] Consolidate completion in Sources/SwiftStore/SwiftStore.swift (depends on T007, same file): in the valid branch, finish the transaction for known products after state updates and also finish verified transactions whose product resolves to `.none` without any state change; confirm the revocation branch (T003) already finishes; expired branch keeps its skip-without-finish behavior; document in code that unverified transactions are intentionally not finished

**Checkpoint**: No verified transaction is re-delivered indefinitely across launches.

---

## Phase 8: User Story 6 — Documentation matches the real interface (Priority: P3)

**Goal**: Doc comments reference only existing members and describe real behavior (spec FR-011, Constitution VI).

**Independent Test**: Quick Help on `SwiftStoreState` members shows only real members; binding description accurate (quickstart.md §G).

### Implementation for User Story 6

- [x] T009 [P] [US6] Rewrite stale documentation in Sources/SwiftStore/SwiftStoreState.swift: remove all `consumableCount`/`boughtNonConsumable` references from usage examples (replace with real members `isPremium`/`activeSubscription`); correct the `projectedValue` doc to describe a `Binding` to the store instance rather than per-property two-way binding; align the feature list bullets with actual capabilities; no declaration changes

**Checkpoint**: Docs match the frozen public surface.

---

## Phase 9: Polish & Cross-Cutting Concerns

**Purpose**: Constitution gates and end-to-end validation

- [x] T010 Public API gate: regenerate `grep -hn "public " Sources/SwiftStore/*.swift | sort` and diff against specs/001-fix-store-bugs/public-api-baseline.txt and contracts/public-api.md; must show zero removals and zero signature changes
  - Result: PASS — diff shows only line-number shifts from added doc comments; all declarations identical
- [x] T011 Full compile gate: `swift build` and `xcodebuild -project Examples/Examples.xcodeproj -scheme Examples -destination 'generic/platform=iOS Simulator' -configuration Debug build` both succeed with zero errors and zero new warnings
  - Result: PASS — package and app both BUILD SUCCEEDED, zero code warnings
- [x] T012 Run quickstart.md automatable scenarios and record results (results in Notes below)
- [ ] T013 Manual-only scenarios requiring Xcode GUI / device interaction, left for manual verification: quickstart §B (temp different legal URLs + tap links), §D.1/D.2 (read-before-init and double-init in a scratch build), §E (purchase → expire/revoke via StoreKit Transaction Manager), §F (unknown-product re-delivery across launches)

---

## Dependencies & Execution Order

### Phase Dependencies

- **Setup (Phase 1)**: T001, T002 first — baseline + clean build prove the gates are measurable
- **Foundational (Phase 2)**: empty
- **US1 (Phase 3)**: T003 → T004 (same function, sequential)
- **US2 (Phase 4) / US3 (Phase 5) / US6 (Phase 8)**: independent files — can start any time after Phase 1
- **US4 (Phase 6)**: T007 after T004 (same file)
- **US5 (Phase 7)**: T008 after T007 (same function area)
- **Polish (Phase 9)**: after all stories

### User Story Dependencies

- US1 → US4 → US5 chain only because they share `Sources/SwiftStore/SwiftStore.swift`
- US2, US3, US6 are fully independent ([P] across stories)

### Parallel Opportunities

```bash
# After Phase 1, these three run in parallel with the US1 chain:
Task: "T005 [P] [US2] Fix cross-wired constant in Examples/Examples/Constants.swift"
Task: "T006 [P] [US3] FNV-1a stable hash in Examples/Examples/SubViews/ProductImage.swift"
Task: "T009 [P] [US6] Doc rewrite in Sources/SwiftStore/SwiftStoreState.swift"
```

---

## Implementation Strategy

### MVP First (User Story 1 Only)

1. T001–T002 (baseline)
2. T003–T004 (entitlement correctness)
3. Validate with quickstart §E → the money-related defect is fixed

### Incremental Delivery

US1 (correctness) → US2/US3/US6 (independent quick wins) → US4 (robustness) → US5 (hygiene) → Polish gates.

## Notes

- [P] tasks = different files, no dependencies
- Unused example code (styles, previews, PurchaseExample, empty Examples/Package.swift) MUST be retained — Constitution I and the user's explicit requirement
- Unverified transactions stay unfinished by design (research.md R4)

### T012 results (2026-09-24, iPhone 18 Pro Max simulator, iOS 27.0)

- **§A compile + API gates**: PASS (T010/T011 above)
- **§C stable colors**: PASS — FNV-1a mapping identical across 2 separate processes (week→palette[17], month→palette[15], year→palette[6], lifetime→palette[16]); visual check on the Examples screen pending (idb not installed, no tap automation)
- **§D safe init (launch subset)**: PASS — app installed, launched and relaunched cleanly, renders "Free Version" (safe default, no crash); scratch-build read-before-init and double-init checks deferred to T013
- **§G docs accuracy**: PASS by inspection — no references to non-existent members remain in Sources/SwiftStore
- **§B, §E, §F**: deferred to T013 (require Xcode StoreKit Transaction Manager GUI / URL swap / purchase flows)
