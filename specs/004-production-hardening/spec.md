# Feature Specification: Production Hardening (Store Pipeline, Restore, Concurrency)

**Feature Branch**: `004-production-hardening`

**Created**: 2026-09-25

**Status**: Draft

**Input**: User description: "Production hardening cho SPM core — 6 blocker P0: single pipeline monitor, restore outcome surfacing, concurrency-friendly initialization, Ask to Buy visibility, billing grace period correctness, LICENSE (MIT). Tất cả additive."

## User Scenarios & Testing *(mandatory)*

### User Story 1 — Every transaction is processed exactly once per app run (Priority: P1)

An app that creates several store instances (the shared instance plus isolated instances for previews or tests) must not process the same platform transaction multiple times. Today each instance runs its own monitoring loops, so one delivered transaction triggers duplicated state updates, duplicated events, and duplicated completion calls. After this feature, the monitoring pipeline runs once per process; every instance still maintains its own entitlement state and still observes every processed outcome.

**Why this priority**: Duplicate processing is a correctness and trust defect in a payments library: doubled events corrupt consumer analytics, and repeated completion calls multiply the blast radius of any state bug.

**Independent Test**: Can be fully tested by creating multiple instances, delivering one simulated transaction outcome to the shared pipeline, and verifying each instance updates once and exactly one completion decision occurs per transaction.

**Acceptance Scenarios**:

1. **Given** three store instances in one process, **When** one verified transaction outcome is delivered, **Then** each instance's entitlement state updates exactly once and exactly one completion decision is recorded for that transaction.
2. **Given** one instance subscribes to events and another does not, **When** a transaction outcome is delivered, **Then** the subscriber receives exactly one event per transaction outcome.
3. **Given** a fresh instance created after startup, **When** it initializes, **Then** it does not restart the platform monitoring loops (they exist once per process) and it receives the pipeline outcomes from that point on.

---

### User Story 2 — Restore reports its real outcome (Priority: P1)

An integrating developer can distinguish between a restore that succeeded with purchases, a restore that finished with nothing to restore, and a restore that failed (for example, no network). Today all three look identical to the app.

**Why this priority**: Showing "premium restored" when the network call actually failed misleads paying users; this is a support-cost and trust defect.

**Independent Test**: Can be fully tested by simulating success, empty, and failure outcomes of the restore operation and verifying the reported outcome matches each scenario.

**Acceptance Scenarios**:

1. **Given** a successful restore with purchases, **When** the restore completes, **Then** the outcome reports success.
2. **Given** a restore with no prior purchases, **When** it completes, **Then** the outcome reports finished-with-nothing-to-restore (distinct from failure).
3. **Given** a restore that fails (for example, offline), **When** it completes, **Then** the outcome reports failure with error context, and no success event is emitted.
4. **Given** an existing consumer using the current restore call, **When** upgraded, **Then** the existing call keeps compiling and behaving as before.

---

### User Story 3 — Configuration can cross concurrency boundaries without friction (Priority: P1)

An integrating developer using strict concurrency checking can assemble a store configuration wherever it is convenient in their app and hand it to the store without concurrency diagnostics, and without any change to existing configuration code.

**Why this priority**: Under the current design, strict-concurrency projects hit compiler friction the moment they adopt the library; this blocks adoption in modern codebases.

**Independent Test**: Can be fully tested by compiling a scratch app in strict concurrency mode that builds configuration off the main actor and passes it to initialization — zero concurrency diagnostics.

**Acceptance Scenarios**:

1. **Given** strict concurrency checking enabled, **When** a consumer constructs a configuration in a non-main context and passes it to initialization, **Then** compilation produces no concurrency diagnostics.
2. **Given** existing consumer code using today's configuration type and builders, **When** compiled after this feature, **Then** it compiles unchanged with identical behavior.

---

### User Story 4 — Pending purchases (Ask to Buy) are visible (Priority: P2)

An integrating developer can find out that a purchase is awaiting approval (Ask to Buy) and can observe when that approval resolves, so the app can show appropriate status instead of silently ignoring the purchase.

**Why this priority**: Prevents a family-approved purchase from appearing lost; but the platform already surfaces the eventual resolution, so this is visibility polish rather than a correctness gap.

**Independent Test**: Can be fully tested by initiating an Ask to Buy purchase in a test environment and observing the app report a pending state, then observing the resolution when the purchase is approved.

**Acceptance Scenarios**:

1. **Given** a purchase awaiting approval, **When** the app checks pending state, **Then** it can report that a purchase is pending.
2. **Given** a pending purchase that gets approved, **When** the approval arrives, **Then** the normal entitlement pipeline processes it and the app observes the resulting outcome event.

---

### User Story 5 — Billing grace period keeps paying users unlocked (Priority: P1)

A subscriber whose renewal payment is temporarily failing but who is within the platform's billing grace period (or whose renewal is in billing retry) keeps their premium access; the library must not treat them as expired while the platform still considers their entitlement active. When the grace period truly lapses, access is removed.

**Why this priority**: Locking out paying users during a card update is a direct revenue and trust failure; the current expiry check does exactly that.

**Independent Test**: Can be fully tested by simulating an expired transaction that is within its grace period and verifying premium access is retained, then simulating full lapse and verifying removal.

**Acceptance Scenarios**:

1. **Given** a transaction past its expiration date but within the platform's grace period, **When** processed, **Then** premium access is retained.
2. **Given** a transaction in billing retry state, **When** processed, **Then** premium access is retained.
3. **Given** a transaction past expiration with no grace protection, **When** processed, **Then** the recorded subscription is cleared as today.
4. **Given** existing apps that rely on the current clearing behavior for plain expiration, **When** upgraded, **Then** that behavior is unchanged for non-grace cases.

---

### User Story 6 — Clear usage license (Priority: P2)

Anyone who finds the repository can determine, in seconds, under what license they may use the library.

**Why this priority**: Without a license file the code is legally unusable by consumers regardless of technical quality; the fix is trivial.

**Independent Test**: Can be fully tested by opening the license file and verifying it names the license and copyright holder.

**Acceptance Scenarios**:

1. **Given** the repository root, **When** a consumer looks for the license, **Then** a standard permissive license file (MIT) exists and is referenced by the README.

---

### Edge Cases

- What happens when an instance is created and deallocated mid-pipeline? (Pipeline continues for remaining instances; no dangling references.)
- What happens when restore succeeds but the platform reports zero restored transactions? (Reported as finished-with-nothing-to-restore, not success-with-purchases.)
- What happens when the grace period expiration date is missing on a retrying transaction? (Treat retry state alone as protection while present.)
- What happens when a pipeline outcome arrives before an instance initializes? (Late-initialized instances catch up through the normal entitlement sync.)
- What happens when two restores overlap? (Already guarded — one runs; the other no-ops. Outcome reporting applies to the one that ran.)
- What happens when configuration is mutated after initialization? (Same as today — repeat initialization refreshes the configuration; this feature does not change that contract.)

## Requirements *(mandatory)*

### Functional Requirements

- **FR-001**: Platform transaction monitoring MUST run exactly once per process, regardless of the number of store instances.
- **FR-002**: Every processed transaction outcome MUST be fanned out to every initialized store instance, each updating its own isolated state exactly once.
- **FR-003**: Completion of a processed transaction MUST happen exactly once per process.
- **FR-004**: Restore MUST report a distinguishable outcome: succeeded (with purchases), finished with nothing to restore, or failed with error context.
- **FR-005**: The existing restore call and its event MUST continue to work unchanged; new outcome detail MUST be additive.
- **FR-006**: A configuration MUST be constructible in any execution context and handed to the store without concurrency diagnostics for integrators using strict checking, without changing the existing configuration type's compiling usage.
- **FR-007**: An expired subscription that is within the platform's grace period or billing retry MUST NOT clear premium access.
- **FR-008**: When grace protection lapses and the entitlement is genuinely expired, the recorded subscription MUST be cleared as today.
- **FR-009**: The app MUST be able to detect that a purchase is awaiting approval and observe its resolution through the existing event pipeline.
- **FR-010**: A standard permissive license file MUST be added at the repository root and referenced from the README.
- **FR-011**: Zero existing public members may be removed or have their signatures changed (Constitution I); all changes additive or deprecation-annotated.
- **FR-012**: New behaviors MUST be covered by tests runnable from the command line without network or a live store (pipeline fan-out, grace decision logic, restore outcome mapping).

### Key Entities *(include if feature involves data)*

- **Pipeline Outcome**: The single, verified result of one platform transaction decision (grant, clear-by-revocation, clear-by-expiry, skip-grace-protected, skip-unverified, skip-unknown) computed once per process and fanned out to instances.
- **Restore Outcome**: Distinguishable restore result — succeeded with purchases, finished with nothing to restore, or failed with error context.
- **Grace Protection**: Platform-provided state (grace period window, billing retry) that shields an otherwise-expired subscription from removal.
- **Pending Purchase Indicator**: App-visible signal that a purchase is awaiting approval (Ask to Buy) and its eventual resolution.

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: With N store instances (N ≥ 3), one delivered transaction outcome produces exactly N state updates (one per instance) and exactly 1 completion decision.
- **SC-002**: Restore outcome reporting distinguishes success / nothing-to-restore / failure in 100% of simulated scenarios.
- **SC-003**: Strict-concurrency scratch project using the new initialization path compiles with zero concurrency diagnostics.
- **SC-004**: Grace-protected expired transactions retain premium access in 100% of simulated grace scenarios; non-grace expiration clears exactly as before.
- **SC-005**: Existing consumer code compiles unchanged (public-surface diff: additions and annotations only).
- **SC-006**: New decision logic (grace, fan-out, restore mapping) covered by command-line-runnable tests with zero network dependency.

## Assumptions

- Additive-only release: removals or signature changes remain out of scope (Constitution I).
- The pipeline coordinates delivery; each instance's entitlement state remains independent (an instance only reflects outcomes it receives after it initialized; earlier history arrives through its own entitlement sync).
- Grace protection follows the platform's own definition of the grace window and billing retry; the library adds no custom grace duration.
- "Pending" visibility is limited to what the platform exposes to non-UI code; purchase-time pending results surfaced by the platform's purchase views remain the integrator's responsibility to display.
- LICENSE will be MIT with the current project owner as copyright holder.
- Restore success reporting counts purchases restored by the platform operation; precise per-transaction attribution arrives through the normal pipeline.
