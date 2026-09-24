# Feature Specification: Clean Up Examples App (Behavior-Preserving Refactor)

**Feature Branch**: `003-clean-examples`

**Created**: 2026-09-25

**Status**: Draft

**Input**: User description: "Refactor app Examples cho sạch, dễ đọc — TUYỆT ĐỐI KHÔNG XOÁ bất kỳ view/feature/function nào, chỉ tái cấu trúc: gộp animation/gradient lặp lại, tách khối view trùng nhau, sửa tên preview trùng, thêm MARK tổ chức, giữ nguyên mọi hành vi hiển thị."

## User Scenarios & Testing *(mandatory)*

### User Story 1 — Maintainers can navigate and extend the demo without fear (Priority: P1)

A developer returning to the example app can find each screen, component, and style quickly because files are organized with clear sections, and can modify one presentation behavior (for example, the fade-in animation) in one place instead of hunting through copies. Nothing they relied on disappears.

**Why this priority**: The demo's whole purpose is to teach integrating developers; unreadable code defeats it.

**Independent Test**: Can be fully tested by reading the refactored files and locating each original view/component by name, and by building the app.

**Acceptance Scenarios**:

1. **Given** the refactored project, **When** a maintainer searches for any view, style, or preview that existed before, **Then** it is found (renames are not used unless purely internal and locality-preserving).
2. **Given** a repeated presentation behavior, **When** a maintainer changes its definition in the single place it is defined, **Then** all screens using it update consistently.

---

### User Story 2 — The demo renders exactly as before (Priority: P1)

Every screen, card, animation, and preview looks and behaves the same as before the refactor: same layout, colors, animation curves and delays, and interactions.

**Why this priority**: A refactor that changes what the demo shows is a behavior change and would betray the no-deletion, no-alteration contract.

**Independent Test**: Can be fully tested by capturing screenshots of the main screens before and after and comparing layout and colors, plus code-level verification that animation curves and delay values are carried over unchanged.

**Acceptance Scenarios**:

1. **Given** screenshots of all main screens before the refactor, **When** the same screens are captured after, **Then** layouts and colors match.
2. **Given** the animation definitions before and after, **When** compared, **Then** every curve, duration, and delay value is unchanged.

---

### User Story 3 — Repeated presentation patterns are defined once (Priority: P2)

The fade-in-with-delay animation pattern, the repeated gradient card/stroke styling, and the near-identical failure/unavailable/unknown status blocks in the product view styles are each defined in exactly one place and reused wherever they appear today.

**Why this priority**: Duplication is the main readability tax in the demo; removing it (without deleting features) is the core ask.

**Independent Test**: Can be fully tested by counting the places a given pattern is defined (one) versus the places it is used (many), and by the app still compiling and rendering identically.

**Acceptance Scenarios**:

1. **Given** the fade-in animation pattern, **When** the codebase is searched, **Then** its implementation is defined once and reused by all call sites that previously hand-rolled it.
2. **Given** the status blocks in the product view styles, **When** compared, **Then** failure/unavailable/unknown presentations share one implementation per style file while rendering as before.

---

### User Story 4 — Previews are unambiguous (Priority: P3)

Every preview in the demo has a unique, descriptive name within its file, so the preview picker distinguishes them at a glance. Where a modifier was applied twice with the second silently overriding the first, only the effective (second) application remains, documented — the rendered result is unchanged.

**Why this priority**: Duplicate preview names confuse the canvas, but this is developer-experience polish with zero runtime impact.

**Independent Test**: Can be fully tested by listing preview display names per file and verifying uniqueness.

**Acceptance Scenarios**:

1. **Given** any demo file with multiple previews, **When** their display names are listed, **Then** no two previews in the same file share a name.
2. **Given** a previously shadowed duplicate modifier, **When** the screen renders, **Then** the visual output matches the pre-refactor output (which the second modifier determined).

---

### Edge Cases

- What happens to commented-out exploratory code? (Preserved — the no-deletion contract includes comments; it may be relocated into clearly labeled sections but not erased.)
- What happens if extracting a shared view would subtly change layout (for example, default spacing)? (The extraction must reproduce the original parameters exactly; if a pattern differs between call sites, parameters are passed in rather than unified.)
- What happens to file count? (No file is deleted; new files may be added for shared helpers.)
- What happens to behavior on previews only? (Previews never ship to users; still, they must compile and render.)

## Requirements *(mandatory)*

### Functional Requirements

- **FR-001**: No view, style, preview, component, function, or feature may be removed. All files present before the refactor must remain.
- **FR-002**: The rendered output of every screen and preview MUST be visually identical after the refactor (layout, colors, animation curves, durations, delays, interactions).
- **FR-003**: Presentation patterns repeated across call sites (fade-in animations, card gradients and strokes, status presentations) MUST be defined once and reused, with per-call-site differences passed as parameters.
- **FR-004**: Preview display names MUST be unique within each file and descriptive.
- **FR-005**: Files MUST be organized with clear section markers and a consistent order: entry points, then sections, then supporting components.
- **FR-006**: After the refactor, the app MUST build with zero errors and no new warnings, and the library build gates MUST remain green.
- **FR-007**: Commented-out code MUST be preserved (may be relocated under clear labels), honoring the no-deletion contract.

### Key Entities *(include if feature involves data)*

- **Reusable Presentation Pattern**: A shared visual behavior (for example, a fade-in-on-appear animation or a status card) defined once, parameterized for per-use differences.
- **Preview Identity**: A uniquely named, descriptively titled canvas preview.

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: Before/after screenshots of the main screens match in layout and colors (100% of screens compared).
- **SC-002**: 100% of pre-refactor views, styles, previews, and components are present after the refactor; zero files deleted.
- **SC-003**: Every hand-rolled repetition of the extracted patterns is replaced by the shared definition (0 remaining duplicates of each extracted pattern).
- **SC-004**: Zero preview name collisions across the project.
- **SC-005**: Build gates: example app and package build with zero errors and no new warnings.

## Assumptions

- This is a demo-app-only change: the SwiftStore library's behavior and public API are untouched.
- "Do not delete anything" is interpreted strictly: no views, styles, previews, components, or commented-out code may be removed; safe exceptions are shadowed duplicate modifiers whose second application made the first inert (rendered output provably unchanged) and duplicate preview display names (renamed, not removed).
- Visual comparison is done by human/screenshot comparison of the main screens; animation equality is additionally verified by carrying over numeric values unchanged.
- Animation timings, gradients, and colors are carried over verbatim — no visual "improvements" in this feature.
