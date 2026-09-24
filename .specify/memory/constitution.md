# SwiftStore Constitution

## Core Principles

### I. Public API Stability (NON-NEGOTIABLE)

SwiftStore is a reusable library consumed by other projects outside this repository. Public members (types, methods, properties, initializers marked `public`) MUST NOT be removed and MUST NOT have their signatures changed — **even when they appear unused inside this repository**. Example-app usage is never evidence that a library API is dead code. API removal requires: (1) marking the member deprecated with a replacement first, (2) a documented migration note, and (3) removal only in a major version. Internal-only code may be refactored freely.

### II. Entitlement Correctness

Premium/entitlement state MUST always reflect verified store transactions. State for one product MUST NEVER be cleared or overwritten because of a transaction belonging to a different product. Expired and revoked transactions affect only their own product. Lifetime and subscription states are independent.

### III. Deterministic Behavior

Anything user-visible derived from data (colors, labels, ordering of presented products) MUST be identical across app launches, devices, and processes. Per-process random seeds, unordered dictionaries, or platform hash values MUST NOT drive user-visible outcomes.

### IV. Safe Initialization & Failure Modes

The library MUST NOT crash when used out of order (e.g., reading state before initialization). Out-of-order reads return safe defaults. Initialization MUST be idempotent: repeated calls create no duplicated background work or duplicated state updates. Failures surface as safe defaults or explicit errors — never as implicit force-unwrap crashes.

### V. Transaction Hygiene

Every verified transaction delivered to the library MUST reach a terminal state (completed), including transactions for products the configuration does not recognize, so the platform does not re-deliver them every launch. Transactions that fail verification MUST be ignored (no state change, no completion) per the platform's secure default.

### VI. Documentation Accuracy

Documentation and doc comments MUST reference only members that exist and MUST describe actual behavior. Stale examples referencing removed or never-existing members are defects and are fixed like code bugs.

## Additional Constraints

- Target platform: iOS 17+; store features use the platform's modern StoreKit (version 2) APIs.
- UI-facing state is main-actor isolated; background transaction work must hop to the main actor before mutating observable state.
- The demo/example app exists to showcase the library and MUST NOT drive library API decisions (see Principle I).
- StoreKit test configuration files and product identifiers must stay in sync with `Constants` in the example app.

## Development Workflow

- **Automatic Spec Kit execution (standing order)**: Every development task the user assigns — new feature, bug fix, or behavioral change — MUST be implemented through the full Spec Kit flow: `/speckit-specify` → `/speckit-plan` → `/speckit-tasks` → `/speckit-implement`, with `/speckit-analyze` before implementation when the change touches entitlement logic. The agent runs all phases back-to-back **automatically, without pausing to ask between phases**: the user states the task once and receives the finished, verified result (code changed, builds green, gates run, tasks checked off). This applies whether or not the user names a speckit command explicitly. Non-development requests (questions, reviews, commits, quick lookups) do not trigger the flow. The user may explicitly opt out per task (e.g., "fix directly", "hotfix") — record the opt-out in the tasks notes.
- **Direct work on `main` — no feature branches (standing order)**: All development happens **directly on the `main` branch**. Creating git branches for tasks (feature branches, per-task branches) is NOT allowed. `Feature Branch:` fields in existing `specs/*/` documents are historical records only, not instructions for future work. This is a deliberate standing order from the user (2026-09-24) and overrides any branch-first default.
- Every change MUST leave the package and the example app building with zero errors before completion.
- Every change touching the library MUST verify Principle I: diff the public interface; zero unapproved removals or signature changes.
- Bug fixes MUST map to a requirement in the feature spec (FR-xxx) and a success criterion; a fix without a testable acceptance scenario is incomplete.

## Governance

- This constitution supersedes all other practices and ad-hoc decisions in this repository.
- Amendments require: a documented reason, an updated version entry below, and a check that no open spec/task conflicts with the amendment.
- Reviewers (human or agent) MUST verify constitution compliance before approving any change.
- Use the Spec Kit guidance files for runtime development guidance; when guidance conflicts with this constitution, this constitution wins.

**Version**: 1.2.0 | **Ratified**: 2026-09-24 | **Last Amended**: 2026-09-24

**Amendment log**:
- v1.2.0 (2026-09-24): Added standing order — all development happens directly on `main`; creating git feature/per-task branches is not allowed. Reason: user preference for a linear history on a single branch; checked that no open spec/task depends on a branch-based workflow (existing `Feature Branch:` fields are historical metadata only).
- v1.1.0 (2026-09-24): Added standing order — all user-assigned development tasks run the full Spec Kit flow automatically, end to end, without per-phase confirmation.
- v1.0.0 (2026-09-24): Initial ratification with six core principles.
