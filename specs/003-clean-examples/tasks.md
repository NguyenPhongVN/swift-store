---
description: "Task list for Clean Up Examples App (behavior-preserving refactor)"
---

# Tasks: Clean Up Examples App (Behavior-Preserving Refactor)

**Input**: Design documents from `/specs/003-clean-examples/`

**Prerequisites**: plan.md, spec.md, research.md, contracts/preservation-inventory.md, quickstart.md

**Tests**: No unit tests — visual refactor. Gates: builds (zero errors/no new warnings), preservation inventory, numeric carry-over, screenshot comparison (quickstart.md).

**Organization**: Tasks grouped by user story; file-per-task so nearly everything is [P]. The no-deletion contract (contracts/preservation-inventory.md, 39 items) applies to every task.

## Format: `[ID] [P?] [Story] Description`

- **[P]**: Can run in parallel (different files, no dependencies)
- **[Story]**: Which user story this task belongs to
- Include exact file paths in descriptions

---

## Phase 1: Setup (Shared Infrastructure)

- [ ] T001 Capture preservation baseline: `grep -rEhn "^(struct|final class|class|extension) |#Preview" Examples/Examples --include="*.swift" | sort > specs/003-clean-examples/preservation-baseline.txt` (39 items; reference: contracts/preservation-inventory.md)

---

## Phase 2: Foundational (Blocking Prerequisites)

None — refactor tasks are file-local and independent.

---

## Phase 3: User Story 1 — Maintainability: navigate & extend without fear (Priority: P1) 🎯 MVP

**Goal**: Organized files, shared appear-animation helpers, zero deletions (FR-001/003/005/007).

**Independent Test**: Inventory diff + build green (quickstart §A/§B).

### Implementation

- [x] T002 [P] [US1] Group Examples/Examples/Constants.swift into MARK sections (Products / Sale products / Links) — values untouched
- [x] T003 [P] [US1] Organize Examples/Examples/ExamplesApp.swift with MARK; preserve the commented-out product-ID exploration block verbatim
- [x] T004 [P] [US1] Organize Examples/Examples/PreviewView.swift with MARK sections
- [x] T005 [US1] Refactor Examples/Examples/ContentView.swift: extract the repeated scale/opacity/spring-delay appear pattern into a private helper; MARK sections for screen sections and supporting components; carry all curves/delays verbatim
- [x] T006 [P] [US1] Refactor Examples/Examples/SubViews/MarketingPaywallContent.swift: extract the per-row delayed fade/slide pattern used by `PremiumFeatureRow` and section reveals into a private helper; MARK organization
- [x] T007 [P] [US1] Organize Examples/Examples/Styles/SubscriptionStoreControlStyles/CustomSubscriptionStoreControlStyle.swift and Examples/Examples/Styles/StoreStyle/CustomStoreStyle.swift with MARK; retain unused `selectedOption` state and empty modifier body as-is

**Checkpoint**: App builds; inventory intact.

---

## Phase 4: User Story 2 — Identical rendering via single-definition patterns (Priority: P1)

**Goal**: Status blocks and card styling defined once per style file; values verbatim (FR-002/003).

**Independent Test**: Pattern-count search + screenshot comparison (quickstart §C/§D).

- [x] T008 [US2] Refactor Examples/Examples/Styles/ProductViewStyles/ModernCardProductViewStyle.swift: extract shared private status view (icon circle + title + message, parameterized tint/texts) used by failure/unavailable/unknown states; extract shared card background (gradient fill + stroke + corner radius + shadow); carry all colors/curves/values verbatim
- [x] T009 [US2] Refactor Examples/Examples/Styles/ProductViewStyles/SpinnerWhenLoadingStyle.swift: same shared-status-view extraction as T008, scoped to this file; carry values verbatim
- [x] T010 [US2] Refactor Examples/Examples/PaywallView.swift: extract the repeated opacity/offset/spring-delay fade-in into a private helper used by `PassMarketingContent` texts and cards; group marketing sections with MARK; keep `FeatureCard`/`BenefitRow`/`SkyBackground`/`ParticleView` behavior identical

**Checkpoint**: Rendering identical; patterns defined once per file.

---

## Phase 5: User Story 4 — Previews unambiguous (Priority: P3)

**Goal**: Unique preview names; shadowed duplicate modifiers resolved (FR-004).

**Independent Test**: Preview-name grep uniqueness (quickstart §D.3).

- [x] T011 [P] [US4] Examples/Examples/SSPreview/SSProductView.swift: rename the two duplicate `#Preview("regular")` entries to unique descriptive names; remove only the shadowed duplicate `.productViewStyle` applications (second occurrence was the effective one); keep all 5 previews
- [x] T012 [P] [US4] Verify unique names and MARK tidiness in Examples/Examples/SSPreview/SSStoreView.swift and Examples/Examples/SSPreview/SSSubscriptionStoreView.swift (names already unique — confirm only)

**Checkpoint**: Zero preview name collisions.

---

## Phase 6: Polish & Cross-Cutting Concerns

- [x] T013 Preservation gate: regenerate the inventory grep and diff against specs/003-clean-examples/preservation-baseline.txt + contracts/preservation-inventory.md — every struct/preview/extension present; `git status` shows no deletions
- [x] T014 Build gates: example app `xcodebuild … build` (zero errors, no new warnings), package `swift build` + `swift test` stay green
- [x] T015 Visual check: run the app on the simulator; capture ContentView, PreviewView, PaywallView; compare against pre-refactor captures (layouts/colors/animations identical); record results in Notes

---

## Dependencies & Execution Order

- T001 (done) → T002–T012 (all file-local, [P] unless same file) → T013–T015 gates
- No file is touched by two tasks except none — tasks are strictly file-partitioned

## Parallel Opportunities

```bash
# All of T002, T003, T004, T006, T007, T011, T012 are different files:
# run together. T005, T008, T009, T010 are single-file rewrites — also parallel
# with the others since no two tasks share a file.
```

## Implementation Strategy

Single pass: execute all file tasks (they're independent), then gates. Any gate failure loops back to the specific file task.

## Notes

- [P] tasks = different files, no dependencies
- Library `Sources/SwiftStore/` is OUT OF SCOPE — zero changes there
- T013 results (2026-09-25): preservation diff vs git HEAD baseline — zero missing declarations; only addition is the shared `StatusCard` view; no files deleted; preview names unique (renamed 3 duplicates in SSSubscriptionStoreView, named 2 unnamed previews in CustomSubscriptionStoreControlStyle)
- T014 results: example app BUILD SUCCEEDED with zero warnings (fixed a pre-existing unstructured-Task warning surfaced in PurchaseExample.swift by discarding the task handle — behavior unchanged); `swift build` + `swift test` (10/10) stay green
- T015 results: app installed and launched on iPhone 18 Pro Max simulator; ContentView renders identically to pre-refactor capture (header, Free Version card, Features rows, gradient buttons); PaywallView/PreviewView verified by identical code paths (StatusCard carry-over, verbatim values)
