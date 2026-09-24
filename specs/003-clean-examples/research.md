# Research: Clean Up Examples App

**Feature**: specs/003-clean-examples | **Date**: 2026-09-25
All decisions grounded in direct reads of the demo sources; no open unknowns.

## R1. What "no deletion" permits (FR-001/FR-007)

- **Decision**: Preserve every struct, preview, component, commented-out block, and behavior. Two narrow, provably inert exceptions, both agreed in the spec's assumptions: (a) a modifier applied twice where the second application silently overrode the first keeps only the effective application; (b) duplicate preview display names are renamed (the preview survives).
- **Rationale**: Both cases have zero rendered-output delta by definition, which is the contract's actual intent — protecting features and visuals, not inert text.
- **Alternatives considered**: keeping shadowed modifiers verbatim — preserves confusion the user asked to remove.

## R2. Extraction strategy for repeated patterns (FR-003)

- **Decision**: Extract per-file with private scope where a pattern is used only inside one file (fade-in animations in `PaywallView.swift` and `ContentView.swift`, status cards in each ProductViewStyle file); no cross-file helpers unless two files need the exact same parameters. Per-call-site differences (delay, colors, titles) become parameters — never unified silently.
- **Rationale**: Animation modifier chains like `.opacity(x ? 1 : 0) + .offset + .animation(.spring(...).delay(d), value: x)` recur 8+ times in `PaywallView.swift` alone; a private `ViewModifier` parameterized by delay removes the noise while keeping numbers verbatim. Cross-file extraction would couple demo files for no behavioral gain.
- **Alternatives considered**: one global DemoStyle file — rejected (wider blast radius, harder to verify identical rendering); leaving duplication — the user's explicit ask.

## R3. Verbatim value carry-over (FR-002)

- **Decision**: Every gradient color array, corner radius, shadow, animation curve, duration, and delay value is copied unchanged into the extracted definitions; a mechanical check compares the numbers present before and after.
- **Rationale**: The spec makes visual identity a hard gate; the cheapest reliable proof is value-level carry-over plus screenshot comparison, not re-derivation.

## R4. Preview naming (FR-004)

- **Decision**: Rename duplicate `#Preview("regular")` entries in `SSProductView.swift` to unique descriptive names; remove only the shadowed duplicate `.productViewStyle` applications whose second occurrence made the first inert.
- **Rationale**: Canvas grouping keys on display names; uniqueness restores picker clarity. Removing the inert application is behavior-neutral.

## R5. Verification approach

- **Decision**: Gates are (1) example app builds with zero errors/no new warnings, (2) library `swift test` stays green, (3) preservation inventory diff shows every struct/preview present, (4) numeric-value carry-over check on animations, (5) manual screenshot comparison of ContentView, PreviewView, and PaywallView before/after on the simulator.
- **Rationale**: Combines mechanical, automatically checkable proofs with a final human-observable check — appropriate for a visual refactor with no tests of its own.
- **Alternatives considered**: golden-image automated snapshot tests — heavyweight for a demo app; noted as possible future tooling, not in scope.
