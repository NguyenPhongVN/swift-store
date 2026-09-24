---
description: "Task list for API Hardening (Additive Improvements)"
---

# Tasks: API Hardening (Additive Improvements)

**Input**: Design documents from `/specs/002-api-hardening/`

**Prerequisites**: plan.md, spec.md, research.md, data-model.md, contracts/public-api-additions.md, quickstart.md

**Tests**: REQUESTED (spec FR-016). Pure-logic tests via Swift Testing in the new SPM test target, written alongside their story. Store-runtime scenarios (real purchases) stay manual per quickstart §B/§F — FR-016 scopes tests to pure logic.

**Organization**: Tasks grouped by user story. File-sharing chains: US1 → US3 → US5 all edit `Sources/SwiftStore/SwiftStore.swift` (sequential); US4 → US6 both edit `Sources/SwiftStore/SSConfiguration.swift` (sequential). New-file tasks and test tasks are [P].

## Format: `[ID] [P?] [Story] Description`

- **[P]**: Can run in parallel (different files, no dependencies)
- **[Story]**: Which user story this task belongs to (e.g., US1, US2)
- Include exact file paths in descriptions

## Path Conventions

- Library: `Sources/SwiftStore/` (SPM product `SwiftStore`)
- Tests: `Tests/SwiftStoreTests/` (new SPM test target)
- Package manifest: `Package.swift` (repo root)

---

## Phase 1: Setup (Shared Infrastructure)

- [x] T001 Capture pre-change public API baseline: `grep -hn "public " Sources/SwiftStore/*.swift | sort > specs/002-api-hardening/public-api-baseline.txt` (done during planning; 26 lines)

---

## Phase 2: Foundational (Blocking Prerequisites)

**Purpose**: Manifest changes that US3/US7 and all test tasks depend on

- [x] T002 Add `.macOS(.v14)` to platforms and a `SwiftStoreTests` test target (dependency on `SwiftStore`) in Package.swift; verify `swift build` now succeeds on the host before any library edits

**Checkpoint**: Desktop build works; test target exists and runs (empty suite passes).

---

## Phase 3: User Story 1 — Integrators can observe store events and failures (Priority: P1) 🎯 MVP

**Goal**: Subscribable event feed for entitlement changes, purchases, verification failures, and restore completion (FR-001/002/003).

**Independent Test**: Event type asserts; handler emits in simulated pipelines; no-subscriber behavior unchanged (quickstart §B).

### Tests for User Story 1 (write first — compile failure counts as red)

- [x] T003 [P] [US1] Create Tests/SwiftStoreTests/StoreEventTests.swift: StoreEvent equality, pattern matching per case, and that a fresh store's `onEvent` is nil

### Implementation for User Story 1

- [x] T004 [P] [US1] Create Sources/SwiftStore/StoreEvent.swift: `public enum StoreEvent: Sendable, Equatable` with cases `entitlementChanged(productID: String, isActive: Bool)`, `purchaseFinished(productID: String)`, `transactionUnverified`, `restoreFinished`, each with doc comments
- [x] T005 [US1] Wire event emission in Sources/SwiftStore/SwiftStore.swift (depends on T004): add `public var onEvent: ((StoreEvent) -> Void)?` with doc comment; add private `emit(_:)` main-actor helper; pass an internal delivery-source context (updates / entitlements / unfinished) into `handle(updatedTransaction:)`; emit `transactionUnverified` for unverified deliveries, `entitlementChanged(productID:isActive:)` after each recognized-product state transition (set, revocation clear, expiry clear), `purchaseFinished(productID:)` when a verified live-update is a first purchase (transaction reason) — no emission for unknown products, no state or completion-rule changes; update `handle` doc comment

**Checkpoint**: Events compile and emit; store behavior with `onEvent == nil` is regression-identical.

---

## Phase 4: User Story 2 — Entitlement state protected from accidental writes (Priority: P1)

**Goal**: UI-writable entitlement pathway deprecated with guidance, still functional (FR-004).

**Independent Test**: Writing through the pathway compiles with a deprecation warning (quickstart §C).

### Implementation for User Story 2

- [x] T006 [P] [US2] In Sources/SwiftStore/SwiftStoreState.swift: annotate the `WritableKeyPath` subscript with `@available(*, deprecated, message: "Entitlement state is managed by the store and is read-only. Use wrappedValue / dynamic member lookup to read. Writable access will be removed in a future major version.")`; keep behavior identical; update the type's doc comment to present read-only usage as the supported path

**Checkpoint**: Misuse warns; reads unchanged; example app builds with zero new warnings.

---

## Phase 5: User Story 3 — Independent store instances for tests/previews (Priority: P2)

**Goal**: Public construction + factory + initialization introspection (FR-005/006).

**Independent Test**: Two factory instances fully isolated; `isInitialized` false→true (quickstart §D).

### Tests for User Story 3 (write first)

- [x] T007 [P] [US3] Create Tests/SwiftStoreTests/FactoryInstanceTests.swift: `make()` returns instances whose configs are independent of each other and of `shared`; `isInitialized` false before initialize / true after; safe defaults before init (empty product list, `isPremium == false`, links nil)

### Implementation for User Story 3

- [x] T008 [US3] In Sources/SwiftStore/SwiftStore.swift (depends on T005, same file): widen `private init()` to `public init()` with doc comment; add `public static func make() -> SwiftStore`; rename the private initialized flag and add `public var isInitialized: Bool { get }` with doc comment

**Checkpoint**: Instances constructible, isolated, introspectable.

---

## Phase 6: User Story 4 — Type-safe identifiers and validated legal links (Priority: P2)

**Goal**: `ProductID` value type + validated `URL?` accessors (FR-007/008).

**Independent Test**: Identifier-configured products classify identically to strings; malformed link yields nil (quickstart §E).

### Tests for User Story 4 (write first)

- [x] T009 [P] [US4] Create Tests/SwiftStoreTests/ProductIDAndLinksTests.swift: ProductID literal/init/equality/hash against rawValue; `hasEntitlement` true only for the active product (lifetime and subscription cases); validated link accessors return URL for valid strings and nil for nil/empty/malformed

### Implementation for User Story 4

- [x] T010 [P] [US4] Create Sources/SwiftStore/ProductID.swift: `public struct ProductID: Hashable, Sendable, ExpressibleByStringLiteral` with `public let rawValue: String`, `public init(_ rawValue: String)`, `public init(stringLiteral value: String)`, doc comments
- [x] T011 [US4] In Sources/SwiftStore/SSConfiguration.swift and Sources/SwiftStore/SwiftStore.swift (depends on T010 for the type; SwiftStore part after T008): add overloads `setSubscriptionIDs(_ ids: [ProductID]) -> Self` and `setLifetimeIDs(_ ids: [ProductID]) -> Self` on the configuration (mapping to rawValue, storing strings unchanged), and `public func hasEntitlement(_ id: ProductID) -> Bool` on the store (lifetime active AND id in lifetimeIDs, OR activeSubscription == id.rawValue)

**Checkpoint**: Identifier-typed configuration and entitlement queries work identically to strings.

---

## Phase 7: User Story 5 — Common account operations from code (Priority: P2)

**Goal**: Restore + subscription management helpers (FR-009/010).

**Independent Test**: Manual on simulator per quickstart §F (store-runtime operations are out of unit-test scope per FR-016).

### Implementation for User Story 5

- [x] T012 [US5] In Sources/SwiftStore/SwiftStore.swift (depends on T008, same file): add `public func restorePurchases() async` — in-flight guard (rapid repeat call is a no-op, no duplicate prompts), wraps the platform store-sync, emits `.restoreFinished` including the nothing-to-restore path; add `public func showManageSubscriptions(in scene: UIWindowScene)` under `#if os(iOS)` importing UIKit conditionally, and `public func showManageSubscriptions()` for other platforms; doc comments noting main-actor usage

**Checkpoint**: Both operations callable from app code; restore observable via events.

---

## Phase 8: User Story 6 — Clearer classification and naming (Priority: P3)

**Goal**: `ProductClassification.unrecognized`, `StoreConfiguration` alias, deprecate old classification value (FR-011/012).

**Independent Test**: Classify configured/unconfigured ids; old value compiles with warning (quickstart §G).

### Tests for User Story 6 (write first)

- [x] T013 [P] [US6] Create Tests/SwiftStoreTests/ClassificationTests.swift: subscription-first precedence, lifetime fallback, unrecognized for unknown ids; `classify(_:)` with String and with ProductID agree; `StoreConfiguration` alias resolves to the configuration type

### Implementation for User Story 6

- [x] T014 [US6] In Sources/SwiftStore/SSConfiguration.swift (depends on T011, same file): add `public enum ProductClassification: Sendable, Equatable { case lifetime, subscription, unrecognized }` with doc comments; add `public func classify(_ id: String) -> ProductClassification` and `public func classify(_ id: ProductID) -> ProductClassification` (same precedence as `getProductType`); add `public typealias StoreConfiguration = SSConfiguration`; annotate `ProductType.none` case with `@available(*, deprecated, message: "Use ProductClassification.unrecognized.")` keeping behavior; update file docs

**Checkpoint**: Explicit classification available; old case warns but works.

---

## Phase 9: User Story 7 & 8 — Desktop build/tests + change log (Priority: P3)

**Goal**: Command-line desktop build/test gate (US7, FR-013/016) and maintained CHANGELOG (US8, FR-014).

**Independent Test**: `swift build`/`swift test` on host; change log readable in one minute (quickstart §A/§H).

- [x] T015 [US7] Verify from repository root: `swift build` succeeds and `swift test` runs the full suite green in under 10 seconds with no network and no simulator; record results in Notes
- [x] T016 [P] [US8] Create CHANGELOG.md at repository root: Keep-a-Changelog format; `## [Unreleased] → Added` lists every addition from contracts/public-api-additions.md; `### Deprecated` lists the two annotations; explicit statement that no existing public member was removed or had its signature changed; note standing instruction to update per release

**Checkpoint**: Desktop gate green; upgrade safety documented.

---

## Phase 10: Polish & Cross-Cutting Concerns

- [x] T017 Public API gate: regenerate `grep -hn "public " Sources/SwiftStore/*.swift | sort` and diff against specs/002-api-hardening/public-api-baseline.txt — diff MUST contain only added declarations and deprecation annotation lines (zero removals / signature changes); confirm example app builds with zero new warnings
- [x] T018 Full compile gates: `swift build`, `swift test`, `xcodebuild -scheme SwiftStore -destination 'generic/platform=iOS Simulator' build`, `xcodebuild -project Examples/Examples.xcodeproj -scheme Examples -destination 'generic/platform=iOS Simulator' -configuration Debug build` — all green
- [x] T019 Run quickstart §B–§H automatable checks and record results in Notes

---

## Dependencies & Execution Order

### Phase Dependencies

- Setup T001 (done) → Foundational T002 → all stories
- US1 chain: T003/T004 (parallel) → T005
- US3: T007 (parallel) → T008 (after T005 — same file)
- US4: T009/T010 (parallel) → T011 (SwiftStore part after T008)
- US5: T012 (after T008 — same file)
- US6: T013 (parallel) → T014 (after T011 — same file)
- US7/US8: T016 parallel; T015 after all library code
- Polish: T017–T019 last

### Parallel Opportunities

```bash
# After T002, these run in parallel (different files):
Task: "T003 [P] [US1] StoreEventTests.swift"
Task: "T004 [P] [US1] StoreEvent.swift"
Task: "T006 [P] [US2] deprecate writable subscript (SwiftStoreState.swift)"
Task: "T009 [P] [US4] ProductIDAndLinksTests.swift"
Task: "T010 [P] [US4] ProductID.swift"
Task: "T013 [P] [US6] ClassificationTests.swift"
Task: "T016 [P] [US8] CHANGELOG.md"
```

---

## Implementation Strategy

### MVP First (User Story 1 Only)

T002 → T003–T005 → observability ships; store behavior unchanged.

### Incremental Delivery

US1 (events) → US2 (deprecation, one annotation) → US3/US4 (instances, types) → US5/US6 (operations, classification) → US7/US8 (desktop gate, changelog) → polish gates.

## Notes

- [P] tasks = different files, no dependencies
- Adding `case unknown` to `ProductType` is FORBIDDEN (breaks consumers' exhaustive switches — see research R6); new `ProductClassification` instead
- Writable subscript deprecation must keep runtime behavior identical (Constitution I)
- T015 results (2026-09-25): `swift build` — Build complete; `swift test` — 10/10 tests passed in 4 suites, ~0.01s (no network, no simulator)
- T019 results: §A gates all green (API diff: 20 additive declarations, zero removals/signature changes; package iOS + example app BUILD SUCCEEDED, zero code warnings); §B–§F store-runtime scenarios remain manual (quickstart); §G/§H verified by tests and CHANGELOG.md
- Implementation refinements: `showManageSubscriptions` is iOS-only — the no-argument macOS variant does not exist in the platform SDK (compile-time verified); ProductID setters named `setSubscriptionProductIDs` / `setLifetimeProductIDs` (distinct from String setters to avoid literal-call-site ambiguity); internal `getProductType` replaced by public `classify(_:)` so the library never references the deprecated `ProductType.none` internally (zero internal deprecation warnings)
