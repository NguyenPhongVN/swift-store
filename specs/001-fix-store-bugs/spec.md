# Feature Specification: Fix Store Bugs & Library Stability Rules

**Feature Branch**: `001-fix-store-bugs`

**Created**: 2026-09-24

**Status**: Draft

**Input**: User description: "Sửa toàn bộ bug đã tìm thấy trong review. Giữ nguyên các function không dùng đến vì các dự án khác cần sử dụng (đây là library). Thêm rules vào dự án."

## User Scenarios & Testing *(mandatory)*

### User Story 1 - Premium status always matches real entitlements (Priority: P1)

A paying user holds one or more entitlements (subscription and/or lifetime). The app must display premium status that exactly reflects the user's actual entitlements. When the store delivers a transaction that is expired or revoked, only the entitlement belonging to that specific product may be removed. A stale, expired, or unrelated transaction must never disable another entitlement that is still valid.

**Why this priority**: This is money-related correctness. A paying user losing access because of an unrelated expired transaction is a direct business and trust failure; it is the most severe defect found.

**Independent Test**: Can be fully tested by configuring two products, simulating one active and one expired transaction, and verifying the active one remains active. Delivers correct paywall/premium gating.

**Acceptance Scenarios**:

1. **Given** subscription A is active, **When** an expired transaction for subscription A is processed, **Then** A's active state is cleared and premium status becomes false (assuming no other entitlement).
2. **Given** subscription A is active, **When** an expired transaction for a different product B is processed, **Then** A remains active and premium status stays true.
3. **Given** lifetime purchase is active, **When** a subscription transaction is revoked, **Then** lifetime remains active and premium status stays true.
4. **Given** a valid transaction for product X, **When** it is processed after another product's transaction, **Then** X's state is recorded correctly regardless of delivery order.

---

### User Story 2 - Legal links open the correct document (Priority: P1)

The developer configures two distinct legal URLs (Terms of Service and Privacy Policy). Every place the app presents these links (paywall policies, settings) must open the document that matches the link's label.

**Why this priority**: Presenting the wrong legal document is a compliance/App Store review risk and the current defect is a clear wiring mistake.

**Independent Test**: Can be fully tested by setting two different URLs in configuration and tapping each link in the paywall; each must open its own document.

**Acceptance Scenarios**:

1. **Given** terms URL = U1 and privacy URL = U2 (U1 ≠ U2), **When** the user opens the Terms of Service link, **Then** U1 is opened.
2. **Given** terms URL = U1 and privacy URL = U2 (U1 ≠ U2), **When** the user opens the Privacy Policy link, **Then** U2 is opened.

---

### User Story 3 - Product appearance is stable across launches (Priority: P2)

The example app assigns a visual color to each product based on its identifier. The color for a given product must be identical on every app launch and on every device, so users and developers see consistent visuals.

**Why this priority**: Visual inconsistency between launches is confusing and breaks the app's stated deterministic design, but it does not affect purchases or access.

**Independent Test**: Can be fully tested by launching the app three times and comparing the color shown for each product; all launches must match.

**Acceptance Scenarios**:

1. **Given** a product with identifier P, **When** the app is launched three separate times, **Then** the color rendered for P is identical each time.
2. **Given** two different product identifiers, **When** rendered side by side, **Then** each keeps its own consistent color across launches.

---

### User Story 4 - Safe and repeatable initialization (Priority: P2)

The store is initialized once at app startup. Initialization must be safe to repeat (no duplicated background monitoring, no duplicated state updates) and the app must not crash when store information is read before initialization completes or before initialization is ever called.

**Why this priority**: Out-of-order or repeated initialization currently risks crashes and duplicated monitoring loops; robustness here protects every consuming project.

**Independent Test**: Can be fully tested by calling initialization twice and by reading store status before initialization; no crash occurs and only one set of monitoring work exists.

**Acceptance Scenarios**:

1. **Given** the store has already been initialized, **When** initialization is called a second time, **Then** the app behaves identically to a single initialization (no duplicated updates, state still correct).
2. **Given** the store has never been initialized, **When** the app reads premium status, legal links, or the product list, **Then** safe defaults are returned (premium = false, empty/nil values) and no crash occurs.
3. **Given** a valid configuration, **When** initialization runs, **Then** the premium state reflects actual entitlements after startup.

---

### User Story 5 - Every transaction reaches a terminal state (Priority: P3)

The store receives transaction notifications for configured products and occasionally for products it does not know about. Every delivered transaction that passes verification must be marked complete, including transactions for unrecognized products, so the store does not re-deliver the same transaction indefinitely on every launch.

**Why this priority**: Stuck transactions cause repeated redundant processing each launch; annoying but self-limiting and not user-visible.

**Independent Test**: Can be fully tested by simulating a verified transaction for an unknown product and confirming it is marked complete and not re-delivered on next launch.

**Acceptance Scenarios**:

1. **Given** a verified transaction for a product not in the configured lists, **When** it is processed, **Then** it is marked complete and will not reappear in later sessions.
2. **Given** a transaction that fails verification, **When** it is processed, **Then** it is ignored (not trusted, not completed) and premium state is unchanged.

---

### User Story 6 - Documentation matches the real interface (Priority: P3)

Developer-facing documentation for the library (doc comments, usage examples) must reference only members that actually exist and must describe behavior accurately, so integrating projects are not misled.

**Why this priority**: Wrong documentation wastes integrator time but does not change runtime behavior.

**Independent Test**: Can be fully tested by reviewing every documented member/example in the library and verifying each referenced member exists and behaves as documented.

**Acceptance Scenarios**:

1. **Given** any documentation example in the library, **When** its referenced members are checked against the public interface, **Then** every member exists.
2. **Given** documentation describing a behavior (e.g., bindings), **When** the actual behavior is compared, **Then** they match.

---

### Edge Cases

- What happens when a transaction arrives for a product that is not in the configured product lists? (Must be completed and must not alter premium state.)
- What happens when a transaction fails verification? (Must be ignored without altering state or completing the transaction.)
- What happens when the user has multiple products in the same subscription group with one expired and one current?
- What happens when initialization is invoked repeatedly (app object re-created, framework re-entry)?
- What happens when legal URL strings are empty or unset? (Links must be absent or safe, never crash.)
- What happens when a revoked transaction belongs to an unknown product? (Must still be completed so it is not re-delivered.)

## Requirements *(mandatory)*

### Functional Requirements

- **FR-001**: The system MUST clear an active-subscription record only when the processed transaction belongs to the currently recorded active subscription product.
- **FR-002**: Expiring or revoking one product MUST NOT change the entitlement state of any other product.
- **FR-003**: Lifetime entitlement state and subscription entitlement state MUST be tracked and updated independently.
- **FR-004**: The privacy-policy presentation MUST use the value configured specifically for privacy, and the terms presentation MUST use the value configured specifically for terms; the two settings MUST NOT be cross-wired.
- **FR-005**: Any visual attribute derived from a product identifier MUST be identical across app launches and devices for the same identifier.
- **FR-006**: Repeated initialization MUST be idempotent: it MUST NOT create duplicate monitoring work or duplicated state updates, and final state MUST equal single-initialization state.
- **FR-007**: Reading store information before initialization MUST return safe defaults (premium = false; legal links and product list empty/nil) instead of failing.
- **FR-008**: Every verified transaction MUST be marked complete, including transactions for unrecognized products, so none are re-delivered indefinitely.
- **FR-009**: Transactions that fail verification MUST be ignored: no state change and no completion.
- **FR-010**: The library's public interface MUST be fully preserved: no public member may be removed or have its signature changed, even if it is unused within this repository, because external projects depend on it.
- **FR-011**: Library documentation MUST reference only existing public members and MUST describe actual behavior.
- **FR-012**: The project MUST record these stability rules in its project constitution, and all future changes MUST comply with them.

### Key Entities *(include if feature involves data)*

- **Transaction**: A purchase record delivered by the platform store; has a product it belongs to, a verification outcome, a lifecycle status (active, expired, revoked), and a completion state.
- **Product**: An item the app sells; identified by a unique identifier and classified as subscription or lifetime.
- **Configuration**: Developer-provided settings: subscription product identifiers, lifetime product identifiers, terms URL, privacy URL.
- **Store State**: The app-visible entitlement status: whether lifetime is active, which subscription product is active, and derived premium status.

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: Premium status matches the user's real entitlements in 100% of test scenarios, including mixed valid/expired/revoked transaction deliveries.
- **SC-002**: Zero crashes in out-of-order usage tests (reading store before initialization; repeated initialization).
- **SC-003**: Product colors are identical across at least 3 consecutive launches for every product.
- **SC-004**: With terms and privacy set to different values, 100% of link taps open the matching document.
- **SC-005**: After fixing, no verified transaction is delivered more than once across sessions (0 stuck transactions).
- **SC-006**: Public interface diff against the pre-change version shows zero removals or signature changes.
- **SC-007**: Zero documentation references to non-existent members.

## Assumptions

- External projects consume this repository as a library and depend on its current public interface; therefore no breaking changes are allowed in this feature.
- Transactions that fail verification are ignored (platform-recommended secure default); completing them is out of scope.
- The example app's legal URLs are placeholders today; this feature fixes the wiring between settings and presentations, not the final URL content.
- Re-creating the app entry object may re-run startup code; initialization must tolerate this.
- Fixing the six reviewed defects is in scope; refactoring for style or removing dead code is explicitly out of scope (dead code must be retained per FR-010).
