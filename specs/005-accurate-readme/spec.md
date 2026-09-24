# Feature Specification: Accurate README (Documentation Correction)

**Feature Branch**: `005-accurate-readme`

**Created**: 2026-09-25

**Status**: Draft

**Input**: User description: "Sửa lại README cho đúng — 100% khớp API hiện tại: claims sai (consumables, Xcode requirement, URL placeholder), API reference đầy đủ (event, make, ProductID, restore, links, classification, deprecations), Quick Start dùng closure init, ví dụ không còn force-unwrap, sections grace/multi-instance/observability/Ask to Buy, license. Docs-only."

## User Scenarios & Testing *(mandatory)*

### User Story 1 — An integrator can adopt the library from the README alone (Priority: P1)

A developer who has never seen this project reads the README, installs the package from the real repository URL, copies a Quick Start snippet, and has working entitlement gating. Every requirement statement, version, and code sample compiles and behaves as written.

**Why this priority**: The README is the front door; wrong instructions (placeholder URLs, stale requirements) block adoption at step one.

**Independent Test**: Can be fully tested by a fresh integrator following the README top-to-bottom in an empty app — every step works without corrections.

**Acceptance Scenarios**:

1. **Given** the Installation section, **When** the integrator adds the package by the documented URL, **Then** the real repository resolves and a version can be selected.
2. **Given** the Quick Start snippet, **When** copied into an app entry point, **Then** it compiles and initializes the store without modification.
3. **Given** the Requirements section, **When** checked against the actual toolchain needs, **Then** every listed version is the true minimum.

---

### User Story 2 — Every documented capability matches reality (Priority: P1)

The README's capability list and API reference cover exactly the library's real public surface: what it does (subscriptions and lifetime purchases, observability, restore, standalone instances, grace retention), what it does not do (consumables are not supported; no pre-approval purchase query), which members exist with correct names and signatures, and which members are deprecated with guidance.

**Why this priority**: Overstated or understated capabilities cause integration dead-ends; missing new capabilities hide the library's value.

**Independent Test**: Can be fully tested by cross-checking every member mentioned in the README against the public interface, and every public capability against the README.

**Acceptance Scenarios**:

1. **Given** the README's API reference, **When** each named member is checked against the library, **Then** every one exists with the documented behavior.
2. **Given** the library's notable public capabilities, **When** the README is reviewed, **Then** each is represented (events, standalone instances, type-safe identifiers, validated links, restore outcomes, classification, initialization state).
3. **Given** the scope statements, **When** read, **Then** unsupported features (consumables, pre-approval purchase queries) are not claimed.

---

### User Story 3 — Examples are safe to copy (Priority: P2)

Every code sample in the README compiles and follows the library's best practices: no force-unwraps where the library offers validated accessors, no deprecated members presented as current guidance, and deprecations noted where relevant for migrating readers.

**Why this priority**: Copy-paste defects propagate into consumer apps, but they are localized to sample code.

**Independent Test**: Can be fully tested by extracting each README snippet into a scratch app and compiling it.

**Acceptance Scenarios**:

1. **Given** any README snippet, **When** compiled in a scratch app, **Then** it builds with no errors.
2. **Given** snippets showing links, **When** reviewed, **Then** they use the validated link accessors rather than manual force-unwrapping.
3. **Given** a deprecated member that must still be shown (migration context), **When** presented, **Then** the text marks it deprecated and names the replacement.

---

### Edge Cases

- What happens when a capability is platform-specific (for example, subscription management presentation on iOS)? (The README states the platform restriction.)
- What happens when the README and in-code documentation disagree? (Both must be corrected together; this feature covers the README, in-code docs were corrected in earlier features.)
- What happens to the changelog? (Release history lives in CHANGELOG.md — the README links to it rather than duplicating it.)

## Requirements *(mandatory)*

### Functional Requirements

- **FR-001**: The installation section MUST reference the real repository URL and a real selectable version.
- **FR-002**: The requirements section MUST list the true minimum platform and toolchain versions.
- **FR-003**: The capability overview MUST accurately state supported product kinds (subscriptions, lifetime) and MUST NOT claim support for unsupported kinds (consumables).
- **FR-004**: The API reference MUST list the library's notable public members with correct names and documented behavior, including observability events, standalone instance creation, initialization state, type-safe identifiers, validated legal links, restore with outcomes, subscription management presentation, classification, and deprecated members marked as such with replacements.
- **FR-005**: The Quick Start MUST use a current recommended initialization path and compile unmodified.
- **FR-006**: All code samples MUST compile and MUST NOT use force-unwrapping where validated accessors exist.
- **FR-007**: The README MUST document behavior guarantees relevant to adopters: single per-process transaction pipeline, billing grace-period retention, per-instance isolation, and the Ask to Buy flow's visibility boundary.
- **FR-008**: The license section MUST name the license and reference the license file.
- **FR-009**: The README MUST link release history (changelog) instead of duplicating it.
- **FR-010**: Documentation-only change: no library or example app source code may be modified.

### Key Entities *(include if feature involves data)*

- **Documented Surface**: The set of public members and behaviors the README claims — must equal the real public interface.
- **Copy-Safe Sample**: A code snippet that compiles as written in a fresh app.

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: A fresh integrator completes installation and Quick Start without deviating from the README (0 required corrections).
- **SC-002**: 100% of members named in the README exist in the public interface; 100% of notable public capabilities are represented.
- **SC-003**: 100% of README snippets compile in a scratch app with zero errors.
- **SC-004**: Zero claims of unsupported capabilities remain.
- **SC-005**: Builds remain green after the change (documentation-only, but gates still run).

## Assumptions

- The repository's public GitHub URL is `https://github.com/NguyenPhongVN/swift-store` (matches the configured remote); latest tagged release is the reference version for installation instructions.
- README language stays English (developer-facing), consistent with the current document.
- The README rewrite is the scope; separate deep documentation (tutorials, DocC publishing) remains out of scope.
- The demo app's placeholder legal URLs are unrelated to the README and stay out of scope.
