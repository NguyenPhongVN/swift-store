# Feature Specification: API Hardening (Additive Improvements)

**Feature Branch**: `002-api-hardening`

**Created**: 2026-09-25

**Status**: Draft

**Input**: User description: "Cải thiện thiết kế API của thư viện SwiftStore theo review: event surface, factory instance, test target, hỗ trợ thêm platform, ProductID, URL accessor, restore/manage helpers, deprecate writable subscript, typealias, ProductType.unknown, isInitialized, CHANGELOG. Toàn bộ additive — không xoá/đổi public member nào."

## User Scenarios & Testing *(mandatory)*

### User Story 1 — Integrators can observe store events and failures (Priority: P1)

A developer integrating the library into their app can subscribe to a feed of store events — entitlement changes, transactions that failed verification, purchase outcomes, restore outcomes — so silent failures become visible and can be logged or surfaced to users. Today these paths fail silently, making production issues undiagnosable.

**Why this priority**: Silent failure is the top operational pain for a payments library: without visibility, integrators cannot debug lost purchases or verification problems.

**Independent Test**: Can be fully tested by subscribing an observer, simulating store scenarios (valid delivery, verification failure, restore with no purchases), and verifying each produces the matching event.

**Acceptance Scenarios**:

1. **Given** an observer is registered, **When** a verified transaction changes entitlements, **Then** an entitlement-changed event is observed with the affected product and resulting state.
2. **Given** an observer is registered, **When** a transaction that fails verification is processed, **Then** a verification-failed event is observed and premium state is unchanged.
3. **Given** an observer is registered, **When** a restore completes with no purchases, **Then** a restore-finished event is observed.
4. **Given** no observer is registered, **When** any store scenario occurs, **Then** behavior is identical to today (no crashes, no changes to entitlement outcomes).

---

### User Story 2 — Entitlement state is protected from accidental writes (Priority: P1)

An app developer can no longer accidentally grant premium access from UI code: the pathway that currently allows assigning entitlement state directly warns integrators at author time while continuing to work, and documentation presents the read-only usage as the supported path.

**Why this priority**: A UI-writable entitlement is a revenue-integrity defect: one stray line of view code grants paid access without purchase.

**Independent Test**: Can be fully tested by writing to the deprecated pathway in a scratch app and observing a compiler-time deprecation warning, while the code still compiles and runs.

**Acceptance Scenarios**:

1. **Given** existing consumer code that assigns entitlement state through the property-wrapper pathway, **When** the consumer compiles after this feature ships, **Then** the code compiles successfully and emits a deprecation warning naming the supported read-only usage.
2. **Given** consumer code that only reads entitlement state, **When** compiled, **Then** no warnings are emitted.

---

### User Story 3 — Integrators can create independent store instances for tests and previews (Priority: P2)

An integrating developer can create standalone store instances (in addition to the shared singleton) to use in unit tests, SwiftUI previews, or multi-environment setups, and can check whether a store instance has been initialized.

**Why this priority**: Unlocks testability for every consuming project; today the singleton's private construction makes isolated testing impossible.

**Independent Test**: Can be fully tested by creating two standalone instances, configuring them differently, and verifying their states and behaviors are fully independent of each other and of the shared instance.

**Acceptance Scenarios**:

1. **Given** two standalone instances configured with different products, **When** each reports its product list, **Then** each shows only its own configuration.
2. **Given** a standalone instance, **When** it is queried before initialization, **Then** it reports not-initialized and returns safe defaults.
3. **Given** the shared singleton exists, **When** a standalone instance is used in the same process, **Then** neither affects the other's state.

---

### User Story 4 — Type-safe identifiers and validated legal links (Priority: P2)

An integrating developer can use a dedicated identifier type instead of raw strings, catching typos at compile time, and can read legal links as validated link values (absent when unset or invalid) without performing manual parsing in app code.

**Why this priority**: Magic strings are the most common integration bug class (silent no-ops on typo); validated links remove crash-prone manual parsing.

**Independent Test**: Can be fully tested by configuring products using the new identifier type and reading links through the validated accessors in a scratch app.

**Acceptance Scenarios**:

1. **Given** a configuration built with identifier-typed products, **When** entitlement logic runs, **Then** matching behaves identically to string configuration.
2. **Given** a legal link configured with a malformed value, **When** the validated accessor is read, **Then** it returns absent rather than crashing or returning a broken value.
3. **Given** existing string-based configuration code, **When** compiled, **Then** it continues to work unchanged.

---

### User Story 5 — Common account operations from code (Priority: P2)

An integrating developer can trigger a restore of previous purchases and can present the system's subscription management screen programmatically, without writing platform-specific plumbing themselves.

**Why this priority**: These are the two most common account operations in subscription apps; every integrator currently re-implements them.

**Independent Test**: Can be fully tested by invoking each operation in a scratch app on a signed-in device and observing the expected system behavior (restore completes and emits an event; management screen appears).

**Acceptance Scenarios**:

1. **Given** a signed-in user with past purchases, **When** restore is invoked, **Then** restoration runs and a restore-finished event is observed.
2. **Given** a user with active subscriptions, **When** the management operation is invoked, **Then** the platform's subscription management screen is presented.

---

### User Story 6 — Clearer classification and naming (Priority: P3)

An integrating developer gets an explicitly named classification for unrecognized products (distinct from any "empty/absent" connotation), a friendlier alias for the configuration type, and a clear deprecation notice on the old classification value — all without breaking existing code.

**Why this priority**: Naming clarity prevents misuse but old names keep working, so it is polish rather than urgency.

**Independent Test**: Can be fully tested by classifying a configured product, an unconfigured product, and by compiling old code unchanged with only warnings.

**Acceptance Scenarios**:

1. **Given** a product identifier not in the configuration, **When** classified, **Then** the result is the explicit "unrecognized" classification.
2. **Given** code using the previous classification value, **When** compiled, **Then** it compiles with a deprecation warning and behaves as before.
3. **Given** code using the configuration type under either its original or alias name, **When** compiled, **Then** both refer to the same type.

---

### User Story 7 — Desktop platform support for fast local builds and tests (Priority: P3)

An integrating developer (and this repository's own checks) can build and run the library's tests on a desktop machine without a mobile device or simulator, and the library becomes usable in desktop apps of consuming projects.

**Why this priority**: Developer-experience improvement; unlocks faster test loops but does not change mobile behavior.

**Independent Test**: Can be fully tested by building the package and running its tests from the command line on a desktop machine with no simulator involved.

**Acceptance Scenarios**:

1. **Given** a desktop development machine, **When** the package is built from the command line, **Then** the build succeeds.
2. **Given** the same machine, **When** the test suite runs from the command line, **Then** all tests execute and pass without any mobile device.

---

### User Story 8 — Upgrade safety is discoverable (Priority: P3)

An integrating developer can consult a maintained change log to determine, in under a minute, what changed in a release, whether it is safe to upgrade without code changes, and which members are deprecated.

**Why this priority**: Multiple external consumers exist; upgrade confidence is essential but not urgent until the next release ships.

**Independent Test**: Can be fully tested by reading the change log after this feature and verifying every addition/deprecation of this feature is listed with migration notes.

**Acceptance Scenarios**:

1. **Given** the change log, **When** a consumer reads the latest entry, **Then** all additions and deprecations from this feature are listed with guidance.
2. **Given** the change log, **When** a consumer checks, **Then** it is explicitly stated that no existing public member was removed or changed.

---

### Edge Cases

- What happens when multiple observers subscribe? (Supported; consumer may multiplex. Event delivery order follows occurrence order.)
- What happens when events originate from background transaction processing? (Delivery must be safe for UI consumption — surfaced on the UI actor.)
- What happens when a validated link string is empty, whitespace, or malformed? (Validated accessor returns absent.)
- What happens when restore is invoked twice quickly? (Second call is a no-op or queued — no duplicate system prompts.)
- What happens when a standalone instance is deallocated while observing? (No dangling callbacks; observation is instance-scoped.)
- What happens when the deprecated write pathway is used from multiple places? (Deprecation warning at each use; runtime behavior unchanged.)
- What happens when a desktop build encounters a UI-only API? (Library core must not require mobile-only frameworks; platform-conditional code stays out of the shared core.)

## Requirements *(mandatory)*

### Functional Requirements

- **FR-001**: The system MUST expose a subscription mechanism delivering store events, including at minimum: entitlement changed, transaction failed verification, purchase finished, and restore finished.
- **FR-002**: Event delivery MUST be safe for UI consumption (surfaced on the UI actor) and MUST preserve occurrence order per subscriber.
- **FR-003**: With no active subscriber, store behavior MUST be identical to previous behavior.
- **FR-004**: The property-wrapper pathway that permits assigning entitlement state MUST be marked deprecated with guidance toward read-only usage, while continuing to compile and function unchanged.
- **FR-005**: Integrators MUST be able to create independent store instances; the existing shared instance MUST remain the default and its behavior MUST NOT change.
- **FR-006**: Every store instance MUST expose whether it has been initialized.
- **FR-007**: Integrators MUST be able to use a dedicated identifier type for product identifiers as an alternative to raw strings; all existing string-based APIs MUST continue to work unchanged.
- **FR-008**: Legal links MUST be readable as validated link values (absent when unset or invalid) in addition to the existing string accessors.
- **FR-009**: Integrators MUST be able to invoke restore of previous purchases programmatically; completion MUST be observable through the event mechanism.
- **FR-010**: Integrators MUST be able to present the platform's subscription management screen programmatically.
- **FR-011**: A second name for the configuration type MUST be provided without altering the original type.
- **FR-012**: A product classification value meaning "unrecognized" MUST be added; the existing classification value MUST be deprecated but remain functional.
- **FR-013**: The package MUST declare desktop platform support (current-generation baseline matching framework availability) so command-line builds and tests run on a desktop machine; the library core MUST compile there.
- **FR-014**: A change log MUST be added and MUST record every addition and deprecation from this feature, stating explicitly that no existing public member was removed or changed.
- **FR-015**: All additions MUST preserve the existing public interface: zero removals, zero signature changes (Constitution I).
- **FR-016**: Automated tests MUST cover the library's pure logic (classification, configuration, identifier mapping, link validation) and MUST run without network access or a live store.

### Key Entities *(include if feature involves data)*

- **Store Event**: A discrete occurrence delivered to subscribers: entitlement changed (product, new state), verification failed (reason context), purchase finished (outcome), restore finished (outcome). Occurrence-ordered per subscriber.
- **Product Identifier**: A value type wrapping a product's unique identifier; constructible from literals for ergonomics; equality by underlying value.
- **Standalone Store Instance**: An independently configured and initialized store context; fully isolated from the shared instance and other instances.
- **Change Log Entry**: A dated record of additions, deprecations, and migration guidance for a release.

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: 100% of simulated store scenarios (valid delivery, verification failure, restore with none) produce the corresponding observable event.
- **SC-002**: Zero deviation in entitlement outcomes when no subscriber is registered (regression-identical behavior).
- **SC-003**: Existing consumer code compiles unchanged: public-surface diff shows zero removals and zero signature changes.
- **SC-004**: The deprecated write pathway produces a compile-time warning in 100% of its uses while compiling successfully.
- **SC-005**: Standalone instances are fully isolated: cross-instance interference tests show 0 state leaks.
- **SC-006**: The pure-logic test suite completes in under 10 seconds with no network and no live store, on desktop, from the command line.
- **SC-007**: A consumer can determine upgrade safety from the change log in under 1 minute (clear additions/deprecations/no-removals statement).

## Assumptions

- Additive-only release: every change is either a new member, a deprecation annotation, a platform declaration, or documentation. Removals/signature changes are explicitly out of scope (next major version).
- Event delivery uses a subscriber-slot mechanism; integrators needing fan-out multiplex on their side. Delivery is occurrence-ordered; delivery to the UI actor is acceptable even if it coalesces bursts.
- Desktop baseline is the current-generation minimum that supports all framework APIs used by the library core.
- Tests use the platform's standard test tooling with no third-party dependencies added.
- The single-active-subscription assumption of the current entitlement model remains in force; multi-group support stays out of scope and should be documented.
- Restore/management operations target the current platform's standard system surfaces.
